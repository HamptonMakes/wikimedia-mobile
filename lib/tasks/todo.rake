require File.expand_path(File.dirname(__FILE__) + "/../../config/init")
 
namespace :todo do
  desc 'List TODOs in all .rb files under app/'
  task(:list) do
      FileList["app/**/*.rb"].egrep(/TODO/)
  end
 
  desc 'Edit all TODOs in VIM' # or your favorite editor
  task(:edit) do
      # jump to the first TODO in the first file
      cmd = 'vim +/TODO/' 
 
      filelist = []
      FileList["app/**/*.rb"].egrep(/TODO/) {|fn,cnt,line| filelist << fn}
 
      # will fork a new process and exit, if you're using gvim
      system("#{cmd} #{filelist.sort.join(' ')}") 
  end
end