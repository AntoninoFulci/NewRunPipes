void multi(std::map<std::string, std::string> Files, int Surf){
    // gStyle->SetLegendBorderSize(1);
    gStyle->SetOptStat("eir");
    int pad = 1;
    int cont = 0;

    map<int, int> markers= {{1,20}, {2,21}, {3,22}, {4,23}, {5,29}, {6,33}, {7,34}, {8,43}, {9,45}};

    vector<string> ranges = {"Energy_0-11", "Energy_0-1e-05", "Energy_1e-05-0.0001", "Energy_0.0001-0.01", "Energy_0.01-0.02", "Energy_0.02-0.1", "Energy_0.1-11"};


    TCanvas *c = new TCanvas("prova", "prova", 600*3, 600*3);
    c->SetGrid();
    c->SetLogy();
    c->Divide(3, 3, 0.01, 0.01);

    for(auto range : ranges){
        cout<< range <<endl;

        THStack *hs = new THStack(Form("Hs_%s", range.c_str()), Form("Neutron %s", range.c_str()));
        TLegend *leg = new TLegend(0.35,0.2);     leg->SetTextSize(0.035);

        for ( const auto &[key, value]: Files ) {
            cont++;

            // cout << key << "  " << value << endl;

            TFile *f = TFile::Open(value.c_str(), "READ");
            f->cd(range.c_str());

            TH1D *h = (TH1D*)gDirectory->Get(Form("Neutron_Energy_Det%d",Surf));
            h->SetLineColor(cont);
            h->SetMarkerStyle(markers[cont]); 
            h->SetMarkerColor(cont);
            h->SetLineWidth(3);
            hs->Add(h);

            leg->AddEntry(h, key.c_str(), "PL");

        }
        
        if(pad == 1) c->cd(2);
        else if(pad > 1) c->cd(pad+2);

        gPad->SetLogy();
        gPad->SetGrid();

        hs->Draw("histe nostack");
        leg->Draw("same");

        pad++;
        // cout<<cont<<endl;
        cont = 0;

    }

    cout<<"Salvando..."<<endl;
    gStyle->SetImageScaling(3);
    gSystem->Exec("mkdir ./Graphs");
    c->SaveAs(Form("Graphs/MultiSpectra%d.png",Surf));



}

void MultiSpectra(){
    std::map<std::string, std::string> Files;
    // Files["Electron source"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-07 - HallA - Creazione sorgente di neutroni - NoBias/Graphs/Graphs.root";
    // Files["Neutron source 300"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-10 - HallA - DaNeutroni300/BigSim/Graphs/Graphs.root";
    Files["Neutron source 500"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-14 - HallA - DaNeutroni500/JLabSim/Graphs.root";
    Files["Neutron source 500 - Sh1"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-20 - HallA - DaNeutroni500 - Shielding/Graphs/Graphs.root";

    multi(Files, 110);
    // multi(Files, 111);
    // multi(Files, 112);
    // multi(Files, 113);
}