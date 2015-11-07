
begin-structure hash
    field: hash.key
    field: hash.value
end-structure

\ inspired by CELLS
: hash-cells hash * ;

\ define a hash-array
: hash:
     hash-cells buffer:
   does>
     swap hash-cells  + 
;

\ define an array of some elements hash'es
4 hash: my-hash
cr 0 my-hash .
cr 1 my-hash .

\ store a key/value pair 
42 3 my-hash hash.key !
4711 3 my-hash hash.value !
