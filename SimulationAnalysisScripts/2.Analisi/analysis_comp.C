#include <iostream>
#include <string>
#include <vector>

#include <TH1D.h>
#include <TGraphErrors.h>
#include <TStopwatch.h>
#include <TDirectory.h>
#include <ROOT/RDataFrame.hxx>
#include <TSystem.h>

using namespace std;
using namespace ROOT;

void histograms(ROOT::RDF::RInterface<ROOT::Detail::RDF::RLoopManager, void> Events, std::vector<unsigned int> SurfaceIDs, int nBin, double Emin, double Emax, string option){
    gErrorIgnoreLevel = kWarning;
    gROOT->SetBatch(kTRUE);
    gSystem->Exec("mkdir ./Graphs");

    //Nome
    string particella = "Neutron";

    TCanvas *c_energies;

    TFile *file = new TFile("Graphs/Graphs.root", option.c_str());
    TDirectory *dir_energy_range;
    dir_energy_range = file->mkdir(Form("Energy_%g-%g", Emin, Emax));
    dir_energy_range->cd();

    double Integrale, Errore;
    double VsY, VsYErr, VsZ, VsZErr;
    vector<double> IntegraliY, ErroriY, VsYs, VsYErrs;
    vector<double> IntegraliZ, ErroriZ, VsZs, VsZErrs;
    
    cout << "Beginning loop for energy range: " << Emin << " - " << Emax << " GeV" <<endl;

    for(int i = 0; i < SurfaceIDs.size(); i++){
        string filter = "SurfaceID == " + std::to_string(SurfaceIDs.at(i));
        auto energy = Events.Filter(filter).Histo1D<double, double>({Form("%s_Energy_Det%d", particella.c_str(), SurfaceIDs.at(i)), Form("%s energy Det %d; E (GeV); Particles/EOT", particella.c_str(), SurfaceIDs.at(i)), nBin, Emin, Emax}, "Ekin", "Peso");
        energy->Write();

        Integrale = energy->IntegralAndError(1, nBin, Errore);

        if(Integrale > 0){
            if(SurfaceIDs.at(i) > 0 && SurfaceIDs.at(i) <= 100){                 //Superfici lungo y
                VsY = Events.Filter(filter).Mean("Vy").GetValue();
                IntegraliY.push_back(Integrale); ErroriY.push_back(Errore); VsYs.push_back(VsY); VsYErrs.push_back(0);
                cout << "Det "<< SurfaceIDs.at(i) << " - Vy: " << VsY << " - Integrale: " << Integrale << " +/- " << Errore << " (" << Errore/Integrale*100 << "%)" << endl;

            }
            else if(SurfaceIDs.at(i) >= 101 && SurfaceIDs.at(i) <= 200){        //Superfici lungo z
                VsZ = Events.Filter(filter).Mean("Vz").GetValue();
                IntegraliZ.push_back(Integrale); ErroriZ.push_back(Errore); VsZs.push_back(VsZ); VsZErrs.push_back(0);
                cout << "Det "<< SurfaceIDs.at(i) << " - Vz: " << VsZ << " - Integrale: " << Integrale << " +/- " << Errore << " (" << Errore/Integrale*100 << "%)" << endl;
            }
            else{
                cout << "Det "<< SurfaceIDs.at(i)<< " - Entries: "<< energy->GetEntries() << " - Integrale: " << Integrale << " +/- " << Errore << " (" << Errore/Integrale*100 << "%)" << endl;
            }

        }

    }

    if(IntegraliY.size() > 0){
        TGraphErrors *gY = new TGraphErrors(IntegraliY.size(), VsYs.data(), IntegraliY.data(),  VsYErrs.data(), ErroriY.data());
        gY->SetName("NeutronsVsY"); gY->SetTitle("Neutrons/EOT vs Y");
        gY->Write();
    }

    if(IntegraliZ.size() > 0){
        TGraphErrors *gZ = new TGraphErrors(IntegraliZ.size(), VsZs.data(), IntegraliZ.data(), VsZErrs.data(), ErroriZ.data());
        gZ->SetName("NeutronsVsZ"); gZ->SetTitle("Neutrons/EOT vs Z");
        gZ->Write();
    }

    file->Close();

}


//Questa funzione ritorna i neutroni uscenti da una superficie, sia come entries che come integrale senza essere diviso per EOT
void count_on_surf(ROOT::RDF::RInterface<ROOT::Detail::RDF::RLoopManager, void> Ekin, int ID){
    string filter = "SurfaceID == " + to_string(ID);

    double Error;

    auto nN0 = Ekin.Filter(filter).Count();
    auto nN1 = Ekin.Filter(filter).Filter("Cy > 0").Count(); 

    cout << "Det " << ID << " - Entries: " << *nN0 << " - Entries with Cy > 0: " << *nN1 << endl;
}

// int main(double NormFactor = 1, string files = "root_files/*.root", bool debug = true){
int main(int argc, char* argv[]){

    /////////////////////////////////////////////////////////////////////////////////////////////
    ///// PRENDIAMO GLI ARGOMENTI
    /////////////////////////////////////////////////////////////////////////////////////////////

    
    printf("You have entered %d arguments:\n", argc);
 
    for (int i = 0; i < argc; i++) {
        printf("%s\n", argv[i]);
    }

    // double NormFactor = (double)argv[1];
    // string files(argv[2]);
    // int debug = int(argv[3]);


    double NormFactor = 1;
    string files = "root_files";
    int debug = 1;

    /////////////////////////////////////////////////////////////////////////////////////////////
    ///// PREAMBOLO
    /////////////////////////////////////////////////////////////////////////////////////////////


    EnableThreadSafety();                 //Giusto per precauzione
    EnableImplicitMT(); int num_threads = ROOT::GetThreadPoolSize(); //Per abilitare il parallelismo, senza nulla tra parentesi usa tutti i core/thread possibili

    cout<<"****************************************************\n";
    cout<<"Normalizazion factor: "<< NormFactor << endl;
    cout<<"File/Folder to be analyzed: "<< files << endl;
    cout << "Number of threads being used: " << num_threads << endl;
    if (debug) cout<<"Debug active"  << endl;
    cout<<"****************************************************\n";

    //Stopwatch
    TStopwatch global, stopwatch;
    if(debug) {global.Start();}

    //Inizializzazione RDataFrame
    RDataFrame Events("Events", files);
    RDataFrame RunSummary("RunSummary", files);

    /////////////////////////////////////////////////////////////////////////////////////////////
    ///// ANALISI PRELIMINARE
    /////////////////////////////////////////////////////////////////////////////////////////////

    //Conteggio elettroni simulati
    if(debug) cout << "Beginning to count primaries simulated..." << endl;
    if(debug) stopwatch.Start();

    unsigned int nEOT = 0;
    RunSummary.Foreach([&nEOT](unsigned int i){ nEOT = nEOT + i;}, {"TotEvents"});

    if(debug){stopwatch.Stop();  stopwatch.Print();}
    
    //Definizione delle lambda da usare per definire nuove colonne nel dataframe
    double n_m	= 0.939565378;
    auto Ekin_calc = [n_m](double Etot){ return Etot - n_m; };
    auto PesoEOT_calc = [nEOT, NormFactor](double weight){ return weight/nEOT * NormFactor; };

    //Definizione di due nuove colorre da usare per gli istogrammi
    if(debug) cout << "Creating new dataframes with correct weight..." << endl;
    auto Ekin = Events.Define("Ekin", Ekin_calc, {"ETot"}).Define("Peso", PesoEOT_calc, {"Weight1"});           //Creiamo il DF Ekin, ha una colonna Ekin, e una Peso

    if(debug) cout << "Calculating time stastitics of the simulation..."<<endl;
    if(debug) stopwatch.Start();
    //Calcolo dei tempi di simulatione
    auto AvgTime = RunSummary.Mean<double>("AvgTime");
    auto TotTime = RunSummary.Mean<double>("TotTime");

    if(debug){stopwatch.Stop();  stopwatch.Print();}

    ///////////////////////////////////////////////////////////////////////////////////////
    ///// FINDING UNIQUE SURFACE IN THE DATAFRAME
    ///////////////////////////////////////////////////////////////////////////////////////

    if(debug) cout << "Finding unique surfaces in the dataset..." << endl;
    if(debug) stopwatch.Start();

    std::vector<std::unordered_set<unsigned int>> v_SurfIDSet(num_threads, std::unordered_set<unsigned int>{});

    std::unordered_set<unsigned int> SurfIDSet;             //Definiamo l'unordered set dove andranno insertie le varie superfici, questo automaticamente accetta solo entries uniche

    Events.ForeachSlot([&](unsigned int s, unsigned int i){ v_SurfIDSet[s].insert(i);}, {"SurfaceID"});       //Qui scorriamo tutte le entries e cerchiamo di inserirle nella set
    for(auto us : v_SurfIDSet){
        SurfIDSet.insert(us.begin(), us.end());
    }

    std::vector<unsigned int> SurfaceIDs(SurfIDSet.begin(), SurfIDSet.end());                   //Convertiamo il set in vettore
    sort(SurfaceIDs.begin(), SurfaceIDs.end());                                                 //Sortiamo il vettore
    SurfaceIDs.erase(std::remove(SurfaceIDs.begin(), SurfaceIDs.end(), 0), SurfaceIDs.end());   //cancella un eventuale superficie 0, che non dovrebbe esistere

    if(debug){stopwatch.Stop();  stopwatch.Print();}

    ///////////////////////////////////////////////////////////////////////////////////////
    ///// PRINTING THE VARIOUS STATS
    ///////////////////////////////////////////////////////////////////////////////////////

    cout<<"****************************************************"<<endl;
    cout << "Total number of primaries simulated: " << nEOT << endl;
    cout << "Mean time to follow a primary: "       << *AvgTime << endl;
    cout << "Mean time to complete a job: "         << *TotTime << endl;
    cout << "Total Surfaces found: " << SurfaceIDs.size() << " -> "; for(auto i : SurfaceIDs) cout << i << " ";  cout << endl;
    cout<<"****************************************************"<<endl;

    ///////////////////////////////////////////////////////////////////////////////////////
    ///// Analysis
    ///////////////////////////////////////////////////////////////////////////////////////
    
    // if(debug) stopwatch.Start();

    // count_on_surf(Ekin, 300);
    // count_on_surf(Ekin, 301);
    // count_on_surf(Ekin, 302);
    // count_on_surf(Ekin, 500);


    // if(debug){stopwatch.Stop();  stopwatch.Print();}

    //qui devo fare una funzione del tipo:
    // funzione <Dataframe, vettore di superfici, nbin, Emin, Emax,  bool b_energy = true, bool b_vertex = false, bool b_momenta = false>
    if(debug) stopwatch.Start();

    histograms(Ekin, SurfaceIDs, 100, 0,    11,  "RECREATE");
    histograms(Ekin, SurfaceIDs, 100, 0,    1e-5,"UPDATE");
    histograms(Ekin, SurfaceIDs, 10,  1e-5, 1e-4,"UPDATE");
    histograms(Ekin, SurfaceIDs, 10,  1e-4, 0.01,"UPDATE");
    histograms(Ekin, SurfaceIDs, 10,  0.01, 0.02,"UPDATE");
    histograms(Ekin, SurfaceIDs, 100, 0.02, 0.1, "UPDATE");
    histograms(Ekin, SurfaceIDs, 200, 0.1,  11,  "UPDATE");

    if(debug){stopwatch.Stop();  stopwatch.Print();}




    if(debug){
        global.Stop();
        cout<<"****************************************************"<<endl;
        cout<<"Total analysis time:" <<endl; 
        global.Print();}
        cout<<"****************************************************"<<endl;

    return 0;
}