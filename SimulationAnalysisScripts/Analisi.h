#ifndef Analisi_h
#define Analisi_h

#include <TROOT.h>
#include <TChain.h>
#include <TFile.h>
#include <dirent.h>
#include <sys/stat.h>

// Header file for the classes stored in the TTree if any.

class Analisi {
public :

   string root_files_dir;
   string merged_file;
   string global_option;

   TTree          *fChain;   //!pointer to the analyzed TTree or TChain
   Int_t           fCurrent; //!current Tree number in a TChain

// Fixed size dimensions of array or collections stored in the TTree if any.

   // Declaration of leaf types
 //Results         *flux;
   UInt_t          NCase;
   UInt_t          ParticleID;
   UInt_t          SurfaceID;
   string          *RegionIn;
   string          *RegionOut;
   Double_t        ETot;
   Double_t        P;
   Double_t        Vx;
   Double_t        Vy;
   Double_t        Vz;
   Double_t        Px;
   Double_t        Py;
   Double_t        Pz;
   Double_t        Cx;
   Double_t        Cy;
   Double_t        Cz;
   Double_t        Weight1;
   Double_t        Weight2;

   Int_t           TotEvents;

   // List of branches
   TBranch        *b_NCase;   //!
   TBranch        *b_ParticleID;   //!
   TBranch        *b_SurfaceID;   //!
   TBranch        *b_RegionIn;   //!
   TBranch        *b_RegionOut;   //!
   TBranch        *b_ETot;   //!
   TBranch        *b_P;   //!
   TBranch        *b_Vx;   //!
   TBranch        *b_Vy;   //!
   TBranch        *b_Vz;   //!
   TBranch        *b_Px;   //!
   TBranch        *b_Py;   //!
   TBranch        *b_Pz;   //!
   TBranch        *b_Cx;   //!
   TBranch        *b_Cy;   //!
   TBranch        *b_Cz;   //!
   TBranch        *b_Weight1;   //!
   TBranch        *b_Weight2;   //!

   TBranch        *b_RunSummary_TotEvents;   //!

   Analisi(TTree *tree=0);
   virtual ~Analisi();
   virtual Int_t    Cut(Long64_t entry);
   virtual Int_t    GetEntry(Long64_t entry);
   virtual Long64_t LoadTree(Long64_t entry);
   virtual void     Init(TTree *tree);
   virtual void     InitRunSummary(TTree *tree);
   virtual Bool_t   Notify();
   virtual void     Show(Long64_t entry = -1);

   //variabili aggiunte
   bool debug = 0;

   //Pre dichiarazoni di funzioni aggiunte post generazione del file
   virtual void     InitializeAll();
   virtual void     InitializeRunSummary();
   virtual void     Setter(std::string option, std::string path);
   virtual void     DebugMode();
   virtual int      GetNEOT();
   virtual vector<int>  GetNSup();
   virtual void     AnalyzeNeutrons(int nEOT, vector<int> surf);
   virtual TChain*  CreateChain(std::string tree_name);
   virtual TTree*   GetTree(std::string tree_name);
   virtual void     Process(std::string option, std::string path, std::string particle);

};

#endif

#ifdef Analisi_cxx
Analisi::Analisi(TTree *tree) : fChain(0){
   std::cout<<"Usage: \n";
   std::cout<<"Analisi_object.Process(\"ALL or MERGED\",\"path/ or merged.root\", \"neutron/muon/neutrino\")";
   Init(tree);
}

Analisi::~Analisi()
{
   if (!fChain) return;
   delete fChain->GetCurrentFile();
}

Int_t Analisi::GetEntry(Long64_t entry)
{
// Read contents of entry.
   if (!fChain) return 0;
   return fChain->GetEntry(entry);
}
Long64_t Analisi::LoadTree(Long64_t entry)
{
// Set the environment to read one entry
   if (!fChain) return -5;
   Long64_t centry = fChain->LoadTree(entry);
   if (centry < 0) return centry;
   if (fChain->GetTreeNumber() != fCurrent) {
      fCurrent = fChain->GetTreeNumber();
      Notify();
   }
   return centry;
}

void Analisi::Init(TTree *tree)
{
   // The Init() function is called when the selector needs to initialize
   // a new tree or chain. Typically here the branch addresses and branch
   // pointers of the tree will be set.
   // It is normally not necessary to make changes to the generated
   // code, but the routine can be extended by the user if needed.
   // Init() will be called many times when running on PROOF
   // (once per file to be processed).
   // Set object pointer
   RegionIn = 0;
   RegionOut = 0;
   // Set branch addresses and branch pointers
   if (!tree) return;
   fChain = tree;
   fCurrent = -1;
   fChain->SetMakeClass(1);

   fChain->SetBranchAddress("NCase", &NCase, &b_NCase);
   fChain->SetBranchAddress("ParticleID", &ParticleID, &b_ParticleID);
   fChain->SetBranchAddress("SurfaceID", &SurfaceID, &b_SurfaceID);
   fChain->SetBranchAddress("RegionIn", &RegionIn, &b_RegionIn);
   fChain->SetBranchAddress("RegionOut", &RegionOut, &b_RegionOut);
   fChain->SetBranchAddress("ETot", &ETot, &b_ETot);
   fChain->SetBranchAddress("P", &P, &b_P);
   fChain->SetBranchAddress("Vx", &Vx, &b_Vx);
   fChain->SetBranchAddress("Vy", &Vy, &b_Vy);
   fChain->SetBranchAddress("Vz", &Vz, &b_Vz);
   fChain->SetBranchAddress("Px", &Px, &b_Px);
   fChain->SetBranchAddress("Py", &Py, &b_Py);
   fChain->SetBranchAddress("Pz", &Pz, &b_Pz);
   fChain->SetBranchAddress("Cx", &Cx, &b_Cx);
   fChain->SetBranchAddress("Cy", &Cy, &b_Cy);
   fChain->SetBranchAddress("Cz", &Cz, &b_Cz);
   fChain->SetBranchAddress("Weight1", &Weight1, &b_Weight1);
   fChain->SetBranchAddress("Weight2", &Weight2, &b_Weight2);
   Notify();
}

void Analisi::InitRunSummary(TTree *tree)
{
   // Set branch addresses and branch pointers
   if (!tree) return;
   fChain = tree;
   fCurrent = -1;
   fChain->SetMakeClass(1);

   fChain->SetBranchAddress("TotEvents", &TotEvents, &b_RunSummary_TotEvents);
   Notify();
}

Bool_t Analisi::Notify()
{
   // The Notify() function is called when a new file is opened. This
   // can be either for a new TTree in a TChain or when when a new TTree
   // is started when using PROOF. It is normally not necessary to make changes
   // to the generated code, but the routine can be extended by the
   // user if needed. The return value is currently not used.

   return kTRUE;
}

void Analisi::Show(Long64_t entry)
{
// Print contents of entry.
// If entry is not specified, print current entry
   if (!fChain) return;
   fChain->Show(entry);
}
Int_t Analisi::Cut(Long64_t entry)
{
// This function may be called from Process.
// returns  1 if entry is accepted.
// returns -1 otherwise.
   return 1;
}
#endif // #ifdef Analisi_cxx
