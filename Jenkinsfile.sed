s/\['high','medium','low']/'high'/

s/HIGH_MAINTAINER/anne.pacalet/
s/HIGH_MEM/700M/
s/HIGH_TIMEOUT/6m/

/\(MEDIUM\|LOW\)_MAINTAINER/d
/MEDIUM_TIMEOUT/d
/LOW_TIMEOUT/d
