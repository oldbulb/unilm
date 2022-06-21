#!/usr/bin/env bash
#
# Adapted from https://github.com/pytorch/fairseq/blob/master/examples/translation/prepare-iwslt14.sh

data=data
source=source
#mkdir -p $1
#URL="https://ai-contest-static.xfyun.cn/2022/%E6%95%B0%E6%8D%AE%E9%9B%86/%E4%BD%8E%E8%B5%84%E6%BA%90%E5%A4%9A%E8%AF%AD%E7%A7%8D%E6%96%87%E6%9C%AC%E7%BF%BB%E8%AF%91%E6%8C%91%E6%88%98%E8%B5%9B%E5%85%AC%E5%BC%80%E6%95%B0%E6%8D%AE.zip"
#wget $URL
## move data under dir $data/$source

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl

src=ms
tgt=zh
lang=ms-zh

train_dir=$data/$source/train
val_dir=$data/$source/valid
test_dir=$data/$source/test
tmp=$data/clean
:<<!
mkdir -p $tmp

echo "pre-processing train data..."
cat < ${train_dir}/train.$lang | awk -F "\t" '{print $1}' > ${train_dir}/train.$lang.$src
cat < ${train_dir}/train.$lang | awk -F "\t" '{print $2}' > ${train_dir}/train.$lang.$tgt

for l in $src $tgt; do
    echo "processing bilingual data"
    bi_f=train.$lang.$l
    bi_tok=train.$lang.tok.$l
    cat < ${train_dir}/$bi_f | \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$bi_tok

    echo "processing monolingual data"
    mono_f=train.$l
    mono_tok=train.tok.$l
    cat < ${train_dir}/$mono_f| \
    perl $TOKENIZER -threads 8 -l $l > $tmp/$mono_tok
done

perl $CLEAN -ratio 2 $tmp/train.$lang.tok $src $tgt $tmp/train.$lang 1 200

echo "pre-processing valid data..."
for l in $src $tgt; do
    val_f=val.$lang.$l.xml
    val_tok=$tmp/val.$lang.tok.$l
    echo $val_f $val_tok
    grep '<seg id' $val_dir/$val_f | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    perl $TOKENIZER -threads 8 -l $l > $val_tok
    echo ""
done
!
echo "pre-processing test data..."
for l in $src $tgt; do
    test_f=test.$lang.$l.xml
    test_tok=$tmp/test.$lang.tok.$l
    echo $test_f $test_tok
    grep '<seg id' $test_dir/$test_f | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    perl $TOKENIZER -threads 8 -l $l > $test_tok
    echo ""
done


echo "Done"



