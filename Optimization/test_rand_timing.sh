#!/bin/bash/

# script to create stimulus timing. 
cd /home/despo/kaihwang/bin/TDSigEI-Paradigm/Optimization

optseq2 \
--ntp 165 \
--tr 1 \
--psdwin 0 16 0.2 \
--ev Target 0.5 30 \
--polyfit 2 \
--tnullmin 0.5 \
--tsearch 48 \
--sumdelays \
--nkeep 2000 \
--o seqtest \
--sum sum.txt

# to create 3 col FSL stim file
# more seqtest-002.par | grep Target | awk {'print $1 " " $3 " " $2'} > stim2.text

# 3dDeconvolve -nodata 180 1 -polort A -num_stimts 2 -stim_times 1 tt1 'SPMG1' -stim_label 1 Rel -stim_times 2 tt2 'SPMG1' -stim_label 2 IRR