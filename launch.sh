#!/usr/bin/env bash

source RunPipes/config.cfg

# Versione script
version=1.2

# Valori di default di sicurezza
file=0
job_number=0
directory=0
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
   echo "r     Add here the name/s of the routines to compile and link."
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

    if [ $directory == 0 ]
    then
        directory=$StrippedName
    fi
    
    # Piccolo controllo prima di far partire lo script
    echo "The file chosen is: $file"
    echo "The number of job to launch is $job_number"
    echo "The following files will be compiled and linked to the fluka exe (DPMJET): ${routines[@]}"
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

        # Script python che genera il file di input con un nuovo seed e il file .sh per avviare la simulazione
        python3 $pyscript --input=$StrippedName --iteration=$i --fluka=$fluka_path --custom_exe=$custom_exe --dump_to_root=$dump_to_root

        # Lancia la simulazione
        echo bsub -P c7 -q $LSF_QUEUE -M 8192 -R "select[mem>8192] rusage[mem=8192]" $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh
        # bsub -P c7 -q $LSF_QUEUE -M 8192 -R "select[mem>8192] rusage[mem=8192]" $err_opt $ERR_FILE $out_opt $OUT_FILE ./job_$i.sh

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
while getopts f:j:d:r:v,h,V,D flag
do
    case "${flag}" in
        f) file=${OPTARG};;
        j) job_number=${OPTARG};;
        d) directory=${OPTARG};;
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
    Clean
fi