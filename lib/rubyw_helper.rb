require 'fileutils'
require 'exception_string'

class RubywHelper

  Version = VERSION = '0.1.0'
  def self.version; Version; end

  app_name = File.basename($0)
  Defaults = {
    :out => File.join(Dir.pwd, 'logs', "#{app_name}.stdout.log"),
    :err => File.join(Dir.pwd, 'logs', "#{app_name}.stderr.log"),
    :in  => case RUBY_PLATFORM
            when /mingw|mswin/
              'NUL:'
            else
              '/dev/null'
            end
  }

  attr_reader :old_out, :old_err, :old_in

  # out replaces $stdout, err replaces $stderr, inn replaces $stdin, simple.
  # provide nils / false to use the Defaults
  def initialize(out = nil, err = nil, inn = nil)
    @stdout, @stderr = out || Defaults[:out], err || Defaults[:err]
    @stdin = inn || Defaults[:in]
    @old_out, @old_err, @old_in = $stdout, $stderr, $stdin
  end

  def stdio_danger?
    $stdout.closed? && $stderr.closed? && $stdin.closed?
  end

  # Takes a block, because under these conditions, it really helps developers
  # if best effort is made to try and log error conditions to the files before
  # leaving the process.
  def with_redirection
    ensure_files!
    redirect_stdio!
    yield
    restore_stdio!
  rescue Exception => exception
    fatal! exception.to_s_mri
  end

  # Sets up the global IO objects to point to where we want.
  def redirect_stdio!
    inn, out, err = open(@stdin), open(@stdout, 'a+'), open(@stderr, 'a+')
    no_warn do
      $stdin   = Object.const_set(:STDIN,  inn)
      $stdout  = Object.const_set(:STDOUT, out)
      $stderr  = Object.const_set(:STDERR, err)
    end
  end

  def restore_stdio!
    no_warn do
      $stdin   = Object.const_set(:STDIN,  @old_in)
      $stdout  = Object.const_set(:STDOUT, @old_out)
      $stderr  = Object.const_set(:STDERR, @old_err)
    end
  end

  private
  # Tries to create any containing directories, and errors out if we can't 
  # write to the outputs or read from the input.
  def ensure_files!
    fatal! "Cannot read from #{@stdin}" unless File.readable? @stdin
    [@stdout, @stderr].each do |f|
      dir = File.dirname(f)
      safely { FileUtils.mkdir_p(dir) unless File.directory?(dir) }
      next if File.writable? f
      fatal! "Cannot write to #{f}"
    end
  end

  # For each output io, safely wrap the given block, and yield the io.
  def safe_each
    [$stderr, $stdout].each { |io| safely { yield io } }
  end

  # Tries real hard to log the message, then exits with failure status.
  def fatal!(message)
    # Not using safe_each in case that caused an error.
    safely { $stdout.reopen(@stdout, 'a+'); $stdout.puts message }
    safely { $stderr.reopen(@stderr, 'a+'); $stderr.puts message }
    exit 1
  end

  # Ignores errors, which we might not be able to avoid.
  def safely
    yield
  rescue Exception
    nil
  end

  # Suppress warnings, most useful for constant redefinition.
  def no_warn
    verbose  = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = verbose
  end
end