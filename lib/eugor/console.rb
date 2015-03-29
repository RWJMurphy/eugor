require 'libtcod'

require 'eugor/monkeys/libtcod'

module Eugor
  class Console
    include TCOD

    LIMIT_FPS = 60

    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
      console_init_root(width, height,
                        'ruby/TCOD tutorial',
                        false,
                        RENDERER_SDL
      )
      @buffer = console_new(width, height)

      sys_set_fps(LIMIT_FPS)
    end

    def clear(player)
      # clear
      console_put_char(@buffer, player.x, player.y, ' '.ord, BKGND_NONE)
    end

    def paint(player)
      # draw
      console_set_default_foreground(@buffer, Color::WHITE)
      console_put_char(@buffer, player.x, player.y, '@'.ord, BKGND_NONE)

      # flush
      console_blit(
        @buffer, 0, 0, width, height,
        nil, 0, 0,
        1.0, 1.0
      )
      console_flush
    end

    def events
      key = console_check_for_keypress KEY_PRESSED
      keys = []
      while key.vk != KEY_NONE
        keys << key
        key = console_check_for_keypress KEY_PRESSED
      end
      return [console_wait_for_keypress(true)] if keys.empty?
      keys
    end

    def wait_for_keypress
      console_wait_for_keypress true
    end

    def closed?
      console_is_window_closed
    end
  end
end
