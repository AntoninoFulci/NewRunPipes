#include <string>
#include <TFile.h>

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

int TimeDiff(const string fine, const string inizio) {
    using namespace std;

    time_t beginning_t, ending_t;

    tm *beginning = new tm();
    tm *ending = new tm();
    // struct tm beginning, ending;

    cout<<"Inizio - Y: "<<stoi(inizio.substr(0,4))<<" M: "<<stoi(inizio.substr(4,2))<<" D: "<<stoi(inizio.substr(6,2))<<" H: "<<stoi(inizio.substr(10,2))<<" m: "<<stoi(inizio.substr(12,2))<<" s: "<<stoi(inizio.substr(14,2))<<endl;
    beginning->tm_year = stoi(inizio.substr(0,4));
    beginning->tm_mon = stoi(inizio.substr(4,2));
    beginning->tm_mday = stoi(inizio.substr(6,2));
    beginning->tm_hour = stoi(inizio.substr(10,2));
    beginning->tm_min = stoi(inizio.substr(12,2));
    beginning->tm_sec = stoi(inizio.substr(14,2));
    beginning_t = mktime(beginning); 

    cout<<"Fine   - Y: "<<stoi(fine.substr(0,4))<<" M: "<<stoi(fine.substr(4,2))<<" D: "<<stoi(fine.substr(6,2))<<" H: "<<stoi(fine.substr(10,2))<<" m: "<<stoi(fine.substr(12,2))<<" s: "<<stoi(fine.substr(14,2))<<endl;

    ending->tm_year = stoi(fine.substr(0,4));
    ending->tm_mon = stoi(fine.substr(4,2));
    ending->tm_mday = stoi(fine.substr(6,2));
    ending->tm_hour = stoi(fine.substr(10,2));
    ending->tm_min = stoi(fine.substr(12,2));
    ending->tm_sec = stoi(fine.substr(14,2));
    ending_t =  mktime(ending);

    cout<<"Diff: "<<difftime(ending_t,beginning_t)<<endl;
    return difftime(ending_t,beginning_t);
}

// Macro principale
void dump_to_root_muons(){

    // Salva il nome in una stringa
    string dump_file = find_dump();
    // cout<<dump_file<<endl;
    
    // Apre il file
    std::ifstream file(dump_file);

    UInt_t NCase, ICode, MotherID, MuonID,TotEvents;
    Double_t M_ETot, M_P, M_Px, M_Py, M_Pz, M_Cx, M_Cy, M_Cz, M_Weight; //For the mother particle
    Double_t MuonEKin, MuonP, MuonVx, MuonVy, MuonVz, MuonPx, MuonPy, MuonPz,  MuonCx, MuonCy, MuonCz, MuonWeight; //For the muon
    Double_t AvgTime, TotTime;
    bool first = true;
    string inizio, fine, line;

    size_t lastindex = dump_file.find_last_of("_"); 
    string root_file_name = dump_file.substr(0, lastindex) + ".root";
    // cout << root_file_name << endl;

    TFile *contenitore = new TFile(root_file_name.c_str(), "recreate");
    TTree *Events = new TTree("Events", "Events");
    TTree *RunSummary = new TTree("RunSummary", "RunSummary");

    //Mother particle information
    Events -> Branch("NCase", &NCase);
    Events -> Branch("ICode", &ICode);

    Events -> Branch("MotherID", &MotherID);
    Events -> Branch("M_ETot", &M_ETot);
    Events -> Branch("M_P", &M_P);
    Events -> Branch("M_Px", &M_Px);
    Events -> Branch("M_Py", &M_Py);
    Events -> Branch("M_Pz", &M_Pz);
    Events -> Branch("M_Cx", &M_Cx);
    Events -> Branch("M_Cy", &M_Cy);
    Events -> Branch("M_Cz", &M_Cz);
    Events -> Branch("M_Weight", &M_Weight);

    //Muon information
    Events -> Branch("MuonID", &MuonID);
    Events -> Branch("MuonEKin", &MuonEKin);
    Events -> Branch("MuonP", &MuonP);
    Events -> Branch("MuonVx", &MuonVx);
    Events -> Branch("MuonVy", &MuonVy);
    Events -> Branch("MuonVz", &MuonVz);
    Events -> Branch("MuonPx", &MuonPx);
    Events -> Branch("MuonPy", &MuonPy);
    Events -> Branch("MuonPz", &MuonPz);    
    Events -> Branch("MuonCx", &MuonCx);
    Events -> Branch("MuonCy", &MuonCy);
    Events -> Branch("MuonCz", &MuonCz);
    Events -> Branch("MuonWeight", &MuonWeight);

    //Run summary information
    RunSummary -> Branch("AvgTime", &AvgTime);
    RunSummary -> Branch("TotTime", &TotTime);
    RunSummary -> Branch("TotEvents", &TotEvents);

    //Retrieve information from txt file
    ofstream myfile {"test.txt"};

    while(getline(file, line)){
        // cout<<line<<endl;
        if(first){
            first = false;
            inizio = line.substr(0,20);

            //skip the second line
            getline(file, line);
            getline(file, line);
        }
        if(line.find("#####")!= string::npos){

            getline(file, line);
            std::stringstream sstream1(line);
            sstream1 >> AvgTime;

            getline(file, line);
            fine = line.substr(0,20);

            getline(file, line);
            std::stringstream sstream3(line);
            sstream3 >> TotEvents;

            TotTime = TimeDiff(fine, inizio);
            RunSummary -> Fill();
            break;
        }
        else{
            std::stringstream sstream(line);
            sstream >>  NCase >>  ICode >>  MotherID >> M_ETot >> M_P >> M_Px >> M_Py >> M_Pz >> M_Cx >> M_Cy >> M_Cz >> M_Weight >> MuonID >> MuonEKin >> MuonP >> MuonVx >> MuonVy >> MuonVz >> MuonPx >> MuonPy >> MuonPz >> MuonCx >> MuonCy >> MuonCz >> MuonWeight;
            myfile << NCase << "\t" <<ICode << "\t" <<MotherID << "\t" <<M_ETot << "\t" <<M_P << "\t" <<M_Px << "\t" <<M_Py << "\t" <<M_Pz << "\t" <<M_Cx << "\t" <<M_Cy << "\t" <<M_Cz << "\t" <<M_Weight << "\t" <<MuonID << "\t" <<MuonEKin << "\t" <<MuonP << "\t" <<MuonVx << "\t" <<MuonVy << "\t" <<MuonVz << "\t" <<MuonPx << "\t" <<MuonPy << "\t" <<MuonPz << "\t" <<MuonCx << "\t" <<MuonCy << "\t" <<MuonCz << "\t" <<MuonWeight << endl;
            Events -> Fill();
        }
        
    } 
    myfile.close();



    Events -> Write();
    RunSummary -> Write();
    contenitore->Close();


}