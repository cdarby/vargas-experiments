#!/bin/bash

VARGASPG=/home1/06358/tg856577/vargas/bin/vargas
TIMEPG=/usr/bin/time

LINEARREF=/work/06358/tg856577/stampede2/gdefs/GRCh38.gdef
GRAPHREF=/work/06358/tg856577/stampede2/gdefs/GRCh38_MAF10.gdef

READSPFX=/work/06358/tg856577/stampede2/NA19017/na19017_split.fq
HOURS=12
MAXREADPARTS=29

# bowtie2 semiglobal + hisat2 linear

mkdir /work/06358/tg856577/stampede2/NA19017/bt2

for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J bt2sg-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${LINEARREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/bt2/${NUM}.sam --ete --ma 0 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3 -u 32"
done

# bowtie2 local

mkdir /work/06358/tg856577/stampede2/NA19017/bt2loc 

for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J bt2loc-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${LINEARREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/bt2loc/${NUM}.sam --ma 2 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3 -u 32"
done

# bwa mem + vg linear

mkdir /work/06358/tg856577/stampede2/NA19017/bwamem

for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J bwamem-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${LINEARREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/bwamem/${NUM}.sam --ma 1 --mp 4,4 --np 1 --rdg 6,1 --rfg 6,1 -u 32"
done

# bwa aln

mkdir /work/06358/tg856577/stampede2/NA19017/bwaaln

for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J bwaaln-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${LINEARREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/bwaaln/${NUM}.sam --ete --ma 0 --mp 3,3 --np 3 --rdg 11,4 --rfg 11,4 -u 32"
done


# vg graph

mkdir /work/06358/tg856577/stampede2/NA19017/vg-graph


for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J vg-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${GRAPHREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/vg-graph/${NUM}.sam --ma 1 --mp 4,4 --np 1 --rdg 6,1 --rfg 6,1 -u 32"
done

# ht2 graph

mkdir /work/06358/tg856577/stampede2/NA19017/ht2-graph

for NUM in `seq 10 ${MAXREADPARTS}`
do
	sbatch -p skx-normal -J ht2g-${NUM} -p skx-normal -N 1 -n 1 -t ${HOURS}:00:00 --wrap="export OMP_NUM_THREADS=96; ${TIMEPG} ${VARGASPG} align -g ${GRAPHREF} -j 95 -U ${READSPFX}${NUM} -S /work/06358/tg856577/stampede2/NA19017/ht2-graph/${NUM}.sam --ete --ma 0 --mp 2,6 --np 1 --rdg 5,3 --rfg 5,3 -u 32"
done
