#!/usr/local/bin/python3

import argparse, os, random

# Questa funzione genera il file di input per una nuova run
# praticamente gli cambia la line "RANDOMIZ" mettendogli un seed diverso random
# possibile miglioramento da fare per garantire che tutti i job abbiano sempre un seed diverso:
# creare un file con tutti i seed da usare e leggerli da lì
# nel file: generare un seed e scriverlo solo se è diverso da tutti i precedenti    

def GenerateInput(input, iteration):

    #   minimo e massimo valore di seed accettati da fluka
    MIN_RAND=1.
    MAX_RAND=9E7

    #   generazione del seed della run
    seed=random.randint(MIN_RAND,MAX_RAND)

    #   generazione della stringa col nuovo seme
    new_randomiz = "RANDOMIZ          1.{:>10n}\n".format(seed)             #":"->inizio formato; ">"->allineato a destra; "10"->dieci spazi da occupare; "n"->numero da mettere

    with open(input+".inp", "r+") as f:                                     #apre il file in modalità lettura e scrittura
        data = f.readlines()                                                #legge tutte le linee e le mette in una lista
        for index, line in enumerate(data):                                 #cicla su tutte le linee, il doppio ciclo permette di avere su index l'indice del ciclo e su line l'elemento della lista
            if "RANDOMIZ" in line:                                          #se trova "RANDOMIZ" allora si attiva
                data[index] = new_randomiz                                  #quindi sostituisce la linea col nuovo randomiz nella lista
                break                                                       #interrompe il ciclo

        f.seek(0)                                                           #si mette a scrivere dall'inizio
        f.writelines(data)                                                  #scrive tutte le linee in data
        f.truncate()                                                        #serve ma non so che faccia

    file_name = input+"_{:04d}".format(iteration)+".inp"                    #genera il nome del nuovo file di input
    os.system("mv " + input + ".inp "+ file_name)                           #rinomina il file

    return file_name                                                        #ritorna il nome del file per usarlo nell'altro metodo


def GenerateSh(input, iteration, fluka_path, custom_exe = "None"):
    # genera il file sh che lancia il comando trovato sul sito: https://fluka.cern/documentation/running/fluka-command-line
    # /pathtofluka/bin/rfluka -M 5 -e ./myfluka example.inp

    # generazione del job da lanciare
    nome = "job_" + str(iteration) + ".sh"                                  # crea il nome del file in base all'iterazione corrente
    nome_dump = "dump"+"_{:04d}".format(iteration)+".txt"
    sh = open(nome, "w")                                                    # crea il file

    # scrittura nel file dei comando da usare
    sh.write("#!/usr/bin/env bash")                                         
    sh.write("\n\n")
    sh.write("export PATH=$PATH:/mnt/project_mnt/jlab12/fiber7_fs/afulci/Programs/FLUKA_CERN/fluka4-3.0/bin")
    sh.write("\n\n")
    sh.write(fluka_path + " -M 1 -e " + custom_exe + " " + input)           # creazione comando
    sh.write("\n\n")
    sh.write("rm *.19 ran* *.out")
    sh.write("\n\n")                
    sh.write("mv *_dump.txt ./" + nome_dump)
    sh.write("\n\n")
    sh.write("echo a questo punto lancio lo script che fa diventare il dump da txt in .root")


    sh.close()                                                              # chiusura del file

    # rende il file eseguibile
    os.system("chmod +x " + nome)

# Serve per poter lanciare lo script con degli arguments
parser = argparse.ArgumentParser(description='Fluka cern run launch script')

# Definizione degli argument da accettare
parser.add_argument('--input',      type=str, required=True, help="Input file name for fluka")
parser.add_argument('--iteration',  type=int, required=True, help='Current iteration')
parser.add_argument('--fluka',      type=str, required=True, help='Path to the fluka-cern path')
parser.add_argument('--custom_exe', type=str, required=True, help='Path to the custom exe')
args = parser.parse_args()

INPUT_FILE  = args.input            #file name, stripped of the .inp
C_ITERATION = args.iteration        #current iteration
FLUKA_PATH  = args.fluka            #fluka-cern path
CUSTOM_EXE  = args.custom_exe       #fluka custom exe

# Lanciamo prima la funzione per generare il nuovo file di input con un seed random
NEW_INPUT = GenerateInput(INPUT_FILE, C_ITERATION)

# Creiamo il file sh che verrà lanciato sulla farm come job
GenerateSh(NEW_INPUT, C_ITERATION, FLUKA_PATH, CUSTOM_EXE)


