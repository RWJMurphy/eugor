require 'eugor/game'

module Eugor
  class CLI
    def initialize(args)
      @game = Game.new
    end

    def run
      @game.run
    end
  end
end
