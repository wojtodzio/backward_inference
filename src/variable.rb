require 'securerandom'

class Variable
  include Dry::Equalizer(:identity_string)

  def initialize(original_name)
    @original_name   = original_name
    @identity_string = SecureRandom.uuid # Use random string with a very very low chance of clashing
  end

  def to_s
    original_name
  end
  alias_method :inspect, :to_s

  private

  attr_reader :original_name, :identity_string
end
