#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mem=64G
#SBATCH --output=/home/marcbo/dataprep/log/%j.out
#SBATCH --error=/home/marcbo/dataprep/log/%j.err
#SBATCH --exclude=tikgpu[01-09],artongpu01

#Job script to test astattendgru preprocessing

# Exit on errors
set -o errexit

# Set a directory for temporary files unique to the job with automatic removal at job termination
TMPDIR=$(mktemp -d)
if [[ ! -d ${TMPDIR} ]]; then
            echo 'Failed to create temp directory' >&2
                exit 1
fi
trap "exit 1" HUP INT TERM
trap 'rm -rf "${TMPDIR}"' EXIT
export TMPDIR

# Change the current directory to the location where you want to store temporary files, exit if changing didn't succeed.
# Adapt this to your personal preference
cd "${TMPDIR}" || exit 1

# Activate the conda environment
#source /home/marcbo/.bashrc
[[ -f /itet-stor/${USER}/net_scratch/conda/bin/conda ]] && eval "$(/itet-stor/${USER}/net_scratch/conda/bin/conda shell.bash hook)"
conda activate astgru
echo "Conda activated"

# Send some noteworthy information to the output log
echo "Running on node: $(hostname)"
echo "In directory:    $(pwd)"
echo "Starting on:     $(date)"
echo "SLURM_JOB_ID:    ${SLURM_JOB_ID}"


# Add the library variable of the srcml tool
#NOTE: change this to match the path of srmls lib in mlmfc (Also change srcmlpath in 0_srcmlast.py!)
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/itet-stor/marcbo/net_scratch/srcml/build/lib
export LD_LIBRARY_PATH


DATAPATH=/itet-stor/marcbo/net_scratch/astgrudata/preprocess/default/

OUTPATH=/itet-stor/marcbo/net_scratch/astgrudata/preprocess/outdir/

# Run the preparation scripts
time python3 /home/marcbo/astgru/funcom/preprocess/0_srcmlast.py ${DATAPATH} ${OUTPATH}
time python3 /home/marcbo/astgru/funcom/preprocess/1_specialchars.py ${OUTPATH}
time python3 /home/marcbo/astgru/funcom/preprocess/2_tokenize.py ${OUTPATH}
time python3 /home/marcbo/astgru/funcom/preprocess/3_final.py ${OUTPATH}

# Send more noteworthy information to the output log
echo "Finished at:     $(date)"

# End the script with exit code 0
exit 0
