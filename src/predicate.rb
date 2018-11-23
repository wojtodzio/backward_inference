require_relative 'constant'

class Predicate
  include Dry::Equalizer(:name, :arity)

  attr_reader :name, :arity

  def initialize(name, arity)
    @name  = name
    @arity = arity
  end

  alias_method :to_s, :name
  alias_method :inspect, :name
end
