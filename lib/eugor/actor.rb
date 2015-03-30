require 'eugor/vector'
require 'forwardable'

module Eugor
  class Actor
    extend Forwardable
    attr_accessor :location, :char, :color
    def_delegators :@location, :x, :x=, :y, :y=

    def initialize(char, color)
      @char = char
      @color = color
      self
    end

    def tick(map)
      move(Vector::V2.new(rand(-1..1), rand(-1..1)))
    end

    def move(d)
      @location += d
    end

  end
end
