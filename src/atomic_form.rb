require_relative 'predicate'
require_relative 'constant'

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

  def uses_variable?(var)
    args.any? do |arg|
      case arg
      when AtomicForm
        arg.uses_variable?(var)
      when var.class
        arg == var
      end
    end
  end

  def dup
    AtomicForm.new(predicate.name, args.map(&:dup))
  end

  def substitute_args(mapping)
    dup.substitute_args!(mapping)
  end

  def substitute_args!(mapping)
    args.map! do |arg|
      if arg.is_a?(AtomicForm)
        arg.substitute_args!(mapping)
      elsif mapping.key?(arg)
        mapping[arg]
      else
        arg
      end
    end
    self
  end
end
