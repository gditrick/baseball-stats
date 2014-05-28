require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/stats'

describe Stats do
  Given(:stats_klass) { Stats }
  Then { stats_klass.should respond_to(:sort_field) }

  Given(:invalid_sort_field) { Stats.sort_field(:xyz) } 
  Then { expect { invalid_sort_field }.to raise_error }

  describe "basic sorting attributes" do
    [:games, :at_bats, :runs, :hits, :doubles, :triples,
     :home_runs, :rbi, :stolen_bases, :caught_stealing].each do |prop|
      Given(:valid_basic_sort_field) { Stats.sort_field(prop) } 
      Then { expect { valid_basic_sort_field }.not_to raise_error }

    end
  end

  Given(:stats) { Stats.new(stats: BattingStat.all) }
  Then{ stats.class.superclass.should == Hashie::Dash }
  [:stats, :restrict, :players, :player_stats, :eligible_stats].each do |prop|
    Then{ stats.should respond_to(prop) }
  end

  Given(:sorted_subklass) { class A < Stats
                              sort_field :rbi
                            end
                            A.new(stats: BattingStat.all)
                          }
  [:_sort, :winner, :top, :rbi].each do |m|
    Then { sorted_subklass.should respond_to(m) }
  end
end
