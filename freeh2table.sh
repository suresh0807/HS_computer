sed -n '/   T        p       ln(qtrans) ln(qrot) ln(qvib) chem.pot.   energy    entropy/,/   T        P              Cv            Cp       enthalpy/p' freeh.out | tail -n+4| head -n-2 > a

sed -i 's/-Infinity-Infinity/     0.00     0.00/g' a

sed -n '/   T        P              Cv            Cp       enthalpy/,/freeh : all done/p' freeh.out | tail -n+3| head -n 201 > b

paste a b | awk '{printf "%2.5f      %2.5f      %2.5f      %2.5f      %2.5f\n", $1, $13-($1*$8), $8*1000, $11*1000, $13 }' > Table




