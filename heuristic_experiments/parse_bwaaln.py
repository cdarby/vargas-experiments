import sys
import pysam

#QNAME,FLAG,RNAME,POS,AS,XS,MAPQ,CIGAR,endpos

samfile = pysam.AlignmentFile(sys.argv[1], "r")
for read in samfile.fetch(until_eof=True):
	print(read.query_name,end=',')
	print(read.flag,end=',')
	if not read.is_unmapped:
		print(read.reference_name,end=',')
		print(read.reference_start+1,end=',') #0-based leftmost coordinate

		score = read.get_tag("XM") * -3
		c = read.cigartuples
		for (op, length) in c:
			if op == 1 or op == 2:
				score += -11 + length * -4
		print(score,end=',')

		print("-1",end=',')
		print(read.mapping_quality,end=',')
		print(read.cigarstring,end=',')
		print(read.reference_end+1) #reference_end points to one past the last aligned residue

	else:
		print("-1,-1,0,-1,0,-1,-1")

