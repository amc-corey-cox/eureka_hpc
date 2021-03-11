# Notes for Running on Eureka HPC

## Eureka_HPC links
ADRN HPC - https://hdchpcprodbarnesadrn1-hpc-1.hdcuser.org/  
CAAPA HPC - https://hdchpcprodcaapa1-hpc-1.hdcuser.org/  
eQTL - https://hdchpcprodbarneseqtl1-hpc-1.hdcuser.org/  

## Google Bucket shares

**ADRN** - hdcekabarnesadrn1\
**CAAPA** - hdcekabarnescaapa1\
**eQTL** - hdcekabarneseqtl1\
**il33** - hdcekabarnesil331
```
gcsfuse --implicit-dirs <project-name> <mount_directory>
```

### HPC staging Buckets
**ADRN HPC staging** - hdchpcprodbarnesadrn1-staging\
**CAAPA HPC staging** - hdcekabarnescaapa1-staging\
**eQTL HPC stagining** - hdcekabarneseqtl1-staging

### Sample code from Chris Arehart

```
#!/bin/bash
#SBATCH -p c2s60
#SBATCH --job-name=PRS_liftover
#SBATCH --out=liftover_and_hapmap3_filter.log
#SBATCH --error=liftover_and_hapmap3_filter.err


gsutil -q cp -r gs://hdchpcprodtis1-staging/arehartc/PRS_software/ . &
echo "# *-*-*-*  current files in directory:"
chmod u+rw ./*
chmod -R u+rwx ./PRS_software/
ls -lrth
set +e restore normal error handling
# add software paths
export PATH="./PRS_software/vcftools_0.1.13_prs/cpp:$PATH"
export PATH="./PRS_software/vcftools_0.1.13_prs/perl:$PATH"
export PATH="./PRS_software/bcftools-1.10.2/bin:$PATH"
export PATH="./PRS_software/:$PATH"


#in the middle of a bash script I do this to run an R script
cat << 'EOF' >c_subset_ethnicities.R
library(data.table)
for (arg in commandArgs(TRUE)){
  eval(parse(text=arg))
}
print("The sumstats prefix is:")
print(SSFNAME)
s <- fread("./freeze_1_and_2_ancestry_predicted_race_umap.txt")
head(s)
summary(as.factor(s$UMAP_RACE))
s$UMAP_RACE <- as.character(s$UMAP_RACE)
f <- fread(paste0("./",SSFNAME,"_freeze2_imputed_hapmap3_filtered.fam"))
colnames(f) <- c("famFID","famIID","famFather","famMother","famSex","famPhenotype")
# for(i in c(  "AFR",  "AMR",  "EAS",  "EUR",  "MLE",  "OCE",   "SAS"  ))
for(i in unique(s$UMAP_RACE)){
	s_i <- subset(s, s$UMAP_RACE == i)
	s_i_merge <- merge(s_i,f, by.x = "SUBJECT", by.y  = "famIID")
	s_i_merge_sub <- s_i_merge[,c("famFID","SUBJECT")]
	# head(s_i_merge_sub)
	print(paste0(i,"   ",nrow(s_i_merge_sub)))
	write.table(s_i_merge_sub, file=paste0(i,"_individuals.txt"), col.names = F, row.names = F, quote = F)
}
EOF
argString="--args SSFNAME=\"$SSFNAME\"" 
echo "$argString"
R CMD BATCH "$argString" "c_subset_ethnicities.R"

```


```
#!/bin/bash
#SBATCH -p c2s8
#SBATCH --job-name=testing
#SBATCH --out=test.log
#SBATCH --error=test.err
# make temporary directory to run the script in
# staging in data and container
set -e # fail script on any error
DIR=$(mktemp -d)
cd "$DIR"

# move appropriate data into tmp space from google bucket
gsutil -q cp gs://… . &
gsutil -q cp gs://… . &
wait
set +e restore normal error handling
# do all of the code
sleep 3
echo "hello world :)"
sleep 3
cat << 'EOF' >outfile.txt
hello world :)
EOF
# move results into google bucket (this is how Nick suggested, but I usually just copy like below)
gsutil -m rsync -r $DIR/… gs://… &
# or you can copy any files you made (and want to keep) back to gs
gsutil -m cp outfile.txt gs://directory


```

## Coldline Google Buckets
ADRN - adrn_coldline\
CAAPA - caapa_coldline\
eQTL - eqtl_coldline

## Archive Google Buckets
ADRN - adrn_archive\
CAAPA - caapa_archive\
eQTL - eqtl_archive
