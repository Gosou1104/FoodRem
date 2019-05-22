#!/bin/sh

# PW+DPによるレシピNEタグ付与

MODEL="recipe416.knm"

# BIOタグ推定モデル構築(Learn.iob2は同梱していません)
# LEARN="Learn.iob2"
# TRAIN_KYTEA="train-kytea"
# TRAIN_KYTEA_OPT="-nows -full $LEARN -global 1 -solver 6 -model $model"
# $TRAIN_KYTEA $TRAIN_KYTEA_OPT

# kyteaにパスを通していない場合はここを変更
KYTEA="kytea"
KYTEA_OPT="-model $MODEL -out conf -nows -tagmax 0 -unktag /UNK"

# BIOタグ確率の推定, PW
echo "BIOタグ確率の推定..."
$KYTEA $KYTEA_OPT < Test.word > Test.Ciob2
echo "done."

# タグ制約適用, DP
# BIOの連接のうちO-I,文頭-Iの経路を消してargmaxを取る
echo "BIOタグ制約を適用して1-bestを出力..."
perl ./bin/NESearch.pl Test.Ciob2 Test.Viob2
echo "done."
echo ""
echo "BIOタグ推定精度(O含む)..."

perl ./bin/WordAccu.pl Test.Viob2 Test.iob2
echo ""
echo "NEチャンクタグ推定精度(O除く)..."

perl ./bin/NEAccu.pl Test.iob2 Test.Viob2
