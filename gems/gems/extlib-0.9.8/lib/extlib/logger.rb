require "time" # httpdate
# ==== Public Merb Logger API
#
# To replace an existing logger with a new one:
#  Merb::Logger.set_log(log{String, IO},level{Symbol, String})
#
# Available logging levels are
#   Merb::Logger::{ Fatal, Error, Warn, Info, Debug }
#
# Logging via:
#   Merb.logger.fatal(message<String>,&block)
#   Merb.logger.error(message<String>,&block)
#   Merb.logger.warn(message<String>,&block)
#   Merb.logger.info(message<String>,&block)
#   Merb.logger.debug(message<String>,&block)
#
# Logging with autoflush:
#   Merb.logger.fatal!(message<String>,&block)
#   Merb.logger.error!(message<String>,&block)
#   Merb.logger.warn!(message<String>,&block)
#   Merb.logger.info!(message<String>,&block)
#   Merb.logger.debug!(message<String>,&block)
#
# Flush the buffer to 
#   Merb.logger.flush
#
# Remove the current log object
#   Merb.logger.close
# 
# ==== Private Merb Logger API
# 
# To initialize the logger you create a new object, proxies to set_log.
#   Merb::Logger.new(log{String, IO},level{Symbol, String})
module Extlib

  class << self
    attr_accessor :logger
  end

  class Logger

    attr_accessor :level
    attr_accessor :delimiter
    attr_accessor :auto_flush
    attr_reader   :buffer
    attr_reader   :log
    attr_reader   :init_args

    # ==== Notes
    # Ruby (standard) logger levels:
    # :fatal:: An unhandleable error that results in a program crash
    # :error:: A handleable error condition
    # :warn:: A warning
    # :info:: generic (useful) information about system operation
    # :debug:: low-level information for developers
    Levels = 
    {
      :fatal => 7, 
      :error => 6, 
      :warn  => 4,
      :info  => 3,
      :debug => 0
    }

    private

    # Readies a log for writing.
    #
    # ==== Parameters
    # log<IO, String>:: Either an IO object or a name of a logfile.
    def initialize_log(log)
      close if @log # be sure that we don't leave open files laying around.

      if log.respond_to?(:write)
        @log = log
      elsif File.exist?(log)
        @log = open(log, (File::WRONLY | File::APPEND))
        @log.sync = true
      else
        FileUtils.mkdir_p(File.dirname(log)) unless File.directory?(File.dirname(log))
        @log = open(log, (File::WRONLY | File::APPEND | File::CREAT))
        @log.sync = true
        @log.write("#{Time.now.httpdate} #{delimiter} info #{delimiter} Logfile created\n")
      end
    end

    public

    # To initialize the logger you create a new object, proxies to set_log.
    #
    # ==== Parameters
    # *args:: Arguments to create the log from. See set_logs for specifics.
    def initialize(*args)
      @init_args = args
      set_log(*args)
    end

    # Replaces an existing logger with a new one.
    # 
    # ==== Parameters
    # log<IO, String>:: Either an IO object or a name of a logfile.
    # log_level<~to_sym>::
    #   The log level from, e.g. :fatal or :info. Defaults to :error in the
    #   production environment and :debug otherwise.
    # delimiter<String>::
    #   Delimiter to use between message sections. Defaults to " ~ ".
    # auto_flush<Boolean>::
    #   Whether the log should automatically flush after new messages are
    #   added. Defaults to false.
    def set_log(log, log_level = nil, delimiter = " ~ ", auto_flush = false)
      if log_level && Levels[log_level.to_sym]
        @level = Levels[log_level.to_sym]
      elsif Merb.environment == "production"
        @level = Levels[:warn]
      else
        @level = Levels[:debug]
      end
      @buffer     = []
      @delimiter  = delimiter
      @auto_flush = auto_flush

      initialize_log(log)

      Merb.logger = self
    end

    # Flush the entire buffer to the log object.
    def flush
      return unless @buffer.size > 0
      @log.write(@buffer.slice!(0..-1).to_s)
    end

    # Close and remove the current log object.
    def close
      flush
      @log.close if @log.respond_to?(:close) && !@log.tty?
      @log = nil
    end

    # Appends a message to the log. The methods yield to an optional block and
    # the output of this block will be appended to the message.
    #
    # ==== Parameters
    # string<String>:: The message to be logged. Defaults to nil.
    #
    # ==== Returns
    # String:: The resulting message added to the log file.
    def <<(string = nil)
      message = ""
      message << delimiter
      message << string if string
      message << "\n" unless message[-1] == ?\n
      @buffer << message
      flush if @auto_flush

      message
    end
    alias :push :<<

    # Generate the logging methods for Merb.logger for each log level.
    Levels.each_pair do |name, number|
      class_eval <<-LEVELMETHODS, __FILE__, __LINE__

      # Appends a message to the log if the log level is at least as high as
      # the log level of the logger.
      #
      # ==== Parameters
      # string<String>:: The message to be logged. Defaults to nil.
      #
      # ==== Returns
      # self:: The logger object for chaining.
      def #{name}(message = nil)
        self << message if #{number} >= level
        self
      end

      # Appends a message to the log if the log level is at least as high as
      # the log level of the logger. The bang! version of the method also auto
      # flushes the log buffer to disk.
      #
      # ==== Parameters
      # string<String>:: The message to be logged. Defaults to nil.
      #
      # ==== Returns
      # self:: The logger object for chaining.
      def #{name}!(message = nil)
        self << message if #{number} >= level
        flush if #{number} >= level
        self
      end

      # ==== Returns
      # Boolean:: True if this level will be logged by this logger.
      def #{name}?
        #{number} >= level
      end
      LEVELMETHODS
    end

  end
  
end
