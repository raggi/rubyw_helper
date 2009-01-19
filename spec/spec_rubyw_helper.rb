require File.dirname(__FILE__) + '/helper'
require 'stringio'
require 'tempfile'

describe "RubywHelper" do

  def temp_io
    stdin = case RUBY_PLATFORM
    when /mingw|mswin/
      'NUL:'
    else
      '/dev/null'
    end
    tmp_io = %W(
    /tmp/rubyw_helper_test_stdout.log
    /tmp/rubyw_helper_test_stderr.log
    )
    tmp_io.each { |f| open(f, 'w') {} }
    yield tmp_io + [stdin]
  ensure
    tmp_io.each { |f| File.delete(f) }
  end

  should "have stdio_danger? when stdout, stderr, and stdin are closed" do
    $stdout, $stderr, $stdin = Array.new(3) { s = StringIO.new(''); s.close; s }
    RubywHelper.new.stdio_danger?.should.eql true
    $stdout, $stderr, $stdin = STDOUT, STDERR, STDIN
  end

  should "have stdio_danger? when stdout, stderr, and stdin are all nulled" do
    $stdout, $stderr, $stdin = Array.new(3) do
      s = StringIO.new('')
      def s.inspect
        '#<IO:NUL>'
      end
      s
    end
    RubywHelper.new.stdio_danger?.should.eql true
    $stdout, $stderr, $stdin = STDOUT, STDERR, STDIN
  end

  should "restore the old stdios" do
    oout, oerr, oin = $stdout, $stderr, $stdin
    h = RubywHelper.new
    $stdout, $stderr, $stdin = Array.new(3) do
      s = StringIO.new('')
      s.close
      s
    end
    h.restore_stdio!
    $stdout.should.eql oout
    $stderr.should.eql oerr
    $stdin.should.eql oin
  end

  should "redirect to the appropriate files and restore stdio afterward" do
    oout, oerr, oin = $stdout, $stderr, $stdin
    temp_io do |out, err, inn|
      h = RubywHelper.new(out, err, inn)
      h.with_redirection do
        $stdout.path.should.eql out
        $stderr.path.should.eql err
        $stdin.path.should.eql inn
        STDOUT.path.should.eql out
        STDERR.path.should.eql err
        STDIN.path.should.eql inn
        $stdout.puts "1234567890"
        $stderr.puts "1234567890"
        [$stdin, $stderr, $stdout].each { |io| io.close unless io.closed? }
      end
      $stdout.should.eql oout
      $stderr.should.eql oerr
      $stdin.should.eql oin
      STDOUT.should.eql oout
      STDERR.should.eql oerr
      STDIN.should.eql oin
      File.read(out).should.eql("1234567890\n")
      File.read(err).should.eql("1234567890\n")
    end
  end

end