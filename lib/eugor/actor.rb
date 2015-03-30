require 'eugor/vector'
require 'forwardable'

module Eugor
  class Actor
    extend Forwardable
    attr_accessor :location, :char, :color
    def_delegators :@location, :x, :x=, :y, :y=, :x, :x=

    def initialize(char, color)
      @char = char
      @color = color
      self
    end

    def tick(map)
      move(Vector.v3(rand(-1..1), rand(-1..1), 0))
    end

    def move(v3)
      @location += v3
    end

  end
end
