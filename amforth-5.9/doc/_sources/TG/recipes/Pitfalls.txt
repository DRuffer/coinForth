
========
Pitfalls
========

Using Forth on a microcontroller is something different
to work on a PC. Some potential pitfalls are discussed here.

Memory content
--------------

On the PC restarting the Forth system resets the dictionary
content. On the microcontroller, the dictionary is unchanged,
but the RAM contents is totally different. You definitly need
a proper initialization phase for each and every byte in RAM.
Starting with version 5.9 amforth cleans all RAM content to
0, older version keep it unchanged.

Stack depth's
-------------

The standard stack depth is 40 cells for both return and
data stacks. A well written program may never reach that
limit. Using interrupts may cause trouble if they happen
in a nested way. For speed reason, amforth does not check
the stack depth's itself. You can check them with a marker
byte (e.g.$dead) at the stack limit that is checked
regularily.

