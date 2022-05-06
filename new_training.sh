#!/bin/bash

# ============================================================================
# This script is used for every new training of DeepSpeech
# ============================================================================

EARLY_STOP="1"
BATCH_SIZE="96"
N_HIDDEN="2048"
EPOCHS="200"
LEARNING_RATE="0.0001"
DROPOUT="0.3"
LM_ALPHA="0.65"
LM_BETA="1.45"
DS_SHA1="73278cf8d6214d67deab30684803f84354fba378"

print_help () {
	echo "new_training.sh : Create a new repo and start a training with all parameters"
	echo "Usage : ./new_training.sh [OPTIONAL: fullpathName]"
}


# Check if argument is present
if [ $# == 0 ]; then
    echo "No args, the repo name will be new_training";
    fullpathName="/media/profenpoche/data/Nicolas/training/new_training"	
else
    # Check if help argument is present
    if [ $1 == '-h' ]; then
        print_help
            exit 0
    fi
    fullpathName=$1
fi


mkdir $fullpathName

: '
#sudo docker build -t coqui:latest -f Dockerfile.train .

container_id=$(sudo docker run --gpus all -itd \
    --mount type=bind,src=/media/profenpoche/data/Nicolas/training/$fullpathName,dst=/mnt \
    --mount type=bind,src=/media/profenpoche/data/Nicolas/training_files,dst=/training_files \
    --mount type=bind,src=/media/profenpoche/data/Nicolas/dataset/,dst=/datasrc \
    ghcr.io/coqui-ai/stt-train)

# Training :
nohup sudo docker exec $container_id bash -c \
    'python3 -m coqui_stt_training.train --alphabet_config_path /training_files/alphabet.txt --scorer_path /training_files/kenlm.scorer --train_files /datasrc/mathia/train.csv --dev_files /datasrc/mathia/dev.csv --test_files /datasrc/mathia/test.csv --checkpoint_dir /mnt/checkpoints --export_dir /mnt/exported-model --test_output_file /mnt/test_output --train_batch_size $BATCH_SIZE --dev_batch_size $BATCH_SIZE --test_batch_size $BATCH_SIZE --epochs $EPOCHS --reduce_lr_on_plateau true --plateau_epochs 8 --plateau_reduction 0.08 --early_stop true --es_epochs $EARLY_STOP --es_min_delta 0.06 --dropout_rate $DROPOUT'\
    > $fullpathName/log 2>&1 &

# Fine-tuning :
nohup sudo docker exec $container_id bash -c \
    'python3 -m coqui_stt_training.train --alphabet_config_path /training_files/alphabet.txt --scorer_path /training_files/kenlm.scorer --train_files /datasrc/mathia/train.csv --dev_files /datasrc/mathia/dev.csv --test_files /datasrc/mathia/test.csv --checkpoint_dir /mnt/checkpoints --export_dir /mnt/exported-model --test_output_file /mnt/test_output --train_batch_size $BATCH_SIZE --dev_batch_size $BATCH_SIZE --test_batch_size $BATCH_SIZE --epochs $EPOCHS --reduce_lr_on_plateau true --plateau_epochs 8 --plateau_reduction 0.08 --early_stop true --es_epochs $EARLY_STOP --es_min_delta 0.06 --dropout_rate $DROPOUT'\
    > $fullpathName/log 2>&1 &

'