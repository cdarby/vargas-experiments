# Vargas-assisted alignment parameter optmization workflow

Sample Dataset: [ERR239486](ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/NA18505/sequence_read/ERR239486_1.filt.fastq.gz) - 100bp reads from 1000 Genomes Project sample NA18505. We use the first 100,000 reads.

## 1. Align the reads with the default parameter selection

Bowtie 2 semiglobal (SG): `--sensitive`, seed length is 22  
Bowtie 2 local (L): `--sensitive-local`, seed length is 20  
BWA-MEM: default, seed length is 19
vg + MAF10 graph: default, seed length is 22

## 2. Select reads that were unaligned or had a non-exact alignment score

Use the Bowtie2 semiglobal alignments to identify the "difficult reads"

```
samtools view -f 4 bt2/s_sg.sam | wc -l
1171
```

aligned, with more than one mismatch or any gaps

```
samtools view -F 4 bt2/s_sg.sam | grep -v 'XM:i:0.*XG:i:0\|XM:i:1.*XG:i:0' | wc -l
7194
```

8,365 reads total

```
samtools view -f 4 SRR901802_bt2.bam | cut -f1 > difficult.txt
samtools view -F 4 SRR901802_bt2.bam | grep -v 'XM:i:0.*XG:i:0\|XM:i:1.*XG:i:0' | cut -f1 >> difficult.txt
sort -k1,1 -o difficult.txt difficult.txt
```

## 3. Use Vargas to align the difficult reads

Vargas alignments for all 100,000 reads with all aligners' parameters had already been performed.

## 4. Parameter exploration

Example: `vargas/bt2_sg.sam` are reads Vargas aligned with Bowtie 2 semiglobal parameters. 

Make a fastq file where read names have the optimal alignment score.

```
cut -f1,18,10,11 vargas/bt2_sg.sam | sed 's/AS:i://' | sort -k 1,1 | join -j1 difficult.txt - | awk '{print "@" $1 "_" $4 "\n" $2 "\n+\n" $3}' > optimization/bt2sg/bt2sg_reads.fq
```

Try different seed lengths and compute summary statistics.

```
for SEED in `seq 10 32`; do ../../bin/time bowtie2 -x ~/data/resources/refdata-GRCh38-2.1.0/fasta/genome.fa -U bt2sg_reads.fq -L ${SEED} > ${SEED}.sam 2>>log.txt; done  
for SEED in `seq 10 32`; do python paramopt_bowtie2.py ${SEED}.sam; done
```


