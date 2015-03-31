require 'eugor/actor'
module Eugor
  class Player < Actor
    def tick(tick, map)
      @fovmap = nil
      return [:ACTOR_NONE]
    end
  end
end
