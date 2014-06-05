require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")

describe Stats do

  it_should_behave_like "BasicStats"

  Given(:subklass) { class Stats::A < Stats
                       sort_field :rbi
                     end
                   }
  Then { expect { subklass }.not_to raise_error }

  When(:new_subklass) { Stats::A.new(stats: BattingStat.all) }
  [:_sort, :winner, :top, :rbi].each do |m|
    Then { new_subklass.should respond_to(m) }
  end
end
