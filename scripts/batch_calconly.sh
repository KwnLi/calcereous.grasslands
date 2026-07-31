#!/bin/bash
#SBATCH --job-name=calconly
#SBATCH --account=open
#SBATCH --partition=himem
#SBATCH --output=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/calconly-%A.out
#SBATCH --error=/storage/home/kbl5733/work/github/calcereous.grasslands/logs/calconly-%A.err
#SBATCH --time=24:00:00
#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --array=2-630%10                ### Array index

module load anaconda
source activate r-geo

Rscript --vanilla /storage/home/kbl5733/work/github/calcereous.grasslands/scripts/batch_calconly.R ${SLURM_ARRAY_TASK_ID}
