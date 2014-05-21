class Player < Sequel::Model
  plugin :timestamps

  one_to_many :batting_stats


  def name
    self.last_name + ', ' + self.first_name
  end
end
