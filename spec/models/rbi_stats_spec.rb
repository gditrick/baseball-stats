require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/rbi_stats'

describe RbiStats do

  it_should_behave_like "BasicStats"

  context ".new" do
    Given(:rbi_stat) { RbiStats.new(stats: BattingStat.all) }
    Then { rbi_stat.should respond_to(:total_rbi) }
  end
end
