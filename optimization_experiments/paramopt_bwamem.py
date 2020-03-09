
# Usage: python paramopt_bwamem.py aln.sam 

# read names are formatted as [readname]_[Vargas optimal AS]

import pysam
import sys

samfile = pysam.AlignmentFile(sys.argv[1],'rb')

n = 0

# Just look at the new score
n_aligned = 0
n_incorrect = 0
incorrect_difference = 0.0

for read in samfile.fetch(until_eof=True):
	n += 1
	name = read.query_name
	
	optscore = int(name.split("_")[1])
	
	newscore = int(read.get_tag("AS"))

	if newscore != 0: # an AS of 0 means the read is unaligned
		n_aligned += 1
		if newscore != optscore:
			n_incorrect += 1
			incorrect_difference += (optscore-newscore)

# number incorrect / total
# number aligned / total
# number incorrect / number aligned
# of aligned reads, average distance between optimal and alignment score
# of incorrect reads, average distance between optimal and alignment score

x = 0.0 if n_incorrect == 0 else 1.0*incorrect_difference/n_incorrect

print("\t".join([str(x) for x in [
	1.0*n_incorrect/n,
	1.0*n_aligned/n,
	1.0*n_incorrect/n_aligned,
	1.0*incorrect_difference/n_aligned,
	x
	]]))