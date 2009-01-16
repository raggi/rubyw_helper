load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'rubyw_helper'

task :default => 'spec:run'

PROJ.name = 'rubyw_helper'
PROJ.authors = 'James Tucker'
PROJ.email = 'raggi@rubyforge.org'
PROJ.url = 'http://github.com/raggi/rubyw_helper'
PROJ.rubyforge.name = 'libraggi'
PROJ.version = RubywHelper.version

PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.git \.hg \.svn ^pkg ^doc \.DS_Store \.cvs
  \.svn \.hgignore \.gitignore \.dotest \.swp$ ~$ \.bin$ \.h$ \.rc$ \.res$)
