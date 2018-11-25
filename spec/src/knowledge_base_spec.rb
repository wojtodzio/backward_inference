RSpec.describe KnowledgeBase do
  describe '#fetch_rules_for_goal' do
    it 'can find atomic facts leading to the given goal' do
      knowledge_base_inputs = <<~KB.split("\n")
        Shop(Lewiatan)
        Polish(Groszek)
        Shop(Groszek)
      KB

      goal = Parser.parse('Shop(x)', query: true).first

      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)
      expect(knowledge_base.fetch_rules_for_goal(goal)).to contain_exactly(
        Parser.parse('Shop(Lewiatan)'),
        Parser.parse('Shop(Groszek)')
      )
    end

    it 'can find clauses leading to the given goal' do
      knowledge_base_inputs = <<~KB.split("\n")
        InPoland(x) AND Shop(x) => Available(Pudliszki, x)
        Light(x) AND Sweet(x) => Like(x)
        Common(x) AND Shop(y) => Available(x, y)
      KB

      goal = Parser.parse('Available(x, Tesco)', query: true).first

      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)
      fetched_rules = knowledge_base.fetch_rules_for_goal(goal)

      in_poland_and_shop = fetched_rules.first.left.map(&:predicate).map(&:name)
      expect(in_poland_and_shop).to contain_exactly('InPoland', 'Shop')

      common_and_shop = fetched_rules.last.left.map(&:predicate).map(&:name)
      expect(common_and_shop).to contain_exactly('Common', 'Shop')
    end
  end

  describe '#ask' do
    it 'gives answers to the given query if there is an atomic fact with the answer' do
      knowledge_base = KnowledgeBase.new(['Knows(John, Jane)'])

      answers = knowledge_base.ask('Knows(John, x)')

      expect(answers.map(&:to_s)).to contain_exactly('Knows(John, Jane)')
    end

    it 'gives answers to the given query if there are multiple atomic facts with the answer' do
      knowledge_base_inputs = <<~KB.split("\n")
        Knows(John, Juliet)
        Knows(Wojtek, Michal)
        Knows(John, Jane)
        Knows(Cezar, Kleopatra)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('Knows(John, x)')

      expect(answers.map(&:to_s)).to contain_exactly('Knows(John, Juliet)', 'Knows(John, Jane)')
    end

    it 'gives no answers if there are no valid substitutions' do
      knowledge_base_inputs = <<~KB.split("\n")
        Knows(John, Juliet)
        Knows(Wojtek, Michal)
        Knows(John, Jane)
        Knows(Cezar, Kleopatra)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('Knows(Marcel, x)')

      expect(answers.map(&:to_s)).to be_empty
    end

    it 'gives answers to the given query if it was given in the AND clause' do
      knowledge_base_inputs = <<~KB.split("\n")
        Knows(John, Juliet) AND Knows(Wojtek, Michal) AND Knows(John, Jane) AND Knows(Cezar, Kleopatra)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('Knows(John, x)')

      expect(answers.map(&:to_s)).to contain_exactly('Knows(John, Juliet)', 'Knows(John, Jane)')
    end

    it 'gives answers to the given query if it is implied' do
      knowledge_base_inputs = <<~KB.split("\n")
        IsNice(PW)
        IsNice(x) => InPoland(x)
        IsNice(Warsaw)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('IsNice(x)')

      expect(answers.map(&:to_s)).to contain_exactly('IsNice(PW)', 'IsNice(Warsaw)')
    end

    it "gives answers to a query if it is implied multiple times and there're facts with answer" do
      knowledge_base_inputs = <<~KB.split("\n")
        InCity(Warsaw, PW)
        InCity(x, PW) => InPoland(x)
        InCity(x, PalacKultury) => IsCapital(x)
        InCity(Warsaw, PalacKultury)
        InPoland(x) AND IsCapital(x) => HaveAirport(x)
        HaveAirport(Katowice)
        InPoland(Katowice)
        InPoland(Krakow) AND HaveAirport(Krakow)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('HaveAirport(x) AND InPoland(x)')

      expect(answers.map(&:to_s)).to contain_exactly('HaveAirport(Warsaw) AND InPoland(Warsaw)',
                                                     'HaveAirport(Katowice) AND InPoland(Katowice)',
                                                     'HaveAirport(Krakow) AND InPoland(Krakow)')
    end

    it 'avoids loops' do
      knowledge_base_inputs = <<~KB.split("\n")
        Equal(x, y) => Equal(y, x)
        Equal(Warsaw, PolandCapital)
        Equal(x, Warsaw) => InPoland(x)
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('InPoland(x)')

      expect(answers.map(&:to_s)).to contain_exactly('InPoland(PolandCapital)')
    end

    it 'can use nested predicates' do
      knowledge_base_inputs = <<~KB.split("\n")
        Knows(x, Mom(x))
        Knows(x, Dad(x))
      KB
      knowledge_base = KnowledgeBase.new(knowledge_base_inputs)

      answers = knowledge_base.ask('Knows(John, y)')

      expect(answers.map(&:to_s)).to contain_exactly(
        'Knows(John, Mom(John))',
        'Knows(John, Dad(John))'
      )
    end
  end
end
