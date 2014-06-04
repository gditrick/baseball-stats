require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
describe Player do
  Then { should respond_to(:batting_stats) }
  And  { should respond_to(:name) }

  context "#name" do
    Given(:player) { create(:player, id: 'P1', first_name: "Joe", last_name: "Smith") }
    When(:name) { player.name }
    Then { expect(name).to eql('Smith, Joe') }
  end
end
