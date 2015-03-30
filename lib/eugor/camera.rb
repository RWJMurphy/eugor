require 'eugor/vector'

module Eugor
  class Camera
    include Vector

    attr_accessor :origin, :width, :height
    def initialize(origin, width, height)
      @origin = origin
      @width = width
      @height = height
      self
    end

    def frame(map, actors = [])
      chunk = map[Vector.v2(0, 0)]
      frame_ = height.times.map do |y|
        width.times.map do |x|
          offset = Vector.v3(x, y, 0)
          terrain = chunk[origin + offset]
          [terrain.char, terrain.color]
        end
      end
      actors.each do |actor|
        offset = actor.location - origin
        if offset.z == 0 && offset.x >= 0 && offset.x < width && offset.y >= 0 && offset.y < height
          frame_[offset.y][offset.x] = [actor.char, actor.color]
        end
      end
      frame_
    end
  end
end
