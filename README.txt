rubyw_helper
    by James Tucker
    http://ra66i.org
    http://github.com/raggi/rubyw_helper

== DESCRIPTION:

A simple redirector for use when you just want to safely redirect stdio.
Simply encapsulates a few different safety mechanisms when redirecting stdio,
with the primary goal of making it easier to write apps that run under
rubyw.exe, where ruby loads with stdio closed.

Whilst the primary intention for use is under win32, and was actually
developed as an external helper for specifically win32-service usage, this gem
may be useful to some other folks on other platforms. It is not win32 
specific.

== FEATURES/PROBLEMS:

* Lacking any tertiary logging infrastructure specific to any platform.

== SYNOPSIS:

The following parameters are also the defaults:

  stdout = File.join(Dir.pwd, 'logs', "#{app_name}.stdout.log"),
  stderr = File.join(Dir.pwd, 'logs', "#{app_name}.stderr.log")
  stdin  = case RUBY_PLATFORM
           when /mingw|mswin/
             'NUL:'
           else
             '/dev/null'
           end

  helper = RubywHelper.new(stdout, stderr, stdin)

You achieve basic redirection if you wrap your runner for your program in the
with_redirection block:

  helper.with_redirection do
    puts "hello logfile!"
  end
  
Or you can simply just redirect them:

  helper.redirect_stdio!

For your convenience, there is also a method which attempts to see if it may
be a good idea to redirect stdio, in other words, it returns true if all of 
stdio is closed:

  helper.stdio_danger?

This typically returns true under rubyw.exe and any equivalents.

== REQUIREMENTS:

* Ruby
* gem inst exception_string

== INSTALL:

* gem inst rubyw_helper

== LICENSE:

(The MIT License)

Copyright (c) 2008 James Tucker

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
