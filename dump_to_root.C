#include <string>

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

void dump_to_root(){

    string dump_file = find_dump();

    // cout<<dump_file<<endl;
    
    std::ifstream file(dump_file);

    int NCase, SurfaceID, ParticleID, TotEvents;
    string RegionIn, RegionOut;
    double ETot, P, Vx, Vy, Vz, Px, Py, Pz, Cx, Cy, Cz, Weight1, Weight2;
    
    //to skip the first line
    string line;
    getline(file, line);

    size_t lastindex = dump_file.find_last_of("_"); 
    string root_file_name = dump_file.substr(0, lastindex) + ".root";
    cout << root_file_name << endl;

    // TFile *contenitore = new TFile(root_file_name.c_str(), "recreate");
    // TTree *events = new TTree("events", "prova");

    while(!file.eof()){
        file >> NCase >> RegionIn >> RegionOut >> SurfaceID >> ParticleID >> ETot >> P >> Vx >> Vy >> Vz >> Px >> Py >> Pz >> Cx >> Cy >> Cz >> Weight1 >> Weight2;
        cout << NCase << "\t" << RegionIn << "\t" << RegionOut << "\t" << SurfaceID << "\t" << ParticleID << "\t" << ETot << "\t" << P << "\t" << Vx << "\t" << Vy << "\t" << Vz << "\t" << Px << "\t" << Py << "\t" << Pz << "\t" << Cx << "\t" << Cy << "\t" << Cz << "\t" << Weight1 << "\t" << "\t" << Weight2 << endl;
        // break;
    }

    // contenitore->Close();


}