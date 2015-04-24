
Recognizers
===========

The goal of a recognizer is to dynamically extent the Forth 
command interpreter and make it understand and handle new data 
formats as well as new synatax's. The present, 2nd generation
recognizers achieve this by generalizing the classic interpreter 
with an API to factor the components. Recognizers are portable 
across different forth's.

Recognizers are not a new concept for forth. They have been
discussed earlier.

* `compgroups.net/comp.lang.forth/additional-recognizers/734676 <http://compgroups.net/comp.lang.forth/additional-recognizers/734676>`__
  in 2003.
* `Number Parsing Hooks <https://groups.google.com/d/msg/comp.lang.forth/r7Vp3w1xNus/Wre1BaKeCvcJ>`__
  in 2007.
* Recent developments were presented at the `Euroforth conference 2012 <http://www.complang.tuwien.ac.at/anton/euroforth/ef12/papers/paysan-recognizers-ho.pdf>`__

The `1st formal RFD </pr/Recognizer-rfc.pdf>`__  (3.10.2014) is available.
A `Draft of Version 2 </pr/Recognizer-rfc-B.pdf>`__ (9.1.2015) is
currently beeing worked on. It incorporates the results of the discussions
and some more ideas.

The papers linked below give some background information and
describe the concept. Examples can be found in the code base.

* `First Generation </pr/Recognizer-en.pdf>`__ is an all in one implementation.
* `Second Generation </pr/Recognizer2-en.pdf>`__ describes the factored component 
  approach.
