# Information for the experiments in emulating heuristic alignment scoring functions

## Vargas parameters

Vargas parameters to emulate default scoring functions for heuristic aligners  

*Bowtie 2 Semiglobal; HISAT2*

`--ete --ma 0 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3`

*Bowtie 2 Local*

`--ma 2 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3`

*BWA-MEM; vg*

Run vg with command-line parameters `-L 0 -t 1 -o 7` and a custom score matrix to enforce a N-penalty of 1  

`--ma 1 --mp 4,4 --np 1 --rdg 6,1 --rfg 6,1`

*BWA aln*

`--ete --ma 0 --mp 3,3 --np 3 --rdg 11,4 --rfg 11,4`

## Whole genome graph

We use the [1000 Genomes GRCh38 callset](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/). Note that variants from all chromosomes are combined and converted to chromosome names beginning with "chr" in the file `GRCh38.vcf`. 

Select variants with MAF >= 10\%

```
vcftools --vcf GRCh38.vcf --recode --maf 0.1  --out MAF10

vargas define -f genome.fa -v MAF10.vcf--out GRCh38_MAF10.gdef
```
