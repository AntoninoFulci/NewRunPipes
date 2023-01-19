import ROOT, ctypes, argparse, random, sys
import pandas
import matplotlib.pyplot as plt
import array as arr
from ROOT import TArrayD, TVectorD, TMatrixD, TDecompLU, gRandom


def GenAndRetro(path, NEvents):
    gRandom.SetSeed(random.randint(1,sys.maxsize))

    histFile = ROOT.TFile.Open(path, "READ")

    hs = histFile.Get("hs")
    hs.Sumw2()

    #array su cui mettere le variabili ri-generate
    tmp = arr.array ("d", [1,2,3,4,5,6,7])

    #Servono per i calcoli per portare le particelle indietro
    A_data = TArrayD(9)    
    B_55cm = TVectorD(3)
    x_55cm = TVectorD(3)
    A = TMatrixD(3,3)
    ok = ctypes.c_bool()

    #file sorgente
    f = open("source.txt", "w")

    #Estrazione e retropropagazione delle particelle
    for i in range(NEvents):
        
        #Generazione
        hs.GetRandom(tmp)

        #Calcoli per la retropropagazione
        A_data[0] = 1/(tmp[0]*tmp[4])
        A_data[1] = -1/(tmp[0]*tmp[5])
        A_data[2] = 0
        A_data[3] = 0
        A_data[4] = 1/(tmp[0]*tmp[5])
        A_data[5] = -1/(tmp[0]*tmp[6])
        A_data[6] = 0
        A_data[7] = 1
        A_data[8] = 0

        B_55cm[0] = (tmp[1]/(tmp[0]*tmp[4])) - (tmp[2]/(tmp[0]*tmp[5]))
        B_55cm[1] = (tmp[2]/(tmp[0]*tmp[5])) - (tmp[3]/(tmp[0]*tmp[6]))
        B_55cm[2] =  55

        A.SetMatrixArray(A_data.GetArray())

        A_decomp = TDecompLU(A)

        x_55cm  = A_decomp.Solve(B_55cm, ok)

        vVx = x_55cm(0)
        vVy = x_55cm(1)
        vVz = x_55cm(2)
        
        #Scrittura su file
        stringa = "{ID} {P:> 15.5f} {Vx:> 15.5f} {Vy:> 15.5f} {Vz:> 15.5f} {Cx:> 15.5f} {Cy:> 15.5f} {Cz:> 15.5f} {W:> 16}\n".format(ID=8, P=tmp[0], Vx = vVx, Vy = vVy, Vz=vVz, Cx=tmp[4], Cy=tmp[5], Cz=tmp[6], W=1)
        f.write(stringa)

def DistroTest():
    df = pandas.read_table("source.txt", sep="\s+", names = ["ID", "P", "Vx", "Vy", "Vz", "Cx", "Cy", "Cz", "W"])

    figure, axis = plt.subplots(3, 3)
    figure.set_size_inches(10,8)

    df["P"].plot.hist(bins=2000, ax=axis[0,0])
    df["Vx"].plot.hist(bins=500, ax=axis[0,1], range=[-250,250])
    df["Vy"].plot.hist(bins=10, ax=axis[0,2], range=[50,60])
    df["Vz"].plot.hist(bins=500, ax=axis[1,0], range=[-250,250])
    df["Cx"].plot.hist(bins=200, ax=axis[1,1], range=[-1,1])
    df["Cy"].plot.hist(bins=200, ax=axis[1,2], range=[-1,1])
    df["Cz"].plot.hist(bins=200, ax=axis[2,0], range=[-1,1])

    plt.show()
    # print(df)


# Serve per poter lanciare lo script con degli arguments
parser = argparse.ArgumentParser(description='Source generator with retropropagation')

# Definizione degli argument da accettare
parser.add_argument('--root_file',  type=str, required=True, help="Path to the root file containing the multidimensional distribution of P, X, Y, Z, Cx, Cy, Cz")
parser.add_argument('--nevents',    type=int, required=True, help='Number of events to generate')

args = parser.parse_args()

INPUT_FILE  = args.root_file
NEVENTS = args.nevents

GenAndRetro(INPUT_FILE, NEVENTS)

# DistroTest()













