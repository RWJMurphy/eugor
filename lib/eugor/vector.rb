module Eugor
  module Vector
    class V2
      attr_accessor :x, :y
      def initialize(x, y)
        @x = x
        @y = y
      end
    end

    def v2(x, y)
      V2.new(x, y)
    end
  end
end
