require 'logging'

require 'eugor/actor'
require 'eugor/camera'
require 'eugor/console'
require 'eugor/map'
require 'eugor/player'
require 'eugor/vector'

module Eugor
  class Game
    include Vector

    SCREEN_WIDTH = 80
    SCREEN_HEIGHT = 50

    SURFACE_LEVEL = 4

    def initialize
      @logger = Logging.logger[self]

      @logger.debug "Creating a new forest map"
      @map = Maps.forest(SURFACE_LEVEL)

      @logger.debug "Initializing console"
      @console = Console.new(SCREEN_WIDTH, SCREEN_HEIGHT)

      @logger.debug "Initializing player"
      @actors = {}
      @player = Player.new('@', Console::Color::WHITE)
      @player.location = Vector.v3(Map::CHUNK_SIZE.x / 2, Map::CHUNK_SIZE.y / 2, SURFACE_LEVEL)
      @actors[@player.location] = @player

      @logger.debug "Initializing camera"
      @camera = Camera.new(
        @player,
        @player.location - Vector.v3(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0),
        SCREEN_WIDTH, SCREEN_HEIGHT
      )

      @logger.debug "Spawning horrible trapezoids"
      rand(10..30).times do
        npc = Actor.new(Console::CHAR_DIAMOND, Console::Color::LIGHT_BLUE)
        location = Vector.v3(rand(Map::CHUNK_SIZE.x), rand(Map::CHUNK_SIZE.y), SURFACE_LEVEL)
        npc.location = location
        @actors[location] = npc
      end

      @actors = @actors.to_h
      @state = :STATE_PLAYER_TURN

      @tick = 0

      self
    end

    def handle_ui_event(event)
      case event.to_sym
      when :KEY_ESCAPE
        [:PLAYER_QUIT]
      when :KEY_UP, :k
        [:ACTOR_MOVE, Vector.v3(0, -1, 0)]
      when :u
        [:ACTOR_MOVE, Vector.v3(1, -1, 0)]
      when :KEY_RIGHT, :l
        [:ACTOR_MOVE, Vector.v3(1, 0, 0)]
      when :n
        [:ACTOR_MOVE, Vector.v3(1, 1, 0)]
      when :KEY_DOWN, :j
        [:ACTOR_MOVE, Vector.v3(0, 1, 0)]
      when :b
        [:ACTOR_MOVE, Vector.v3(-1, 1, 0)]
      when :KEY_LEFT, :h
        [:ACTOR_MOVE, Vector.v3(-1, 0, 0)]
      when :y
        [:ACTOR_MOVE, Vector.v3(-1, -1, 0)]
      when :<
        [:CAMERA_MOVE, Vector.v3(0, 0, 1)]
      when :>
        [:CAMERA_MOVE, Vector.v3(0, 0, -1)]
      else
        [:UNHANDLED_KEY, event]
      end
    end

    def handle_game_event(game_event)
      next_state = nil
      event_type, *args = game_event
      case @state
      when :STATE_PLAYER_TURN
        case event_type
        when :ACTOR_MOVE
          delta = args.first
          target = @player.location + delta
          if @actors[target]
            @logger.debug "Player walked into #{@actors[target]}, ignoring move"
            next_state = @state
          elsif !@map[target].walkable?
            @logger.debug "Player walked into #{@map[target]}, ignoring move"
            next_state = @state
          else
            @actors.delete(@player.location)
            @console.dirty(@player.location)
            @player.location += delta
            @console.dirty(@player.location)
            @actors[@player.location] = @player
            next_state = :STATE_WORLD_TURN
          end
        when :CAMERA_MOVE
          new_origin = args.first + @camera.origin
          if new_origin.z >= 0 && new_origin.z < @map.height * Map::CHUNK_SIZE.z
            @camera.origin.set_from!(new_origin)
            @console.all_dirty
          else
            @logger.warn "Tried to move camera out of bounds: #{new_origin}"
          end
          next_state = @state
        when :PLAYER_QUIT
          next_state = :STATE_QUIT
        when :UNHANDLED_KEY
          key = args.first
          @logger.warn "Unhandled key: #{key.c}"
          next_state = @state
        end
      when :STATE_WORLD_TURN
        case event_type
        when :ACTOR_NONE
          next_state = :STATE_WORLD_TURN
        when :ACTOR_MOVE
          actor = args.shift
          delta = args.shift
          target = actor.location + delta
          if @actors[target]
            @logger.debug "#{actor} walked into #{@actors[target]}, ignoring move"
          elsif !@map[target].walkable?
            @logger.debug "#{actor} walked into #{@map[target]}, ignoring move"
          else
            @actors.delete(actor.location)
            @console.dirty(actor.location)
            actor.location += delta
            @console.dirty(actor.location)
            @actors[actor.location] = actor
          end
          next_state = :STATE_WORLD_TURN
        when :WORLD_TURN_ENDED
          @tick += 1
          next_state = :STATE_PLAYER_TURN
        end
      end
      fail "#{@state} can't handle #{event_type}!" unless next_state
      @state = next_state
    end

    def run
      @console.all_dirty
      @console.paint(@camera, @map, @actors)

      until quit?
        case @state
        when :STATE_PLAYER_TURN
          ui_event = @console.wait_for_keypress
          game_event = handle_ui_event(ui_event)
          handle_game_event(game_event)
          @console.paint(@camera, @map, @actors)
        when :STATE_WORLD_TURN
          @actors.each_value.map { |actor| actor.tick(@tick, @map) }.each do |game_event|
            handle_game_event(game_event)
          end
          @console.paint(@camera, @map, @actors)
          handle_game_event(:WORLD_TURN_ENDED)
        end
      end
    end

    def quit?
      [
        @console.closed?,
        @state == :STATE_QUIT
      ].any?
    end
  end
end
