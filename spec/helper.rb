# Disable test/unit and rspec from running, in case loaded by broken tools.
Test::Unit.run = false if defined?(Test) && defined?(Test::Unit)
Spec::run = false if defined?(Spec) && Spec::respond_to?(:run=)

# Setup a nice testing environment
$DEBUG, $TESTING = true, true
$:.push File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.uniq!

%w[rubygems bacon].each { |r| require r }

# Bacon doesn't do any automagic, so lets tell it to!
Bacon.summary_on_exit

require File.expand_path(
  File.join(File.dirname(__FILE__), %w[.. lib rubyw_helper]))
