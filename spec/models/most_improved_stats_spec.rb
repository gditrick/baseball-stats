require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")

describe MostImprovedStats do

  it_should_behave_like "BasicMostImprovedStats"

  Given(:subklass) { class MostImprovedStats::A < MostImprovedStats
                       sort_field :rbi
                     end
                   }
  Then { expect { subklass }.not_to raise_error }

  When(:new_subklass) { MostImprovedStats::A.new(stats: BattingStat.all, prev_stats: BattingStat.all) }
  [:_sort, :winner, :most_improved, :top, :rbi].each do |m|
    Then { new_subklass.should respond_to(m) }
  end
end
