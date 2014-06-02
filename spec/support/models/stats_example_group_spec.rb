require 'models/stats'

shared_examples_for "BasicStats" do
  Then { respond_to(:sort_field) }
  Then { respond_to(:stats) }
  Then { respond_to(:restrict) }
  Then { respond_to(:players) }
  Then { respond_to(:player_stats) }
  Then { respond_to(:eligible_stats) }

  context ".sort_field" do
    describe "invalid sort attribute" do
      Given(:invalid_sort_field) { Stat.sort_field(:xyz) }
      Then { expect { invalid_sort_field }.to raise_error }
    end

    describe "valid sorting attributes" do
      [:games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs, :rbi,
       :stolen_bases, :caught_stealing, :average, :slugging].each do |prop|
        Given(:valid_sort_field) { Stats.sort_field(prop) } 
        Then { expect { valid_sort_field }.not_to raise_error }
      end
    end
  end

  context ".new" do
    Given(:not_given_stats) { Stats.new }
    Then { expect { not_given_stats }.to raise_error }

    Given(:given_stats) { Stats.new(stats: BattingStat.all) }
    Then{ given_stats.class.superclass.should == Hashie::Dash }

    [:stats, :restrict, :players, :player_stats, :eligible_stats].each do |prop|
      And{ given_stats.should respond_to(prop) }
    end
  end
end
