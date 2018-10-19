# HS_computer
Computes free energy profiles of reactions based on ab initio data

# USAGE:

./compute-auto.sh x y a A b B c C d D nR nP pR pP N
 
  here- x, y are number of reactants and products
  
  a, b, c, d are reaction coefficients
  
  A, B, C, D are the molecules/bulk/surface
  
  nR, nP are the number of reactant and product molecules to be considered for pressure calculation
  
  pR, pP are the partial pressure of reactants and products in Torr
  
  N is the normalization factor

Example: ./compute-auto.sh 2 2 1 HfO2 4 HF 1 HfF4 2 H2O 5 3 1.0 0.1 1


# Prerequisites:

1. One folder for each species that enters the reaction. Rename the folder with the name of the species.

2. A file named 'Table' must be present on this folder. 

3. Its contents should be as per the output from phonopy code when 'phonopy -t -p mesh.conf' is executed as follows..

     Line 1: #Total energy
     Line 2: #Temp #Free energy [KJ/mol] #Entropy [J/K/mol] #Heat capacity [J/K/mol] #Enthalpy [Kj/mol]
     Line 3: ...
     Line 4: ...
     .
     .
     .
    
4. Run the './freeh2table.sh' script without argument to convert the output of freeh program of Turbomole suite 
   to the above format.

