# -*- coding:utf-8 -*-  
import json
import os
import sys
import subprocess
import unicodedata
import csv
import codecs

def unicode_convert(input):#c处理乱码问题
    if isinstance(input, dict):
        return {unicode_convert(key): unicode_convert(value) for key, value in input.iteritems()}
    elif isinstance(input, list):
        return [unicode_convert(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode('utf-8')
    else:
        return input
DIR = "/Users/gosou/Desktop/1/food_jsonFile/"
counterOfFile = len([name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name))])#数有几个json

fr=open("/Users/gosou/Desktop/1/test.csv",'r')

x=0

temp_line_3=""
#for line in open('/Users/gosou/Desktop/1/test1.csv'):
for x in xrange(0,counterOfFile):


    line = fr.readline()
    with open(DIR+"rapide_"+str(x)+".json",'r') as load_f:#读取json按照顺序
        load_dict = json.load(load_f)
        new_load_dict =json.dumps(load_dict, ensure_ascii=False)
        #new_load_dict =new_load_dict.encode('unicode-escape')
        new_load_dict = unicode_convert(json.loads(new_load_dict))
        #print(new_load_dict)

    #fw=open("/Users/gosou/Desktop/1/test_new.csv",'a')

    w = open("/Users/gosou/Desktop/1/food_txtFile_final/final_result_"+str(x)+".txt","w")

    i=0
    #tempe_line_3 =""
    for line1 in open("/Users/gosou/Desktop/1/food_txtFile/temp_output_9"+str(x)+".txt"):
        name_set =[]
        one_line = line1.strip().replace("\n", "")#.split(",")

        # print one_line#大根,だいこん/F
        temp_line_1 = one_line.split("/")[0]#大根,だいこん/F  豚,ぶた=ひき肉,ひきにく/F
        if '=' in temp_line_1:
            temp_line_1t = temp_line_1.split("=")
            for item_tt in temp_line_1t:
                name_set.append(item_tt.split(",")[0])
        else:
            
            name_set.append(temp_line_1.split(",")[0])#eg.大根 # 这个就是第一个

        #temp_line_3 = temp_line_1.split(",")[i]
       # if "=" in temp_line_3:
        #    print temp_line_3
         #   i+=1
        for item_ttt in name_set: 
            if (new_load_dict.has_key(one_line)):

                csv_fifle = csv.reader(open("/Users/gosou/Desktop/1/food.csv","r"))
                for item in csv_fifle:  # item的第三项
                    if(item[3].decode('utf-8').encode('utf-8')==item_ttt):
                        #w.write(one_line + ","+new_load_dict[one_line])
                        #temp_line_3+=item[2]+" "
                        #print "2"+item[2]   
                        #print "3"+temp_line_3
                        w.write(item[2].decode('utf-8').encode('utf-8')+" ")#new information
                    #print "oo"
                    else:
                        #print ("ERROR!!!")
                        pass
    #x+=1
    #fw.writerows(line+','+temp_line_3+"\n")
    #fw.close()
    #print "tempe_line_3"+temp_line_3
    #temp_line_3=""
    


             
#fr.close()           
w.close()

