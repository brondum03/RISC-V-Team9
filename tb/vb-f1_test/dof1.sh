#!/bin/sh

rm -rf obj_dir
rm -f waveform.vcd
rm -f program.hex

../assemble.sh ../asm/f1_fsm.s

cp ../program.hex .


verilator -Wall --cc --trace \
    ../../rtl/top.sv \
    -I../../rtl \
    --exe f1_fsm_tb.cpp \
    --prefix Vdut \
    -o Vdut

make -j -C obj_dir/ -f Vdut.mk

obj_dir/Vdut
