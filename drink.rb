require 'date'

class Drink
  attr_reader :expiration_date
  
  def initialize(year, month, date)
    date = Date.new(year, month, date)
    @expiration_date = date
  end
  
end
