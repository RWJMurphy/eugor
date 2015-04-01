require 'libtcod'

require 'eugor/vector'
require 'eugor/player'

module Eugor
  class Camera
    attr_accessor :pov, :origin, :width, :depth
    def initialize(pov, origin, width, depth)
      @pov = pov
      @origin = origin
      @width = width
      @depth = depth
      @frame = TCOD.console_new(width, depth)
      self
    end

    def frame(map, actors = {}, dirty = nil)
      fov = @pov.fov(map)

      if dirty.nil?
        dirty = depth.times.map { |y| width.times.map { |x| Vector.v2(x + origin.x, y + origin.y) } }.flatten(1)
      end

      coord = origin.clone
      dirty.each do |v2|
        coord.x = v2.x
        coord.y = v2.y
        char = nil
        color = nil
        0.downto(-4).each do |z|
          coord.z = origin.z + z
          # next unless fov.in_fov?(coord.x, coord.y)

          actor = actors[coord]
          terrain = map[coord]
          if actor
            char = actor.char
            color = actor.color.clone
          else
            char = terrain.char
            color = terrain.color.clone
          end
          next if char == ' '
          color *= 0.5 unless terrain.lit
          color.scale_hsv(1.0, 2**z)
          break
        end
        coord.sub!(origin)
        TCOD.console_set_default_foreground(@frame, color)
        TCOD.console_put_char(@frame, coord.x, coord.y, char.ord, TCOD::BKGND_NONE)
      end
      @frame
    end
  end
end
