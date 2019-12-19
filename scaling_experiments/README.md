# Scaling experiments

We use the [1000 Genomes GRCh38 callset](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/). Note that variants from all chromosomes are combined and converted to chromosome names beginning with "chr" in the file `GRCh38.vcf`. 

Select heterozygous and hom-alt variants from individual NA18505 using [vcftools](https://vcftools.github.io/index.html) (This is the small graph from the scaling experiments.)

```
vcftools --vcf GRCh38.vcf --chr chr19 --out chr19_GRCh38_NA18505 --recode --indv NA18505 --non-ref-ac 1

vargas define -f genome.fa -v chr19_GRCh38_NA18505.vcf -g chr19 -t chr19_small_graph.gdef
```

Exclude NA18505 private variants from the vcf (This is the large graph from the scaling experiments.)

```
vcftools --vcf GRCh38.vcf --chr chr19 --out chr19_GRCh38_exclude --recode --remove-indv NA18505 --non-ref-ac 1 

vargas define -f genome.fa -v chr19_GRCh38_exclude.vcf -g chr19 -t chr19_large_graph.gdef
```

Build the no-variants graph (This is the linear genome from the scaling experiments.)

```
vargas define -f genome.fa -g chr19 -t chr19_linear.gdef
```

Simulate 100bp reads from NA18505

```
mason_simulator -ir chr19.fa -iv chr19_GRCh38_NA18505.vcf.gz -n 100000 -o 100bp.fq
```