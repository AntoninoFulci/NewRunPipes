#!/usr/bin/env bash

fluka_folder="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka4-3.0"

file_name="default_name"

# Ottiene le opzioni dal terminale. Quelle con i ":" vogliono qualcosa, quelle con "," sono ad attivazione
while getopts n:c flag
do
    case "${flag}" in
        n) file_name=${OPTARG};;
    esac
done


echo "Cleaning the folder..."
rm *.o $file_name

echo "Compiling the executable..."
#Compiling
gfortran -c -I$fluka_folder/include -g -cpp -O3 -fd-lines-as-comments -Wall -Waggregate-return -Wcast-align -Wline-truncation -Wno-conversion -Wno-integer-division -Wno-tabs -Wno-unused-dummy-argument -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable -Wsystem-headers -Wuninitialized -Wunused-label -mtune=generic -fPIC -fexpensive-optimizations -funroll-loops -fstrength-reduce -fno-automatic -finit-local-zero -ffixed-line-length-132 -fbackslash -funderscoring -frecord-marker=4 -falign-commons -fbacktrace -frange-check -fbounds-check -fdump-core -ftrapping-math -ffpe-trap=invalid,zero,overflow -o mgdraw.o mgdraw.f

echo "Linking the executable..."
#Linking
gfortran -o $file_name -fuse-ld=bfd mgdraw.o $fluka_folder/lib/interface/asciir.o $fluka_folder/lib/interface/dpmjex.o $fluka_folder/lib/interface/evdini.o $fluka_folder/lib/interface/eventd.o $fluka_folder/lib/interface/eveout.o $fluka_folder/lib/interface/eveqmd.o $fluka_folder/lib/interface/evqmdi.o $fluka_folder/lib/interface/glaubr.o $fluka_folder/lib/interface/idd2f.o $fluka_folder/lib/interface/idf2d.o $fluka_folder/lib/interface/rqm2pr.o $fluka_folder/lib/interface/rqmdex.o $fluka_folder/lib/interface/zrdpcm.o $fluka_folder/lib/interface/zrrqcm.o -L$fluka_folder/lib -lrqmd -lfluka -lstdc++ -lz -lDPMJET

echo "Done!"