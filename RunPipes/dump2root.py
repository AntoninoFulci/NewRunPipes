from datetime import datetime
import uproot
import pandas
import ROOT
import os, glob, re
import numpy as np
from file_read_backwards import FileReadBackwards as FRB

def get_first(filename):
    with open(filename, 'r') as file:
        for line in file:
            first_line = line
            break
        
    return first_line

def get_last3(filename):
    last_lines = []
    count = 0

    with FRB(filename, encoding="utf-8") as frb:
        for line in frb:
            if count < 3:
                last_lines.insert(0, line)
            else:
                break
            count += 1
    return last_lines

def get_time_stamp(line):
    date_format="%Y%m%d  %H%M%S"
    stripped_string = line .rsplit('.', 1)[0]
    time_stamp = datetime.strptime(stripped_string, date_format)
    return time_stamp

def get_avg_time(line):
    pattern = r'[-+]?\d*\.\d+(?:[Ee][-+]?\d+)?'
    match = re.search(pattern, line)

    # Extract the matched number
    if match:
        extracted_number = match.group()
        return extracted_number
    else:
        return 1
    
def get_tot_events(line):
    pattern = r'[-+]?\d*\.\d+|\d+'
    matches = re.findall(pattern, line)

    if matches:
        extracted_numbers = [match for match in matches if match.strip()]
        if extracted_numbers:
            extracted_number = extracted_numbers[0]
            return extracted_number
        else:
            return 1
    else:
        return 5
    

###################################################
#####                 MAIN                    #####
###################################################

#Get the dump file/s name
dumps = glob.glob(os.path.join('./', '*_dump.txt'))

for d in dumps:
    #Read the 1st line
    first_line = get_first(d)
    
    #Read the last 3 lines
    last3_line = get_last3(d)
    
    #Get avg time a particle is simulated
    AvgTime = float(get_avg_time(last3_line[0]))
    print("Avg time: ", type(AvgTime), AvgTime)
    
    #Get run time
    start = get_time_stamp(first_line)
    end   = get_time_stamp(last3_line[1])
    TotTime = (end - start).total_seconds()
    
    print("TotTime: ", type(TotTime), TotTime)

    #Get total primaries simulated
    TotEvents = int(get_tot_events(last3_line[2]))
    print("TotEvents: ", type(TotEvents), TotEvents)
    
    #Convert the dump file in a root file
    df = pandas.read_csv(d, sep='\s+|,', skiprows=1, skipfooter=4, engine='python')
    df.drop(["RegionIn", "RegionOut"], axis=1, errors='ignore', inplace=True)

    file = uproot.recreate(d.replace("_dump.txt", ".root"))
    #Create the 1st tree with the events
    file["Events"] = df
    #Create the 2nd tree with the information about the run
    file["RunSummary"] = {"AvgTime": np.array([AvgTime]), "TotTime": np.array([TotTime]), "TotEvents": np.array([TotEvents])}

