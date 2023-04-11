import os
import shutil
import glob

#Sposta i file tutti i file con la stessa estensione nella stessa cartella
def sort_by_extension(paths: list, ext: str):
    all_ext_paths = [x for x in paths if x.endswith("." + ext)]

    files_dir = "./" + ext + "_files"

    if not os.path.exists(files_dir):
        print(ext + " files folder does not exist, creating it...")
        os.mkdir(files_dir)

    print("Moving all ." + ext + " files in " + files_dir)
    for single_file in all_ext_paths:
        shutil.move(single_file,files_dir) 


#Questa lista contiene tutti i path dei file contenuti nelle cartelle jobs
paths = [x for x in glob.glob("./*/*") if "job_" in x]

extensions = ["root", "21", "22"]

for i in extensions:
    sort_by_extension(paths, i)

print("Removing jobs folders...")

os.system("rm -r job_*")

print("Done. Bye! :)")