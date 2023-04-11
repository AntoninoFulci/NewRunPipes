///////////////////////////////////////////////////
// File used for functions and methods before the
// exectution of the analysis program
///////////////////////////////////////////////////

void Analisi::Setter(const std::string option, const std::string path){


  gErrorIgnoreLevel = 6001;
  gSystem->RedirectOutput("/dev/null");
  gSystem->RedirectOutput(0,0);

  TTree::SetMaxTreeSize( 1000000000000LL ); // 1 TB
  if(debug) cout<<"New max TTree size: "<<TTree::GetMaxTreeSize()<<endl;

  global_option = option;

  if(option == "ALL"){
    root_files_dir = path;
  }
  else if(option == "MERGED"){
    merged_file = path;
  }

  GetTimeNow(); cout<<"Environment setted."<<endl;

}

void Analisi::DebugMode(){
  cout<<"Entering DebugMode..."<<endl;
  debug = true;
}
