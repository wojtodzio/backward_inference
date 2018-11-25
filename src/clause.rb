class Clause
  include Dry::Equalizer(:left, :right)

  attr_reader :left, :right

  def initialize(left, right)
    @left  = ListOfConjuncts.from(left)
    @right = ListOfConjuncts.from(right)
  end

  def to_s
    "#{left.to_s} => #{right.to_s}"
  end

  def inspect
    "#{left.inspect} => #{right.inspect}"
  end

  def split_right
    right.map do |compound|
      Clause.new(left, compound)
    end
  end
end
