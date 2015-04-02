require 'libtcod'

require 'eugor/vector'
require 'eugor/player'

module Eugor
  class Camera
    attr_accessor :pov, :origin, :width, :depth
    def initialize(pov, origin, width, depth)
      @pov = pov
      @origin = origin
      @width = width
      @depth = depth
      @frame = TCOD.console_new(width, depth)
      @logger = Logging.logger[self]
      self
    end

    Z_LEVELS = 4

    def frame(map, actors = {}, dirty = nil)
      fov = @pov.fov(map)
      world_coord = origin.clone
      world_coord.z -= Z_LEVELS

      subchunk = map.subchunk(world_coord, width, depth, Z_LEVELS + 1)
      subchunk_coord = Vector.v3(0, 0, 0)

      if dirty.nil?
        dirty = depth.times.map { |y| width.times.map { |x| Vector.v2(x + origin.x, y + origin.y) } }.flatten(1)
      end

      dirty.each do |dirty_coord|
        world_coord.x = dirty_coord.x
        world_coord.y = dirty_coord.y

        subchunk_coord.x = world_coord.x - origin.x
        subchunk_coord.y = world_coord.y - origin.y

        next unless subchunk_coord.x >= 0 && subchunk_coord.x < width &&
                    subchunk_coord.y >= 0 && subchunk_coord.y < depth

        char = nil
        color = nil

        (Z_LEVELS).downto(0).each do |z|
          next if z <= 0 || z > map.height * Map::CHUNK_SIZE.z
          world_coord.z = origin.z - Z_LEVELS + z
          subchunk_coord.z = z

          # next unless fov.in_fov?(world_coord.x, world_coord.y)

          actor = actors[world_coord]
          terrain = subchunk[subchunk_coord]
          if actor
            char = actor.char
            color = actor.color.clone
          else
            char = terrain.char
            color = terrain.color.clone
          end
          next if char == ' '
          color *= 0.5 unless terrain.lit
          color.scale_hsv(1.0, 2**(z - Z_LEVELS))
          break
        end

        TCOD.console_set_default_foreground(@frame, color)
        TCOD.console_put_char(@frame, subchunk_coord.x, subchunk_coord.y, char.ord, TCOD::BKGND_NONE)
      end
      @frame
    end
  end
end
