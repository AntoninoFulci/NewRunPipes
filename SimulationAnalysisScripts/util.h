///////////////////////////////////////////////////
// File utility contente diverse funzioni che
// vengono utilizzate durante il processing
// dei dati
///////////////////////////////////////////////////

#include <dirent.h>
#include <sys/stat.h>

//Funzione che ritorna un vettore di stringhe contente i nomi di tutti i file
//e cartelle presenti nel path passato
std::vector<std::string> GetNames(string dir_name, bool debug = 0){
  DIR *dir;
  struct dirent *ent;
  vector<string> files;

  if ((dir = opendir (dir_name.c_str())) != NULL) {
    /* print all the files and directories within directory */
    while ((ent = readdir (dir)) != NULL) {
      if(debug) cout<<ent->d_name<<endl;
      files.push_back(ent->d_name);
    }
    closedir (dir);
  }

  return files;
}

bool has_suffix(const std::string &str, const std::string &suffix){
    return str.size() >= suffix.size() &&
           str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

vector<double> LogBinning(double EMax, double EMin, int NumberoBin){

  double Emax = EMax;
	double Emin = EMin;

	int LogBinNumber = NumberoBin;

	double lMaxE = log10(Emax);
	double lMinE = log10(Emin);
	double lWidth = (lMaxE - lMinE)/LogBinNumber;

	vector <double> LogBinningEdges (LogBinNumber+1);

	for(int i = 0; i<=  LogBinNumber; i++){
		LogBinningEdges[i] = TMath::Power(10,lMinE+i * lWidth);
	}

  return LogBinningEdges;
}


void GetTimeNow(){
  char s[1000];

  time_t t = time(NULL);
  struct tm * p = localtime(&t);

  strftime(s, 1000, "%d/%m/%y - %T", p);

  cout<<">"<<s<<": ";


  return 0;
}

void MkDir(string f_path, bool debug = 0){
  struct stat st;
	string path = f_path;
	if(stat(path.c_str(),&st) == 0){
  	if(debug) cout<<"The directory "<<path<<" already exists skipping creating it"<<endl;
	}
	else{
		if(debug) cout<<path<<" does not exits, creating it"<<endl;
		mkdir(path.c_str(), ACCESSPERMS);
	}
}