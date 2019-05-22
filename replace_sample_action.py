# # -*- coding: utf-8 -*-
# # replace_sample.py (for Python 2)
# # 
# # Coded by Takuya Kadowaki
# # 
# # This software is released under the MIT License.
# # 
# # http://opensource.org/licenses/mit-license.php
# # 
# import os
# import sys
# import subprocess
# import csv


# def main(k, input_path, output_path, temp_path):

#     k = int(k)
#     command = 'cat {0} | tr " " "\n" | sort | uniq -c | sort -nr > {1}'.format(input_path, temp_path)
#     subprocess.call(command, shell=True)

#     # 出現数k以下の単語をsetにaddする処理
#     source_set = set()
#     for line in open(temp_path):
#         item = line.replace("\n", "").split(" ")
#         if int(item[-2]) > k:
#             continue
#         source_set.add(item[-1])

#     # "UNK"に置換する処理
#     target_word = "UNK"
#     fp = open(output_path, "a")
#     csv_file = csv.reader(open(input_path,'r'))
#     for stu in csv_file:
#         line = stu[0]    
#         line = line.replace("\n", "").split(" ")
#         output_list = []
#         for word in line:
#             if word in source_set:
#                 output_list.append(target_word)
#             else:
#                 output_list.append(word)
#         csv_write = csv.writer(fp)
#         csv_write.writerow(output_list)
#     fp.close()


# if __name__ == "__main__":
#     argvs = sys.argv
#     argc = len(argvs)
#     if argc != 4:
#         print '以下の書式で実行してください'
#         print 'python replace_sample.py [この値以下の出現回数の単語をUNKに置換] [入力元のパス] [出力先のパス]'
#         sys.exit()
#     k = argvs[1]
#     input_path = argvs[2]
#     output_path = argvs[3]
#     temp_path = input_path + "_temp"
#     print '"{0}"に一時的なファイルが生成されますが，処理終了後，削除していただいて構いません．'.format(os.path.abspath(temp_path))
#     main(k, input_path, output_path, temp_path)
#     print 'DONE!!'
# -*- coding: utf-8 -*-
# replace_sample.py (for Python 3)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
import os
import sys
import subprocess
import json
import subprocess
import unicodedata
import time



def main(k, input_path, output_path, temp_path):
    k = int(k)
    command = 'cat {0} | tr " " "\n" | sort | uniq -c | sort -nr > {1}'.format(input_path, temp_path)
    subprocess.call(command, shell=True)

    # 出現数k以下の単語をsetにaddする処理
    source_set = set()
    dic = {} 
    for line in open(temp_path):
        item = line.replace("\n", "").split(" ")
        if int(item[-2]) > k:#如果在这个里面
            # print(' 这是item')
            # print (item[-2]) 
            # f_set.add(item[-1])
            ##
            ##save the data 字典
            dic[str(item[-1])]=item[-2]
            ##
            continue
        source_set.add(str(item[-1]).decode('UTF-8'))


    # "UNK"に置換する処理
    target_word = "UNK"
    fp = open(output_path, "w")
    for line in open(input_path):
        line = line.replace("\n", "").split(" ")
        output_list = []
        for word in line:
            if word in source_set:
                output_list.append(target_word)
            else:
                output_list.append(word)
                ##
                ##添加到里面

                ##
        fp.write(" ".join(output_list) + "\n")
    fp.close()
    jsObj = json.dumps(dic,ensure_ascii=False)
    DIR="/Users/gosou/Desktop/1/action_jsonFile/"
    conter = len([name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name))])#查询有多少个文件
    jsonPath = "/Users/gosou/Desktop/1/action_jsonFile/rapide_"+str(conter)+".json"
    fileObject = open(jsonPath,'w')

    fileObject.write(jsObj)
    fileObject.close()


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    if argc != 4:
        print '以下の書式で実行してください'
        print 'python replace_sample.py [この値以下の出現回数の単語をUNKに置換] [入力元のパス] [出力先のパス]'
        sys.exit()
    k = argvs[1]
    input_path = argvs[2]
    output_path = argvs[3]
    temp_path = input_path + "_temp"
    print '"{0}"に一時的なファイルが生成されますが，処理終了後，削除していただいて構いません．'.format(os.path.abspath(temp_path))
    main(k, input_path, output_path, temp_path)
    print 'DONE!!'
