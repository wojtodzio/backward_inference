require_relative 'node'

class Statement
  include Node
  include Dry::Equalizer(:type, :left, :right)

  SUPPORTED_TYPES = [:and, :implication]

  attr_reader :left, :right

  def self.implication(left, right)
    new(:implication, left, right)
  end

  def self.and(left, right)
    new(:and, left, right)
  end

  def initialize(type, left, right)
    raise "Unsupported type #{type}" if !SUPPORTED_TYPES.include?(type)
    @type  = type
    @left  = left
    @right = right
  end

  def implication?
    type == :implication
  end

  def and?
    type == :and
  end

  def to_s
    "#{left.to_s} #{printable_type} #{right.to_s}"
  end

  def inspect
    "#{left.inspect} #{printable_type} #{right.inspect}"
  end

  private

  attr_reader :type

  def printable_type
    return 'AND' if and?
    return '=>' if implication?
  end
end
