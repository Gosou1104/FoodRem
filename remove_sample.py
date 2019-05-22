# # -*- coding: utf-8 -*-
# # remove_sample.py (for Python 2)
# # 
# # Coded by Takuya Kadowaki
# # 
# # This software is released under the MIT License.
# # 
# # http://opensource.org/licenses/mit-license.php
# # 
# import sys
# import csv

# def main(input_path, output_path):
#     fp = open(output_path, "a")
#     csv_file = csv.reader(open(input_path,'r'))
#     for stu in csv_file:
#         line =stu[6]
#         line = line.replace("\n", "")
#         inwords_set = line.split(" ")
#         outwords_set = []
#         for inwords in inwords_set:
#             tag = ""
#             if  "/" in inwords:
#                 temp = inwords.split("/")
#                 inwords = temp[0]
#                 tag = temp[1]
#             if "=" in inwords:
#                 inwords = inwords.split("=")
#             else:
#                 inwords = [inwords]
#             outword = []
#             for inword in inwords:
#                 inword = inword.split(",")
#                 moto = inword[0]
#                 if inword[-1] != "NA":
#                     outword.append(moto + "," + inword[-1])
#                 else:
#                     outword.append(moto)
#             outwords = "=".join(outword)
#             if tag != "":
#                 outwords += "/" + tag
#             outwords_set.append(outwords)
#         csv_write = csv.writer(fp)
#         csv_write.writerow(outwords_set)
#     fp.close()


# if __name__ == "__main__":
#     argvs = sys.argv
#     argc = len(argvs)
#     if argc != 3:
#         print '以下の書式で実行してください'
#         print 'python remove_sample.py [入力元のパス] [出力先のパス]'
#         sys.exit()
#     input_path = argvs[1]
#     output_path = argvs[2]
#     main(input_path, output_path)
#     print 'DONE!!'
# -*- coding: utf-8 -*-
# remove_sample.py (for Python 2)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
# -*- coding: utf-8 -*-
# remove_sample.py (for Python 2)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
import sys
import unicodedata



def main(input_path, output_path):
    fp = open(output_path, "w")
    for line in open(input_path):
        line = line.replace("\n", "")
        inwords_set = line.split(" ")
        outwords_set = []
        for inwords in inwords_set:
            tag = ""
            if  "/" in inwords:
                temp = inwords.split("/")
                inwords = temp[0]
                tag = temp[1]
            if "=" in inwords:
                inwords = inwords.split("=")
            else:
                inwords = [inwords]
            outword = []
            for inword in inwords:
                inword = inword.split(",")
                moto = inword[0]
                if inword[-1] != "NA":
                    outword.append(moto + "," + inword[-1])
                else:
                    outword.append(moto)
            outwords = "=".join(outword)
            if tag != "":
                outwords += "/" + tag
            outwords_set.append(outwords)
        fp.write(" ".join(outwords_set) + "\n")
    fp.close()


if __name__ == "__main__":
    argvs = sys.argv
    argc = len(argvs)
    if argc != 3:
        print '以下の書式で実行してください'
        print 'python remove_sample.py [入力元のパス] [出力先のパス]'
        sys.exit()
    input_path = argvs[1]
    output_path = argvs[2]
    main(input_path, output_path)
    print 'DONE!!'