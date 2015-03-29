require 'forwardable'

module Eugor
  class Actor
    extend Forwardable
    attr_accessor :location
    def_delegators :@location, :x, :x=, :y, :y=
  end
end
