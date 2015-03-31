require 'eugor/console'
require 'eugor/rectangle'
require 'eugor/cuboid'
require 'eugor/vector'

require 'libtcod/map'

module Eugor
  class Terrain
    include Enumerable

    attr_accessor :char, :color, :lit

    def initialize(char, color, transparent = false, walkable = false)
      @char = char
      @color = color
      @walkable = !!walkable
      @transparent = !!transparent
      @lit = false
      self
    end

    def inspect
      "<#{self.class.name} #{char}, #{color}, #{walkable? ? 'walkable' : 'not walkable'}, #{transparent? ? 'transparent' : 'not transparent'}>"
    end

    def to_s
      char
    end

    def walkable?
      @walkable
    end

    def transparent?
      @transparent
    end

    NULL =       Terrain.new(' ', Console::Color::BLACK,       true,  false)
    AIR =        Terrain.new(' ', Console::Color::BLUE,        true,  false)
    GROUND =     Terrain.new('.', Console::Color::WHITE,       true,  true)
    WALL =       Terrain.new('#', Console::Color::WHITE,       false, false)
    SOLID_DIRT = Terrain.new('#', Console::Color::DARK_ORANGE, false, false)
    TREE =       Terrain.new('^', Console::Color::GREY,        false, false)
  end

  class Chunk
    attr_accessor :width, :depth, :height
    def initialize(width, depth, height)
      @width = width
      @depth = depth
      @height = height
      @terrains = (0...height).map { (0...depth).map { (0...width).map { Terrain::NULL } } }
      self
    end

    def inspect
      "<#{self.class.name} #{size}}>"
    end

    def size
      Vector.v3(width, depth, height)
    end

    def fovmap(z)
      @fovmap ||= {}
      @fovmap[z] ||= begin
        layer = @terrains[z]
        fovmap = TCOD::Map.new(width, depth)
        depth.times do |y|
          width.times do |x|
            terrain = layer[y][x]
            fovmap.set_properties(x, y, terrain.transparent?, terrain.walkable?)
          end
        end
        fovmap
      end
    end

    def calculate_lighting
      depth.times do |y|
        width.times do |x|
          (height-1).downto(0).each do |z|
            o = Vector.v3(x, y, z)
            t = self[o]
            t.lit = true
            unless t.transparent?
              break
            end
          end
        end
      end
    end

    def each(&block)
      each_key do |o|
        yield [o, self[o]]
      end
    end
    alias_method :each_with_key, :each

    def each_key(&block)
      height.times do |z|
        depth.times do |y|
          width.times do |x|
            yield Vector.v3(x, y, z)
          end
        end
      end
    end

    def [](v)
      @terrains[v.z][v.y][v.x]
    end

    def []=(v, terrain)
      fail IndexError unless v.z >= 0 && v.z < height &&
                             v.y >= 0 && v.y < depth &&
                             v.x >= 0 && v.x < width
      @terrains[v.z][v.y][v.x] = terrain
    end
  end

  class Map
    CHUNK_SIZE = {
      width: 128,
      depth: 128,
      height: 64
    }

    attr_accessor :width, :depth

    def initialize(width, depth)
      @width = width
      @height = depth
      @chunks = width.times.map do
        depth.times.map do
          Chunk.new(CHUNK_SIZE[:width], CHUNK_SIZE[:depth], CHUNK_SIZE[:height])
        end
      end
      self
    end

    def inspect
      "<#{self.class.name} (#{chunks.first.size},#{chunks.size})>"
    end

    def [](v)
      @chunks[v.x][v.y]
    end

    def []=(v, chunk)
      @chunks[v.x][v.y] = chunk
    end
  end

  class TerrainFeature < Chunk
    def blit(otherChunk, offset)
      each do |o, t|
        begin
          otherChunk[o + offset] = t.clone unless t.nil?
        rescue IndexError
          next
        end
      end
    end
  end

  module Maps
    class << self
      def forest
        map = Map.new(1, 1)
        chunk = map[Vector.v2(0, 0)]

        blocks = [
          [Cuboid.new(Vector.v3(0, 0, 0), 128, 128, 32), Terrain::SOLID_DIRT],
          [Cuboid.new(Vector.v3(0, 0, 32), 128, 128, 1), Terrain::GROUND],
          [Cuboid.new(Vector.v3(0, 0, 33), 128, 128, 31), Terrain::AIR]
        ]

        blocks.each do |block, terrain|
          block.each do |v3|
            chunk[v3] = terrain.clone
          end
        end

        # Pines are evergreen, coniferous resinous trees (or rarely
        # shrubs) growing 3-80 m tall, with the majority of species
        # reaching 15-45 m tall.
        # https://en.wikipedia.org/wiki/Pine#Description
        pine_trunk = Terrain.new('#', Console::Color::DARK_ORANGE, false, false)
        pine_leaf = Terrain.new('*', Console::Color::DARK_GREEN, false, true)
        pine_leaf_snowed = Terrain.new('*', Console::Color::WHITE, false, true)

        make_pine = proc do |width, depth, height|
          pine = TerrainFeature.new(width, depth, height)
          pine.each_key do |o|
            t = case
            when o.y == depth / 2 && o.x == depth / 2
              pine_trunk
            when o.z >= 2
              if rand(height) - o.z > 0
                if height - o.z <= 10
                  pine_leaf_snowed
                else
                  pine_leaf
                end
              end
            end
            pine[o] = t
          end
          pine
        end

        chunk.depth.times do |y|
          chunk.width.times do |x|
            if rand(100) < 20
              pine = make_pine.call(3, 3, 30 - rand(15))
              o = Vector.v3(x, y, 32) - Vector.v3(pine.width / 2, pine.height / 2, 0)
              pine.blit(chunk, o)
            end
          end
        end

        chunk.calculate_lighting
        map
      end
    end
  end
end
