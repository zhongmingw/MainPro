import os ,sys
from PIL import Image
import csv

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
for dirpath in tab :
	img = Image.open(dirpath)
	imgSize = img.size
	maxSize = imgSize[0]
	minSize = imgSize[1]
	if maxSize%4 != 0 or minSize%4 != 0 :
		t = []
		t.append(dirpath)
		t.append(imgSize)
		if maxSize%4 != 0 :
			for i in range(3) :
				if (maxSize+i+1)%4 == 0 :
					maxSize = maxSize+i+1
		if minSize%4 != 0 :
			for i in range(3) :
				if (minSize+i+1)%4 == 0 :
					minSize = minSize+i+1
		testSize = []
		testSize.append(maxSize)		
		testSize.append(minSize)
		t.append(testSize)
		t.append(img.format)
		model = img.mode
		t.append(model)
		picTab.append(t)
with open('pictures.csv', 'w', encoding='utf8', newline='') as csvfile:
        writer = csv.writer(csvfile)
        result = ['路径', '分辨率', '建议尺寸', '图片类型', 'model']
        writer.writerow(result)
        CsvData = picTab
        for item in CsvData:
            writer.writerow(item)
