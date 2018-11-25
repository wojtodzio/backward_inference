require 'securerandom'

class Variable
  include Dry::Equalizer(:identity_string)

  def initialize(original_name)
    @original_name = original_name

    random_number_for_display ||= SecureRandom.random_number(1000)
    @identity_string = SecureRandom.uuid # Use random string with a very very low chance of clashing
  end

  def to_s
    original_name
  end
  alias_method :inspect, :to_s

  def variable?
    true
  end

  private

  attr_reader :original_name, :identity_string
end
