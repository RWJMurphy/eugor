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
    attr_reader :origin, :width, :depth, :height
    def initialize(origin, width, depth, height)
      @origin = origin
      @width = width
      @depth = depth
      @height = height
      @terrains = (0...height).map { (0...depth).map { (0...width).map { Terrain::NULL } } }
      self
    end

    def inspect
      "<#{self.class.name} #{size}@#{origin}}>"
    end

    def size
      @size ||= Vector.v3(width, depth, height)
    end

    def blit(otherChunk, origin)
      otherChunk.each do |index, terrain|
        dest = index + origin
        self[dest] = terrain.clone
      end
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
      v3 = Vector.v3(0, 0, 0)
      height.times do |z|
        depth.times do |y|
          width.times do |x|
            v3.set!(x, y, z)
            yield v3
          end
        end
      end
    end

    def [](v3)
      # fail IndexError unless v3.z >= 0 && v3.z < height &&
      #                        v3.y >= 0 && v3.y < depth &&
      #                        v3.x >= 0 && v3.x < width
      @terrains[v3.z][v3.y][v3.x]
    end

    def []=(v3, terrain)
      # fail IndexError unless v3.z >= 0 && v3.z < height &&
      #                        v3.y >= 0 && v3.y < depth &&
      #                        v3.x >= 0 && v3.x < width
      @terrains[v3.z][v3.y][v3.x] = terrain
    end
  end

  class Map
    CHUNK_SIZE = Vector.v3(128, 128, 64)

    attr_reader :width, :depth, :height

    def initialize(width, depth)
      @width = width
      @depth = depth
      @height = 1
      @chunks = width.times.map do |x|
        depth.times.map do |y|
          Chunk.new(Vector.v2(x * CHUNK_SIZE.x, y * CHUNK_SIZE.y), CHUNK_SIZE.x, CHUNK_SIZE.y, CHUNK_SIZE.z)
        end
      end
      self
    end

    def inspect
      "<#{self.class.name} (#{chunks.first.size},#{chunks.size})>"
    end

    def size
      @size ||= Vector.v3(
        width * CHUNK_SIZE.x,
        depth * CHUNK_SIZE.y,
        height * CHUNK_SIZE.z
      )
    end

    def blit(otherChunk, origin)
      otherChunk.each do |index, terrain|
        dest = index + offset
        next unless !terrain.nil? &&
                    dest.x >= 0 && dest.x < size.x &&
                    dest.y >= 0 && dest.y < size.y &&
                    dest.z >= 0 && dest.z < size.z
        chunk_for(dest)[dest % CHUNK_SIZE] = terrain.clone
      end
    end

    def chunk_for(v3)
      x = v3.x / CHUNK_SIZE.x
      y = v3.y / CHUNK_SIZE.y
      # fail IndexError unless x >= 0 && x < width &&
      #                        y >= 0 && y < depth
      @chunks[x][y]
    end

    def subchunk(origin, width, depth, height)
      subchunk = Chunk.new(origin.clone, width, depth, height)
      global_coord = Vector.v3(0, 0, 0)
      width.times do |x|
        depth.times do |y|
          global_coord.x = origin.x + x
          global_coord.y = origin.y + y
          chunk = chunk_for(global_coord)
          height.times do |z|
            global_coord.z = origin.z + z
            local_coord = global_coord % CHUNK_SIZE
            subchunk[Vector.v3(x, y, z)] = chunk[local_coord]
          end
        end
      end
      subchunk
    end

    def each_chunk_index(&block)
      v2 = Vector.v2(0, 0)
      width.times do |x|
        depth.times do |y|
          v2.set!(x, y)
          yield v2
        end
      end
    end

    def each_chunk
      each_chunk_index do |chunk_index|
        yield @chunks[chunk_index.x][chunk_index.y]
      end
    end

    def [](v3)
      chunk_for(v3)[v3 % CHUNK_SIZE]
    end

    def []=(v3, chunk)
      chunk_for(v3)[v3 % CHUNK_SIZE] = chunk
    end
  end

  class TerrainFeature < Chunk
  end

  module Maps
    class << self
      def forest(surface_level = 32)
        map = Map.new(1, 1)

        blocks = [
          [Cuboid.new(Vector.v3(0, 0, 0), 128, 128, surface_level), Terrain::SOLID_DIRT],
          [Cuboid.new(Vector.v3(0, 0, surface_level), 128, 128, 1), Terrain::GROUND],
          [Cuboid.new(Vector.v3(0, 0, surface_level + 1), 128, 128, 64 - (surface_level + 1)), Terrain::AIR]
        ]

        blocks.each do |block, terrain|
          block.each do |v3|
            map[v3] = terrain.clone
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

        Map::CHUNK_SIZE.y.times do |y|
          Map::CHUNK_SIZE.x.times do |x|
            if rand(100) < 1
              pine = make_pine.call(3, 3, 30 - rand(15))
              o = Vector.v3(x, y, 32) - Vector.v3(pine.width / 2, pine.height / 2, 0)
              map.blit(pine, o)
            end
          end
        end

        map.each_chunk(&:calculate_lighting)
        map
      end
    end
  end
end
