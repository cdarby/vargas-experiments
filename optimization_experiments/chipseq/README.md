# Vargas-assisted alignment parameter optmization workflow

Sample Dataset: [SRR901802](https://www.ncbi.nlm.nih.gov/sra/SRR901802) - 41,619,485 36bp ChIP-seq reads from (McVicker et al., 2013)
Sample Aligner: Bowtie 2

## 1. Align the reads with an initial parameter selection

These reads were analyzed with Bowtie 2 default parameters in (Van de Geijn et al., 2015).

```
bowtie2 -p 16 --very-sensitive -x ~/data/resources/refdata-GRCh38-2.1.0/fasta/genome.fa -U SRR901802.fastq.gz | samtools view -b > SRR901802_bt2.bam
41619485 reads; of these:
  41619485 (100.00%) were unpaired; of these:
    174521 (0.42%) aligned 0 times
    30242587 (72.66%) aligned exactly 1 time
    11202377 (26.92%) aligned >1 times
99.58% overall alignment rate
```
5702.65user 392.02system 6:26.03elapsed 1578%CPU (0avgtext+0avgdata 3526780maxresident)k
3313272inputs+0outputs (0major+99209687minor)pagefaults 0swaps

## 2. Select reads that were unaligned or had a non-exact alignment score

unaligned 

```
samtools view -f 4 SRR901802_bt2.bam | wc -l
174521
```

aligned, with more than one mismatch or any gaps

```
samtools view -F 4 SRR901802_bt2.bam | grep -v 'XM:i:0.*XG:i:0\|XM:i:1.*XG:i:0' | wc -l
396268
```

570789 reads total

```
samtools view -h -f 4 SRR901802_bt2.bam > to_realign.sam
samtools view -F 4 SRR901802_bt2.bam | grep -v 'XM:i:0.*XG:i:0\|XM:i:1.*XG:i:0' >> to_realign.sam
samtools fastq to_realign.sam > to_realign.fq
```

## 3. Use Vargas to align the unaligned and non-exactly-aligning reads


```
vargas align -g GRCh38.gdef -j 95 -U {fastq} --ma 0 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3 --ete -S {sam}
```

vargas_realigned.sam

## 4. Evaluate correctness

```
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas_realigned.sam | sort -V -t, -k1,1 | sed 's/"//g' > vargas.csv

~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" to_realign.sam | sed 's/"//g' | python ../scripts/cigar2endpos.py 3 7 | sort -V -t, -k1,1 > bt2.csv
```


396268 reads with >1 mismatch or >0 indel in the Bowtie 2 alignment (0.95% of total dataset):  

84% had correct alignment score and 73% had correct alignment location (+/- 5bp)
-8.70/-8 mean/median optimal AS 
-9.42/-9 mean/median Bowtie 2 AS 

76% had a unique optimal alignment
	of these, 88% had correct alignment score and 91% had correct alignment location (+/- 5bp)
	-8.27/-8 mean/median optimal AS 
	-8.79/-8 mean/median Bowtie 2 AS 
24% had multiple optimal alignments
	of these, 71% had correct alignment score and 18% had the same alignment location as Vargas reported (+/- 5bp) 
	-10.15/-10 mean/median optimal AS 
	-11.36/-11 mean/median Bowtie 2 AS 
	
	
174521 reads that were unaligned (0.42% of total dataset):  

69% had a unique optimal alignment
-17.29/-15 mean/median optimal AS 



## 5. Parameter exploration

Make an augmented fastq file

vargas_realigned.sam is just records with no header

```
cut -f1,18,10,11 vargas_realigned.sam | sed 's/AS:i://' | sort -k1,1 > vargas_scores.tsv
cut -f1,5 -d, bt2.csv | tr , '\t' | sort -k1,1 | join -j1 - vargas_scores.tsv | awk '{print "@" $1 "_" $2 "_" $5 "\n" $3 "\n+\n" $4}' > scored_reads.fq
```

Try different seed lengths and DP-extension iterations - align the first 10,000 reads only.

```
for SEED in `seq 12 2 32`; do for EXTEND in 20 60 100; do ../../bin/time bowtie2 -x ~/data/resources/refdata-GRCh38-2.1.0/fasta/genome.fa -U scored_reads.fq -L ${SEED} -D ${EXTEND} -u 10000 > params/l${SEED}d${EXTEND}.sam; done; done
for SEED in `seq 12 2 32`; do for EXTEND in 20 60 100; do python paramopt_bowtie2.py params/l${SEED}d${EXTEND}.sam; done; done
```

Realign all reads with optimal parameters

```
../../bin/time bowtie2 -x ~/data/resources/refdata-GRCh38-2.1.0/fasta/genome.fa -U to_realign.fq -L 14 -D 100 > bt2_l14d100.sam
570789 reads; of these:
  570789 (100.00%) were unpaired; of these:
    134610 (23.58%) aligned 0 times
    250440 (43.88%) aligned exactly 1 time
    185739 (32.54%) aligned >1 times
76.42% overall alignment rate
961.04user 31.13system 16:33.93elapsed 99%CPU (0avgtext+0avgdata 3381596maxresident)k
99552inputs+194528outputs (0major+20955955minor)pagefaults 0swaps
```
