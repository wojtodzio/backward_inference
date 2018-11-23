require_relative 'substitutions'

class BackwardChainingSolver
  def self.solve_query(knowledge_base, query)
    new(knowledge_base).solve_or(query).to_a
  end

  def initialize(knowledge_base, substitutions = Substitutions.new)
    @knowledge_base = knowledge_base
    @substitutions  = substitutions
    @visited        = [] # TODO
  end

  def solve_or(goal)
    Enumerator.new do |results|
      knowledge_base.fetch_rules_for_goal(goal).each do |rule|
        unified_substitutions = substitutions.unify(rule.right, goal)
        solver(unified_substitutions).solve_and(rule.left).each do |result|
          results << result
        end
      end
    end
  end

  def solve_and(goals)
    Enumerator.new do |results|
      next if substitutions.none?
      next results << substitutions if goals.none?

      current_goal, *rest_of_goals = goals.args
      substituted_goal = substitutions.apply(current_goal)
      solver(substitutions).solve_or(substituted_goal).each do |current_goal_substitution|
        solver(current_goal_substitution).solve_and(rest_of_goals) do |all_goals_substitution|
          results << all_goals_substitution
        end
      end
    end
  end

  private

  attr_reader :knowledge_base, :goals, :substitutions, :visited

  def solver(substitutions)
    BackwardChainingSolver.new(knowledge_base, substitutions)
  end
end
