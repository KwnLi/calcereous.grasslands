#!/bin/bash
#SBATCH --job-name=calcgrass
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/calcgrass-%A_%a.out
#SBATCH --error=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/logs/calcgrass-%A_%a.err
#SBATCH --time=24:00:00
#SBATCH --mem=300G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --array=1                ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/batch_grame.R ${SLURM_ARRAY_TASK_ID}
