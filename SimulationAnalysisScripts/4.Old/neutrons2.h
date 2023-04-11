///////////////////////////////////////////////////
// File per analizzare i neutroni
///////////////////////////////////////////////////

void Analisi::AnalyzeNeutrons(int nEOT, vector<int> surf){
    using namespace ROOT;
    EnableImplicitMT(15);                // Tell ROOT you want to go parallel

    GetTimeNow(); cout<<"Building histograms for neutrons..."<<endl;

    string particella = "neutron";
    double n_m	= 0.939565378;			//massa del neutrone in GeV


    RDataFrame DF_sim("Events", "simulazione.root");        //creiamo il DataFrame, gli passiamo il TTree e il root file TODO: mettere che si prende il path

    //Definizione delle lambda da usare per definire nuove colonne nel dataframe
    auto Ekin_calc = [n_m](double Etot){ return Etot - n_m; };
    auto PesoEOT_calc = [nEOT](double weight){ return weight/nEOT; };

    //Definizione di due nuovi dataframe da usare per gli istogrammi (ogni nuovo dataframe eredita anche tutte le variabili del genitore)
    auto Ekin = DF_sim.Define("Ekin", Ekin_calc, {"ETot"}).Define("Peso", PesoEOT_calc, {"Weight1"});           //Creiamo il DF Ekin, ha una colonna Ekin, e una Peso
    auto DF_WeightsEOT = DF_sim.Define("Peso", PesoEOT_calc, {"Weight1"});                                      //Creiamo il DF con i pesi 

    //Creiamo il file che conterrà gli istogrammi
    TFile *contenitore = new TFile(Form("Analisi_%s.root",particella.c_str()), "recreate");
    TTree *alb = new TTree("Histograms", "Histograms");

    //Creiamo gli istogrammi, il ciclo di volta in volta filtra il dataframe per superficie 
    for(int i = 0; i < surf.size(); i++){

        //Filtro da usare: ad ogni ciclo creo dinamicamente l'espressione da passare alla funzione Filter
        string filter = "SurfaceID == " + std::to_string(surf[i]);

        //La funzione Filter essenzialmente crea un DF dove ci sono solo le entries che rispettano la condizione del filtro
        //La funzione Histo1D<double,double> (<tipo della colonna da istogrammare, tipo della colonna dei pesi> serve at ottimizzare il codice) crea l'istogramma 

        auto energy               = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_Det%d", particella.c_str(), surf[i]), Form("%s energy Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 200, 0, 0},"Ekin", "Peso");
        auto energy0_10KeV        = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_0_10_Det%d", particella.c_str(), surf[i]), Form("%s energy 0-10KeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 1e-5},"Ekin", "Peso");
        auto energy10_100KeV      = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_10_100_Det%d", particella.c_str(), surf[i]), Form("%s energy 10-100KeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 1e-5, 1e-4},"Ekin", "Peso");
        auto energy100KeV_10MeV   = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_100_10_Det%d", particella.c_str(), surf[i]), Form("%s energy 100KeV-10MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 1e-4, 0.01},"Ekin", "Peso");
        auto energy10_20MeV       = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_10_20_Det%d", particella.c_str(), surf[i]), Form("%s energy 10-20MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 0.01, 0.02},"Ekin", "Peso");
        auto energy20_100MeV      = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_20_100_Det%d", particella.c_str(), surf[i]), Form("%s energy 100KeV-10MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0.02, 0.1},"Ekin", "Peso");
        auto energy100MeV_11GeV   = Ekin.Filter(filter).Histo1D<double, double>({Form("%s_Energy_100_11_Det%d", particella.c_str(), surf[i]), Form("%s energy 100-11 Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 200, 0.1, 11},"Ekin", "Peso");

        auto XFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_x_Det%d", particella.c_str(), surf[i]), Form("%s x Det %d; x(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0},"Vx", "Peso");
        auto YFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_y_Det%d", particella.c_str(), surf[i]), Form("%s y Det %d; y(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0},"Vy", "Peso");
        auto ZFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_z_Det%d", particella.c_str(), surf[i]), Form("%s z Det %d; z(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0},"Vz", "Peso");

        auto PFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_p_Det%d", particella.c_str(), surf[i]), Form("%s p Det %d; p(GeV); Particles/EOT", particella.c_str(), i), 100, 0, 0},"P", "Peso");
        auto PxFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_px_Det%d", particella.c_str(), surf[i]), Form("%s p_x Det %d; px(GeV); Particles/EOT", particella.c_str(), i), 100, 0, 0},"Px", "Peso");
        auto PyFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_py_Det%d", particella.c_str(), surf[i]), Form("%s p_y Det %d; py(GeV); Particles/EOT", particella.c_str(), i), 100, 0, 0},"Py", "Peso");
        auto PzFiltered = DF_WeightsEOT.Filter(filter).Histo1D<double, double>({Form("%s_pz_Det%d", particella.c_str(), surf[i]), Form("%s p_z Det %d; pz(GeV); Particles/EOT", particella.c_str(), i), 100, 0, 0},"Pz", "Peso");

        //Questo permette di buildare gli istogrammi parallelamente (infatti non sono creati subito sopra per via delle <>)
        ROOT::RDF::RunGraphs({PFiltered, PxFiltered, PyFiltered, PzFiltered, XFiltered, YFiltered, ZFiltered, energy, energy0_10KeV, energy10_100KeV, energy100KeV_10MeV, energy10_20MeV, energy20_100MeV, energy100MeV_11GeV});
        
        //Saving degli istogrammi nel root file
        XFiltered->Write();
        YFiltered->Write();
        ZFiltered->Write();

        PFiltered->Write();
        PxFiltered->Write();
        PyFiltered->Write();
        PzFiltered->Write();

        energy->Write();
        energy0_10KeV->Write();
        energy10_100KeV->Write();
        energy100KeV_10MeV->Write();
        energy10_20MeV->Write();
        energy20_100MeV->Write();
        energy100MeV_11GeV->Write();

    }

    GetTimeNow(); cout<<"Done."<<endl;
    GetTimeNow(); cout<<"Saving histograms for neutrons..."<<endl;

    contenitore->Close();

    GetTimeNow(); cout<<"Done."<<endl;

}
