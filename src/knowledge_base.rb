require_relative 'parser'
require_relative 'backward_chaining_solver'

class KnowledgeBase
  def initialize(inputs)
    @clauses = inputs.map { |input| Parser.parse(input) }
  end

  def ask(query_string)
    query = Parser.parse(query_string, query: true)

    BackwardChainingSolver.solve_query(self, query)
  end

  def fetch_rules_for_goal(goal)
    goal_predicates = goal.map(&:predicate)

    clauses.select do |clause|
      shared_predicates = clause.right.map(&:predicate) & goal_predicates
      shared_predicates.any?
    end
  end

  private

  attr_reader :clauses
end
