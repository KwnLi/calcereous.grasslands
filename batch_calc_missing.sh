#!/bin/bash -l

#SBATCH --partition=atlas
#SBATCH --qos=normal
#SBATCH --job-name=calcgrass
#SBATCH --output=/90daydata/geoecoservices/calcereous_grasslands/logs/missing-%j.out
#SBATCH --error=/90daydata/geoecoservices/calcereous_grasslands/logs/missing-%j.err
#SBATCH --account=geoecoservices
#SBATCH --mail-user=kevin.li@usda.gov
#SBATCH --mail-type=NONE
#SBATCH --time=24:00:00
#SBATCH --mem=300G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --get-user-env              ### Import your user environment setup
#SBATCH --array=1-6                 ### Array index

module purge

source /project/geoecoservices/R_packages/Rspatial.sh

Rscript --vanilla batchjob_missing.R ${SLURM_ARRAY_TASK_ID}
