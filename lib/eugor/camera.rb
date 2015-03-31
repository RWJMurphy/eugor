require 'eugor/vector'
require 'eugor/player'

module Eugor
  class Camera
    include Vector

    attr_accessor :pov, :origin, :width, :depth
    def initialize(pov, origin, width, depth)
      @pov = pov
      @origin = origin
      @width = width
      @depth = depth
      self
    end

    def frame(map, actors = {})
      fov = @pov.fov(map)
      chunk = map.active_chunk

      frame_ = depth.times.map do |y|
        width.times.map do |x|
          char = nil
          color = nil
          0.downto(-origin.z).each do |z|
            coord = origin + Vector.v3(x, y, z)
            # next unless fov.in_fov?(coord.x, coord.y)

            actor = actors[coord]
            terrain = chunk[coord]
            if actor
              char = actor.char
              color = actor.color.clone
            else
              char = terrain.char
              color = terrain.color.clone
            end
            next if char == ' '
            color *= 0.5 unless terrain.lit
            color.scale_hsv(1.0, 1.0 + z * 0.5)
            break
          end
          [char, color]
        end
      end
      frame_
    end
  end
end
