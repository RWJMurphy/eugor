require 'eugor/vector'
require 'forwardable'

require 'libtcod' # ugh why does this have to leak up to here

module Eugor
  class Actor
    extend Forwardable
    attr_accessor :location, :char, :color
    def_delegators :@location, :x, :x=, :y, :y=, :z, :z=

    def initialize(char, color)
      @char = char
      @color = color

      @brain = {}
      self
    end

    def tick(tick, map)
      @fovmap = nil
      move(Vector.v3(rand(-1..1), rand(-1..1), 0))
    end

    def fov(map)
      @fovmap ||= begin
        chunk = map[Vector.v2(0, 0)]
        fovmap = chunk.fovmap(z).clone
        fovmap.compute_fov(x, y, 0, true, TCOD::FOV_SHADOW)
        fovmap
      end
    end

    def move(v3)
      @location += v3
    end

  end
end
