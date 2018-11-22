RSpec.describe Parser do
  it 'can parse facts' do
    parsed = Parser.parse('Tesco')
    expect(parsed).to be_a(Predicate)
    expect(parsed).to be_fact
  end

  it 'can parse predicates with only fact args' do
    parsed = Parser.parse('Like(John, Tesco)')
    expect(parsed).to be_a(Predicate)
    expect(parsed).to be_fact
  end

  it 'can parse predicates with variables' do
    parsed = Parser.parse('Available(Tesco, meal)')
    expect(parsed).to be_a(Predicate)
    expect(parsed).not_to be_fact
  end

  it 'can parse variables' do
    parsed = Parser.parse('shop')
    expect(parsed).to be_a(Variable)
  end

  it 'can parse AND sentences' do
    parsed = Parser.parse('Like(John, x) AND Shop(x)')
    expect(parsed).to be_a(Statement)
    expect(parsed).to be_and
    expect(parsed.left).to be_a(Predicate)
    expect(parsed.right).to be_a(Predicate)
  end

  it 'can parse implication sentences' do
    parsed = Parser.parse('Like(John, x) => Shop(x)')
    expect(parsed).to be_a(Statement)
    expect(parsed).to be_implication
    expect(parsed.left).to be_a(Predicate)
    expect(parsed.right).to be_a(Predicate)
  end

  it 'favours implication precedence over AND' do
    parsed = Parser.parse('Like(John, x) AND Building(x) => Shop(x)')

    expect(parsed.left).to be_a(Statement)
    expect(parsed.left).to be_and
    expect(parsed.right).to be_a(Predicate)
  end

  it 'does variables standarization' do
    parsed = Parser.parse('Shop(y) AND Available(y, x) => Like(John, x)')

    shop_and_available = parsed.left

    shop      = shop_and_available.left
    available = shop_and_available.right
    like      = parsed.right

    expect(shop.args.first).to eq(available.args.first)
    expect(shop.args.first).not_to eq(available.args.last)
    expect(available.args.last).to eq(like.args.last)
  end

  it 'does not standarize variables between calls' do
    parsed_1 = Parser.parse('Shop(y)')
    parsed_2 = Parser.parse('Shop(y)')

    expect(parsed_1.args.first).not_to eq(parsed_2.args.first)
  end
end
