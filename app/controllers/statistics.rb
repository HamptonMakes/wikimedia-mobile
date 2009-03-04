require 'gchart'

class Statistics < Application
  layout false

  def index
    @daily_usages = DailyUsage.all(:order => ["date"])
    @counts = @daily_usages.collect {|d| d.count}
    render
  end
  
  def parse
    redirect "/statistics/index"
  end
  
end
