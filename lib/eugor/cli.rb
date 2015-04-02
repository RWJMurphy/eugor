require 'trollop'
require 'logging'

require 'eugor/game'

module Eugor
  class CLI
    def initialize(args)
      opts = Trollop::options(args) do
        opt :verbose, "Emit more noises"
      end
      # parse args

      Logging.logger['Eugor'].level = opts[:verbose] ? :debug : :info
      Logging.logger['Eugor'].appenders = Logging.appenders.stderr
      @logger = Logging.logger[self]
      @logger.info "Initialising Eugor v0.0.1"
      @game = Game.new
    end

    def run
      @logger.info "Starting Eugor"
      @game.run
    end
  end
end
