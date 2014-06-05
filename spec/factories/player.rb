FactoryGirl.define do
  factory :player do
    sequence :id do |i| "test%3.3d" % i end
    sequence :first_name do |i| "First%3.3d" % i end
    sequence :last_name do |i| "Last%3.3d" % i end
    birth_year '1980'
  end
end
