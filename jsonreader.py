# -*- coding:utf-8 -*-  
import json
import os
import sys
import subprocess
import unicodedata
import csv
import codecs
import shutil
#import simplejson

def unicode_convert(input):#c处理乱码问题
    if isinstance(input, dict):
        return {unicode_convert(key): unicode_convert(value) for key, value in input.iteritems()}
    elif isinstance(input, list):
        return [unicode_convert(element) for element in input]
    elif isinstance(input, unicode):
        return input.encode('utf-8')
    else:
        return input
DIR = "/Users/gosou/Desktop/1/action_jsonFile/"
counterOfFile = len([name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name))])#数有几个json

for x in xrange(0,counterOfFile):


    with open(DIR+"rapide_"+str(x)+".json",'r') as load_f:#读取json按照顺序
        load_dict = json.load(load_f)
        new_load_dict =json.dumps(load_dict, ensure_ascii=False)
        #new_load_dict =new_load_dict.encode('unicode-escape')
        new_load_dict = unicode_convert(json.loads(new_load_dict))
        #print(new_load_dict)

    w = open("/Users/gosou/Desktop/1/action_txtFile_final/final_result_"+str(x)+".txt","w")#按照顺序读取txt
    for line in open("/Users/gosou/Desktop/1/action_txtFile/temp_output_8"+str(x)+".txt"):
        one_line = line.strip().replace("\n", "")#.split(",")
        print one_line#eg.かけ,かける/Ac
        temp_line_1 = one_line.split("/")[0]#eg.かけ,かける
        temp_line_2 = temp_line_1.split(",")[1]#eg.かける
        #print (type(new_load_dict))
        if (new_load_dict.has_key(one_line)):
            #w.write(one_line + ","+new_load_dict[one_line])
            csv_fifle = csv.reader(open("/Users/gosou/Desktop/1/make_food_action.csv","r"))
            for item in csv_fifle:
                #print(item[0].decode('utf-8'))
                #item_temp = item.split(",")
                #print(item[1].decode('utf-8'))
                #print(temp_line_2)
                #print("-------------")
                #print (item[1].decode('utf-8').encode('utf-8'))
                if(item[1].decode('utf-8').encode('utf-8')==temp_line_2):
                    w.write(one_line + ","+new_load_dict[one_line])
                    w.write(","+item[0].decode('utf-8').encode('utf-8')+"\n")
                    print "oo"

                else:
                    #print ("ERROR!!!")
                    pass
    w.close()



