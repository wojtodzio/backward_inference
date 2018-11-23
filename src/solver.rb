require_relative 'parser'

class Solver
  def self.solve(knowledge_base, query_string)
    query = Parser.parse(query)
    new(knowledge_base, [query], []).solve
  end

  def initialize(knowledge_base, goals, substitutions)
    @knowledge_base = knowledge_base
    @goals          = goals
    @substitutions  = substitutions
    @visited        = []
  end

  def solve
    return substitutions if goals.empty?

    current_goal, *other_goals = goals

    return substitutions if visited.include?(current_goal)
    visited << current_goal

    substitutions.apply(current_goal)
  end

  private

  attr_reader :knowledge_base, :goals, :substitutions, :visited
end
