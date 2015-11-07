\ redefine (, still buggy
: (
   begin
     >in @ [char] ) parse nip
     >in @ rot - = \ something found?
   while
       refill 0=
       if
        abort" refill while searching ) failed"
       then
   repeat ; immediate
