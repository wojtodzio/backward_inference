RSpec.describe Parser do
  it 'can parse variables' do
    parsed = Parser.parse('shop')

    expect(parsed.right.first).to be_a(Variable)
  end

  it 'can parse constants' do
    parsed = Parser.parse('Tesco')

    expect(parsed.right.first).to be_a(Constant)
  end

  it 'considers atomic facts as clauses with empty left side' do
    parsed = Parser.parse('Like(John, Tesco)')

    expect(parsed).to be_a(Clause)
    expect(parsed.left).to be_nil
    expect(parsed.right).to be_a(AndStatement)

    like = parsed.right.first

    expect(like).to be_a(AtomicForm)
    expect(like.predicate.arity).to eq(2)

    john  = like.args.first
    tesco = like.args.last

    expect(john).to be_a(Constant)
    expect(tesco).to be_a(Constant)
  end

  it 'can parse atomic forms with variable arguments' do
    parsed = Parser.parse('Available(Tesco, meal)')

    expect(parsed).to be_a(Clause)
    expect(parsed.left).to be_nil
    expect(parsed.right).to be_a(AndStatement)

    available = parsed.right.first

    expect(available).to be_a(AtomicForm)
    expect(available.predicate.arity).to eq(2)

    tesco = available.args.first
    meal  = available.args.last

    expect(tesco).to be_a(Constant)
    expect(meal).to be_a(Variable)
  end

  it 'can parse atomic forms with atomic form arguments' do
    parsed = Parser.parse('Available(x, Shop(x), Tesco)')

    expect(parsed).to be_a(Clause)
    expect(parsed.left).to be_nil
    expect(parsed.right).to be_a(AndStatement)

    available = parsed.right.first

    expect(available).to be_a(AtomicForm)
    expect(available.predicate.arity).to eq(3)

    x, shop, tesco = available.args

    expect(x).to be_a(Variable)
    expect(tesco).to be_a(Constant)

    expect(shop).to be_a(AtomicForm)
    expect(shop.predicate.arity).to eq(1)
    expect(shop.args.first).to be_a(Variable)
    expect(shop.args.first).to eq(x)
  end

  it 'can parse AND sentences' do
    parsed = Parser.parse('Like(John, x) AND Shop(x) AND Polish(x)')
    expect(parsed).to be_a(Clause)
    expect(parsed.right).to be_a(AndStatement)

    like, shop, polish = parsed.right

    expect(like).to be_a(AtomicForm)
    expect(like.predicate.arity).to eq(2)

    expect(shop).to be_a(AtomicForm)
    expect(shop.predicate.arity).to eq(1)

    expect(polish).to be_a(AtomicForm)
    expect(polish.predicate.arity).to eq(1)

    expect(shop.args.first).to eq(polish.args.first)
  end

  it 'can parse implication clauses' do
    parsed = Parser.parse('Like(John, x) => Shop(x)')

    expect(parsed).to be_a(Clause)

    like = parsed.left.first
    shop = parsed.right.first

    expect(like).to be_a(AtomicForm)
    expect(like.predicate.arity).to eq(2)

    expect(shop).to be_a(AtomicForm)
    expect(shop.predicate.arity).to eq(1)
  end

  it 'favours implication precedence over AND' do
    parsed = Parser.parse('Like(John, x) AND Building(x) => Shop(x)')

    expect(parsed).to be_a(Clause)

    like_and_building = parsed.left

    expect(like_and_building).to be_a(AndStatement)

    like     = like_and_building.first
    building = like_and_building.last

    expect(like).to be_a(AtomicForm)
    expect(like.predicate.arity).to eq(2)

    expect(building).to be_a(AtomicForm)
    expect(building.predicate.arity).to eq(1)

    shop = parsed.right.first

    expect(shop).to be_a(AtomicForm)
    expect(shop.predicate.arity).to eq(1)
  end

  it 'does variables standarization' do
    parsed_1 = Parser.parse('Shop(y)')
    parsed_2 = Parser.parse('Shop(y)')

    shop_1 = parsed_1.right.first
    shop_2 = parsed_2.right.first

    expect(shop_1.args.first).not_to eq(shop_2.args.first)
  end

  it 'treates same named variables within one clause as the same' do
    parsed = Parser.parse('Shop(y) AND Available(y, x) => Like(John, x)')

    shop_and_available = parsed.left
    like               = parsed.right.first

    shop      = shop_and_available.first
    available = shop_and_available.last

    expect(shop.args.first).to eq(available.args.first)
    expect(shop.args.first).not_to eq(available.args.last)
    expect(available.args.last).to eq(like.args.last)
  end

  it 'treates same named predicates with the same arity as the same' do
    available_1 = Parser.parse('Available(x, y)').right.first
    available_2 = Parser.parse('Available(Tesco, z)').right.first

    expect(available_1).not_to eq(available_2)
    expect(available_1.predicate).to eq(available_2.predicate)
  end

  it 'treates same named predicates with different arity as different' do
    available_1 = Parser.parse('Available(x, y, z)').right.first
    available_2 = Parser.parse('Available(Tesco, z)').right.first

    expect(available_1).not_to eq(available_2)
    expect(available_1.predicate).not_to eq(available_2.predicate)
  end

  it 'treates differently named predicates with the same arity as different' do
    available = Parser.parse('Available(x, y)').right.first
    like      = Parser.parse('Like(x, y)').right.first

    expect(available).not_to eq(like)
    expect(available.predicate).not_to eq(like.predicate)
  end

  it 'does not wrap predicates inside a clause if called for a query' do
    parsed = Parser.parse('Available(x)', query: true)

    expect(parsed).to be_a(AndStatement)
    expect(parsed.count).to eq(1)
  end

  it 'does not wrap AND statements inside a clause if called for a query' do
    parsed = Parser.parse('Shop(x) AND Available(x)', query: true)

    expect(parsed).to be_a(AndStatement)
    expect(parsed.count).to eq(2)
  end
end
