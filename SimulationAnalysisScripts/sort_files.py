import os
import shutil
import glob

#Sposta i file tutti nella stessa cartella

# retrieve file list
def sort(file_ext):
    cwd = os.getcwd() + '/'
    files = cwd + "*." + file_ext
    files_dir = cwd + file_ext + "_files"

    if not os.path.exists(files_dir):
        print( file_ext + " files folder does not exist, creating it.")
        os.mkdir(files_dir)
    else:
        print(files_dir + " already exits! Skipping it.")

    filelist=glob.glob(files)
    for single_file in filelist:
        # move file with full paths as shutil.move() parameters
        print(single_file)
        shutil.move(single_file,files_dir) 

extensions = ["err", "log", "txt", "out", "inp", "19", "root"]

for i in extensions:
    sort(i)

os.system("rm ran*")