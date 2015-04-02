module Eugor
  module Vector
    V2 = Struct.new(:x, :y) do
      def set!(x, y)
        self.x = x
        self.y = y
        self
      end

      def set_from!(other)
        case other
        when V2, V3
          self.x = other.x
          self.y = other.y
        else
          fail TypeError
        end
        self
      end

      def add(other)
        clone.add!(other)
      end
      alias_method :+, :add

      def add!(other)
        case other
        when Numeric
          self.x += other
          self.y += other
        when V2
          self.x += other.x
          self.y += other.y
        else
          fail TypeError
        end
        self
      end

      def sub!(other)
        case other
        when Numeric
          self.x -= other
          self.y -= other
        when V2
          self.x -= other.x
          self.y -= other.y
        else
          fail TypeError
        end
        self
      end

      def sub(other)
        clone.sub!(other)
      end
      alias_method :-, :sub

      def mul!(other)
        case other
        when Numeric
          self.x *= other
          self.y *= other
        when V2
          self.x *= other.x
          self.y *= other.y
        else
          fail TypeError
        end
        self
      end

      def mul(other)
        clone.mul!(other)
      end
      alias_method :*, :mul

      def -@
        mul(-1)
      end

      def div!(other)
        case other
        when Numeric
          self.x /= other
          self.y /= other
        when V2
          self.x /= other.x
          self.y /= other.y
        else
          fail TypeError
        end
        self
      end

      def div(other)
        clone.div!(other)
      end
      alias_method :/, :div

      def modulo!(other)
        case other
        when Numeric
          self.x %= other
          self.y %= other
        when V2
          self.x %= other.x
          self.y %= other.y
        else
          fail TypeError
        end
        self
      end

      def modulo(other)
        clone.modulo!(other)
      end
      alias_method :%, :modulo

      def to_v3
        V3.new(x, y, 0)
      end
    end

    V3 = Struct.new(:x, :y, :z) do
      def set!(x, y, z)
        self.x = x
        self.y = y
        self.z = z
        self
      end

      def set_from!(other)
        case other
        when V2
          self.x = other.x
          self.y = other.y
          self.z = 0
        when V3
          self.x = other.x
          self.y = other.y
          self.z = other.z
        else
          fail TypeError
        end
        self
      end

      def add!(other)
        case other
        when Numeric
          self.x += other
          self.y += other
          self.z += other
        when V3
          self.x += other.x
          self.y += other.y
          self.z += other.z
        else
          fail TypeError
        end
        self
      end

      def add(other)
        clone.add!(other)
      end
      alias_method :+, :add

      def sub!(other)
        case other
        when Numeric
          self.x -= other
          self.y -= other
          self.z -= other
        when V3
          self.x -= other.x
          self.y -= other.y
          self.z -= other.z
        else
          fail TypeError
        end
        self
      end

      def sub(other)
        clone.sub!(other)
      end
      alias_method :-, :sub

      def mul!(other)
        case other
        when Numeric
          self.x *= other
          self.y *= other
          self.z *= other
        when V3
          self.x *= other.x
          self.y *= other.y
          self.z *= other.z
        else
          fail TypeError
        end
        self
      end

      def mul(other)
        clone.mul!(other)
      end
      alias_method :*, :mul

      def -@
        mul(-1)
      end

      def div!(other)
        case other
        when Numeric
          self.x /= other
          self.y /= other
          self.z /= other
        when V3
          self.x /= other.x
          self.y /= other.y
          self.z /= other.z
        else
          fail TypeError
        end
        self
      end

      def div(other)
        clone.div!(other)
      end
      alias_method :/, :div

      def modulo!(other)
        case other
        when Numeric
          self.x %= other
          self.y %= other
          self.z %= other
        when V3
          self.x %= other.x
          self.y %= other.y
          self.z %= other.z
        else
          fail TypeError
        end
        self
      end

      def modulo(other)
        clone.modulo!(other)
      end
      alias_method :%, :modulo

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
