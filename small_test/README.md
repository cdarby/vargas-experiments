# Commands to generate a small dataset and run Vargas

- Use [Mason2](https://github.com/seqan/seqan/tree/master/apps/mason2) to simulate a random genome of length 10,000

```
mason_genome -l 10000 -o small_test/G.fa
```

- Simulate one haplotype with frequent SNPs and indels

```
mason_variator -ir small_test/G.fa -ov small_test/G.vcf --snp-rate 0.02 -of small_test/G_var.fa --small-indel-rate 0.02
```

- Simulate 1,000 100-bp reads

```
mason_simulator -ir small_test/G.fa -n 1000 -o small_test/reads100.fq
```

- Simulate 1,000 200-bp reads

```
mason_simulator -ir small_test/G.fa -n 1000 -o small_test/reads200.fq --illumina-read-length 200
```

- Define a Vargas graph with no variants

```
vargas define -f small_test/G.fa -t small_test/G.gdef
```

- Define a Vargas graph with variants from vcf (remove haplotype column so Vargas can process)

```
cut -f1-9 small_test/G.vcf > small_test/G_cut.vcf
vargas define -f small_test/G.fa -t small_test/G_var.gdef -v small_test/G_cut.vcf
```

- Align 100bp reads to graph

```
vargas align -g small_test/G_var.gdef -U small_test/reads100.fq -S small_test/100_reads_to_G_var.sam
```

- Align 100bp reads to no-variant genome (will calculate traceback)

```
vargas align -g small_test/G.gdef -U small_test/reads100.fq -S small_test/100_reads_to_G.sam
```

- Align 200bp reads to graph in end-to-end mode (will use 16-bit aligner)

```
vargas align -g small_test/G_var.gdef -U small_test/reads200.fq -S small_test/200_reads_to_G_var.sam --ete
```

- Align 200bp reads to no-variant genome in end-to-end mode (will use 16-bit aligner and calculate traceback)

```
vargas align -g small_test/G.gdef -U small_test/reads200.fq -S small_test/200_reads_to_G.sam --ete
```