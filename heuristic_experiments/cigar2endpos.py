import sys
from itertools import groupby

# operations that consume the reference
_cigar_ref = set(('M', 'D', 'N', '=', 'X', 'EQ'))
# operations that consume the query
_cigar_query = set(('M', 'I', 'S', '=', 'X', 'EQ'))
# operations that do not represent an alignment
_cigar_no_align = set(('H', 'P'))
_valid_cigar = _cigar_ref | _cigar_query | _cigar_no_align
# operations that can be represented as aligned to the reference
_cigar_align = _cigar_ref & _cigar_query
# operations that only consume the reference
_cigar_ref_only = _cigar_ref - _cigar_align
# operations that only consume the query
_cigar_query_only = _cigar_query - _cigar_align

def cigar_split(C):
    # https://github.com/brentp/bwa-meth
    # https://github.com/mdshw5/simplesam/blob/master/simplesam.py
    if C == "*":
        yield (0, None)
        raise StopIteration
    cig_iter = groupby(C, lambda c: c.isdigit())
    for _, n in cig_iter:
        op = int("".join(n)), "".join(next(cig_iter)[1])
        if op[1] in _valid_cigar:
            yield op
        else:
            raise ValueError("CIGAR operation %s is invalid." % (op[1]))

posfieldnum = int(sys.argv[1])
cigarfieldnum = int(sys.argv[2])

for line in sys.stdin.readlines():
    fields = line.strip().split(",")
    pos = int(fields[posfieldnum]) - 1
    if fields[cigarfieldnum] == "*":
        print(line.strip() + ",-1")
    else:
        for (n,op) in cigar_split(fields[cigarfieldnum]):
            if op in _cigar_ref:
                pos += n
        print(line.strip() + "," + str(pos))
