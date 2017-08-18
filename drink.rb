require 'date'

class Drink
  attr_reader :expiration_date
  
  def initialize(year, month, date)
    @expiration_date = Date.new(year, month, date)
  end
  
end
