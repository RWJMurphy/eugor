require 'eugor/vector'

module Eugor
  class Rectangle
    attr_accessor :origin, :width, :depth
    def initialize(origin, width, depth)
      @origin = origin
      @width = width
      @depth = depth
    end

    def inspect
      "<#{self.class.name} #{@origin}, #{size}>"
    end

    def translate(v2)
      @origin += v2
    end

    def size
      Vector.v2(width, depth)
    end

    def northeast
      origin + size
    end

    def include?(v2)
      v2.x >= origin.x && v2.x < northeast.x && v2.y >= origin.y && v2.y < bottomright.y
    end
    alias_method :===, :include?
  end
end
