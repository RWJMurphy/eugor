require 'eugor/vector'

module Eugor
  class Cuboid
    attr_accessor :origin, :width, :depth, :height
    def initialize(origin, width, depth, height)
      @origin = origin
      @width = width
      @depth = depth
      @height = height
    end

    def translate(v3)
      @origin += v3
    end

    def topnortheast
      origin + Vector.v3(width, depth, height)
    end

    def include?(v3)
      v3.x >= origin.x && v3.x < topnortheast.x &&
        v3.y >= origin.y && v3.y < topnortheast.y &&
        v3.z >= origin.z && v3.z < topnortheast.z
    end
    alias_method :===, :include?
  end
end
