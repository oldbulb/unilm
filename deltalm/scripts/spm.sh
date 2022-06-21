#!/usr/bin/env bash
set -e
#URL="https://deltalm.blob.core.windows.net/deltalm/spm.model"
#wget $URL

input_dir=data/clean
output_dir=data/spm
lang=ms-zh
src=ms
tgt=zh

mkdir -p $output_dir

SPM_MODEL=spm.model

for split in train val test;
do
    for l in $src $tgt ; do
        cat < $input_dir/$split.$lang.tok.$l | spm_encode --model=$SPM_MODEL --output_format=piece > $output_dir/$split.$l;
        if [ $split == train ]; then
            cat < $input_dir/$split.tok.$l | spm_encode --model=$SPM_MODEL --output_format=piece > $output_dir/mono.$l;
        fi
    done;
done

#mv $SPM_MODEL $output_dir

echo "Done"