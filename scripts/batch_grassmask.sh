#!/bin/bash
#SBATCH --job-name=maskgrass
#SBATCH --account=open
#SBATCH --partition=basic
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/maskgrass-%A.out
#SBATCH --error=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/maskgrass-%A.err
#SBATCH --time=01:00:00
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=2-631%10                ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/batch_grassmask.R ${SLURM_ARRAY_TASK_ID}
