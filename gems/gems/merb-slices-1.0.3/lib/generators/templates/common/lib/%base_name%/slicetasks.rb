namespace :slices do
  namespace :<%= symbol_name %> do 
    
    # add your own <%= base_name %> tasks here
    
    # implement this to test for structural/code dependencies
    # like certain directories or availability of other files
    desc "Test for any dependencies"
    task :preflight do
    end
    
    # implement this to perform any database related setup steps
    desc "Migrate the database"
    task :migrate do
    end
    
  end
end