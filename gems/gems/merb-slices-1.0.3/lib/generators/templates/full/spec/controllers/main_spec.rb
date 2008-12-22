require File.dirname(__FILE__) + '/../spec_helper'

describe "<%= module_name %>::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { add_slice(:<%= module_name %>) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should have access to the slice module" do
    controller = dispatch_to(<%= module_name %>::Main, :index)
    controller.slice.should == <%= module_name %>
    controller.slice.should == <%= module_name %>::Main.slice
  end
  
  it "should have an index action" do
    controller = dispatch_to(<%= module_name %>::Main, :index)
    controller.status.should == 200
    controller.body.should contain('<%= module_name %>')
  end
  
  it "should work with the default route" do
    controller = get("/<%= base_name %>/main/index")
    controller.should be_kind_of(<%= module_name %>::Main)
    controller.action_name.should == 'index'
  end
  
  it "should work with the example named route" do
    controller = get("/<%= base_name %>/index.html")
    controller.should be_kind_of(<%= module_name %>::Main)
    controller.action_name.should == 'index'
  end
    
  it "should have a slice_url helper method for slice-specific routes" do
    controller = dispatch_to(<%= module_name %>::Main, 'index')
    
    url = controller.url(:<%= symbol_name %>_default, :controller => 'main', :action => 'show', :format => 'html')
    url.should == "/<%= base_name %>/main/show.html"
    controller.slice_url(:controller => 'main', :action => 'show', :format => 'html').should == url
    
    url = controller.url(:<%= symbol_name %>_index, :format => 'html')
    url.should == "/<%= base_name %>/index.html"
    controller.slice_url(:index, :format => 'html').should == url
    
    url = controller.url(:<%= symbol_name %>_home)
    url.should == "/<%= base_name %>/"
    controller.slice_url(:home).should == url
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(<%= module_name %>::Main, :index)
    controller.public_path_for(:image).should == "/slices/<%= base_name %>/images"
    controller.public_path_for(:javascript).should == "/slices/<%= base_name %>/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/<%= base_name %>/stylesheets"
    
    controller.image_path.should == "/slices/<%= base_name %>/images"
    controller.javascript_path.should == "/slices/<%= base_name %>/javascripts"
    controller.stylesheet_path.should == "/slices/<%= base_name %>/stylesheets"
  end
  
  it "should have a slice-specific _template_root" do
    <%= module_name %>::Main._template_root.should == <%= module_name %>.dir_for(:view)
    <%= module_name %>::Main._template_root.should == <%= module_name %>::Application._template_root
  end

end