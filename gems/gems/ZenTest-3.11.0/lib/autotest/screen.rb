##
# Autotest::Screen is test result notify GNU Screen's statusline.
#
# === screenshots
# * <img src="http://f.hatena.ne.jp/images/fotolife/s/secondlife/20061109/20061109015543.png" />
# * <img src="http://f.hatena.ne.jp/images/fotolife/s/secondlife/20061109/20061109015522.png" />
#
# == SYNOPSIS
#   require 'autotest/screen'
#   # Autotest::Screen.statusline = '%H %`%-w%{=b bw}%n %t%{-}%+w (your statusline)'
#

class Autotest::Screen
  DEFAULT_STATUSLINE = '%H %`%-w%{=b bw}%n %t%{-}%+w'
  DEFAULT_SCREEN_CMD = 'screen'

  SCREEN_COLOR = {
    :black => 'dd',
    :green => 'gk',
    :red   => 'rw',
  }

  def self.message(msg, color = :black)
    col = SCREEN_COLOR[color]
    msg = %Q[ %{=b #{col}} #{msg} %{-}]
    send_cmd(msg)
  end

  def self.clear
    send_cmd('')
  end

  def self.run_screen_session?
    str = `#{screen_cmd} -ls`
    str.match(/(\d+) Socket/) && ($1.to_i > 0)
  end

  def self.execute?
    !($TESTING || !run_screen_session?)
  end

  @statusline, @screen_cmd = nil
  def self.statusline; @statusline || DEFAULT_STATUSLINE.dup; end
  def self.statusline=(a); @statusline = a; end
  def self.screen_cmd; @screen_cmd || DEFAULT_SCREEN_CMD.dup; end
  def self.screen_cmd=(a); @screen_cmd = a; end

  def self.send_cmd(msg)
    cmd = %(#{screen_cmd} -X eval 'hardstatus alwayslastline "#{(statusline + msg).gsub('"', '\"')}"') #' stupid ruby-mode
    system cmd
  end

  Autotest.add_hook :run do  |at|
    message 'Run Tests' if execute?
  end

  Autotest.add_hook :quit do |at|
    clear if execute?
  end

  Autotest.add_hook :ran_command do |at|
    if execute? then
      output = at.results.join
      failed = output.scan(/^\s+\d+\) (?:Failure|Error):\n(.*?)\((.*?)\)/)
      if failed.size == 0 then
        message "All Green", :green
      else
        f,e = failed.partition { |s| s =~ /Failure/ }
        message "Red F:#{f.size} E:#{e.size}", :red
      end
    end
  end
end
