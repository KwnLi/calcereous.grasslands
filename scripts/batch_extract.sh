#!/bin/bash
#SBATCH --job-name=extr_calc
#SBATCH --account=open
#SBATCH --partition=basic
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/extr_%A.out
#SBATCH --error=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/extr_%A.err
#SBATCH --time=1:00:00
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=2-630              ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/batch_extract.R ${SLURM_ARRAY_TASK_ID}
