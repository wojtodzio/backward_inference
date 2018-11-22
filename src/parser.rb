require_relative 'variable'
require_relative 'statement'
require_relative 'predicate'

class Parser
  def self.parse(*args)
    new(*args).parse
  end

  def initialize(string, variables = {})
    @string    = normalize_string(string)
    @variables = variables
  end

  def parse
    return build_implication if string.include?('=>')
    return build_and if string.include?('AND')

    first_letter = string[0]
    return get_variable(string) if first_letter.downcase == first_letter
    return build_predicate if string.include?('(')
    return parse_fact
  end

  private

  attr_reader :string, :variables

  def parse_fact
    Predicate.new(string, [])
  end

  def build_implication
    left, *right   = string.split('=>')
    left_sentence  = Parser.parse(left, variables)
    right_sentence = Parser.parse(right.join('=>'), variables)

    Statement.implication(left_sentence, right_sentence)
  end

  def build_and
    left, *right   = string.split('AND')
    left_sentence  = Parser.parse(left, variables)
    right_sentence = Parser.parse(right.join('AND'), variables)

    Statement.and(left_sentence, right_sentence)
  end

  def build_predicate
    predicate_name, args = string.scan(/(\S+)\s*\((.*)\)/).flatten
    args = args.split(',').map { |arg| Parser.parse(arg, variables) }

    Predicate.new(predicate_name, args)
  end

  def normalize_string(string)
    string.strip.squeeze(' ').gsub(/,\s+/, ',')
  end

  def get_variable(string_variable)
    variables[string_variable] ||= Variable.new(string_variable)
  end
end
