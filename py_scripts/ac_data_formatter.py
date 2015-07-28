import shapefile
import re
import csv
#start and end year defined in case we ever need to change it (assumed to be inclusive)
start_year = 1993;
end_year = 2014;
ac_data = {};
ac_array = [];
#Open the csv we're going to write to
with open("C:/Users/Young/Documents/GitHub/Research-2015-Energy-Data/data/generated/AC_India_Index.csv", 'w', newline='') as ac_index:
    #our csv writer object
    ac_index_writer = csv.writer(ac_index, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    #regular expression matching to split state from AC ID
    pattern = re.compile("([a-zA-Z& ]+)([0-9]+)")
    #our shapefile reader
    sf = shapefile.Reader("C:/Users/Young/Documents/Github/Research-2015-Energy-Data/data/AC_India_Geo/AC_ALLINDIA")
    #print the record format we've found for easy debugging
    print("Record format:", sf.fields)
    #start our easy unique id counter at 0
    unique_id = 0;
    #iterate through the records, and parse stateid into state:id.
    #write it into our csv file output, and add it to our ac_array
    #since we're going to use it later to reformat the data
    for r in sf.iterRecords():
        result = pattern.match(r[4])
        if result:
            stateid = pattern.match(r[4]).groups()
            #print("INDEX:", unique_id, "STATE:", stateid[0], "ID:", stateid[1]);
            ac_array.append((stateid[0] + ':' + stateid[1]).upper());
            ac_index_writer.writerow([unique_id, (stateid[0] + ':' + stateid[1]).upper()])
            unique_id += 1
        else:
            print("ERROR:", r[4], "could not be matched");
            exit();
#print(ac_array);
#define indexing functions
def date_to_index(year, month):
    return (year-start_year)*12+month-1
def index_to_date(index):
    return [index//12+start_year, index%12+1]
#open the data we're going to read, and the data we're going to write
with  open("C:/Users/Young/Documents/GitHub/Research-2015-Energy-Data/data/AC_India_Data/AC_India_Data.csv", newline='') as ac_data_in:
    print("Data in opened")
    #set up reader object
    datareader = csv.DictReader(ac_data_in)
    #set up our ac_data (initialize an empty array in each of the valid state:id's)
    for ac_id in ac_array:
        # data is a [21][12] list, indexed via [year since 1993][month]
        data = [ [-1.0]*12 for x in range(end_year-start_year+1)]
        ac_data[ac_id] = data
    #start reading in the data!
    for row in datareader:
        row_key = (row["State"] + ':' + row["Constituency"]).upper()
        if row_key in ac_data:
            #print("Reading key", row_key)
            try:
                ac_data[row_key][int(row["Year"])-start_year][int(row["Month"])-1] = float(row["NCS_20K_Pred_Month"])
            except IndexError:
                print("ERROR: year", int(row["Year"])-start_year, "month", int(row["Month"])-1, "out of bounds with ac_data entry size", len(ac_data[row_key]), "by", len(ac_data[row_key][0]))
                exit()
        #else:
            #print("Formatted key", row_key, "not found")

with open("C:/Users/Young/Documents/GitHub/Research-2015-Energy-Data/data/generated/AC_India_Data_Formatted.csv", 'w', newline='') as ac_data_out:
    #set up writer object
    fieldnames = ["Year", "Month"]
    fieldnames.extend(ac_array)
    #print("Writing CSV with header:", fieldnames)
    datawriter = csv.DictWriter(ac_data_out, fieldnames = fieldnames, lineterminator = '\n')
    datawriter.writeheader()
    for year in range(start_year, end_year+1):
        for month in range(12):
            row = {"Year":year, "Month":month+1}
            for ac_id in ac_array:
                try:
                    row[ac_id] = ac_data[ac_id][year-start_year][month]
                except IndexError:
                    print("ERROR: year", int(row["Year"])-start_year, "month", int(row["Month"])-1, "out of bounds with ac_data entry size", len(ac_data[row_key]), "by", len(ac_data[row_key][0]))
                    exit()
            print("Writing row for", month+1, "/", year)
            datawriter.writerow(row)
print("Finished")
