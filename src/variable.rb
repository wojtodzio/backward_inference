require_relative 'node'

class Variable
  include Node

  def initialize(original_name)
    @name = "#{original_name}_#{quite_unique_random_number}"
  end

  def to_s
    name
  end
  alias_method :inspect, :to_s

  def variable?
    true
  end

  private

  attr_reader :name

  def quite_unique_random_number
    Time.now.to_i % rand(1000)
  end
end
