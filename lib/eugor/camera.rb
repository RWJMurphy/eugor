require 'libtcod'

require 'eugor/vector'
require 'eugor/player'

module Eugor
  class Camera
    LIGHT = TCOD::Color::LIGHTER_AMBER * 0.25
    attr_accessor :pov, :center, :width, :depth
    def initialize(pov, center, width, depth)
      @pov = pov
      @center = center

      @width = width
      @depth = depth
      @frame = TCOD.console_new(width, depth)
      @xframe = TCOD.console_new(width, depth)

      @logger = Logging.logger[self]
      self
    end

    def size
      @size ||= Vector.v3(width, depth, 0)
    end

    PROBE_DEPTH = 20
    def north(map, actors = {}, dirty_world_coords = nil)
      frame_axis_to_world = {
        x: [:x, 1],
        y: [:z, -1],
        z: [:y, -1],
      }
      frame(frame_axis_to_world, PROBE_DEPTH, map, actors, dirty_world_coords)
    end

    def xframe(map, actors = {}, dirty_world_coords = nil)
      frame_axis_to_world = {
        x: [:y, 1],
        y: [:z, -1],
        z: [:x, -1],
      }
      frame(frame_axis_to_world, PROBE_DEPTH, map, actors, dirty_world_coords)
    end

    def frame(frame_axis_to_world, probe_depth, map, actors = {}, dirty_world_coords = nil)
      center = @center.clone
      center[frame_axis_to_world[:y].first] = [depth / 2, center[frame_axis_to_world[:y].first]].max

      if dirty_world_coords.nil?
        # @logger.debug "All coords dirty :|"
        dirty_world_coords = Enumerator.new do |yielder|
          world_coord = Vector.v3(0, 0, 0)
          center = center.clone
          depth.times.map do |frame_y|
            width.times.map do |frame_x|
              world_coord[frame_axis_to_world[:x].first] = frame_x + center[frame_axis_to_world[:x].first] - (width / 2)
              world_coord[frame_axis_to_world[:y].first] = frame_y + center[frame_axis_to_world[:y].first] - (depth / 2)
              world_coord[frame_axis_to_world[:z].first] = center[frame_axis_to_world[:z].first]
              yielder << world_coord.clone
            end
          end
        end
      else
        # @logger.debug "Dirty coords: #{dirty_world_coords}"
      end

      dirty_world_coords.map do |world_coord|
        # @logger.debug "Dirty coord: #{world_coord}"
        dirty_frame = Vector.v2(world_coord.x, world_coord.y)
        dirty_frame.x = world_coord[frame_axis_to_world[:x].first] - center[frame_axis_to_world[:x].first] + (width / 2)
        dirty_frame.y = world_coord[frame_axis_to_world[:y].first] - center[frame_axis_to_world[:y].first] + (depth / 2)
        dirty_frame.x = (width - 1) - dirty_frame.x if frame_axis_to_world[:x][1] == -1
        dirty_frame.y = (depth - 1) - dirty_frame.y if frame_axis_to_world[:y][1] == -1
        # @logger.debug "Frame coord: #{dirty_frame}"
        [world_coord, dirty_frame]
      end.select do |world_coord, dirty_frame|
        dirty_frame.x >= 0 && dirty_frame.x < width &&
          dirty_frame.y >= 0 && dirty_frame.y < depth
      end.each do |world_coord, dirty_frame|
        char = nil
        fg_color = nil
        bg_color = nil
        overlays = []

        probe_depth.times do |dz|
          world_coord[frame_axis_to_world[:z].first] = center[frame_axis_to_world[:z].first] + dz * frame_axis_to_world[:z][1]

          # @logger.debug "Probing #{world_coord}"
          terrain = map[world_coord]
          actor = actors[world_coord]

          if actor
            # @logger.debug "Found #{actor.inspect}@#{world_coord}"
            # binding.pry if actor.is_a? Player
            char ||= actor.char
            fg_color ||= begin
              fg_color = actor.color.clone
              # @logger.debug "Foreground color: #{fg_color}"
              fg_color *= 0.5 unless terrain.lit
              fg_color += LIGHT if terrain.lit
              fg_color.scale_hsv(1.0, 2**(0.2 * dz))
              # @logger.debug "Modified foreground color: #{fg_color}"
              fg_color
            end
          end

          bg_color ||= begin
            if !terrain.transparent? || terrain.alpha >= 1.0
              # @logger.debug "Found terrain #{terrain.inspect}@#{world_coord}"
              bg_color = terrain.color.clone
              # @logger.debug "Background color: #{bg_color}"
              bg_color *= 0.5 unless terrain.lit
              bg_color += LIGHT if terrain.lit
              bg_color.scale_hsv(1.0, 2**-(0.2 * dz))
              # @logger.debug "Modified background color: #{bg_color}"
              bg_color
            end
          end

          if terrain.alpha > 0 && terrain.alpha < 1.0
            overlay = terrain.color.clone
            overlay += LIGHT if terrain.lit
            overlay *= 0.5 unless terrain.lit
            overlay.scale_hsv(1.0, 2 * 2**-(0.2 * dz))
            overlays << [overlay, terrain.alpha]
          end

          next unless bg_color.nil?
        end

        char ||= ' '
        bg_color ||= Console::Color::BLACK
        fg_color ||= Console::Color::WHITE

        # TCOD.console_set_default_foreground(@xframe, fg_color)
        # TCOD.console_set_default_background(@xframe, bg_color)
        # @logger.debug "#xframe: console_put_char_ex #{dirty_frame.x}, #{dirty_frame.y}, #{char}, #{fg_color}, #{bg_color}"
        # binding.pry unless dirty_frame.x >= 0 && dirty_frame.x < width &&
        #                    dirty_frame.y >= 0 && dirty_frame.y < depth
        TCOD.console_put_char_ex(@xframe, dirty_frame.x, dirty_frame.y, char.ord, fg_color, bg_color)
        overlays.each do |overlay, alpha|
          TCOD.console_set_char_background(
            @xframe, dirty_frame.x, dirty_frame.y,
            overlay, TCOD::Color.bkgnd_alpha(alpha)
          )
        end

      end
      @xframe
    end

    Z_RANGE_MAX = 4

    def zframe(map, actors = {}, dirty = nil)
      fov = @pov.fov(map)
      world_coord = center - size / 2
      world_coord.z -= Z_RANGE_MAX

      subchunk = map.subchunk(world_coord, width, depth, Z_RANGE_MAX + 1)
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

        (Z_RANGE_MAX).downto(0).each do |z|
          next if z <= 0 || z > map.height * Map::CHUNK_SIZE.z
          world_coord.z = origin.z - Z_RANGE_MAX + z
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
          color.scale_hsv(1.0, 2**(z - Z_RANGE_MAX))
          break
        end

        TCOD.console_set_default_foreground(@frame, color)
        TCOD.console_put_char(@frame, subchunk_coord.x, subchunk_coord.y, char.ord, TCOD::BKGND_NONE)
      end
      @frame
    end
  end
end
