#include <string>

// Funzione che scansiona la cartella alla ricerca di un file che finisce per "_dump.txt"
string find_dump(const char *dirname="./", const char *ext="_dump.txt") {
    string defa = "null";
    TSystemDirectory dir(dirname, dirname); 
    TList *files = dir.GetListOfFiles(); 
    if (files) { 
        TSystemFile *file; 
        TString fname; 
        TIter next(files); 
        while ((file=(TSystemFile*)next())) { 
            fname = file->GetName(); 
            if (!file->IsDirectory() && fname.EndsWith(ext)) {
                defa = fname.Data();
                if(defa != "null") return fname.Data();
            } 
        }
    }

    return defa;
}

// Macro principale
void dump_to_root(){

    // Salva il nome in una stringa
    string dump_file = find_dump();
    
    // Apre il file
    std::ifstream file(dump_file);

    UInt_t NCase, SurfaceID, ParticleID, TotEvents;
    string RegionIn, RegionOut;
    Double_t ETot, P, Vx, Vy, Vz, Px, Py, Pz, Cx, Cy, Cz, Weight1, Weight2;
    Double_t AvgTime, TotTime;
    
    //to skip the first line
    string line;
    getline(file, line);

    size_t lastindex = dump_file.find_last_of("_"); 
    string root_file_name = dump_file.substr(0, lastindex) + ".root";
    cout << root_file_name << endl;

    TFile *contenitore = new TFile(root_file_name.c_str(), "recreate");
    TTree *Events = new TTree("Events", "Events");
    TTree *RunSummary = new TTree("RunSummary", "RunSummary");

    Events -> Branch("NCase", &NCase);
    Events -> Branch("ParticleID", &ParticleID);
    Events -> Branch("SurfaceID", &SurfaceID);
    Events -> Branch("RegionIn", &RegionIn);
    Events -> Branch("RegionOut", &RegionOut);
    Events -> Branch("ETot", &ETot);
    Events -> Branch("P", &P);
    Events -> Branch("Vx", &Vx);
    Events -> Branch("Vy", &Vy);
    Events -> Branch("Vz", &Vz);
    Events -> Branch("Px", &Px);
    Events -> Branch("Py", &Py);
    Events -> Branch("Pz", &Pz);
    Events -> Branch("Cx", &Cx);
    Events -> Branch("Cy", &Cy);
    Events -> Branch("Cz", &Cz);
    Events -> Branch("Weight1", &Weight1);
    Events -> Branch("Weight2", &Weight2);

    RunSummary -> Branch("AvgTime", &AvgTime);
    RunSummary -> Branch("TotTime", &TotTime);
    RunSummary -> Branch("TotEvents", &TotEvents);

    while(getline(file, line)){
        // cout<<line<<endl;
        if(line.find("#####")!= string::npos){

            getline(file, line);
            std::stringstream sstream1(line);
            sstream1 >> AvgTime;

            getline(file, line);
            std::stringstream sstream2(line);
            sstream2 >> TotTime;

            getline(file, line);
            std::stringstream sstream3(line);
            sstream3 >> TotEvents;

            RunSummary -> Fill();
            break;
        }
        else{
            std::stringstream sstream(line);
            sstream >> NCase >> RegionIn >> RegionOut >> SurfaceID >> ParticleID >> ETot >> P >> Vx >> Vy >> Vz >> Px >> Py >> Pz >> Cx >> Cy >> Cz >> Weight1 >> Weight2;
            Events -> Fill();
        }
        
    }

    Events -> Write();
    RunSummary -> Write();
    contenitore->Close();


}