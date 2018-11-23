RSpec.describe Parser do
  it 'can parse variables' do
    parsed = Parser.parse('shop')

    expect(parsed.right.args.first).to be_a(Variable)
  end

  it 'can parse constants' do
    parsed = Parser.parse('Tesco')

    expect(parsed.right.args.first).to be_a(Constant)
  end

  it 'considers atomic facts as clauses with empty left side' do
    parsed = Parser.parse('Like(John, Tesco)')

    expect(parsed).to be_a(Clause)
    expect(parsed.left).to be_nil
    expect(parsed.right).to be_a(ListOfConjuncts)

    like = parsed.right.args.first

    expect(like).to be_a(Predicate)
    expect(like).to be_fact
    expect(like.arity).to eq(2)

    john  = like.args.first
    tesco = like.args.last

    expect(john).to be_a(Constant)
    expect(tesco).to be_a(Constant)
  end

  it 'can parse predicates with variables' do
    parsed = Parser.parse('Available(Tesco, meal)')

    expect(parsed).to be_a(Clause)
    expect(parsed.left).to be_nil
    expect(parsed.right).to be_a(ListOfConjuncts)

    available = parsed.right.args.first

    expect(available).to be_a(Predicate)
    expect(available).not_to be_fact
    expect(available.arity).to eq(2)

    tesco = available.args.first
    meal  = available.args.last

    expect(tesco).to be_a(Constant)
    expect(meal).to be_a(Variable)
  end

  it 'can parse AND sentences' do
    parsed = Parser.parse('Like(John, x) AND Shop(x) AND Polish(x)')
    expect(parsed).to be_a(Clause)
    expect(parsed.right).to be_a(ListOfConjuncts)

    like, shop, polish = parsed.right.args

    expect(like).to be_a(Predicate)
    expect(like).not_to be_fact
    expect(like.arity).to eq(2)

    expect(shop).to be_a(Predicate)
    expect(shop).not_to be_fact
    expect(shop.arity).to eq(1)

    expect(polish).to be_a(Predicate)
    expect(polish).not_to be_fact
    expect(polish.arity).to eq(1)

    expect(shop.args.first).to eq(polish.args.first)
  end

  it 'can parse implication clauses' do
    parsed = Parser.parse('Like(John, x) => Shop(x)')

    expect(parsed).to be_a(Clause)

    like = parsed.left.args.first
    shop = parsed.right.args.first

    expect(like).to be_a(Predicate)
    expect(like.arity).to eq(2)

    expect(shop).to be_a(Predicate)
    expect(shop.arity).to eq(1)
  end

  it 'favours implication precedence over AND' do
    parsed = Parser.parse('Like(John, x) AND Building(x) => Shop(x)')

    expect(parsed).to be_a(Clause)

    like_and_building = parsed.left

    expect(like_and_building).to be_a(ListOfConjuncts)

    like     = like_and_building.args.first
    building = like_and_building.args.last

    expect(like).to be_a(Predicate)
    expect(like.arity).to eq(2)

    expect(building).to be_a(Predicate)
    expect(building.arity).to eq(1)

    shop = parsed.right.args.first

    expect(shop).to be_a(Predicate)
    expect(shop.arity).to eq(1)
  end

  it 'does variables standarization' do
    parsed_1 = Parser.parse('Shop(y)')
    parsed_2 = Parser.parse('Shop(y)')

    shop_1 = parsed_1.right.args.first
    shop_2 = parsed_2.right.args.first

    expect(shop_1.args.first).not_to eq(shop_2.args.first)
  end

  it 'treates same named variables within one clause as the same' do
    parsed = Parser.parse('Shop(y) AND Available(y, x) => Like(John, x)')

    shop_and_available = parsed.left
    like               = parsed.right.args.first

    shop      = shop_and_available.args.first
    available = shop_and_available.args.last

    expect(shop.args.first).to eq(available.args.first)
    expect(shop.args.first).not_to eq(available.args.last)
    expect(available.args.last).to eq(like.args.last)
  end

  it 'does not wrap predicates inside a clause if called for a query' do
    parsed = Parser.parse('Available(x)', query: true)

    expect(parsed).to be_a(ListOfConjuncts)
    expect(parsed.args.count).to eq(1)
  end

  it 'does not wrap AND statements inside a clause if called for a query' do
    parsed = Parser.parse('Shop(x) AND Available(x)', query: true)

    expect(parsed).to be_a(ListOfConjuncts)
    expect(parsed.args.count).to eq(2)
  end
end
