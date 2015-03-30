require 'eugor/console'
require 'eugor/vector'

module Eugor
  class Terrain
    attr_accessor :char, :color

    def initialize(char, color, crossable)
      @char = char
      @color = color
      @crossable = !!crossable
      self
    end

    def crossable?
      @crossable
    end

    NULL = Terrain.new(' ', Console::Color::BLACK, false).freeze
    GROUND = Terrain.new('.', Console::Color::WHITE, true).freeze
    WALL = Terrain.new('#', Console::Color::WHITE, false).freeze
  end

  class Chunk
    SIZE = {
      width: 128,
      depth: 128,
      height: 16
    }
    attr_accessor :width, :depth, :height

    def initialize(
      width = SIZE[:width],
      depth = SIZE[:depth],
      height = SIZE[:height]
    )
      @width = width
      @depth = depth
      @height = height
      @terrains = (0...height).map { (0...depth).map { (0...width).map { Terrain::NULL } } }
      self
    end

    def [](v)
      @terrains[v.z][v.y][v.x]
    end

    def []=(v, terrain)
      @terrains[v.z][v.y][v.x] = terrain
    end
  end

  class Map
    attr_accessor :width, :depth

    def initialize(width, depth)
      @width = width
      @height = depth
      @chunks = (0...width).map { (0...depth).map { Chunk.new } }
      self
    end

    def [](v)
      @chunks[v.x][v.y]
    end

    def []=(v, chunk)
      @chunks[v.x][v.y] = chunk
    end
  end
end
