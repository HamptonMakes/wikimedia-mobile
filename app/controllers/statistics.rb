class Statistics < Application
  layout false

  def index
    render
  end
  
  def parse
    render `cat #{Merb::Config[:log_file]} | grep ReqLogger`, :layout => false
  end
  
end
