require 'models/player'
FactoryGirl.define do
  factory :player do
    sequence :id do |i| sprintf("test%2.2d", i) end
    birth_year '1980'
  end
end
