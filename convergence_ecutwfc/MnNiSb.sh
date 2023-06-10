#!/bin/sh
module purge
module add impi sci/dft sci/qe_7.2
export MKL_NUM_THREADS=1
export ASE_ESPRESSO_COMMAND="mpirun /home/sci/opt/qe-7.2_impi/bin/pw.x -np 4 < PREFIX.pwi > PREFIX.pwo"
NAME="ecut"
declare -A energy_dict  # Declare an associative array for storing energies
for CUTOFF in  10 15 20 25 30 35 40 45 50 55 60 65 70 75
do
cat > ${NAME}_${CUTOFF}.in << EOF
&CONTROL
    calculation = 'relax'
    prefix = 'MnNiSb'
    outdir = './out/'
    pseudo_dir = './pseudos/'
 /
&SYSTEM
   ecutwfc          =  $CUTOFF
   occupations      = 'smearing'
   degauss          = 0.0146997171
   ntyp             = 2
   nat              = 4
   ibrav            = 0
 /
&ELECTRONS
/
&IONS
/
&CELL
/

ATOMIC_SPECIES
Mn 54.938044 Mn.pbe-spn-kjpaw_psl.0.3.1.UPF
Sb 121.76 Sb.pbe-n-kjpaw_psl.1.0.0.UPF

K_POINTS gamma

CELL_PARAMETERS angstrom
3.64580405000000 0.00000000000000 0.00000000000000
-1.82290202500000 3.15735892452019 0.00000000000000
0.00000000000000 0.00000000000000 5.04506600000000

ATOMIC_POSITIONS angstrom
Mn 0.0000000000 0.0000000000 0.0000000000 
Mn 0.0000000000 0.0000000000 2.5225330000 
Sb -0.0000000182 2.1049059602 1.2612665000 
Sb 1.8229020432 1.0524529643 3.7837995000
EOF

pw.x < ${NAME}_${CUTOFF}.in > ${NAME}_${CUTOFF}.out
echo ${NAME}_${CUTOFF}
grep ! ${NAME}_${CUTOFF}.out
energy=$(grep "!" "${NAME}_${CUTOFF}.out" | awk '{print $5}')  # Extract the energy value using awk
energy_dict["${CUTOFF}"]=$energy  # Store energy in the dictionary with cutoff value as key
done
# Print the dictionary
for key in "${!energy_dict[@]}"; do
    echo "Cutoff: $key, Energy: ${energy_dict[$key]}"
done
# Save energies in text file with corresponding cutoff
echo "$CUTOFF $energy" >> "energies.txt"  # Append cutoff and energy to the output file