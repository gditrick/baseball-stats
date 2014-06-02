require 'models/league'
FactoryGirl.define do
  factory :league do
    id "TL"
    name { "Test #{id} League" }

    factory :league_with_teams do
      ignore do
        teams_count 5
      end

      after(:create) do |league, evaluator|
        evaluator.teams_count.times do |i|
          team_id = sprintf("%c%2.2d", league.id[0], i+1)
          FactoryGirl.create(:team, league: league, team_id: team_id)
        end
      end
    end
  end
end
