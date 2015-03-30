require 'eugor/actor'
require 'eugor/camera'
require 'eugor/console'
require 'eugor/map'
require 'eugor/player'
require 'eugor/vector'

require 'libtcod'
require 'pry'

module Eugor
  class Game
    include Vector

    SCREEN_WIDTH = 80
    SCREEN_HEIGHT = 50

    def initialize
      @map = Map.new(1, 1) # 1x1 chunks = 128x128x16 terrains

      chunk = @map[v2(0, 0)]
      offset = v3(128, 128, 0) / 2 - v3(5, 5, 0)
      [
        "##########",
        "#........#",
        "#........#",
        "#........#",
        "#........#",
        "#........#",
        "#........#",
        "#........#",
        "#........#",
        "##########"
      ].each_with_index do |line, y|
        line.chars.each_with_index do |c, x|
          chunk[offset + v3(x, y, 0)] = case c
          when '#'
            Terrain::WALL
          when '.'
            Terrain::GROUND
          else
            Terrain::NULL
          end
        end
      end


      @console = Console.new(SCREEN_WIDTH, SCREEN_HEIGHT)
      @camera = Camera.new(
        v3((128 - SCREEN_WIDTH) / 2, (128 - SCREEN_HEIGHT) / 2, 0),
        SCREEN_WIDTH, SCREEN_HEIGHT
      )

      @player = Player.new('@', Console::Color::WHITE)
      @player.location = v2(128 / 2, 128 / 2)

      npc = Actor.new('@', Console::Color::YELLOW)
      npc.location = v2(128 / 2 + 5, 128 / 2)

      @actors = [@player, npc]
      @state = :STATE_PLAYER_TURN

      self
    end

    def handle_ui_event(event)
      game_event = case event.to_sym
      when :KEY_ESCAPE
        [:PLAYER_QUIT]
      when :KEY_UP
        [:PLAYER_MOVE, v2(0, -1)]
      when :KEY_DOWN
        [:PLAYER_MOVE, v2(0, 1)]
      when :KEY_LEFT
        [:PLAYER_MOVE, v2(-1, 0)]
      when :KEY_RIGHT
        [:PLAYER_MOVE, v2(1, 0)]
      else
        [:UNHANDLED_KEY, event]
      end
      game_event
    end

    def handle_game_event(event, arg = nil)
      next_state = nil
      case @state
      when :STATE_PLAYER_TURN
        case event
        when :PLAYER_MOVE
          @player.location += arg
          next_state = :STATE_WORLD_TURN
        when :PLAYER_QUIT
          next_state = :STATE_QUIT
        when :UNHANDLED_KEY
          STDERR.puts("Unhandled key: #{arg.c}")
          next_state = @state
        end
      when :STATE_WORLD_TURN
        case event
        when :WORLD_TURN_ENDED
          next_state = :STATE_PLAYER_TURN
        end
      end
      fail "#{@state} can't handle #{event}!" unless next_state
      @state = next_state
    end

    def run
      until quit?
        case @state
        when :STATE_PLAYER_TURN
          @console.paint(@camera, @map, @actors)
          @console.clear(@camera, @map, @actors)

          @console.events.each do |ui_event|
            game_event = handle_ui_event(ui_event)
            if game_event.is_a? Enumerable
              game_event, arg = game_event.first, game_event[1]
            end
            handle_game_event(game_event, arg)
            @console.paint(@camera, @map, @actors)
            @console.clear(@camera, @map, @actors)
          end
        when :STATE_WORLD_TURN
          @actors
            .reject { |actor| actor == @player }
            .each { |actor| actor.tick(@map) }
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
