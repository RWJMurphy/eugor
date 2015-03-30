module Eugor
  module Vector
    class V2
      attr_accessor :x, :y

      def initialize(x, y)
        @x = x
        @y = y
      end

      def +(other)
        V2.new(x + other.x, y + other.y)
      end

      def -(other)
        self + -other
      end

      def *(other)
        V2.new(other * x, other * y)
      end

      def -@
        self * -1
      end

      def /(other)
        V2.new(x / other, y / other)
      end

      def ==(other)
        other.x == x && other.y == y
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

      def +(other)
        V3.new(x + other.x, y + other.y, z + other.z)
      end

      def -(other)
        self + -other
      end

      def *(other)
        fail TypeError unless other.is_a? Numeric
        V3.new(other * x, other * y, other * z)
      end

      def -@
        self * -1
      end

      def /(other)
        fail TypeError unless other.is_a? Numeric
        V3.new(x / other, y / other, z / other)
      end

      def ==(other)
        other.x == x && other.y == y && other.z == z
      end

      def to_v2
        V2.new(x, y)
      end
    end

    def v2(x, y)
      V2.new(x, y)
    end

    def v3(x, y, z)
      V3.new(x, y, z)
    end
  end
end
