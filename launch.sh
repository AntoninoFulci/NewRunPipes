#!/usr/bin/env bash

################################################################################
# Program options                                                              #
################################################################################
# path to the fluka-cern executable and the custom exe
fluka_path="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka4-3.0/bin/rfluka"                       # con "/" all'inizio, serve per lanciare la run
# fluka_folder="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka4-3.0"                              # con "/" all'inizio, serve per compilare e linkare le routine fortran
fluka_folder="/Users/antoninofulci/Fluka/fluka4-3.0"                                                                    

# path to the python script that generates the runs
# pyscript="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Simulations/generate_run.py"
pyscript="/Users/antoninofulci/FlukaWork/NewRunPipes/generate_run.py"

# write here the queue where to launch the jobs
LSF_QUEUE="long"

# some options
Overwriting="n"         #Overwrite the file for each run: y/n
ERR_FILE="err.txt"
OUT_FILE="out.txt"

# Versione script
version=1.1

# Valori di default di sicurezza
file=0
job_number=0
directory=0
mgdraw=0
verbose=false
help=false
Version=false
Defa=false

################################################################################
# Help                                                                         #
################################################################################
Help(){
   # Display Help
   echo "This script launch a simulation on the farm."
   echo
   echo "Syntax:"
   echo "./launch.sh -f <fluka_input_file>.input -j <number of job> [-d <simulation/directtory/path/>|-v|-V|-D]"
   echo
   echo "Required arguments:"
   echo "f     Fluka input file (must ends in .inp)."
   echo "j     Number of jobs to run (must be >0)."
   echo ""
   echo "Optional arguments"
   echo "d     Directory where to save the simulations run/s."
   echo "m     Name of the mgdraw.f for scoring to be compiled and linked. The results will be saved in the simulation directory."
   echo "s     Name of the source.f/source_newgen.f for custom source to be compiled and linked. The results will be saved in the simulation directory."
   echo "v     Verbose mode."
   echo "h     Show this message."
   echo "V     Print software version and exit."
   echo "D     Print default variables values."
   echo
}

Defaults(){
    echo "Default file: $file"
    echo "Default job_number $job_number"
    echo "Default directory ./file_name/"
    echo "Default verbose = $verbose"
    echo "Default FLUKA-CERN executable path: None. Must be inserted"
    echo "Default FLUKA custom executable path: None. Must be inserted"
    exit 0
}

################################################################################
# Launching jobs function                                                      #
################################################################################

# Funzione per ottenere il path assoluto del file, trovata su internet, funziona.
get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# Funzione che genera il custom exe per la run
MakeExe(){

    #Compiling
    echo "Compiling the executables..."
    if [ -f "$mgdrawAbs" ] 
    then
        echo "Compiling mgdraw.f..."
        gfortran -c -I$fluka_folder/include -g -cpp -O3 -fd-lines-as-comments -Wall -Waggregate-return -Wcast-align -Wline-truncation -Wno-conversion -Wno-integer-division -Wno-tabs -Wno-unused-dummy-argument -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable -Wsystem-headers -Wuninitialized -Wunused-label -mtune=generic -fPIC -fexpensive-optimizations -funroll-loops -fstrength-reduce -fno-automatic -finit-local-zero -ffixed-line-length-132 -fbackslash -funderscoring -frecord-marker=4 -falign-commons -fbacktrace -frange-check -fbounds-check -fdump-core -ftrapping-math -ffpe-trap=invalid,zero,overflow -o mgdraw.o $mgdrawAbs
        mgdrawO="mgdraw.o"
    else
        echo "No mgdraw.f found. Skipping it"
    fi

    if [ -f "$sourceAbs" ] 
    then
        echo "Compiling source.f..."
        gfortran -c -I$fluka_folder/include -g -cpp -O3 -fd-lines-as-comments -Wall -Waggregate-return -Wcast-align -Wline-truncation -Wno-conversion -Wno-integer-division -Wno-tabs -Wno-unused-dummy-argument -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable -Wsystem-headers -Wuninitialized -Wunused-label -mtune=generic -fPIC -fexpensive-optimizations -funroll-loops -fstrength-reduce -fno-automatic -finit-local-zero -ffixed-line-length-132 -fbackslash -funderscoring -frecord-marker=4 -falign-commons -fbacktrace -frange-check -fbounds-check -fdump-core -ftrapping-math -ffpe-trap=invalid,zero,overflow -o source_newgen.o $sourceAbs
        sourceO="source_newgen.o"
    else
        echo "No source_newgen.f found. Skipping it"
    fi

    #Linking
    echo "Linking the executable..."
    gfortran -o custom_exe -fuse-ld=bfd $mgdrawO $sourceO $fluka_folder/lib/interface/asciir.o $fluka_folder/lib/interface/dpmjex.o $fluka_folder/lib/interface/evdini.o $fluka_folder/lib/interface/eventd.o $fluka_folder/lib/interface/eveout.o $fluka_folder/lib/interface/eveqmd.o $fluka_folder/lib/interface/evqmdi.o $fluka_folder/lib/interface/glaubr.o $fluka_folder/lib/interface/idd2f.o $fluka_folder/lib/interface/idf2d.o $fluka_folder/lib/interface/rqm2pr.o $fluka_folder/lib/interface/rqmdex.o $fluka_folder/lib/interface/zrdpcm.o $fluka_folder/lib/interface/zrrqcm.o -L$fluka_folder/lib -lrqmd -lfluka -lstdc++ -lz -lDPMJET

    custom_exe=$(get_abs_filename "custom_exe")
    echo $custom_exe
}


# Funzione che lancia le varie simulazioni sulla farm
Launch(){
    # Strippa il nome del file di input
    StrippedName=${file%.*}

    if [ $directory == 0 ]
    then
        directory=$StrippedName
    fi
    
    # Piccolo controllo prima di far partire lo script
    echo "The file chosen is: $file"
    echo "The number of job to launch is $job_number"
    echo "The following files will be compiled and linked to the fluka exe (DPMJET), be sure they are in the current folder: $mgdraw $source"
    echo "The simulation will be saved in the new directory (be sure it does not already exits): $(pwd)/$directory" 
    echo "Is it correct? [y/n]"
    read response

    if [ $response == "n" ]
    then
        echo "Exiting bye!"
        exit
    fi

    # Se si vuole sovrascrivere i file err.txt e out.txt
    if [ $Overwriting == "y" ]
    then
        err_opt="-eo"
        out_opt="-oo"
    else
        err_opt="-e"
        out_opt="-o"
    fi


    # Ottiene il path assoluto del file di input
    FileAbsPath=$(get_abs_filename "$file")
    mgdrawAbs=$(get_abs_filename "$mgdraw")
    sourceAbs=$(get_abs_filename "$source")

    # Creala cartella che conterrà la simulazione e ci entra, se l'opzione -d è passata con un valore diverso da 0 allora la creerà con quel nome
    mkdir ./$directory
    cd $directory

    MakeExe

    # Cicla sul numero di job che si vuole lanciare
    for (( i = 0001; i <= $job_number; i++ )); do
        
        # Crea il nome della cartella del job come 0001 in modo che poi appaiano in ordine
        job=`printf ./job_%04d $i`
        mkdir $job
        cd $job
        
        # Copia il file dentro la cartella
        cp $FileAbsPath .

        # Script python che genera il file di input con un nuovo seed e il file .sh per avviare la simulazione
        python3 $pyscript --input=$StrippedName --iteration=$i --fluka=$fluka_path --custom_exe=$custom_exe 

        # Lancia la simulazione
        echo bsub -P c7 -q $LSF_QUEUE -M 8192 -R "select[mem>8192] rusage[mem=8192]" $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh
        # bsub -P c7 -q $LSF_QUEUE -M 8192 -R "select[mem>8192] rusage[mem=8192]" $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh

        # Torna indietro in modo da poter rieseguire tutto da capo
        cd ".."

    done
}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

# Ottiene le opzioni dal terminale. Quelle con i ":" vogliono qualcosa, quelle con "," sono ad attivazione
while getopts f:j:d:m:s:v,h,V,D flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        j) job_number=${OPTARG};;
        d) directory=${OPTARG};;
        m) mgdraw=${OPTARG};;
        s) source=${OPTARG};;
        v) verbose=true;;
        h) help=true;;
        V) Version=true;;
        D) Defa=true;;
    esac
done

# Se l'opzione -D è passata al programma stampa a schermo i valori di default
if [ $Defa == true ]
then
    Defaults
fi

# Se l'opzione -h è passata al programma stampa il messaggio di help
if [ $help == true ]
then
    Help
fi

# Se l'opzione -V è passata al programma stampa a schermo la versione dello script
if [ $Version == true ]
then
    echo "Launching scirpt version: $version"
    exit 0
fi

#Checking the correct usage of the script
if [ "${file: -4}" != ".inp" -o $job_number -le 0 ]
then
    echo "Error!!!"
    echo 
    Help
else
    Launch
fi