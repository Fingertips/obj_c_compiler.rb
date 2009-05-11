# Obj-C Compiler for Ruby

The ObjCCompiler module compiles your Obj-C classes into bundles and
requires them so you can use them from Ruby.

There are a number of ways to load classes defined from Cocoa into Ruby. The
solution presented here works best if the classes written in Obj-C are also
meant to be used from Ruby. The solution requires RubyCocoa and assumes that
you've written your application using Rucola.

# Example

Let's assume you're working on a project that implements a Match class that
wraps SearchKit matches. And you have a <tt>match.m</tt> somewhere in your
lib directory.

Your implementation needs one extra line, this function is invoked by the
Ruby interpreter when you try to load a bundle.

### lib/search_kit/match.m
<pre><code>void Init_Match() {}</code></pre>

After that you need to

1. Compile your code to a bundle
2. require the code
3. Import the class into the namespace

We've wrapped these three steps into one method.

### test/unit/match_test.rb
<pre><code>ObjCCompiler.require('lib/search_kit/match', 'WebKit')</code></pre>

Sometimes you might want to write a part of the class in Ruby, note that
your Obj-C class ended up in the OSX namespace, so you might need to
assign it to a new constant.

### lib/search_kit/match.rb
<pre><code>module SearchKit
  Match = OSX::Match
  
  class Match < OSX::NSObject
    def inspect
      "#&lt;SearchKit::Match:#{object_id} score=#{score}&gt;"
    end
  end
end
</code></pre>

Copyright © 2009 Fingertips,
  Eloy Duran <eloy@fngtps.com>,
  Manfred Stienstra <manfred@fngtps.com>