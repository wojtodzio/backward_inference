require_relative 'parser'
require_relative 'backward_chaining_solver'

class KnowledgeBase
  def initialize(inputs)
    @clauses = inputs.reduce([]) do |clauses, input|
      parsed = Parser.parse(input)

      if parsed.right.count > 1
        clauses.push(*parsed.split_right)
      else
        clauses.push(parsed)
      end
    end
  end

  def ask(query_string)
    query = Parser.parse(query_string, query: true)

    substitutions = BackwardChainingSolver.solve_query(self, query)
    substitutions.map do |substitution|
      query.map { |compound| substitution.apply(compound) }
    end
  end

  def fetch_rules_for_goal(goal)
    goal_predicate = goal.predicate

    clauses.select do |clause|
      clause.right.any? { |compound| compound.predicate == goal_predicate }
    end
  end

  private

  attr_reader :clauses
end
