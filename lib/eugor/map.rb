require 'eugor/console'
require 'eugor/rectangle'
require 'eugor/cuboid'
require 'eugor/vector'

require 'libtcod/map'

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
    AIR = Terrain.new(' ', Console::Color::BLUE, false).freeze
    GROUND = Terrain.new('.', Console::Color::WHITE, true).freeze
    WALL = Terrain.new('#', Console::Color::WHITE, false).freeze
    SOLID_DIRT = Terrain.new('#', Console::Color::DARK_ORANGE, false).freeze
    TREE = Terrain.new('^', Console::Color::DARK_GREEN, false).freeze

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

    def fovmap(z)
      @fovmap ||= {}
      @fovmap[z] ||= begin
        layer = @terrains[z]
        fovmap = TCOD::Map.new(width, depth)
        depth.times do |y|
          width.times do |x|
            terrain = layer[y][x]
            fovmap.set_properties(x, y, terrain.crossable?, terrain.crossable?)
          end
        end
        fovmap
      end
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

  module Maps
    class << self
      def forest
        map = Map.new(1, 1)
        chunk = map[Vector.v2(0, 0)]

        underground = Cuboid.new(Vector.v3(0, 0, 0), 128, 128, 8)
        surface = Cuboid.new(Vector.v3(0, 0, 8), 128, 128, 1)
        air = Cuboid.new(Vector.v3(0, 0, 8), 128, 128, 7)

        chunk.height.times do |z|
          chunk.depth.times do |y|
            chunk.width.times do |x|
              o = Vector.v3(x, y, z)
              chunk[o] = case o
              when underground
                Terrain::SOLID_DIRT
              when surface
                if rand(100) < 20
                  Terrain::TREE
                else
                  Terrain::GROUND
                end
              when air
                Terrain::AIR
              end
            end
          end
        end

        map
      end
    end
  end
end
