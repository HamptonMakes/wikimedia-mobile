class Information < Application

  def donate
    @title = "Donate to Wikipedia"
    params[:footmenu] = "false"
    render
  end
  def disable
    @title = ""
    @path = params[:title] || ""
    params[:footmenu] = "false"
    render
  end

end
