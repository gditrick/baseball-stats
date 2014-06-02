require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/home_run_stats'

describe HomeRunStats do

  it_should_behave_like "BasicStats"

  context ".new" do
    Given(:hr_stat) { HomeRunStats.new(stats: BattingStat.all) }
    Then { hr_stat.should respond_to(:total_home_runs) }
  end
end
