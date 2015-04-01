module Eugor
  module Vector
    class V2
      attr_accessor :x, :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      def inspect
        "<#{self.class.name} #{self.to_s}>"
      end

      def to_s
        "(#{x}, #{y})"
      end

      def +(other)
        fail TypeError unless other.is_a? V2
        V2.new(x + other.x, y + other.y)
      end

      def -(other)
        self + -other
      end

      def *(other)
        case other
        when Numeric
          V2.new(x * other, y * other)
        when V2
          V2.new(x * other.x, y * other.y)
        else
          fail TypeError
        end
      end

      def -@
        self * -1
      end

      def /(other)
        case other
        when Numeric
          V2.new(x / other, y / other)
        when V2
          V2.new(x / other.x, y / other.y)
        else
          fail TypeError
        end
      end

      def %(other)
        case other
        when Numeric
          V2.new(x % other, y % other)
        when V2
          V2.new(x % other.x, y % other.y)
        else
          fail TypeError
        end
      end

      def ==(other)
        return false unless other.is_a? V2
        other.x == x && other.y == y
      end
      alias_method :eql?, :==

      def hash
        [x, y].hash
      end

      def to_v3
        V3.new(x, y, 0)
      end
    end

    class V3
      attr_accessor :x, :y, :z
      def initialize(x, y, z)
        @x = x
        @y = y
        @z = z
        self
      end

      def inspect
        "<#{self.class.name} #{self.to_s}>"
      end

      def to_s
        "(#{x}, #{y}, #{z})"
      end

      def +(other)
        fail TypeError unless other.is_a? V3
        V3.new(x + other.x, y + other.y, z + other.z)
      end

      def -(other)
        self + -other
      end

      def *(other)
        case other
        when Numeric
          V3.new(x * other, y * other, z * other)
        when V3
          V3.new(x * other.x, y * other.y, z * other.z)
        else
          fail TypeError
        end
      end

      def %(other)
        case other
        when Numeric
          V3.new(x % other, y % other, z % other)
        when V3
          V3.new(x % other.x, y % other.y, z % other.z)
        else
          fail TypeError
        end
      end

      def -@
        self * -1
      end

      def /(other)
        case other
        when Numeric
          V3.new(x / other, y / other, z / other)
        when V3
          V3.new(x / other.x, y / other.y, z / other.z)
        else
          fail TypeError
        end
      end

      def ==(other)
        return false unless other.is_a? V3
        other.x == x && other.y == y && other.z == z
      end
      alias_method :eql?, :==

      def hash
        [x, y, z].hash
      end

      def to_v2
        V2.new(x, y)
      end
    end

    class << self
      def v2(x, y)
        V2.new(x, y)
      end

      def v3(x, y, z)
        V3.new(x, y, z)
      end
    end
  end
end
