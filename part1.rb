# !/usr/bin/env ruby
require 'libtcod'

module Eugor
  class Game
    include TCOD

    SCREEN_WIDTH = 80
    SCREEN_HEIGHT = 50
    LIMIT_FPS = 20  # 20 frames-per-second maximum

    def initialize
      # console_set_custom_font('terminal.png', FONT_TYPE_GREYSCALE | FONT_LAYOUT_TCOD, 0, 0)
      console_init_root(SCREEN_WIDTH, SCREEN_HEIGHT,
                        'ruby/TCOD tutorial',
                        false,
                        RENDERER_SDL
      )
      sys_set_fps(LIMIT_FPS)

      @playerx = SCREEN_WIDTH / 2
      @playery = SCREEN_HEIGHT / 2
    end

    def handle_keys
      key = console_wait_for_keypress(true)  # turn-based

      if key.vk == KEY_ENTER && key.lalt
        # Alt+Enter: toggle fullscreen
        console_set_fullscreen(!console_is_fullscreen())
      elsif key.vk == KEY_ESCAPE
        return true  # exit game
      end

      # movement keys
      if console_is_key_pressed(KEY_UP)
        @playery -= 1
      elsif console_is_key_pressed(KEY_DOWN)
        @playery += 1
      elsif console_is_key_pressed(KEY_LEFT)
        @playerx -= 1
      elsif console_is_key_pressed(KEY_RIGHT)
        @playerx += 1
      end

      false
    end

    def mainloop
      until quit?
        # draw
        console_set_default_foreground(nil, Color::WHITE)
        console_put_char(nil, @playerx, @playery, '@'.ord, BKGND_NONE)

        # flush
        console_flush()

        # clear
        console_put_char(nil, @playerx, @playery, ' '.ord, BKGND_NONE)

        @state = handle_keys
      end
    end

    def quit?
      console_is_window_closed ||
        @state == STATE_QUIT
  end
end

if $PROGRAM_NAME == __FILE__
  game = Eugor::Game.new()
  game.mainloop()
end
