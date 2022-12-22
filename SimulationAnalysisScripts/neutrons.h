///////////////////////////////////////////////////
//File used to inizialize neutrons
///////////////////////////////////////////////////

void Analisi::AnalyzeNeutrons(int nEOT, vector<int> surf){

  string particella = "neutron";

  /////////////////////////////////////////////////////////////
  //                  Definizione istogrammi                 //
  /////////////////////////////////////////////////////////////

  int LogBinNumber = 10000;
  vector<double> LogBinningEdges = LogBinning(11, 1e-14, LogBinNumber);
	double* LogBinningEdges_array = &LogBinningEdges[0];

  vector<TH2D*> SptDistr; TH2D *h_SptDistr;
  vector<TH2D*> EvsMID;   TH2D *h_EvsMID;
  vector<TH2D*> th_pVSr;  TH2D *h_th_pVSr;
  vector<TH2D*> m_EVSr;   TH2D *h_m_EVSr;

  vector<TH1D*> energy;           TH1D *h_energy;
	vector<TH1D*> energyLog;        TH1D *h_energyLog;
	vector<TH1D*> energy0_20MeV;    TH1D *h_energy0_20MeV;

	vector<TH1D*> energy0_10KeV;       TH1D *h_energy0_10KeV;
	vector<TH1D*> energy10_100KeV;     TH1D *h_energy10_100KeV;
	vector<TH1D*> energy100KeV_10MeV;  TH1D *h_energy100KeV_10MeV;
	vector<TH1D*> energy10_20MeV;      TH1D *h_energy10_20MeV;
	vector<TH1D*> energy20_100MeV;     TH1D *h_energy20_100MeV;
	vector<TH1D*> energy100MeV_11GeV;  TH1D *h_energy100MeV_11GeV;

  vector<TH1D*> x;    TH1D *h_x;
  vector<TH1D*> y;    TH1D *h_y;
  vector<TH1D*> z;    TH1D *h_z;

  vector<TH1D*> p;    TH1D *h_p;
  vector<TH1D*> px;   TH1D *h_px;
  vector<TH1D*> py;   TH1D *h_py;
  vector<TH1D*> pz;   TH1D *h_pz;

  vector<TH1D*> r;    TH1D *h_r;

  vector<TH1D*> theta_p;  TH1D *h_theta_p;

  for(int i=0; i<surf.size(); i++){

    if(surf[i]>100 && surf[i]<200){
      h_SptDistr  = new TH2D(Form("%s_XvsZ_Det%d", particella.c_str(), surf[i]), Form("%s X vs Z Det %d; x(cm); z(cm)", particella.c_str(), surf[i]), 100, 0, 0, 100, 0, 0);
    }
    else{
      h_SptDistr  = new TH2D(Form("%s_XvsY_Det%d", particella.c_str(), surf[i]), Form("%s X vs Y Det %d; x(cm); y(cm)", particella.c_str(), surf[i]), 100, 0, 0, 100, 0, 0);
    }

    h_EvsMID  = new TH2D(Form("%s_h_EvsMID_Det%d", particella.c_str(), surf[i]), Form("%s Energy VS MotherID %d; E(GeV); M_ID", particella.c_str(), surf[i]), 100, 0, 0, 100, 0, 0);

    h_th_pVSr = new TH2D(Form("%s_th_pVSr_Det%d", particella.c_str(), surf[i]), Form("%s Theta_p VS R Det %d; #theta_{p}(#circ); r(cm)", particella.c_str(), surf[i]), 100, 0, 0, 100, 0, 0);
    h_m_EVSr = new TH2D(Form("%s_m_EVSr_Det%d", particella.c_str(), surf[i]), Form("%s m_E VS r Det %d; E(GeV); r(cm)", particella.c_str(), i), 100, 0, 0, 100, 0, 0);

    h_x = new TH1D(Form("%s_x_Det%d", particella.c_str(), surf[i]), Form("%s x Det %d; x(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);
    h_y = new TH1D(Form("%s_y_Det%d", particella.c_str(), surf[i]), Form("%s y Det %d; y(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);
    h_z = new TH1D(Form("%s_z_Det%d", particella.c_str(), surf[i]), Form("%s z Det %d; z(cm); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);

    h_p   = new TH1D(Form("%s_p_Det%d", particella.c_str(), surf[i]), Form("%s p Det %d; p(GeV); Particles/EOT", particella.c_str(), i), 100, 0, 0);
    h_px  = new TH1D(Form("%s_px_Det%d", particella.c_str(), surf[i]), Form("%s p_x Det %d; p_{x}(GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);
    h_py  = new TH1D(Form("%s_py_Det%d", particella.c_str(), surf[i]), Form("%s p_y Det %d; p_{y}(GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);
    h_pz  = new TH1D(Form("%s_pz_Det%d", particella.c_str(), surf[i]), Form("%s p_z Det %d; p_{z}(GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);

    h_r  = new TH1D(Form("%s_r_Det%d", particella.c_str(), surf[i]), Form("%s r Det %d; r(cm); Particles/EOT", particella.c_str(), i), 100, 0, 0);
    h_theta_p  = new TH1D(Form("%s_theta_p_Det%d", particella.c_str(), surf[i]), Form("%s theta_p Det %d; #theta_{p}(#circ); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 0);

    h_energy  = new TH1D(Form("%s_Energy_Det%d", particella.c_str(), surf[i]), Form("%s energy Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 200, 0, 0);
    h_energyLog  = new TH1D(Form("%s_EnergyLog_Det%d", particella.c_str(), surf[i]), Form("%s energy Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), LogBinNumber, LogBinningEdges_array);
    h_energy0_20MeV       = new TH1D(Form("%s_Energy_0_20_Det%d", particella.c_str(), surf[i]), Form("%s energy 0-20MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 300, 0, 0.02);

    h_energy0_10KeV       = new TH1D(Form("%s_Energy_0_10_Det%d", particella.c_str(), surf[i]), Form("%s energy 0-10KeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0, 1e-5);
    h_energy10_100KeV     = new TH1D(Form("%s_Energy_10_100_Det%d", particella.c_str(), surf[i]), Form("%s energy 10-100KeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 1e-5, 1e-4);
    h_energy100KeV_10MeV  = new TH1D(Form("%s_Energy_100_10_Det%d", particella.c_str(), surf[i]), Form("%s energy 100KeV-10MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 1e-4, 0.01);
    h_energy10_20MeV      = new TH1D(Form("%s_Energy_10_20_Det%d", particella.c_str(), surf[i]), Form("%s energy 10-20MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 10, 0.01, 0.02);
    h_energy20_100MeV     = new TH1D(Form("%s_Energy_20_100_Det%d", particella.c_str(), surf[i]), Form("%s energy 100KeV-10MeV Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 100, 0.02, 0.1);
    h_energy100MeV_11GeV  = new TH1D(Form("%s_Energy_100_11_Det%d", particella.c_str(), surf[i]), Form("%s energy 100-11 Det %d; E (GeV); Particles/EOT", particella.c_str(), surf[i]), 200, 0.1, 11);

    SptDistr.push_back(h_SptDistr);
    EvsMID.push_back(h_EvsMID);
    th_pVSr.push_back(h_th_pVSr);
    m_EVSr.push_back(h_m_EVSr);

    x.push_back(h_x);
    y.push_back(h_y);
    z.push_back(h_z);

    p.push_back(h_p);
    py.push_back(h_py);
    px.push_back(h_px);
    pz.push_back(h_pz);

    r.push_back(h_r);
    theta_p.push_back(h_theta_p);

    energy              .push_back(h_energy);
    energyLog           .push_back(h_energyLog);

    energy0_20MeV       .push_back(h_energy0_20MeV);

    energy0_10KeV       .push_back(h_energy0_10KeV);
    energy10_100KeV     .push_back(h_energy10_100KeV);
    energy100KeV_10MeV  .push_back(h_energy100KeV_10MeV);
    energy10_20MeV      .push_back(h_energy10_20MeV);
    energy20_100MeV     .push_back(h_energy20_100MeV);
    energy100MeV_11GeV  .push_back(h_energy100MeV_11GeV);
  }
  /////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////
  //                 Inizio analisi dei file                 //
  /////////////////////////////////////////////////////////////


  double n_m	= 0.939565378;			//neutron mass in GeV
  double n_px(0), n_py(0), n_pz(0), n_p(0), n_r_p(0), n_th_p(0);
  double n_r(0), n_Ek(0), peso_eot(0);


  //Initialize the root files
  // GetTimeNow(); cout<<"Initializing root_files..."<<endl;
  // InitializeAll();
  // GetTimeNow(); cout<<"Done..."<<endl;

  GetTimeNow(); cout<<"Building histograms for neutrons..."<<endl;

  Long64_t nentries = fChain->GetEntriesFast();
  Long64_t nbytes = 0, nb = 0;
  cout<<nEOT<<endl;
  for (Long64_t jentry=0; jentry<nentries;jentry++) {
    //***************************************************
    Long64_t ientry = LoadTree(jentry);
    if (ientry < 0) break;
    nb = fChain->GetEntry(jentry);
    nbytes += nb;
    //***************************************************

    //Definizione peso per eot
    peso_eot = Weight1*0.03326392857/nEOT; // /nEOT;

    //Neutron kin energy & momentum
    n_Ek = ETot - n_m;
    n_p = sqrt(pow(ETot,2.0)-pow(n_m, 2.0));

    //Current particle r from center
    // m_r =     sqrt(m_vx*m_vx + m_vy*m_vy);
    //Neutron momentum radius & theta
    // n_r_p =   sqrt(n_px*n_px + n_py*n_py + n_pz*n_pz);
    // n_th_p =  atan2(sqrt(n_px*n_px+n_py*n_py),n_pz) * 180 / M_PI;

    //Filling
    for(int i = 0; i<surf.size(); i++){
      //neutrino e antinuetrino elettronico
      //for the old simulation swhere flux_ID start from 0 purt surf[i]-1
      if(SurfaceID == surf[i]-1 && (ParticleID == 8)){

        if(surf[i]>100 && surf[i]<200){
          SptDistr[i]-> Fill(Vx, Vz, peso_eot);
        }
        else{
          SptDistr[i]-> Fill(Vx, Vy, peso_eot);
        }

        x[i]      -> Fill(Vx,peso_eot);
        y[i]      -> Fill(Vy,peso_eot);
        z[i]      -> Fill(Vz,peso_eot);

        p[i]      -> Fill(P,peso_eot);
        px[i]     -> Fill(Px,peso_eot);
        py[i]     -> Fill(Py,peso_eot);
        pz[i]     -> Fill(Pz,peso_eot);

        energy[i]   -> Fill(n_Ek,peso_eot);
        energyLog[i]-> Fill(n_Ek,peso_eot);

        energy0_20MeV[i]       -> Fill(n_Ek,peso_eot);

        energy0_10KeV[i]       -> Fill(n_Ek,peso_eot);
        energy10_100KeV[i]     -> Fill(n_Ek,peso_eot);
        energy100KeV_10MeV[i]  -> Fill(n_Ek,peso_eot);
        energy10_20MeV[i]      -> Fill(n_Ek,peso_eot);
        energy20_100MeV[i]     -> Fill(n_Ek,peso_eot);
        energy100MeV_11GeV[i]  -> Fill(n_Ek,peso_eot);

      }
    }

  }

  GetTimeNow(); cout<<"Done."<<endl;
  GetTimeNow(); cout<<"Saving histograms for neutrons..."<<endl;

  TFile *contenitore = new TFile(Form("Analisi_%s.root",particella.c_str()), "recreate");
  TTree *alb = new TTree("Histograms", "Histograms");

  TCanvas *c;
  MkDir("Graphs");

  for(int i=0; i<surf.size(); i++){
    c = new TCanvas(Form("Canvas_%d",i), Form("Canvas_%d",i), 1800, 1000);
    c->Divide(3,2);

    SptDistr[i]          -> Write();

    energy[i]            -> Write();
    energyLog[i]         -> Write();
    energy0_20MeV[i]     -> Write();

    c->cd(1);
    energy0_10KeV[i]     -> Draw("histe");
    c->cd(2);
    energy10_100KeV[i]   -> Draw("histe");
    c->cd(3);
    energy100KeV_10MeV[i]-> Draw("histe");
    c->cd(4);
    energy10_20MeV[i]    -> Draw("histe");
    c->cd(5);
    energy20_100MeV[i   ]-> Draw("histe");
    c->cd(6);
    energy100MeV_11GeV[i]-> Draw("histe");

    c->SaveAs(Form("Graphs/Surface_%d.pdf",surf[i]));

    energy0_10KeV[i]     -> Write();
    energy10_100KeV[i]   -> Write();
    energy100KeV_10MeV[i]-> Write();
    energy10_20MeV[i]    -> Write();
    energy20_100MeV[i]   -> Write();
    energy100MeV_11GeV[i]-> Write();

    x[i]   ->Write();
    y[i]   ->Write();
    z[i]   ->Write();

    p[i]   -> Write();
    px[i]  -> Write();
    py[i]  -> Write();
    pz[i]  -> Write();

    }

  contenitore->Close();

  GetTimeNow(); cout<<"Done."<<endl;




}
