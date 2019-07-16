import glob, os
from PIL import Image
import csv
import shutil

def exportCSV(Tab,csvName):
	exportTab = []
	for name in Tab :
		t = []
		t.append(name)
		exportTab.append(t)
	with open(csvName, 'w', encoding='utf8', newline='') as csvfile:
	        writer = csv.writer(csvfile)
	        result = ['名字']
	        writer.writerow(result)
	        CsvData = exportTab
	        for item in CsvData:
	            writer.writerow(item)

def file_name(file_dir):   
    L=[]   
    for dirpath, dirnames, filenames in os.walk(file_dir):  
        for file in filenames :  
            if os.path.splitext(file)[1] == '.png':  
            	L.append(os.path.join(dirpath, file))  
    return L
tab = file_name("F:/picture")
tab2 = file_name("F:/picture_UI")
picTab = []
picTab2 = []
# for dirpath in tab2 :
# 	pathT = dirpath.split("\\")
for dirpath2 in tab :
	pathT2 = dirpath2.split("\\")
	picTab2.append(pathT2[-1])
		# if pathT2[-1] == pathT[-1] :
		# 	picTab.append(pathT2[-1])
		# 	break

a = [] 
for item in picTab2: 
	if picTab2.count(item)>1: 
		a.append(item)
print(set(a))

# retD = list(set(picTab2).difference(set(picTab)))


exportCSV(picTab2,'all.csv')
exportCSV(set(a),'setTab.csv')
# print(differenceTab)
# filenames = 'F:\\picture\\different\\'
# for dirpath in tab:
# 	pathT = dirpath.split("\\")
# 	for difname in differenceTab:
# 		if difname[0] == pathT[-1]:
# 			print(difname[0])
# 			shutil.copyfile(dirpath,filenames+difname[0])
