require_relative 'predicate'

class AtomicForm
  include Dry::Equalizer(:predicate, :args)

  attr_reader :predicate, :args

  def initialize(predicate_name, args)
    @predicate = Predicate.new(predicate_name, args.length)
    @args      = args
  end

  def to_s
    args_string = args.map(&:to_s).join(', ')
    "#{predicate.to_s}(#{args_string})"
  end

  def inspect
    args_inspect = args.map(&:inspect).join(', ')
    "#{predicate.inspect}(#{args_inspect})"
  end

  def fact?
    args.all? { |arg| arg.is_a?(Constant) }
  end
end
