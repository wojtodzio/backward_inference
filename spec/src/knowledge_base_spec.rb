RSpec.describe KnowledgeBase do
  describe '#fetch_rules_for_goal' do
    it 'can find atomic facts leading to the given goal' do
      knowledge_base_inputs = <<~KB.split("\n")
        Sklep(Lewiatan)
        Polski(Groszek)
        Sklep(Groszek)
      KB

      goal = Parser.parse('Sklep(x)', query: true)

      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)
      expect(knowledge_base.fetch_rules_for_goal(goal)).to contain_exactly(
        Parser.parse('Sklep(Lewiatan)'),
        Parser.parse('Sklep(Groszek)')
      )
    end

    it 'can find clauses leading to the given goal' do
      knowledge_base_inputs = <<~KB.split("\n")
        InPoland(x) AND Sklep(x) => Available(Pudliszki, x)
        Light(x) AND Sweet(x) => Like(x)
        Common(x) AND Sklep(y) => Available(x, y)
      KB

      goal = Parser.parse('Available(x, Tesco)', query: true)

      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)
      fetched_rules = knowledge_base.fetch_rules_for_goal(goal)

      in_poland_and_shop = fetched_rules.first.left.map(&:predicate).map(&:name)
      expect(in_poland_and_shop).to contain_exactly('InPoland', 'Sklep')

      common_and_shop = fetched_rules.last.left.map(&:predicate).map(&:name)
      expect(common_and_shop).to contain_exactly('Common', 'Sklep')
    end
  end

  describe '#ask' do
    it 'gives answers to the given query based on the given knowledge base' do
      query = 'Sklep(x) AND Dostepne(BelgijskaCzekolada, x)'
      knowledge_base_inputs = <<~KB.split("\n")
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
      answer = knowledge_base.ask(query)

      expect(answer.map(&:to_s)).to contain_exactly('Lidl', 'Lewiatan')
    end
  end
end
