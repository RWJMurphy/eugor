require 'eugor/console'
require 'eugor/player'
require 'eugor/vector'

module Eugor
  class Game
    include Vector

    SCREEN_WIDTH = 80
    SCREEN_HEIGHT = 50

    def initialize
      @console = Console.new(SCREEN_WIDTH, SCREEN_HEIGHT)

      @player = Player.new()
      @player.location = v2(
        SCREEN_WIDTH / 2,
        SCREEN_HEIGHT / 2
      )
      @state = :STATE_MAIN
    end

    def handle_event(event)
      return :STATE_QUIT if event.key_escape?
      case
      when event.key_up?
        @player.y -= 1
      when event.key_down?
        @player.y += 1
      when event.key_left?
        @player.x -= 1
      when event.key_right?
        @player.x += 1
      end
      :STATE_MAIN
    end

    def run
      until quit?
        @console.paint(@player)
        @console.clear(@player)

        @console.events.each do |event|
          @state = handle_event event
          @console.clear(@player)
          @console.paint(@player)
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
