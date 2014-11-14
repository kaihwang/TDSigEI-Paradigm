#!/bin/bash/

# script to create stimulus timing. 

optseq2 \
--ntp 170 \
--tr 1 \
--psdwin 0 16 0.1 \
--ev Target 0.5 30 \
--polyfit 2 \
--tnullmin 0.5 \
--nsearch 1000 \
--sumdelays \
--nkeep 10 \
--o seqtest \
--sum sum.txt
