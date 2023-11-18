#!/bin/bash -f     
# ---------------------------
#$ -M <my-email-address>            
#$ -m be
#$ -V
#$ -cwd
#$ -N main
#$ -S /bin/bash
#$ -l vf=600M   
#$ -pe ompi-local 40
#$ -q I_40T_64G_GPU.q            
#
echo "Got ${NSLOTS} slots."
IPWD=`pwd`
echo "in ${IPWD}"
nsys launch --wait=primary --trace=cuda,nvtx julia --project -g2 -t auto main.jl        
exit 0
