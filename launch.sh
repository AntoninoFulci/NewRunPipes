#!/usr/bin/env bash

source RunPipes/config.cfg

# Versione script
version=1.3

# Valori di default di sicurezza
file=0
job_number=0
directory=0
verbose=false
help=false
Version=false
Defa=false
CustomSourceDiff=false      #Flag da accendere in caso si voglia una sorgente diversa per ogni simulazione

#colori
RED='\033[0;31m'
NC='\033[0m' # No Color

################################################################################
# Help                                                                         #
################################################################################
Help(){
   # Display Help
   echo "This script launch a simulation on the farm."
   echo
   echo "Syntax:"
   echo "./launch.sh -f <fluka_input_file>.inp -j <number of job> [-d <simulation/directtory/path/>] [-v|-V|-D] [-r <path1/to/fluka/routines> <path2/to/fluka/routines> ...]"
   echo
   echo "Required arguments:"
   echo "f     Fluka input file (must ends in .inp)."
   echo "j     Number of jobs to run (must be >0)."
   echo ""
   echo "Optional arguments"
   echo "d     Directory where to save the simulations run/s."
   echo "r     Add here the name/s of the routines to compile and link."
   echo "v     Verbose mode."
   echo "h     Show this message."
   echo "V     Print software version and exit."
   echo "D     Print default variables values."
   echo "C     Use a different text source file for each run (requires that you use a text file as a source using sourge_newgen.f"
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
    if [ ${#routines[@]} -eq 0 ]
    then
        echo "No routines to compile."
    else
        echo "Compiling the routine/s..."
    fi

    mkdir $directory/RunFiles

    for i in "${routines[@]}"
    do
    : 
        if [ -f "$i" ] 
        then
            cd $directory
            cd RunFiles
            echo "Compiling $i..."

            y=${i%.*}

            gfortran -c -I$fluka_folder/include -g -cpp -O3 -fd-lines-as-comments -Wall -Waggregate-return -Wcast-align -Wline-truncation -Wno-conversion -Wno-integer-division -Wno-tabs -Wno-unused-dummy-argument -Wno-unused-function -Wno-unused-parameter -Wno-unused-variable -Wsystem-headers -Wuninitialized -Wunused-label -mtune=generic -fPIC -fexpensive-optimizations -funroll-loops -fstrength-reduce -fno-automatic -finit-local-zero -ffixed-line-length-132 -fbackslash -funderscoring -frecord-marker=4 -falign-commons -fbacktrace -frange-check -fbounds-check -fdump-core -ftrapping-math -ffpe-trap=invalid,zero,overflow -o ${y##*/}.o ../../$i
            routinesO+="${y##*/}.o "

            cd ..
            cd ..
        else
            echo "No $i found. Skipping it."
        fi
    done
    
    #Linking
    if [ ${#routinesO[@]} -eq 0 ]
    then
        echo "No routines to link."
    else
        cd $directory
        cd RunFiles

        echo "Linking the routine/s..."
        gfortran -o custom_exe -fuse-ld=bfd ${routinesO[@]} $fluka_folder/lib/interface/asciir.o $fluka_folder/lib/interface/dpmjex.o $fluka_folder/lib/interface/evdini.o $fluka_folder/lib/interface/eventd.o $fluka_folder/lib/interface/eveout.o $fluka_folder/lib/interface/eveqmd.o $fluka_folder/lib/interface/evqmdi.o $fluka_folder/lib/interface/glaubr.o $fluka_folder/lib/interface/idd2f.o $fluka_folder/lib/interface/idf2d.o $fluka_folder/lib/interface/rqm2pr.o $fluka_folder/lib/interface/rqmdex.o $fluka_folder/lib/interface/zrdpcm.o $fluka_folder/lib/interface/zrrqcm.o -L$fluka_folder/lib -lrqmd -lfluka -lstdc++ -lz -lDPMJET

        custom_exe=$(get_abs_filename "custom_exe")
        echo "Custom executable created: $custom_exe"

        cd ..
        cd ..
    fi


}


# Funzione che lancia le varie simulazioni sulla farm
Launch(){
    # Strippa il nome del file di input
    StrippedName=${file%.*}

    #Creiamo la cartella, nel caso in cui esiste già gli diamo un suffisso
    base_directory_name=$StrippedName
    new_directory_name="${base_directory_name}"

    counter=1
    while [ -e "${new_directory_name}" ]; do
        new_directory_name="${base_directory_name}_${counter}"
        counter=$((counter + 1))
    done

    directory=$new_directory_name
    
    # Piccolo controllo prima di far partire lo script
    echo -e "The file chosen is: ${RED}$file${NC}"
    echo -e "The number of job to launch is ${RED}$job_number${NC}"
    echo -e "The jobs will be launched in the following queue: ${RED}$queue${NC}"
    echo -e "The following files will be compiled and linked to the fluka exe (DPMJET): ${RED}${routines[@]}${NC}"
    echo -e "The simulation will be saved in the new directory (be sure it does not already exits): ${RED}$(pwd)/$directory${NC}" 
    echo -e "Is it correct? [y/n]"
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

    # crea gli eseguibili
    MakeExe

    cd $directory

    # Cicla sul numero di job che si vuole lanciare
    for (( i = 0001; i <= $job_number; i++ )); do
        
        # Crea il nome della cartella del job come 0001 in modo che poi appaiano in ordine
        job=`printf ./job_%04d $i`
        mkdir $job
        cd $job
        
        # Copia il file dentro la cartella
        cp $FileAbsPath .

        python3 $pyscript --input=$StrippedName --iteration=$i --fluka=$fluka_path --custom_exe=$custom_exe --dump_to_root=$dump_to_root

        # Lancia la simulazione
        echo bsub -P c7 -q $queue $MEMORY $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh
        # bsub -P c7 -q $queue $MEMORY $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh

        # Torna indietro in modo da poter rieseguire tutto da capo
        cd ..

    done

}

Clean(){
    
    echo "Cleaning the folder..."
    cd ..
    mv $file $directory

}

################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################

# Ottiene le opzioni dal terminale. Quelle con i ":" vogliono qualcosa, quelle con "," sono ad attivazione
unset -v routines
while getopts f:j:d:q:r:v,h,V,D flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        j) job_number=${OPTARG};;
        d) directory=${OPTARG};;
        q) queue=${OPTARG};;
        r) routines=("$OPTARG")
            until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                routines+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
            ;;
        v) verbose=true;;
        h) help=true;;
        V) Version=true;;
        D) Defa=true;;
    esac
done

if [ $OPTIND -eq 1 ] 
then 
    echo "No options were passed."
    echo
    Help
    exit 0
fi

if [ -z "$queue"  ]
then
    queue="$LSF_QUEUE"
fi

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
    echo "Error. File does not end with .inp or the number of jobs to launch was set to 0."
    echo
    Help
    exit 0
else
    if [ -f "$file" ]
    then
        Launch
        Clean
    else
        echo "File does not exits."
        exit 0
    fi
fi