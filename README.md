# funk
more Functional Programming for LuaJIT

Origin Story
------------
funk is in essence a recreation of some functional programming routines
from the [luafun](https://luafun.github.io/) project.  You can look there for documentation on all
the various functions.

Why recreate?
* To play with new concepts and approaches without disturbing the original.

Why not fork?
* no need to confuse things
* this is not a drop in replacement as it relies on LuaJIT

Why not pull requests?
* want to move faster than original project
* want to have clear split
* want to follow different design constraints
* want to introduce new lines of thinking on the subject

Design constraints
------------------
* Do not want any usage of 'assert' or 'error', use return values
* Do not have aliases for function names, name them one thing
* Support for luajit ctype objects
* revisit, reaffirm, challenge some assumptions
* implement some stuff not in luafun


Notable Additions
=================
The original luafun is generic lua code, so it does not have a dependency
on LuaJIT.  It performs well because the JIT will transform it into some
well constructed iteration code.

<emphasis>cdata support</emphasis> - funk is different in that it explicitly relies on LuaJIT.  In particular the rawiter() function has provision for iterating over cdata arrays.
This is great because it makes iterating over file input (memory mapped)
just as easy as iterating over strings.  This makes the whole kit very
useful for file parsing, without having to load everything into the
limited LuaJIT memory model.

<emphasis>Namespace handling</emphasis> - Not strictly a part of the library, but namespace.lua in 
the test directory shows how to import the routines into a local namespace.
This makes it really convenient to call the various functions as if they 
were global, without actually polluting the actual global namespace.

Experiments
===========
The original approach was to replicate the functional programming interface, but use
lua coroutines as iterators instead of the gen/param/state approach.  It turned out to be
more challenging and limiting that the original approach, so it was abandoned.  Some of the 
code is still sitting in the funkit.lua file for posterity.

finq - Looking at the LinQ interfaces, finq is an experiment in implementing that kind
of interface.  There are large parts of funk that translate directly to finq, and finq
introduces some new things, like 'unique'.  For the most part, finq introduces things that
make you store all data in memory, whereas most of funk is more stream processing, iterators
with very little intermediate storage.

At some point, finq might become more complete as it's very useful for doing typical
database programming, as the original LinQ was meant to be.

Copyright - William Adams 2019  
=========
The code here was recreated, not copied, so it is NOT bug compatible with 
the original luafun.  It introduces a whole new set of bugs.
