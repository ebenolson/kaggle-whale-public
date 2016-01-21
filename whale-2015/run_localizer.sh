#!/bin/bash -e
#
# Train localizer and generate predictions.
#

function prep() {
    for file in imgs.zip train.csv w_7489.jpg sample_submission.csv
    do
        if [ ! -f $data_dir/$file ]
        then
            echo $data_dir/$file not found
            exit
        fi
    done
    echo Unzipping: `date`
    unzip -qu $data_dir/imgs.zip -d $data_dir
    cp $data_dir/w_7489.jpg $data_dir/imgs
    mkdir -p $data_dir/train $data_dir/test
    for file in `cat $data_dir/train.csv | cut -f1 -d',' | tail -n +2`
    do
        mv $data_dir/imgs/$file $data_dir/train/
    done
    mv $data_dir/imgs/* $data_dir/test

    echo Cropping training images: `date`
    python crop.py points1.json points2.json $data_dir/train $data_dir/traincrops $imwidth 0

    echo Writing macrobatches: `date`
    python batch_writer.py --image_dir=$data_dir/train --data_dir=$data_dir/macrotrain --points1_file points1.json --points2_file points2.json --target_size $imwidth --val_pct 0
    python batch_writer.py --image_dir=$data_dir/test --data_dir=$data_dir/macrotest --target_size $imwidth --val_pct 100
    python batch_writer.py --image_dir=$data_dir/traincrops --data_dir=$data_dir/macrotraincrops --id_label 1 --target_size $imwidth --val_pct 0

    touch $data_dir/prepdone
    echo Prep done: `date`
}


if [ "$2" == "" ]
then
    echo Usage:  $0 /path/to/data
    exit
fi

data_dir=$1
num_epochs=40
imwidth=384

echo Starting: `date`

if [ -f $data_dir/prepdone ]
then
    echo $data_dir/prepdone exists. Skipping prep...
else
    prep
fi
echo prep finished

echo data_dir=$data_dir, num_epochs=$num_epochs, imwidth=$imwidth

for i in `seq 0 16`;
do
    echo Round $i

    echo Localizing first point: `date`
    ./localizer.py -z32 -e $num_epochs -w $data_dir/macrotrain -tw $data_dir/macrotest -r0 -s model1_.pkl -bgpu -pn 1 -iw $imwidth --serialize 1 ${@:2}
    echo Localizing second point: `date`
    ./localizer.py -z32 -e $num_epochs -w $data_dir/macrotrain -tw $data_dir/macrotest -r0 -s model2_.pkl -bgpu -pn 2 -iw $imwidth --serialize 1 ${@:2}

    mv testpoints1.json $data_dir/testpoints/testpoints1_$i.json
    mv testpoints2.json $data_dir/testpoints/testpoints2_$i.json
done
