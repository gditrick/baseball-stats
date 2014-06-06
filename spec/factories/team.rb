FactoryGirl.define do
  factory :team do
    sequence :team_id, 1 do |i| league.nil? ? make_team_id("AL", i) : make_team_id(league.id, i) end
    league
    name { "Test #{team_id} Team" }
  end
end
