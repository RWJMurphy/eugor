require 'eugor/actor'
module Eugor
  class Player < Actor
    def tick(tick, map)
      @fovmap = nil
    end
  end
end
