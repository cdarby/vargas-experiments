#!/bin/bash

SCRIPTSDIR=/scratch/groups/blangme2/cdarby/scripts

mkdir summary

~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/bwamem.sam | sort -V -t, -k1,1 > summary/vargas_bwamem.csv
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/bt2_sg.sam | sort -V -t, -k1,1 > summary/vargas_bt2_sg.csv
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/bt2_local.sam | sort -V -t, -k1,1 > summary/vargas_bt2_local.csv
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/bwaaln.sam | sort -V -t, -k1,1 > summary/vargas_bwaaln.csv
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/ht2_graph.sam | sort -V -t, -k1,1 > summary/vargas_ht2_graph.csv
~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,AS,mc,ss,sc,mp" vargas/vg_graph.sam | sort -V -t, -k1,1 > summary/vargas_vg_graph.csv

sed -i 's/"//g' summary/vargas_bwamem.csv
sed -i 's/"//g' summary/vargas_bt2_sg.csv
sed -i 's/"//g' summary/vargas_bt2_local.csv
sed -i 's/"//g' summary/vargas_bwaaln.csv
sed -i 's/"//g' summary/vargas_ht2_graph.csv
sed -i 's/"//g' summary/vargas_vg_graph.csv

for i in `ls bt2/*sg.sam`; do 
	~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
	mode=`echo "$i" | cut -d/ -f 2 | cut -d_ -f 1`
	sed "s/^/\"${mode}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/bt2_sg.csv
	rm ${i%.*}.csv	
done

sed -i 's/\*/-1/g' summary/bt2_sg.csv

for i in `ls bt2/*local.sam`; do
        ~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
        mode=`echo "$i" | cut -d/ -f 2 | cut -d_ -f 1`
        sed "s/^/\"${mode}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/bt2_local.csv
	rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/bt2_local.csv

for i in `ls bt2/*localbwamscore.sam`; do
        ~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
        mode=`echo "$i" | cut -d/ -f 2 | cut -d_ -f 1`
        sed "s/^/\"${mode}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/bt2_localbwamscore.csv
        rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/bt2_localbwamscore.csv

for i in `ls bwamem/*.sam`; do
	~/work2/cdarby/vargas/bin/vargas-keep convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
	k=`echo "$i" | cut -d/ -f 2 | cut -d. -f 1`
	sed "s/^/\"${k}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/bwamem.csv
	rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/bwamem.csv

for i in `ls bwamem2/*.sam`; do
	~/work2/cdarby/vargas/bin/vargas-keep convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
	k=`echo "$i" | cut -d/ -f 2 | cut -d. -f 1`
	sed "s/^/\"${k}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/bwamem2.csv
	rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/bwamem2.csv

for i in `ls ht2/*linear.sam`; do
        ~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
        mode=`echo "$i" | cut -d/ -f 2 | cut -d_ -f 1`
        sed "s/^/\"${mode}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/ht2_linear.csv
	rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/ht2_linear.csv

for i in `ls ht2/*graph.sam`; do
        ~/work2/cdarby/vargas/bin/vargas convert -f "QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR" $i > ${i%.*}.csv
        mode=`echo "$i" | cut -d/ -f 2 | cut -d_ -f 1`
        sed "s/^/\"${mode}\",/" < ${i%.*}.csv | sed 's/"//g' | python ${SCRIPTSDIR}/cigar2endpos.py 4 8 >> summary/ht2_graph.csv
	rm ${i%.*}.csv
done

sed -i 's/\*/-1/g' summary/ht2_graph.csv

cp vg/linear.tsv summary/vg_linear.tsv
cp vg/graph.tsv summary/vg_graph.tsv

if [ -d "bwaaln" ]
then
	for i in `ls bwaaln/*csv`; do
		mode=`echo "$i" | cut -d/ -f 2 | cut -d. -f 1`
		sed "s/^/\"${mode}\",/" < ${i} >> summary/bwaaln.csv
	done
fi


