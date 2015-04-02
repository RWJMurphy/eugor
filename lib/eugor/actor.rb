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
      @logger = Logging.logger[self]
      self
    end

    def tick(tick, map, actors)
      @fovmap = nil
      return [:ACTOR_MOVE, self, Vector.v3(rand(-1..1), rand(-1..1), 0)]
    end

    def fov(map)
      @fovmap ||= begin
        chunk = map.chunk_for(location)
        fovmap = chunk.fovmap(z).clone
        fovmap.compute_fov(x, y, 0, true, TCOD::FOV_SHADOW)
        fovmap
      end
    end

    def move(v3)
      @location += v3
    end

    def inspect
      "<#{self.class.name} #{char}, #{color}>"
    end
    alias_method :to_s, :inspect
  end

  module Actors
    class HorribleTrapezoid < Actor
      def initialize(char = Console::CHAR_DIAMOND, color = Console::Color::LIGHT_BLUE)
        super(char, color)
      end

      def tick(tick, map, actors = {})
        player = actors.each_value.detect { |actor| actor.is_a? Player }
        if map[player.location].lit
          @brain[:player_location] = player.location.clone
        end

        if @brain[:player_location]
          choice = (-1..1).flat_map { |x| (-1..1).map { |y| Vector.v3(x, y, 0) } }
            .map { |movement| [movement, movement + location] }
            .reject { |_movement, destination| (actors[destination] && !actors[destination].is_a?(Player)) || !map[destination].walkable? }
            .sort_by! { |_movement, destination| (@brain[:player_location] - destination).size }
            .first
          unless choice.nil?
            @fovmap = nil
            return [:ACTOR_MOVE, self, choice.first]
          end
        end
        super(tick, map, actors)
      end
    end
  end
end
