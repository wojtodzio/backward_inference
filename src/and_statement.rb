class AndStatement < Array
  def self.from(args)
    new(args).flatten if args
  end

  def initialize(*args)
    super(args.flatten)
  end

  def flatten
    flat_args = each_with_object([]) do |arg, accumulator|
      if arg.is_a?(AndStatement)
        arg.each { |conjunct| accumulator << conjunct }
      else
        accumulator << arg
      end
    end
    AndStatement.new(flat_args)
  end

  def to_s
    map(&:to_s).join(' AND ')
  end

  def inspect
    map(&:inspect).join(' AND ')
  end

  def map(&block)
    AndStatement.new(super)
  end

  def dup
    AndStatement.new(map(&:dup))
  end
end
