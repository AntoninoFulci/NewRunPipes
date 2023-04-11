#!/bin/bash

echo "Sourcing gcc.."
source /mnt/project_mnt/software_fs/gcc/4.8.4/x86_64-cc7/setup.sh

echo "Sourcing ROOT..."
source /mnt/project_mnt/software_fs/root/6.18.00/x86_64-centos7-gcc48-opt/bin/thisroot.sh

echo "Setting new TMPDIR..."
export TMPDIR=/mnt/project_mnt/jlab12/fiber7_fs/afulci/temp/

echo "Checking if root recognize the new temp dir:"
root -l -b <<EOF
gSystem->TempDirectory()
.q
EOF

echo "Launching the scripts..."

#For neutrons
root -l -b <<EOF
.L /mnt/project_mnt/jlab12/fiber7_fs/afulci/Simulations/AnalysisScripts/Analisi.C
Analisi o
o.Process("MERGED", "simulazione.root", "neutron")
EOF
