#!/bin/sh

rm -rf obj_dir
rm -f waveform.vcd
rm -f program.hex

../assemble.sh ../reference/pdf.s

cp ../program.hex .


verilator -Wall --cc --trace \
    ../../rtl/top.sv \
    -I../../rtl \
    --exe pdf_tb.cpp \
    --prefix Vdut \
    -o Vdut

make -j -C obj_dir/ -f Vdut.mk

obj_dir/Vdut