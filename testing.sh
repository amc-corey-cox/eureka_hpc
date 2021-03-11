#!/bin/bash
#SBATCH -p c2s4
#SBATCH --job-name=hpc_tmp
#SBATCH --out=hpc_tmp.log
#SBATCH --error=hpc_tmp.err

# These lines generally make bash shell scripts safer
set -euo pipefail        # -e: exit on any error, -u: treat unset variables as error
IFS="`printf '\n\t'`"    # split words only on \n and \t, not space (improves loops)

# Uncomment this for better logging
set -x # Print each command after variable exansion

DIR=$(mktemp -d)
cd "$DIR"

# move appropriate data into tmp space from google bucket
gsutil -q cp gs://hdcekabarnesadrn1/ADRN_MEGA_META_SEVERITY/EOS_PRS/tools/bin . &
# gsutil -q cp gs://… . &
wait

PATH=$DIR:$PATH

#in the middle of a bash script I do this to run an R script
cat << 'EOF' >c_subset_ethnicities.R
library(tidyverse)
print(r_arg)
EOF
argString="--args r_arg=\"R works!\"" 
echo "$argString"
R CMD BATCH "$argString" "c_subset_ethnicities.R" > outfile.txt

echo $PATH >> outfile.txt

# do all of the code
sleep 3
echo "hello world :)"
sleep 3
cat << 'EOF' >> outfile.txt
hello world :)
EOF

tabix >> outfile.txt

# move rsync results into google bucket
# gsutil -m rsync -r $DIR/… gs://… &
# wait

# or you can copy any files you made (and want to keep) back to gs
gsutil -m cp outfile.txt gs://hdcekabarnesadrn1/ADRN_MEGA_META_SEVERITY/EOS_PRS/testing/
