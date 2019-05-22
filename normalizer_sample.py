# -*- coding: utf-8 -*-
# normalizer_sample.py (for Python 2)
# 
# Coded by Takuya Kadowaki
# 
# This software is released under the MIT License.
# 
# http://opensource.org/licenses/mit-license.php
# 
import sys
import htmlentitydefs
import re
import unicodedata
import zenhan


class Normalizer(object):
    def __init__(self, char_path):
        # 全角 JIS X 0208 の文字群
        self.char_set = set()
        for line in open(char_path):
            self.char_set.add(line[:-1].decode('utf-8'))

    def __del__(self):
        pass

    def main(self, input_path, output_path):
        num = 0
        fp = open(output_path, 'w')
        for line in open(input_path):
            line = line.replace('\n', '')  # <--必要に応じて改行コードを変更
            norm_line = self.check(line.decode('utf-8'))
            if norm_line == -1:
                print 'ERROR: Input text is not unicode.'
                sys.exit()
            fp.write(norm_line.encode('utf-8') + '\n')  # <--必要に応じて改行コードを変更
        fp.close()

    def check(self, text):
        """textを全角 JIS X 0208で構成されるように変換・除去し，返す
        """
        if type(text) != type(u''):
            return -1
        text2 = self.htmlentity2unicode(self.htmlentity2unicode(text))
        text_norm = unicodedata.normalize('NFKC', text2)
        text_zen = zenhan.h2z(text_norm)
        zyokyo_list = []
        for zen in text_zen:
            if zen not in self.char_set:
                zyokyo_list.append(zen)
        for zyokyo in zyokyo_list:
            text_zen = text_zen.replace(zyokyo, '')  # 除去
        return text_zen

    def htmlentity2unicode(self, text):
        """実体参照と文字参照を通常の文字に変換し返す
        ＜参考元URL＞
        http://www.programming-magic.com/20080820002254/
        """
        # 正規表現のコンパイル
        reference_regex = re.compile(u'&(#x?[0-9a-f]+|[a-z]+);', re.IGNORECASE)
        num16_regex = re.compile(u'#x\d+', re.IGNORECASE)
        num10_regex = re.compile(u'#\d+', re.IGNORECASE)

        result = u''
        i = 0
        while True:
            # 実体参照 or 文字参照を見つける
            match = reference_regex.search(text, i)
            if match is None:
                result += text[i:]
                break

            result += text[i:match.start()]
            i = match.end()
            name = match.group(1)

            # 実体参照
            if name in htmlentitydefs.name2codepoint.keys():
                result += unichr(htmlentitydefs.name2codepoint[name])
                # 文字参照
            elif num16_regex.match(name):
                # 16進数
                result += unichr(int(u'0' + name[1:], 16))
            elif num10_regex.match(name):
                # 10進数
                result += unichr(int(name[1:]))

        return result


if __name__ == '__main__':
    argvs = sys.argv
    argc = len(argvs)
    if argc != 4:
        print '以下の書式で実行してください'
        print 'python normalizer_sample.py [JIS X 0208文字一覧ファイル] [解析したい手順文書のパス] [出力先のパス]'
        sys.exit()
    char_path = argvs[1]
    input_path = argvs[2]
    output_path = argvs[3]
    n = Normalizer(char_path)
    n.main(input_path, output_path)
    print 'DONE!!'
