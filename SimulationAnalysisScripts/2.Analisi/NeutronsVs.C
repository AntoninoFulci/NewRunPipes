void multi_plot(std::map<std::string, std::string> Files, string axis){
    // gStyle->SetLegendBorderSize(2);
    int pad = 1;
    int cont = 0;

    map<int, int> markers= {{1,20}, {2,21}, {3,22}, {4,23}, {5,29}, {6,33}, {7,34}, {8,43}, {9,45}};
    vector<string> ranges;

    ranges = {"Energy_0-11", "Energy_0-1e-05", "Energy_1e-05-0.0001", "Energy_0.0001-0.01", "Energy_0.01-0.02", "Energy_0.02-0.1", "Energy_0.1-11"};

    TCanvas *c = new TCanvas("prova", "prova", 600*3, 600*3);
    c->SetGrid();
    c->SetLogy();
    c->Divide(3,3, 0.01, 0.01);

    TGraphErrors *g;
    
    for(auto range : ranges){

        cout<<range<<endl;
        TMultiGraph *multi = new TMultiGraph();
        TLegend *leg = new TLegend(0.45,0.1);     leg->SetTextSize(0.035);

        for ( const auto &[key, value]: Files ) {
            // cout<<"Opening file: "<<value<<endl;
            cont++;
            TFile *f = TFile::Open(value.c_str(), "READ");
            f->cd(range.c_str());

            if(axis=="Y")       g = (TGraphErrors*)gDirectory->Get("NeutronsVsY");
            else if(axis=="Z")  g = (TGraphErrors*)gDirectory->Get("NeutronsVsZ");
            else return;

            g->SetMarkerStyle(markers[cont]);      g->SetMarkerColor(cont);       g->SetLineColor(cont);        g->SetLineWidth(3);

            multi->Add(g);
            leg->AddEntry(g, key.c_str(), "PL");
            f->Close();
        }

        if(axis=="Y"){
            multi->SetTitle(Form("%s GeV; Y (cm); Neutron/EOT", range.c_str()));
            multi->GetYaxis()->SetRangeUser(0.5e-12,0.5e-1);
        }
        else if(axis=="Z"){
            multi->SetTitle(Form("%s GeV; Z (cm); Neutron/EOT", range.c_str()));
            multi->GetYaxis()->SetRangeUser(0.5e-12,0.5e-9);
        }


        if(pad == 1) c->cd(2);
        else if(pad > 1) c->cd(pad+2);

        gPad->SetLogy();
        gPad->SetGrid();

        multi->Draw("APL");
        leg->Draw();

        pad++;
        // cout<<cont<<endl;
        cont = 0;

    }

    cout<<"Salvando..."<<endl;
    gStyle->SetImageScaling(3);
    c->SaveAs(Form("Graphs/NeutronsVs%s.png",axis.c_str()));

}

void NeutronsVsY(){
    std::map<std::string, std::string> FilesY;
    FilesY["Electron source"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-07 - HallA - Creazione sorgente di neutroni - NoBias/Graphs/Graphs.root";
    FilesY["Neutron source 300"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-10 - HallA - DaNeutroni300/BigSim/Graphs/Graphs.root";
    FilesY["Neutron source 500"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-14 - HallA - DaNeutroni500/JLabSim/Graphs.root";

    multi_plot(FilesY, "Y");

}

void NeutronsVsZ(){
    std::map<std::string, std::string> FilesZ;
    FilesZ["Neutron source 500"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-14 - HallA - DaNeutroni500/JLabSim/Graphs.root";
    FilesZ["Neutron source 500 - Sh1"] = "/Users/antoninofulci/FlukaWork/HallA/Simulazioni/2023-03-20 - HallA - DaNeutroni500 - Shielding/JLabSim/Graphs.root";

    multi_plot(FilesZ, "Z");

}