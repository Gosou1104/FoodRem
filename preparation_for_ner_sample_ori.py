# -*- coding: utf-8 -*-
# preparation_for_ner_sample.py (for Python 2)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
import sys


def main(input_path, output_path):
    num = 0
    #flag = 0
    fp = open(output_path, 'w')
    for line in open(input_path):
        line = line.replace('\n', '')  # <--必要に応じて改行コードを変更
        #words = [w.split('/')[0] for w in line.split(' ')]
        words =[]
        for w in line.split(' '):
            # if flag==0:
            if((w.split('/')[-1] !="NA") and (w.split('/')[1]=="動詞")):
                words_temp = w.split('/')[-1]
                words.append(words_temp)
                print("2")
                print(words[-1])   
            else:
                words_temp= w.split('/')[0]
                words.append(words_temp)
                print("1")
                print(words[-1])
                    #flag =1
            # else:
            #     flag = 0    
        print(' '.join(words) + '\n')
        fp.write(' '.join(words) + '\n')  # <--必要に応じて改行コードを変更
    fp.close()


if __name__ == '__main__':
    argvs = sys.argv
    argc = len(argvs)
    if argc != 3:
        print '以下の書式で実行してください'
        print 'python preparation_for_ner_sample.py [手順2で出力されたファイルのパス] [出力先のパス]'
        sys.exit()
    input_path = argvs[1]
    output_path = argvs[2]
    main(input_path, output_path)
    print 'DONE!!'
