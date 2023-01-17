#define Analisi_cxx
#include "Analisi.h"
#include <TH2.h>
#include <TStyle.h>
#include <TCanvas.h>
#include <ROOT/RDataFrame.hxx>
#include <chrono>
#include <ctime>

#include "util.h"
#include "setter.h"
#include "init.h"
#include "neutrons.h"

//Get the number of electrons in the simulation
int Analisi::GetNEOT(){

  InitializeRunSummary();
  int ElectronNumber = 0;

  Long64_t nentries = fChain->GetEntriesFast();
  Long64_t nbytes = 0, nb = 0;

  for (Long64_t jentry=0; jentry<nentries; jentry++) {
    Long64_t ientry = LoadTree(jentry);
    if (ientry < 0) break;
    nb = fChain->GetEntry(jentry);   nbytes += nb;

    ElectronNumber = ElectronNumber + TotEvents;
  }

  return ElectronNumber;
}

//Get the number of surfaces used on the mgdraw.f file
vector<int> Analisi::GetNSup(std::string path){
  vector <int> surfaces;

  ROOT::EnableImplicitMT(10); // Tell ROOT you want to go parallel
  ROOT::RDataFrame DF_SurfaceID("Events", path);
  auto h_fluxID = DF_SurfaceID.Histo1D({"SurfaceID", "SurfaceID", 1000u, 0., 1000.}, "SurfaceID");

  for(int i = 1; i<=h_fluxID->GetNbinsX(); i++){
    if(h_fluxID->GetBinContent(i) != 0){
      surfaces.push_back(h_fluxID->GetBinCenter(i));
    }
  }

  ROOT::DisableImplicitMT();
  return surfaces;

}


void Analisi::Process(const std::string option, const std::string path, const std::string particle){
  
  if(option != "ALL" && option != "MERGED"){
    cout<<"Wrong option!"<<endl;
    return;
  }

  auto start_t = std::chrono::steady_clock::now();

  // DebugMode();

  //option = 1) ALL: all files in a TCHAIN 2) MERGED: use a merged file
  Setter(option, path);

  //Getting the total number of electrons simulated
  int nEOT = GetNEOT();
  GetTimeNow(); cout<<"Total number of electrons simulated: "<<nEOT<<endl;

  //Getting the surfaces
  vector<int> surf = GetNSup(path);
  GetTimeNow(); cout<<"Total number of surfaces found: "<<surf.size()<<endl;
  GetTimeNow(); cout<<"Surfaces found: "<<endl;
  for(auto i:surf){
    cout<<i<<" ";
  }
  cout<<endl;

  GetTimeNow(); cout<<"Analyzing files..."<<endl;
  InitializeAll();
  if(particle == "neutron"){
    AnalyzeNeutrons(nEOT, surf);
  }
  else{
    cout<<"Wrong particle name."<<endl;
    return;
  }


  auto end_t = std::chrono::steady_clock::now();
  std::chrono::duration<double> elapsed_seconds = end_t-start_t;
  cout<<"Total time: "<<elapsed_seconds.count()<<" s" <<endl;

}
