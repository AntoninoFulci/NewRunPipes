import os
import shutil

#cartella all'interno della quale si trovano le cartelle job
#basta mettere il file dove ci sono le cartelle job e fa tutto da solo
# print(os.getcwd() + '/')
job_dir = os.getcwd() + '/'

root_files_dir = job_dir + 'root_files'
err_files_dir  = job_dir + 'err_files'
out_files_dir  = job_dir + 'out_files'
log_files_dir  = job_dir + 'log_files'
txt_files_dir  = job_dir + 'txt_files'

#creazione delle cartelle se non ci sono

# cartella con i root files
if not os.path.exists(root_files_dir):
    print("root files folder does not exist, creating it.")
    os.mkdir(root_files_dir)
else:
    print(root_files_dir + " already exits! Skipping it.")

# cartella con i txt file (err.txt, out.txt, _dump.txt)
if not os.path.exists(txt_files_dir):
    print("root files folder does not exist, creating it.")
    os.mkdir(txt_files_dir)
else:
    print(txt_files_dir + " already exits! Skipping it.")

# cartella con i file .err
if not os.path.exists(err_files_dir):
    print("err files folder does not exist, creating it.")
    os.mkdir(err_files_dir)
else:
    print(err_files_dir + " already exits!  Skipping it.")

# cartella con i file .out
if not os.path.exists(out_files_dir):
    print("out files folder does not exist, creating it.")
    os.mkdir(out_files_dir)
else:
    print(out_files_dir + " already exits!  Skipping it.")

# cartella con i file .log
if not os.path.exists(log_files_dir):
    print("log files folder does not exist, creating it.")
    os.mkdir(log_files_dir)
else:
    print(log_files_dir + " already exits!  Skipping it.")

##########################################################

#Sposta i file tutti nella stessa cartella
buffer = os.listdir(job_dir)

jobs_list = []

for x in buffer:
    if "job" in x:
        jobs_list.append(x)

print("Sorting files...")
for x in jobs_list:
    jobs = job_dir + x
    job_files = os.listdir(jobs)
    for file in job_files:
        if file.endswith('.root'):
            shutil.move(os.path.join(jobs,file), os.path.join(root_files_dir,file))
        if file.endswith('.err'):
            shutil.move(os.path.join(jobs,file), os.path.join(err_files_dir,file))
        if file.endswith('.out'):
            shutil.move(os.path.join(jobs,file), os.path.join(out_files_dir,file))
        if file.endswith('.log'):
            shutil.move(os.path.join(jobs,file), os.path.join(log_files_dir,file))
        if file.endswith('.txt'):
            shutil.move(os.path.join(jobs,file), os.path.join(txt_files_dir,file))
    # cancella la cartella dei job
    shutil.rmtree(jobs)
