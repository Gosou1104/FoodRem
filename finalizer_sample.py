# -*- coding: utf-8 -*-
# finalizer_sample.py (for Python 2)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
import sys
#import xlrd
#import uniout
import unicodedata

class Finalizer(object):
    def __init__(self):
        pass

    def __del__(self):
        pass

    def main(self, input_path1, input_path2, output_path):
        num = 0
        fp = open(output_path, 'w')
        lists1 = []
        lists2 = []
        for line in open(input_path1): # 形態素解析結果 这里是二
            line = line.replace('\n', '').split(' ')  # <--必要に応じて改行コードを変更
            lists1.append(line)
        for line in open(input_path2): # NERされたもの 四是分类
            line = line.replace('\n', '').split(' ')  # <--必要に応じて改行コードを変更
            lists2.append(self._modify_Viob2(line))
        for list1, list2 in zip(lists1, lists2):
            restored_list = self._restore(list1, list2)
            output_list = self._join_words(restored_list)
            fp.write(' '.join(output_list) + '\n')  # <--必要に応じて改行コードを変更
        fp.close()

    def _modify_Viob2(self, input_list):#去点不重要的tag
        """
        入力例）[糸/F-B 蒟蒻/F-I を/O 下茹で/Ac-B し/O ま/O す/O 。/O]
        出力例）[糸/F 蒟蒻/F を 下茹で/Ac し ま す 。]
        """
        output_list = []
        for item in input_list:
            if item == '':
                continue
            item = item.split('/')
            if item[1] == 'O':
                output_list.append(item[0])
            else:
                output_list.append(item[0] + '/' + item[1].split('-')[0])
        return output_list

    def _restore(self, input_list1, input_list2):
        """
        入力１例）[糸/名詞/名詞-普通名詞-一般+/し,蒟蒻/名詞/名詞-普通名詞-一般+/こんにゃく,...]
        入力２例）[糸/F 蒟蒻/F を 下茹で/Ac し ま す 。]
        出力例）  [糸,名詞,名詞-普通名詞-一般+,し/F 蒟蒻,名詞,名詞-普通名詞-一般+,こんにゃく/F ...]
        """
        output_list = []
        for item1, item2 in zip(input_list1, input_list2):
            item1 = item1.split('/')
            if '/' in item2:
                item2 = item2.split('/')
            else:
                item2 = [item2, '']
            # if item1[0] not in item2[0]:#continuehange != into in
            #     print (item1[0])
            #     print (item2[0])
            #     print 'ERROR: item1 != item2 at _restore'
            #     sys.exit()
            if item2[1] == '':
                output_list.append(','.join(item1))
            else:
                output_list.append(','.join(item1) + '/' + item2[1])
        return output_list

    def _join_words(self, input_list):
        """
        入力例）[糸,名詞,名詞-普通名詞-一般+,し/F 蒟蒻,名詞,名詞-普通名詞-一般+,こんにゃく/F ...]
        出力例）[糸,名詞,名詞-普通名詞-一般+,し=蒟蒻,名詞,名詞-普通名詞-一般+,こんにゃく/F ...]
        """
        tag_list = []
        for item in input_list:
            item = item.split('/')
            if(item[0].find(',NA')!=-1):
                item[0] = item[0].replace(',NA','')

            if len(item) == 1:  # タグなし
                tag_list.append('')
            else:
                tag_list.append(item[1])
        i = 0
        output_str = ''
        for item in input_list:
            if(item.find(',NA')!=-1):
                item = item.replace(',NA','')
            if tag_list[i] == '':  # タグなし
                output_str += item + ' '
                #print item
            else:
                if i == (len(input_list) - 1):  # 最後の単語
                    output_str += item + ' '
                else:
                    if tag_list[i] == tag_list[i + 1]:  # 次単語と同一タグ
                        output_str += item.split('/')[0] + '='
                    else:
                        output_str += item + ' '
            i += 1
        output_list = output_str.split(' ')[:-1]
        return output_list

if __name__ == '__main__':
    argvs = sys.argv
    argc = len(argvs)
    if argc != 4:
        print '以下の書式で実行してください'
        print 'python finalizer_sample.py [手順2で出力されたファイルのパス] [手順4で出力されたファイルのパス] [出力先のパス]'
        sys.exit()
    input_path1 = argvs[1]
    input_path2 = argvs[2]
    output_path = argvs[3]
    f = Finalizer()
    f.main(input_path1, input_path2, output_path)
    print 'DONE!!'
