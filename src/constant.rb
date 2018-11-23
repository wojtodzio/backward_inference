class Constant
  def initialize(name)
    @name = name
  end

  def to_s
    name
  end
  alias_method :inspect, :to_s

  private

  attr_reader :name
end
