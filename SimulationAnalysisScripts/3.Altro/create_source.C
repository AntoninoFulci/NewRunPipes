#define create_source_cxx
#include "create_source.h"
#include <TH2.h>
#include <TStyle.h>
#include <TCanvas.h>
#include <THnSparse.h>

void create_source::Loop(){
   gSystem->Exec("mkdir ./Graphs");
   gSystem->Exec("mkdir ./Graphs/Source/");

   if (fChain == 0) return;

   Long64_t nentries = fChain->GetEntriesFast();

   //Inizializzazione istogrammi per gli spettri
   TH1D *h_energy0_10KeV       = new TH1D("Energy_0_10_Det", "energy 0-10KeV; E (GeV); Particles/EOT", 100, 0, 1e-5);
   TH1D *h_energy10_100KeV     = new TH1D("Energy_10_100_Det", "energy 10-100KeV ; E (GeV); Particles/EOT", 10, 1e-5, 1e-4);
   TH1D *h_energy100KeV_10MeV  = new TH1D("Energy_100_10_Det", "energy 100KeV-10MeV ; E (GeV); Particles/EOT", 10, 1e-4, 0.01);
   TH1D *h_energy10_20MeV      = new TH1D("Energy_10_20_Det", "energy 10-20MeV ; E (GeV); Particles/EOT", 10, 0.01, 0.02);
   TH1D *h_energy20_100MeV     = new TH1D("Energy_20_100_Det", "energy 100KeV-10MeV ; E (GeV); Particles/EOT", 100, 0.02, 0.1);
   TH1D *h_energy100MeV_11GeV  = new TH1D("Energy_100_11_Det", "energy 100-11 ; E (GeV); Particles/EOT", 200, 0.1, 11);

   TH1D *EnergySource = new TH1D("EnergySource", "EnergySource; E_{kin}(GeV); Particles/EOT", 200, 0, 0);

   //Inizializzazione istogramma multidimensionale dal quale generare la sorgente
   //Dimensione:       0,       1,   2,    3,    4,  5,   6   
   //Variabile         P,       x,   y,    z,   cx, cy,  cz
   Int_t bins[8] =    {2500,   500,  500,  500, 200, 200, 200, 1000};            //array con il numero di bin
   Double_t xmin[8] = {0,   -250,   -250,  4492,  -1,  -1,  -1, 0};              //array con i limiti inferiori
   Double_t xmax[8] = {5,   250,  250,  6204,   1,   1,  1, 2};                  //array con i limiti massimi

   THnSparseD *histo = new THnSparseD("hs", "hs", 8, bins, xmin, xmax);
   THnSparseD *histo_regen = new THnSparseD("hs_r", "hs_r", 8, bins, xmin, xmax);
   histo->Sumw2();                                                         //Enable calculation of errors.                    

   Long64_t nbytes = 0, nb = 0;

   double Ekin;
   double neutron_mass = 939.565378/1000; //GeV/c^2

   int cont = 0;
   int cont2 = 0;
   int cont3 = 0;
   
   double peso_eot;
   double errore;

   double temp[8] = {};

   for (Long64_t jentry=0; jentry<nentries;jentry++) {
      Long64_t ientry = LoadTree(jentry);
      if (ientry < 0) break;
      nb = fChain->GetEntry(jentry);   nbytes += nb;
      // if (Cut(ientry) < 0) continue;

      Ekin = ETot - neutron_mass;
      peso_eot = Weight1;

      h_energy0_10KeV       -> Fill(Ekin,peso_eot);
      h_energy10_100KeV     -> Fill(Ekin,peso_eot);
      h_energy100KeV_10MeV  -> Fill(Ekin,peso_eot);
      h_energy10_20MeV      -> Fill(Ekin,peso_eot);
      h_energy20_100MeV     -> Fill(Ekin,peso_eot);
      h_energy100MeV_11GeV  -> Fill(Ekin,peso_eot);

      //Riempiamo l'istogramma multidimensionale solo con i neutroni che vanno verso l'alto
      if(SurfaceID == 300 && Cy > 0){
         EnergySource -> Fill(Ekin, peso_eot);
         cont++;

         temp[0] = P;
         temp[1] = Vx;
         temp[2] = Vy;
         temp[3] = Vz;
         temp[4] = Cx;
         temp[5] = Cy;
         temp[6] = Cz;
         temp[7] = Weight1;

         histo -> Fill(temp, Weight1);

         //Conta i neutroni con energia maggiore di 20 MeV
         if(Ekin>0.02){
            cont3++;
         }
      }
      cont2++;
      
   }

   TFile *filez = new TFile("NDistribution.root", "recreate");
   // TTree *alb = new TTree("Histograms", "Histograms");
   histo -> Write();

   // cout<<"Totale neutroni: "<<cont2<<endl;
   double integrale = EnergySource->IntegralAndError(1, 200, errore);
   cout<<"Totale neutroni Cy > 0 uscenti dalla superficie 300 (con peso): "<<integrale << " errore: " << errore << "("<<errore/integrale*100 <<"%)"<<endl;
   // cout<<"Neutroni con Ekin > 0.02 GeV: "<<cont3<<endl;

   //Creaimo e stampiamo gli spettri con il rispettivo numero di neutroni/eot

   vector<TPaveText*> pts;
    TPaveText *pt;
    for (int i=0; i<6; i++){
        pt = new TPaveText();
        pt->SetX1NDC(0.60);
        pt->SetY1NDC(0.75);
        pt->SetX2NDC(0.97);
        pt->SetY2NDC(0.92);
        pt->SetTextSize(0.033);
        pt->SetTextFont(42);
        pt->SetBorderSize(1);
        pt->SetFillColor(0);
        pts.push_back(pt);

    }

   TCanvas *c = new TCanvas("canvas1", "canvas1", 1800, 1000);
   c->Divide(3,2);

   c->cd(1);
   gPad->SetLogx();
   gPad->SetLogy();
   pts[0]->AddText(Form("No. of n/EOT = %1.2E", h_energy0_10KeV->Integral()));
   h_energy0_10KeV      -> Draw("histe");
   pts[0]->Draw();

   c->cd(2);
   pts[1]->AddText(Form("No. of n/EOT = %1.2E", h_energy10_100KeV->Integral()));
   h_energy10_100KeV    -> Draw("histe");
   pts[1]->Draw();

   c->cd(3);
   pts[2]->AddText(Form("No. of n/EOT = %1.2E", h_energy100KeV_10MeV->Integral()));
   h_energy100KeV_10MeV -> Draw("histe");
   pts[2]->Draw();

   c->cd(4);
   pts[3]->AddText(Form("No. of n/EOT = %1.2E", h_energy10_20MeV->Integral()));
   h_energy10_20MeV     -> Draw("histe");
   pts[3]->Draw();

   c->cd(5);
   pts[4]->AddText(Form("No. of n/EOT = %1.2E", h_energy20_100MeV->Integral()));
   h_energy20_100MeV    -> Draw("histe");
   pts[4]->Draw();

   c->cd(6);
   pts[5]->AddText(Form("No. of n/EOT = %1.2E", h_energy100MeV_11GeV->Integral()));
   gPad->SetLogx();
   gPad->SetLogy();
   h_energy100MeV_11GeV -> Draw("histe");
   pts[5]->Draw();

   gStyle->SetImageScaling(5.);
   c->SaveAs("Graphs/Source/create_source.png");

   //Creiamo e stampiamo le distribuzioni dell'istogramma multidimensionale
   TCanvas *c2 = new TCanvas("canvas", "canvas", 1800, 1000);
   c2->Divide(3,3);
   c2->cd(1);
   gPad->SetLogx();
   gPad->SetLogy();
   TH1D *p = histo->Projection(0);
   p->SetTitle("P");
   p->Draw("hist");
   
   c2->cd(2);
   TH1D *vx = histo->Projection(1);
   vx->SetTitle("vx");
   vx->Draw("hist");

   c2->cd(3);
   TH1D *vy = histo->Projection(2);
   vy->SetTitle("vy");
   vy->Draw("hist");

   c2->cd(4);
   TH1D *vz = histo->Projection(3);
   vz->SetTitle("vz");
   vz->Draw("hist");

   c2->cd(5);
   TH1D *cx = histo->Projection(4);
   cx->SetTitle("cx");
   cx->Draw("hist");

   c2->cd(6);
   TH1D *cy = histo->Projection(5);
   cy->SetTitle("cy");
   cy->Draw("hist");

   c2->cd(7);
   TH1D *cz = histo->Projection(6);
   cz->SetTitle("cz");
   cz->Draw("hist");

   c2->cd(8);
   TH1D *wei = histo->Projection(7);
   wei->SetTitle("weight");
   wei->Draw("hist");

   gStyle->SetImageScaling(5.);
   c2->SaveAs("Graphs/Source/Distributions.png");

   double tmp[8] = {};

   ofstream myfile2;
   myfile2.open ("source.txt");
   for(int i=0; i<1000000; i++){
      histo->GetRandom(tmp);
      // myfile<<ParticleID<< "\t" <<P<< "\t" <<Vx<< "\t" <<Vy<< "\t" <<Vz<< "\t" <<Cx<< "\t" <<Cy<< "\t" <<Cz<< "\t" <<Weight1<<endl;
      myfile2<<8<<"\t"<<tmp[0]<<"\t"<<tmp[1]<<"\t"<<tmp[2]<<"\t"<<tmp[3]<<"\t"<<tmp[4]<<"\t"<<tmp[5]<<"\t"<<tmp[6]<<"\t"<<1<<endl;

      histo_regen -> Fill(tmp, 1);

   }

   myfile2.close();

   //Creiamo e stampiamo le distribuzioni dell'istogramma multidimensionale
   TCanvas *c3 = new TCanvas("canvas", "canvas", 1800, 1000);
   c3->Divide(3,3);
   c3->cd(1);
   gPad->SetLogx();
   gPad->SetLogy();
   TH1D *p_r = histo_regen->Projection(0);
   p_r->SetTitle("P");
   p_r->Draw("hist");
   
   c3->cd(2);
   TH1D *vx_r = histo_regen->Projection(1);
   vx_r->SetTitle("vx");
   vx_r->Draw("hist");

   c3->cd(3);
   TH1D *vy_r = histo_regen->Projection(2);
   vy_r->SetTitle("vy");
   vy_r->Draw("hist");

   c3->cd(4);
   TH1D *vz_r = histo_regen->Projection(3);
   vz_r->SetTitle("vz");
   vz_r->Draw("hist");

   c3->cd(5);
   TH1D *cx_r = histo_regen->Projection(4);
   cx_r->SetTitle("cx");
   cx_r->Draw("hist");

   c3->cd(6);
   TH1D *cy_r = histo_regen->Projection(5);
   cy_r->SetTitle("cy");
   cy_r->Draw("hist");

   c3->cd(7);
   TH1D *cz_r = histo_regen->Projection(6);
   cz_r->SetTitle("cz");
   cz_r->Draw("hist");   
   
   c3->cd(8);
   TH1D *wei_r = histo_regen->Projection(7);
   wei_r->SetTitle("weight");
   wei_r->Draw("hist");

   gStyle->SetImageScaling(5.);
   c3->SaveAs("Graphs/Source/DistributionsRegen.png");

}
