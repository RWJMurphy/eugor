require 'eugor/vector'

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

    def frame(map, actors = [])
      fov = @pov.fov(map)
      chunk = map[Vector.v2(0, 0)]
      frame_ = depth.times.map do |y|
        width.times.map do |x|
          coord = origin + Vector.v3(x, y, 0)
          if fov.in_fov?(coord.x, coord.y)
            terrain = chunk[coord]
          else
            terrain = Terrain::NULL
          end
          [terrain.char, terrain.color]
        end
      end
      actors.each do |actor|
        offset = actor.location - origin
        if offset.z == 0 && offset.x >= 0 && offset.x < width && offset.y >= 0 && offset.y < depth
          frame_[offset.y][offset.x] = [actor.char, actor.color]
        end
      end
      frame_
    end
  end
end
