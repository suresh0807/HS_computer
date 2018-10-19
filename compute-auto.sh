#!/bin/bash

##### Suresh Kondati Natarajan  ####
#####Tyndall National Institute ####
#####        2018               ####

#USAGE:
# ./compute-auto.sh x y a A b B c C d D nR nP pR pP N
# here- x, y are number of reactants and products
# a, b, c, d are reaction coefficients
# A, B, C, D are the molecules/bulk/surface
# nR, nP are the number of reactant and product molecules to be considered for pressure calculation
# pR, pP are the partial pressure of reactants and products
# N is the normalization coefficient
# Is it alright to include bulk and surface species in the pressure terms?



# get the number of reactants R and products P and print them
R=`echo "$1"`
P=`echo "$2"`
echo "$R -> $P"

# create a string 'eqn' with the equation of the reaction for the file creation

for((i=3;i<=($R+$P)*2+2;i+=2)); do 
dum=`echo "$i+1" | bc` 
dum1=`echo "$R*2+1" | bc`  
dum2=`echo "($R+$P)*2" | bc` 
if [ "$R" == 1 ] && [ "$i" == 3 ]
then 
printf  "${!i}${!dum}---" > eqn
elif [ "$R" -gt 1 ]  && [ "$i" -eq "$dum1" ] 
then
printf  "${!i}${!dum}---" >> eqn
elif [ "$R" -gt 1 ]  && [ "$i" == 3 ]
then
printf  "${!i}${!dum}+" > eqn
elif [ "$i" -gt "$dum2" ]  
then 
printf  "${!i}${!dum}" >> eqn
else  
printf  "${!i}${!dum}+" >> eqn
fi 
done



eqn=`cat eqn`

echo "$eqn"

# write separate files for each reactant ad product containing their H TS and E values

for((i=1;i<=$R;i++))
do
	dum=`echo "$i*2+1" | bc`
	dum1=`echo "$i*2+2" |bc`
	ee=`awk -v aa=${!dum}    '{if(NR == 1){ print $1*aa}}' ${!dum1}/Table`
	zpe=`awk -v aa=${!dum}    '{if(NR == 2){ print $5*aa/96.485}}' ${!dum1}/Table`
	echo "${!dum}  ${!dum1} $ee"
	awk -v aa=${!dum} -v E=$ee  -v ZP=$zpe '{if(NR != 1){ print $1" "E" "E+ZP" "(($1*$3*aa*0.001)/96.485)" "(($5*aa)/96.485)-ZP" "E+ZP-(($1*$3*aa*0.001)/96.485)+(($1*$4*aa*0.001)/96.485)" "E+(($2*aa)/96.485) }}' ${!dum1}/Table > R$i
done

for((i=1;i<=$P;i++))
do
	dum=`echo "$i*2+$R*2+1" | bc`
	dum1=`echo "$i*2+$R*2+2" |bc`
	ee=`awk -v aa=${!dum}    '{if(NR == 1){ print $1*aa}}' ${!dum1}/Table`
        zpe=`awk -v aa=${!dum}    '{if(NR == 2){ print $5*aa/96.485}}' ${!dum1}/Table`
	echo "${!dum}  ${!dum1} $ee"
	awk -v aa=${!dum} -v E=$ee  -v ZP=$zpe '{if(NR != 1){ print $1" "E" "E+ZP" "(($1*$3*aa*0.001)/96.485)" "(($5*aa)/96.485)-ZP" "E+ZP-(($1*$3*aa*0.001)/96.485)+(($1*$4*aa*0.001)/96.485)" "E+(($2*aa)/96.485)}}' ${!dum1}/Table > P$i
done

# create string for the files to be used in the calculation of free energies

for((i=1;i<=$R;i++))
do
if [ $i -eq 1 ]
then
printf "R%i " "$i" > eqn
else
printf "R%i " "$i" >> eqn
fi
done

for((i=1;i<=$P;i++))
do
printf "P%i " "$i" >> eqn
done

all=`cat eqn`
echo "$all"

#pressure term computation


nR=`echo "($R+$P)*2+3" |bc -l`
nP=`echo "($R+$P)*2+4" | bc -l`
pR=`echo "($R+$P)*2+5" |bc -l`
pP=`echo "($R+$P)*2+6" | bc -l`
scale=`echo "($R+$P)*2+7" | bc -l`
echo "${!nR} (${!pR}) --> ${!nP} (${!pP})"

#paste $all | awk -v r=$R -v p=$P -v prP=${!pP} -v prR=${!pR} -v nrP=${!nP} -v nrR=${!nR} -v ss=${!scale} '{ x=0; y=0; a=0; b=0; c=0; d=0; e=0; f=0; g=0; h=0; ax=0; by=0; for(i=2;i<=r*7;i+=7) x=x+$i ; for(i=(r*7)+2;i<=(r*7)+(p*7);i+=7) y=y+$i ; for(i=3;i<=r*7;i+=7) a=a+$i ; for(i=(r*7)+3;i<=(r*7)+(p*7);i+=7) b=b+$i ; for(i=4;i<=r*7;i+=7) c=c+$i ; for(i=(r*7)+4;i<=(r*7)+(p*7);i+=7) d=d+$i ; for(i=5;i<=r*7;i+=7) e=e+$i ; for(i=(r*7)+5;i<=(r*7)+(p*7);i+=7) f=f+$i ; for(i=6;i<=r*7;i+=7) g=g+$i ; for(i=(r*7)+6;i<=(r*7)+(p*7);i+=7) h=h+$i ; for(i=7;i<=r*7;i+=7) ax=ax+$i ; for(i=(r*7)+7;i<=(r*7)+(p*7);i+=7) by=by+$i ;print $1" "(y-x)/ss" "(b-a)/ss" "(d-c)/ss" "(8.314*(0.00001036)*$1*log(((prP/750)^nrP)/((prR/750)^nrR)))/ss" "(f-e)/ss" "(h-g+(8.314*(0.00001036)*$1*log(((prP/750)^nrP)/((prR/750)^nrR))))/ss" "(by-ax+(8.314*(0.00001036)*$1*log(((prP/750)^nrP)/((prR/750)^nrR))))/ss }' >F_$eqn
paste $all | awk -v r=$R -v p=$P -v prP=${!pP} -v prR=${!pR} -v nrP=${!nP} -v nrR=${!nR} -v ss=${!scale} '{ x=0; y=0; a=0; b=0; c=0; d=0; e=0; f=0; g=0; h=0; ax=0; by=0; for(i=2;i<=r*7;i+=7) x=x+$i ; for(i=(r*7)+2;i<=(r*7)+(p*7);i+=7) y=y+$i ; for(i=3;i<=r*7;i+=7) a=a+$i ; for(i=(r*7)+3;i<=(r*7)+(p*7);i+=7) b=b+$i ; for(i=4;i<=r*7;i+=7) c=c+$i ; for(i=(r*7)+4;i<=(r*7)+(p*7);i+=7) d=d+$i ; for(i=5;i<=r*7;i+=7) e=e+$i ; for(i=(r*7)+5;i<=(r*7)+(p*7);i+=7) f=f+$i ; for(i=6;i<=r*7;i+=7) g=g+$i ; for(i=(r*7)+6;i<=(r*7)+(p*7);i+=7) h=h+$i ; for(i=7;i<=r*7;i+=7) ax=ax+$i ; for(i=(r*7)+7;i<=(r*7)+(p*7);i+=7) by=by+$i ;print $1" "(y-x)/ss" "(b-a)/ss" "(d-c)/ss" "(8.314*(0.00001036)*$1*log(((prP/750)^nrP)/((prR/750)^nrR)))/ss" " (f-e)/ss" "((by-ax)+(8.314*(0.00001036)*$1*log(((prP/750)^nrP)/((prR/750)^nrR))))/ss }' >F_${eqn}_${!nR}_${!nP}_${!pR}_${!pP}_${!scale}

# Temp delE delZPE TdelS RtlnQ delH delG

#rm $all

f=`awk '{if(NR==1) {print $2}}' F_${eqn}_${!nR}_${!nP}_${!pR}_${!pP}_${!scale}`
fg=`echo "scale=4;$f/$3" | bc`
fh=`echo "scale=4;$f/$5" | bc`
echo " R1 + R2 ---> P1 + P2, E, per R2"
echo "$eqn,$f,$fh"


rm eqn 


#rm P1 P2 R1 R2
