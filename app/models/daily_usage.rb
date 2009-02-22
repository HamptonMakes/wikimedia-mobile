class DailyUsage
  include DataMapper::Resource
  
  property :id, Serial
  property :date, DateTime
  property :count, Integer, :default => 0


  def self.find_or_create(date)
    DailyUsage.first(:date => date) || DailyUsage.new(:date => date)
  end
  
  def increment
    self.count = (self.count || 0) + 1
  end
end
