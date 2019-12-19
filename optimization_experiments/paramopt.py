
# Usage: python paramopt.py aln.sam 

# read names are formatted as [readname]_[default Bowtie2 AS]_[Vargas optimal AS]

import pysam
import sys

samfile = pysam.AlignmentFile(sys.argv[1],'rb')

n = 0

# Just look at the new score
n_aligned = 0
n_incorrect = 0
incorrect_difference = 0.0

# Take consensus of default and new score
con_n_aligned = 0
con_n_incorrect = 0
con_incorrect_difference = 0.0

for read in samfile.fetch(until_eof=True):
	n += 1
	name = read.query_name
	
	optscore = int(name.split("_")[2])
	
	try: newscore = read.get_tag("AS")
	except: newscore = "*"

	if newscore != "*":
		n_aligned += 1
		if newscore != optscore:
			n_incorrect += 1
			incorrect_difference += (optscore-newscore)

	defaultscore = name.split("_")[1]
	if defaultscore != "*" : defaultscore = int(defaultscore) #might be "*" if unaligned
	
	bestscore = "*"
	if defaultscore == "*" and newscore != "*" : bestscore = newscore
	elif defaultscore != "*" and newscore == "*" : bestscore = defaultscore
	elif defaultscore != "*" and newscore != "*" : bestscore = max(defaultscore,newscore)

	if bestscore != "*":
		con_n_aligned += 1
		if bestscore != optscore:
			con_n_incorrect += 1
			con_incorrect_difference += (optscore-bestscore)




# number incorrect / total
# number aligned / total
# number incorrect / number aligned
# of aligned reads, average distance between optimal and alignment score
# of incorrect reads, average distance between optimal and alignment score

print("\t".join([str(x) for x in [
	1.0*n_incorrect/n,
	1.0*n_aligned/n,
	1.0*n_incorrect/n_aligned,
	1.0*incorrect_difference/n_aligned,
	1.0*incorrect_difference/n_incorrect,

	1.0*con_n_incorrect/n,
	1.0*con_n_aligned/n,
	1.0*con_n_incorrect/con_n_aligned,
	1.0*con_incorrect_difference/con_n_aligned,
	1.0*con_incorrect_difference/con_n_incorrect
	]]))