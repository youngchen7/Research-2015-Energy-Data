import csv
import time

def date_to_index(year, month):
	return (year-1993)*12+month-1

def index_to_date(index):
	return [index//12+1993, index%12+1]

with open('E:\Development\Research-2015-Energy-Data\Data\\022615-Hardoi.csv') as csv_in, open('E:\Development\Research-2015-Energy-Data\Data\\Hardoi_processed.csv', 'w') as csv_out:
    NUM_VILLAGES = 80
    NUM_DATA = 12*(2013-1993+1)
    fieldnames = ['Village_ID', 'Longitude', 'Latitude', 'Year', 'Month', 'Vis', 'Count']
    processed_results = []
    datareader = csv.DictReader(csv_in)
    writer = csv.DictWriter(csv_out, fieldnames = fieldnames, lineterminator = '\n')
    writer.writeheader()
    num_entries = 0
    num_vil = 0
    start = time.time()
    for row in datareader:
        #keep track of how many entries we've processed and print out updates
        if(num_entries%10000 == 0):
            print(num_entries, " entries processed")
        num_entries+=1
        #for some reason, these labels reappear in the datafile, don't read them in
        if row["UPshape.C_CODE01"] == "UPshape.C_CODE01":
            #+2 is to compensate for the fact that I increment entries processed _after_ successfully processing an entry
            #and that the first entry is consumed to create column labels
            print("Labels found at CSV line number ", num_entries+2, ", ignored.")
        elif row["li"] == '-1':
            pass
            #print("Malformed data with 'li' label equal to -1 found at line number ", num_entries+2, ", ignored.")
        elif row["slm"] == "255":
            pass
            #print("No data (slm value 255) found at line number ", num_entries+2, ", ignored.")
        else:
            try:
                for vil in processed_results:
                    if(vil[0] == row["UPshape.C_CODE01"]):
                        #calculate the index for data this entry should go in
                        d_idx = date_to_index(int(row["satellite"][3:]), int(row["month"]))
                        #to update averages, I take (average*count + new_data)/(count+1)
                        #and then count = count+1
                        vil[3][d_idx][0] = (vil[3][d_idx][0]*vil[3][d_idx][1] + int(row["vis"]))/(vil[3][d_idx][1] + 1)
                        vil[3][d_idx][1]+=1
                        break
                else:
                    print("Created new village entry ", num_vil," with ID: ", row["UPshape.C_CODE01"])
                    num_vil+=1
                    #new_data has NUM_DATA entries of [[average, count]] where average is the current average and count is the number of points
                    #used to calculate that average                    
                    new_data = [[0,0] for  x in range(NUM_DATA)]
                    new_data[date_to_index(int(row["satellite"][3:]), int(row["month"]))] = [int(row["vis"]), 1]
                    new_vil = [row["UPshape.C_CODE01"], float(row["UPshape.LONGITUDE"]), float(row["UPshape.LATITUDE"]), new_data]
                    processed_results.append(new_vil)
            except ValueError:
                pass
                #print("Malformed data (vis was not a valid integer (", row["vis"], ") at line number ", num_entries+2,", ignored.")
    for vil in processed_results:
        for index, data in enumerate(vil[3]):
            date = index_to_date(index)
            writer.writerow({'Village_ID': vil[0], 'Longitude':vil[1], 'Latitude':vil[2], 'Year':date[0], 'Month':date[1], 'Vis':data[0], 'Count':data[1] })
    #finished processing
    print("Finished processing ", num_entries, " entries, with a total of ", num_vil, " villages in ", time.time()-start, " seconds")
