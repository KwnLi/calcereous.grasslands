#!/bin/bash
#SBATCH --job-name=extr_calc
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=basic
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/extr_calc-%A_%a.out
#SBATCH --error=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/extr_calc-%A_%a.err
#SBATCH --time=3:00:00
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --array=1              ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/batch_extract.R ${SLURM_ARRAY_TASK_ID}
