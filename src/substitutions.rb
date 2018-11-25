class Substitutions
  def initialize(initial_mapping = {})
    @mapping = initial_mapping
    @failed  = false
  end

  def unify(x, y)
    dup.unify!(x, y)
  end

  def unify!(x, y)
    return self if failed?
    return self if x == y

    return unify_variable(x, y) if x.is_a?(Variable)
    return unify_variable(y, x) if y.is_a?(Variable)

    x_and_y_are_atomic_forms = x.is_a?(AtomicForm) && y.is_a?(AtomicForm)
    return unify!(x.predicate, y.predicate).unify!(x.args, y.args) if x_and_y_are_atomic_forms

    x_and_y_are_lists = x.is_a?(Array) && y.is_a?(Array)
    if x_and_y_are_lists && x.count == y.count
      x_first, *x_rest = x
      y_first, *y_rest = y
      return unify!(x_first, y_first).unify!(x_rest, y_rest)
    end

    return x.reduce(self) { |unified, conjunct| unified.unify!(conjunct, y) } if x.is_a?(ListOfConjuncts)
    return y.reduce(self) { |unified, conjunct| unified.unify!(x, conjunct) } if y.is_a?(ListOfConjuncts)

    fail!
  end

  def apply(atomic_form)
    atomic_form.substitute_args(mapping)
  end

  def failed?
    @failed
  end

  def dup
    Substitutions.new(mapping.dup)
  end

  private

  attr_accessor :mapping, :failed

  def fail!
    self.failed = true
    self
  end

  def add(substitution)
    self.mapping = mapping.merge(substitution)
    self
  end

  def unify_variable(variable, x)
    return unify(mapping[variable], x) if mapping.key?(variable)
    return unify(variable, mapping[x]) if mapping.key?(x)
    if x.is_a?(AtomicForm)
      return fail! if x.uses_variable?(variable)
      x = apply(x)
    end

    add(variable => x)
  end
end
