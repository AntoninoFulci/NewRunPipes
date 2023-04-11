///////////////////////////////////////////////////
//File used to inizialize the root files
///////////////////////////////////////////////////


TChain* Analisi::CreateChain(std::string tree_name){
  TChain::SetMaxTreeSize( 1000000000000LL ); // 1 TB
  TChain * chain = new TChain(tree_name.c_str(),"");

  vector<string> files = GetNames(root_files_dir);
  int counter = 1;
  cout<<"Total number of files found: "<<files.size()<<endl;
  for(auto i:files){
    if(has_suffix(i, ".root")){
      string file_path = root_files_dir + i;
      if(debug) cout<<file_path<<endl;

      TFile *file = TFile::Open(file_path.c_str());
      if (file->IsZombie()) {
        cout<<"Found a corrupted file: "<<i<<endl;
      }
      if (file->TestBit(TFile::kRecovered)) {
        cout<<"Found a recovered file: "<<i<<endl;
      }
      else{
        cout<<"["<<counter<<"] Adding: "<<file_path<<"...\n";
        chain->Add(file_path.c_str());

        counter++;
      }
      file->Close();

    }
  }

  return chain;

}

TTree* Analisi::GetTree(std::string tree_name){

  TFile *f = new TFile(merged_file.c_str());
  TTree *t1 = (TTree*)f->Get(tree_name.c_str());

  return t1;

}

////////////////////////////////////////////////////////////////////////////////
void Analisi::InitializeAll(){

  std::string option = global_option;

  TTree *tree;

  if(option == "ALL"){
    tree = CreateChain("Events");
  }
  else if(option == "MERGED"){
    tree = GetTree("Events");
  }

  Analisi::Init(tree);

}

////////////////////////////////////////////////////////////////////////////////
void Analisi::InitializeRunSummary(){

  std::string option = global_option;

  TTree *tree;

  if(option == "ALL"){
    tree = CreateChain("RunSummary");
  }
  else if(option == "MERGED"){
    tree = GetTree("RunSummary");
  }

  Analisi::InitRunSummary(tree);

}
