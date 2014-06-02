require 'models/team'
FactoryGirl.define do
  factory :team do
    sequence :team_id, 1 do |i| sprintf("%c%2.2d", league.id[0], i) end
    league
    name { "Test #{team_id} Team" }
  end
end
