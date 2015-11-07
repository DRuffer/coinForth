\ 'core.frt' generated automatically, do not edit
#include  q-negate.frt
#include  2over.frt
#include  2swap.frt
#include  aligned.frt
#include  align.frt
#include  blank.frt
#include  c-comma.frt
#include  char-plus.frt
#include  chars.frt
#include  dot-paren.frt
#include  environment-q.frt
#include  erase.frt
#include  evaluate.frt
#include  fm-slash-mod.frt
#include  star-slash.frt
#include  move.frt

#include  sm-slash-rem.frt
#include  source-id.frt
#include  to-body.frt
#include  find.frt

\ update the environment
get-current environment set-current
: core -1 ;
\ reset the definition word list
set-current
