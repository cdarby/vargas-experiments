#!/bin/bash

module load bowtie2 samtools gcc

READS=/scratch/groups/blangme2/cdarby/NA18505/reads/100k.fq
OUTPUT=/scratch/groups/blangme2/cdarby/100bp
TIMEPG=/scratch/groups/blangme2/bin/time
SAMTOOLSPG=samtools
SCRIPTSDIR=/scratch/groups/blangme2/cdarby/scripts

# bowtie2

BOWTIE2PG=bowtie2
BOWTIE2IDX=/work-zfs/mschatz1/resources/refdata-GRCh38-2.1.0/fasta/genome.fa
mkdir ${OUTPUT}/bt2

# semiglobal

${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-fast 2> ${OUTPUT}/bt2/vf_sg.log 1> ${OUTPUT}/bt2/vf_sg.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --fast 2> ${OUTPUT}/bt2/f_sg.log 1> ${OUTPUT}/bt2/f_sg.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --sensitive 2> ${OUTPUT}/bt2/s_sg.log 1> ${OUTPUT}/bt2/s_sg.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-sensitive 2> ${OUTPUT}/bt2/vs_sg.log 1> ${OUTPUT}/bt2/vs_sg.sam 
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} -L 30 -D 60 2> ${OUTPUT}/bt2/l30d60_sg.log 1> ${OUTPUT}/bt2/l30d60_sg.sam 

# local

${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-fast-local 2> ${OUTPUT}/bt2/vf_local.log 1> ${OUTPUT}/bt2/vf_local.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --fast-local 2> ${OUTPUT}/bt2/f_local.log 1> ${OUTPUT}/bt2/f_local.sam 
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --sensitive-local 2> ${OUTPUT}/bt2/s_local.log 1> ${OUTPUT}/bt2/s_local.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-sensitive-local 2> ${OUTPUT}/bt2/vs_local.log 1> ${OUTPUT}/bt2/vs_local.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} -L 30 -D 60 --local 2> ${OUTPUT}/bt2/l30d60_local.log 1> ${OUTPUT}/bt2/l30d60_local.sam

# local + bwa mem scoring function

${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-fast-local --ma 1 --mp 4,4 --rdg 6,1 --rfg 6,1 --score-min L,30,0 2> ${OUTPUT}/bt2/vf_localbwamscore.log 1> ${OUTPUT}/bt2/vf_localbwamscore.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --fast-local --ma 1 --mp 4,4 --rdg 6,1 --rfg 6,1 --score-min L,30,0 2> ${OUTPUT}/bt2/f_localbwamscore.log 1> ${OUTPUT}/bt2/f_localbwamscore.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --sensitive-local --ma 1 --mp 4,4 --rdg 6,1 --rfg 6,1 --score-min L,30,0 2> ${OUTPUT}/bt2/s_localbwamscore.log 1> ${OUTPUT}/bt2/s_localbwamscore.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --very-sensitive-local --ma 1 --mp 4,4 --rdg 6,1 --rfg 6,1 --score-min L,30,0 2> ${OUTPUT}/bt2/vs_localbwamscore.log 1> ${OUTPUT}/bt2/vs_localbwamscore.sam
${TIMEPG} ${BOWTIE2PG} -x ${BOWTIE2IDX} -U ${READS} --local --ma 1 --mp 4,4 --rdg 6,1 --rfg 6,1 --score-min L,30,0 -L 30 -D 60 2> ${OUTPUT}/bt2/l30d60_localbwamscore.log 1> ${OUTPUT}/bt2/l30d60_localbwamscore.sam 

# bwa mem

BWAPG=/home-1/cdarby3@jhu.edu/bin/bwa
BWAIDX=/work-zfs/mschatz1/resources/refdata-GRCh38-2.1.0/fasta/genome.fa
mkdir ${OUTPUT}/bwamem

${TIMEPG} ${BWAPG} mem -k 16 -r 1.2 ${BWAIDX} ${READS} 2> ${OUTPUT}/bwamem/k16r12.log | ${SAMTOOLSPG} view -h -F 2048 > ${OUTPUT}/bwamem/k16r12.sam  
${TIMEPG} ${BWAPG} mem ${BWAIDX} ${READS} 2> ${OUTPUT}/bwamem/k19.log | ${SAMTOOLSPG} view -h -F 2048 > ${OUTPUT}/bwamem/k19.sam
${TIMEPG} ${BWAPG} mem -k 22 -r 3 ${BWAIDX} ${READS} 2> ${OUTPUT}/bwamem/k22r3.log | ${SAMTOOLSPG} view -h -F 2048 > ${OUTPUT}/bwamem/k22r3.sam
${TIMEPG} ${BWAPG} mem -k 25 -r 4 ${BWAIDX} ${READS} 2> ${OUTPUT}/bwamem/k25r4.log | ${SAMTOOLSPG} view -h -F 2048 > ${OUTPUT}/bwamem/k25r4.sam

# bwa aln

mkdir ${OUTPUT}/bwaaln

${TIMEPG} ${BWAPG} aln -o 1 -n 5 ${BWAIDX} ${READS} -f ${OUTPUT}/bwaaln/o1n5.sai 2> ${OUTPUT}/bwaaln/o1n5.log 
${TIMEPG} ${BWAPG} samse ${BWAIDX} ${OUTPUT}/bwaaln/o1n5.sai ${READS} 2>> ${OUTPUT}/bwaaln/o1n5.log > ${OUTPUT}/bwaaln/o1n5.sam
python ${SCRIPTSDIR}/parse_bwaaln.py ${OUTPUT}/bwaaln/o1n5.sam > ${OUTPUT}/bwaaln/o1n5.csv
rm ${OUTPUT}/bwaaln/o1n5.sai

${TIMEPG} ${BWAPG} aln -o 3 -n 10 ${BWAIDX} ${READS} -f ${OUTPUT}/bwaaln/o3n10.sai 2> ${OUTPUT}/bwaaln/o3n10.log 
${TIMEPG} ${BWAPG} samse ${BWAIDX} ${OUTPUT}/bwaaln/o3n10.sai ${READS} 2>> ${OUTPUT}/bwaaln/o3n10.log > ${OUTPUT}/bwaaln/o3n10.sam
python ${SCRIPTSDIR}/parse_bwaaln.py ${OUTPUT}/bwaaln/o3n10.sam > ${OUTPUT}/bwaaln/o3n10.csv
rm ${OUTPUT}/bwaaln/o3n10.sai

${TIMEPG} ${BWAPG} aln -o 5 -n 15 ${BWAIDX} ${READS} -f ${OUTPUT}/bwaaln/o5n15.sai 2> ${OUTPUT}/bwaaln/o5n15.log 
${TIMEPG} ${BWAPG} samse ${BWAIDX} ${OUTPUT}/bwaaln/o5n15.sai ${READS} 2>> ${OUTPUT}/bwaaln/o5n15.log > ${OUTPUT}/bwaaln/o5n15.sam
python ${SCRIPTSDIR}/parse_bwaaln.py ${OUTPUT}/bwaaln/o5n15.sam > ${OUTPUT}/bwaaln/o5n15.csv
rm ${OUTPUT}/bwaaln/o5n15.sai

# hisat2

HISAT2PG=/scratch/users/cdarby3@jhu.edu/hisat2/hisat2
HISAT2LINEARINDEX=/work-zfs/mschatz1/resources/refdata-GRCh38-2.1.0/fasta/ht2/genome
HISAT2GRAPHINDEX=/scratch/groups/blangme2/cdarby/hisat2_graphs/maf10
mkdir ${OUTPUT}/ht2

# linear

${TIMEPG} ${HISAT2PG} -x ${HISAT2LINEARINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} 2> ${OUTPUT}/ht2/f_linear.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/f_linear.sam 
${TIMEPG} ${HISAT2PG} -x ${HISAT2LINEARINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} --sensitive 2> ${OUTPUT}/ht2/s_linear.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/s_linear.sam 
${TIMEPG} ${HISAT2PG} -x ${HISAT2LINEARINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} --very-sensitive 2> ${OUTPUT}/ht2/vs_linear.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/vs_linear.sam

# graph

${TIMEPG} ${HISAT2PG} -x ${HISAT2GRAPHINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} 2> ${OUTPUT}/ht2/f_graph.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/f_graph.sam 
${TIMEPG} ${HISAT2PG} -x ${HISAT2GRAPHINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} --sensitive 2> ${OUTPUT}/ht2/s_graph.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/s_graph.sam 
${TIMEPG} ${HISAT2PG} -x ${HISAT2GRAPHINDEX} -k 1 --no-spliced-alignment --no-softclip -U ${READS} --very-sensitive 2> ${OUTPUT}/ht2/vs_graph.log | ${SAMTOOLSPG} view -h -F 256 > ${OUTPUT}/ht2/vs_graph.sam 

# vg

VGPG=/home-1/cdarby3@jhu.edu/vg
VGLINEARINDEX=/scratch/groups/blangme2/cdarby/vg_graphs/genome
VGGRAPHINDEX=/scratch/groups/blangme2/cdarby/vg_graphs/maf10
VGSCORING=/scratch/groups/blangme2/cdarby/npenalty.mat
mkdir ${OUTPUT}/vg

${TIMEPG} ${VGPG} map -d ${VGLINEARINDEX} -f ${READS} --score-matrix ${VGSCORING} -L 0 -t 1 -o 7 > ${OUTPUT}/vg/linear.tsv 2> ${OUTPUT}/vg/linear.log
${TIMEPG} ${VGPG} map -d ${VGGRAPHINDEX} -f ${READS} --score-matrix ${VGSCORING} -L 0 -t 1 -o 7 > ${OUTPUT}/vg/graph.tsv 2> ${OUTPUT}/vg/graph.log
