require_relative 'constant'
require_relative 'variable'
require_relative 'clause'
require_relative 'atomic_form'
require_relative 'list_of_conjuncts'

class Parser
  def self.parse(string, parent: nil, query: false)
    parsed = new(string, parent: parent).parse

    if parsed.is_a?(Clause)
      parsed
    elsif query
      ListOfConjuncts.from(parsed)
    elsif parent.nil?
      Clause.new(nil, parsed)
    else
      parsed
    end
  end

  def initialize(string, parent: nil)
    @string = normalize_string(string)

    if parent
      @parent = parent
    else
      @variables = {}
    end
  end

  def parse
    return build_implication if string.include?('=>')
    return build_and if string.include?('AND')
    return get_variable(string) if starts_with_lowercase_letter?
    return build_atomic_form if string.include?('(')
    return build_constant
  end

  def get_variable(string_variable)
    if parent
      parent.get_variable(string_variable)
    else
      variables[string_variable] ||= Variable.new(string_variable)
    end
  end

  private

  attr_reader :string, :variables, :parent

  def starts_with_lowercase_letter?
    first_letter = string[0]
    first_letter.downcase == first_letter
  end

  def build_constant
    Constant.new(string)
  end

  def build_implication
    left, *right   = string.split('=>')
    left_sentence  = Parser.parse(left, parent: self)
    right_sentence = Parser.parse(right.join('=>'), parent: self)

    Clause.new(left_sentence, right_sentence)
  end

  def build_and
    string.split('AND').map { |conjunt| Parser.parse(conjunt, parent: self) }
  end

  def build_atomic_form
    predicate_name, args = string.scan(/(\S+)\s*\((.*)\)/).flatten
    args = args.split(',').map { |arg| Parser.parse(arg, parent: self) }

    AtomicForm.new(predicate_name, args)
  end

  def normalize_string(string)
    string.strip.squeeze(' ').gsub(/,\s+/, ',')
  end
end
