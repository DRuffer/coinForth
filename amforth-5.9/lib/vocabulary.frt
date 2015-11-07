\ create a vocabulary, at runtime replace
\ the first entry in the search-list
: vocabulary ( "char" -- )
    <builds
      wordlist ,
    does>
      @i >r
      get-order nip
      r> swap
      set-order
;
