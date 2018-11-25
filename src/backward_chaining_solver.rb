require_relative 'substitutions'

class BackwardChainingSolver
  def self.solve_query(knowledge_base, query)
    new(knowledge_base: knowledge_base).solve_and(query)
  end

  def initialize(substitutions = Substitutions.new, parent: nil, knowledge_base: nil)
    @substitutions = substitutions
    @visited_goals = []

    if parent
      @parent = parent
    else
      @knowledge_base = knowledge_base
    end
  end

  def solve_or(goal)
    return [] if visited?(goal)
    visit!(goal)

    knowledge_base.fetch_rules_for_goal(goal).each_with_object([]) do |rule, results|
      unified_substitutions = substitutions.unify(rule.right, goal)
      solver(unified_substitutions).solve_and(rule.left).each do |result|
        results << result
      end
    end
  end

  def solve_and(goals)
    return [] if substitutions.failed?
    return [substitutions] if goals.nil? || goals.none?

    current_goal, *rest_of_goals = goals
    substituted_goal = substitutions.apply(current_goal)
    solver(substitutions).solve_or(substituted_goal).each_with_object([]) do |current_goal_substitution, results|
      solver(current_goal_substitution).solve_and(rest_of_goals).each do |all_goals_substitution|
        results << all_goals_substitution
      end
    end
  end

  protected

  def knowledge_base
    if parent
      parent.knowledge_base
    else
      @knowledge_base
    end
  end

  def visited?(goal)
    visited_goals.include?(goal) || (parent && parent.visited?(goal))
  end

  private

  attr_reader :substitutions, :parent, :visited_goals

  def visit!(goal)
    visited_goals << goal
  end

  def solver(substitutions)
    BackwardChainingSolver.new(substitutions, parent: self)
  end
end
