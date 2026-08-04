#!/bin/bash
#SBATCH --job-name=landmetric
#SBATCH --account=open
#SBATCH --partition=himem
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/landmetric-%A_%a.log
#SBATCH --time=24:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1                    ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/landscapemetrics.R ${SLURM_ARRAY_TASK_ID}
