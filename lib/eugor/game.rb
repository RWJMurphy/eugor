require 'eugor/actor'
require 'eugor/camera'
require 'eugor/console'
require 'eugor/map'
require 'eugor/player'
require 'eugor/vector'

require 'libtcod'

module Eugor
  class Game
    include Vector

    SCREEN_WIDTH = 80
    SCREEN_HEIGHT = 50

    def initialize
      @map = Maps.forest

      @console = Console.new(SCREEN_WIDTH, SCREEN_HEIGHT)
      @player = Player.new('@', Console::Color::WHITE)
      @player.location = Vector.v3(128 / 2, 128 / 2, 32)

      @camera = Camera.new(
        @player,
        Vector.v3((128 - SCREEN_WIDTH) / 2, (128 - SCREEN_HEIGHT) / 2, 32),
        SCREEN_WIDTH, SCREEN_HEIGHT
      )

      npc = Actor.new('@', Console::Color::YELLOW)
      npc.location = Vector.v3(128 / 2 + 5, 128 / 2, 32)

      @actors = [@player, npc].map{ |actor| [actor.location, actor] }.to_h
      @state = :STATE_PLAYER_TURN

      @tick = 0

      self
    end

    def handle_ui_event(event)
      game_event = case event.to_sym
      when :KEY_ESCAPE
        [:PLAYER_QUIT]
      when :KEY_UP
        [:ACTOR_MOVE, Vector.v3(0, -1, 0)]
      when :KEY_DOWN
        [:ACTOR_MOVE, Vector.v3(0, 1, 0)]
      when :KEY_LEFT
        [:ACTOR_MOVE, Vector.v3(-1, 0, 0)]
      when :KEY_RIGHT
        [:ACTOR_MOVE, Vector.v3(1, 0, 0)]
      when :<
        [:CAMERA_MOVE, Vector.v3(0, 0, 1)]
      when :>
        [:CAMERA_MOVE, Vector.v3(0, 0, -1)]
      else
        [:UNHANDLED_KEY, event]
      end
      game_event
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
          if @map.active_chunk[target].walkable?
            @actors.delete(@player.location)
            @player.location += delta
            @actors[@player.location] = @player
            next_state = :STATE_WORLD_TURN
          else
            STDERR.puts "bump"
            next_state = @state
          end
        when :CAMERA_MOVE
          delta = args.first
          @camera.origin += delta
          next_state = @state
        when :PLAYER_QUIT
          next_state = :STATE_QUIT
        when :UNHANDLED_KEY
          key = args.first
          STDERR.puts("Unhandled key: #{key.c}")
          next_state = @state
        end
      when :STATE_WORLD_TURN
        case event_type
        when :ACTOR_NONE
          next_state = :STATE_WORLD_TURN
        when :ACTOR_MOVE
          actor, delta = args
          target = actor.location + delta
          destination = @map.active_chunk[target]
          if destination.walkable?
            @actors.delete(actor.location)
            actor.location += delta
            @actors[actor.location] = actor
          else
            STDERR.puts("#{actor} bumps into #{destination}")
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
      until quit?
        case @state
        when :STATE_PLAYER_TURN
          @console.paint(@camera, @map, @actors)
          @console.clear(@camera, @map, @actors)

          @console.wait_for_keypress.tap do |ui_event|
            game_event = handle_ui_event(ui_event)
            handle_game_event(game_event)
            @console.paint(@camera, @map, @actors)
            @console.clear(@camera, @map, @actors)
          end
        when :STATE_WORLD_TURN
          @actors.each_value.map { |actor| actor.tick(@tick, @map) }.each do |game_event|
            handle_game_event(game_event)
            @console.paint(@camera, @map, @actors)
            @console.clear(@camera, @map, @actors)
          end
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
