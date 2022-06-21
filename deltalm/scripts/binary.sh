#!/usr/bin/env bash
set -e

input_dir=data/spm
output_dir=data/bin
dict_file=data/dict.txt
src=ms
tgt=zh

python preprocess.py  \
    --trainpref $input_dir/train \
    --validpref $input_dir/val \
    --testpref $input_dir/test \
    --source-lang $src --target-lang $tgt \
    --destdir $output_dir \
    --srcdict $dict_file \
    --tgtdict $dict_file \
    --workers 40