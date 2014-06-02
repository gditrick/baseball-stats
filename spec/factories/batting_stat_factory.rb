require 'models/batting_stat'
FactoryGirl.define do
  factory :batting_stat do
    trait :with_nil_data do
      games           nil
      at_bats         nil
      runs            nil 
      hits            nil
      doubles         nil
      triples         nil
      home_runs       nil
      rbi             nil
      stolen_bases    nil
      caught_stealing nil
    end

    trait :with_zero_data do
      games           0
      at_bats         0
      runs            0
      hits            0
      doubles         0
      triples         0
      home_runs       0
      rbi             0
      stolen_bases    0
      caught_stealing 0
    end
  end
end
