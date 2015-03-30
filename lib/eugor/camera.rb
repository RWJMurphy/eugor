require 'eugor/vector'

module Eugor
  class Camera
    include Vector

    attr_accessor :origin, :width, :height, :z
    def initialize(origin, width, height)
      @origin = origin
      @width = width
      @height = height
      @z = 0
      self
    end

    def frame(map, actors = [])
      chunk = map[v2(0, 0)]
      frame_ = (0...height).map do |y|
        (0...width).map do |x|
          offset = v3(x, y, z)
          chunk[origin + offset].char
        end
      end
      actors.each do |actor|
        offset = actor.location - origin.to_v2
        if offset.x >= 0 && offset.x < width && offset.y >= 0 && offset.y < height
          frame_[offset.y][offset.x] = actor.char
        end
      end
      frame_
    end
  end
end
