#!/usr/bin/env bash

################################################################################
# Program options                                                              #
################################################################################
#path to the fluka-cern executable and the custom exe
fluka_path="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka4-3.0/bin/rfluka"                         # con "/" all'inizio
custom_exe="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka_custom_exes/dumping"                     # con "/" all'inizio

#path to the python script that generates the runs
pyscript="/mnt/project_mnt/jlab12/fiber7_fs/afulci/Simulations/generate_run.py"

#wirte here the queue where to launch the jobs
LSF_QUEUE="long"

#some options
Overwriting="n"         #Overwrite the file for each run: y/n
ERR_FILE="err.txt"
OUT_FILE="out.txt"

# Versione script
version=0.9

# Valori di default di sicurezza
file=0
job_number=0
directory=0
verbose=false
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
   echo "f     Fluka input file (must ends in .inp)"
   echo "j     Number of jobs to run (must be >0)"
   echo ""
   echo "Optional arguments"
   echo "d     Directory where to save the simulations run/s"
   echo "v     Verbose mode."
   echo "V     Print software version and exit."
   echo "D     Print default variables values"
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

    # Creala cartella che conterrà la simulazione e ci entra, se l'opzione -d è passata con un valore diverso da 0 allora la creerà con quel nome
    mkdir ./$directory
    cd $directory

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
while getopts f:j:d:v,V,D flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        j) job_number=${OPTARG};;
        d) directory=${OPTARG};;
        v) verbose=true;;
        V) Version=true;;
        D) Defa=true;;
    esac
done

# Se l'opzione -D è passata al programma stampa a schermo i valori di default
if [ $Defa == true ]
then
    Defaults
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