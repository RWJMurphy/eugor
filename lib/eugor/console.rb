require 'libtcod'

require 'eugor/rectangle'
require 'eugor/vector'
require 'eugor/monkeys/libtcod'

module Eugor
  class Console
    include TCOD

    LIMIT_FPS = 20

    attr_reader :width, :height

    def initialize(width, height)
      @logger = Logging.logger[self]

      @width = width
      @height = height
      console_init_root(width, height,
                        'Eugor',
                        false,
                        RENDERER_SDL
      )
      @dirty = []
      @all_dirty = false

      sys_set_fps(LIMIT_FPS)
    end

    def to_rect
      @to_rect ||= Eugor::Rectangle(Eugor::Vector.v2(0, 0), width, height)
    end

    def putc(x, y, c, color = Color::WHITE)
      console_set_default_foreground(@buffer, color)
      console_put_char(@buffer, x, y, c.ord, BKGND_NONE)
    end

    def dirty(v3)
      @dirty << v3
    end

    def all_dirty
      @all_dirty = true
    end

    def paint(camera, map, actors)
      # draw
      frame = nil
      if @all_dirty
        frame = camera.north(map, actors, nil)
      elsif !@dirty.empty?
        frame = camera.north(map, actors, @dirty)
      end
      console_blit(
        frame, 0, 0, camera.width, camera.depth,
        nil, 0, 0,
        1.0, 1.0
      ) unless frame.nil?
      # flush
      # console_blit(
      #   @buffer, 0, 0, width, height,
      #   nil, 0, 0,
      #   1.0, 1.0
      # )
      console_flush
      @all_dirty = false
      @dirty = []
    end

    def wait_for_keypress
      console_wait_for_keypress true
    end

    def closed?
      console_is_window_closed
    end
  end
end
