shared_examples_for "BasicMostImprovedStats" do

  it_should_behave_like "BasicStats"

  Then { respond_to(:prev_stats) }

  context ".new" do
    Given(:not_given_stats) { MostImprovedStats.new }
    Then { expect { not_given_stats }.to raise_error }

    Given(:given_stats) { MostImprovedStats.new(stats: BattingStat.all) }
    Then { expect { given_stats }.to raise_error }

    Given(:given_prev_stats) { MostImprovedStats.new(prev_stats: BattingStat.all) }
    Then { expect { given_prev_stats }.to raise_error }

    Given(:given_stats_prev_stats) { MostImprovedStats.new(stats: BattingStat.all, prev_stats: BattingStat.all) }
    Then { expect { given_stats_prev_stats }.not_to raise_error }

    [:prev_stats].each do |prop|
      And{ given_stats_prev_stats.should respond_to(prop) }
    end
  end
end
