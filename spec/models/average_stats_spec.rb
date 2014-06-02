require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/average_stats'

describe AverageStats do

  it_should_behave_like "BasicStats"

  context ".new" do
    Given(:avg_stat) { AverageStats.new(stats: BattingStat.all) }
    Then { avg_stat.should respond_to(:average) }
  end
end
