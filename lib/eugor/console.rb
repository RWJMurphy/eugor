require 'libtcod'

require 'eugor/monkeys/libtcod'

module Eugor
  class Console
    include TCOD

    LIMIT_FPS = 20

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

    def clear(camera, map, actors)
      frame = camera.frame(map)
      actors.each do |actor|
        offset = actor.location - camera.origin
        if offset.x >= 0 && offset.x < width && offset.y >= 0 && offset.y < height
          tile = frame[offset.y][offset.x]
          putc(offset.x, offset.y, tile[0], tile[1])
        end
      end
    end

    def putc(x, y, c, color = Color::WHITE)
      console_set_default_foreground(@buffer, color)
      console_put_char(@buffer, x, y, c.ord, BKGND_NONE)
    end

    def paint(camera, map, actors)
      # draw
      camera.frame(map, actors).each_with_index do |row, y|
        row.each_with_index do |tile, x|
          putc(x, y, tile[0], tile[1])
        end
      end

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
      until key.to_sym == :KEY_NONE
        keys << key
        key = console_check_for_keypress KEY_PRESSED
      end
      return [console_wait_for_keypress(false)] if keys.empty?
      keys
    end

    def wait_for_keypress
      console_wait_for_keypress false
    end

    def closed?
      console_is_window_closed
    end
  end
end
