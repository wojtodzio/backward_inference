require_relative 'node'

class Predicate
  include Node
  include Dry::Equalizer(:name, :args)

  attr_reader :name, :args

  def initialize(name, args)
    @name = name
    @args = args
  end

  def to_s
    args_string = args.map(&:to_s).join(', ')
    "#{name}(#{args_string})"
  end

  def inspect
    return name if args.empty?

    args_inspect = args.map(&:inspect).join(', ')
    "#{name}(#{args_inspect})"
  end

  def predicate?
    true
  end

  def fact?
    args.empty? || args.all?(&:fact?)
  end
end
