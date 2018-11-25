RSpec.describe 'High level application flow' do
  it 'gives answers to the given query based on the given knowledge base' do
    knowledge_base_inputs = <<-KB.split("\n")
      Sklep(Lewiatan)
      Sklep(Groszek)
      Sklep(PiotrIPawel)
      Sklep(Zabka)
      Sklep(Tesco)
      Sklep(Lidl)
      Sklep(Ikea)
      JestBelgijskie(BelgijskaCzekolada)
      JestPolskie(Kubus)
      JestPolskie(Pudliszki)
      JestBelgijskie(Praliny)
      JestMeblem(Krzeslo)
      JestMeblem(Stol)
      Dostepne(HotDog, Zabka)
      JestCzekolada(BelgijskaCzekolada)
      JestCzekolada(Milka)
      JestCzekolada(Wedel)
      JestSzwajcarskie(Milka)
      JestPolskie(Wedel)
      JestSlodyczem(Toffifee)
      JestNiemieckie(Toffifee)
      JestSlodyczem(x) AND JestPolskie(x) => Dostepne(x, Zabka)
      JestCzekolada(x) AND JestPolskie(x) => Dostepne(x, Tesco)
      JestSlodyczem(x) AND JestBelgijskie(x) => Dostepne(x, Lidl)
      JestCzekolada(x) => JestSlodyczem(x)
      JestCzekolada(x) => Dostepne(x, Lewiatan)
      JestMeblem(x) AND JestSzweckie(x) => Dostepne(x, Ikea)
    KB

    knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

    answer = knowledge_base.ask('Sklep(x) AND Dostepne(BelgijskaCzekolada, x)')

    expect(answer.map(&:to_s)).to contain_exactly(
      'Sklep(Lidl) AND Dostepne(BelgijskaCzekolada, Lidl)',
      'Sklep(Lewiatan) AND Dostepne(BelgijskaCzekolada, Lewiatan)'
    )
  end

  it 'gives answers when clauses includes nested atomic forms, avoids loops and allows multiple conclusions' do
    knowledge_base_inputs = <<-KB.split("\n")
      Mom(child, mom) => Child(mom, child) AND Parent(child, mom)
      Dad(child, dad) => Child(dad, child) AND Parent(child, dad)
      Child(parent, child) => Parent(child, parent)
      Parent(child, parent) => GrandMother(Parent(parent), child) AND GrandFather(Parent(parent), child)
      Mom(Michal, Beata)
      Dad(Wojtek, Joanna)
    KB

    knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

    answer = knowledge_base.ask('GrandFather(y, x)')

    expect(answer.map(&:to_s)).to contain_exactly(
      "GrandFather(Parent(Beata), Michal)",
      'GrandFather(Parent(Joanna), Wojtek)'
    )
  end
end
