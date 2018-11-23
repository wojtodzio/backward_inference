class ListOfConjuncts
  include Enumerable
  include Dry::Equalizer(:args)

  attr_reader :args

  def self.from(args)
    new(args).flatten if args
  end

  def initialize(*args)
    @args = args.flatten
  end

  def flatten
    flat_args = args.each_with_object([]) do |arg, accumulator|
      if arg.is_a?(ListOfConjuncts)
        arg.each { |conjunct| accumulator << conjunct }
      else
        accumulator << arg
      end
    end
    ListOfConjuncts.new(args)
  end

  def to_s
    args_strings = args.map(&:to_s)
    "(#{args_strings.join(' AND ')})"
  end

  def inspect
    args_inspects = args.map(&:inspect)
    "(#{args_inspects.join(' AND ')})"
  end

  def each(&block)
    args.each(&block)
  end

  def last
    args.last
  end

  alias_method :to_ary, :to_a
end
