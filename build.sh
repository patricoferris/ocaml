#!/bin/sh

# Checkout code before the inline assembly updates
git checkout 403042794068d29583e8b30e22bde94abaf27192
./configure --disable-ocamldoc --disable-debugger --disable-ocamltest --prefix=/riscv-ocaml
make -j8 world.opt && make install
export PATH="/riscv-ocaml/bin:${PATH}"
# Checkout the latest code with the inline assembly
git checkout 86e8e6bcca211c8618f032597ab28f0097167412 
make clean
./configure --host=riscv32-unknown-linux-gnu --prefix=/riscv-ocaml \ 
	    --disable-ocamldoc --disable-debugger --disable-ocamltest \ 
	    --with-target-bindir=/riscv-ocaml/bin \ 
	    AS='riscv32-unknown-linux-gnu-as -march=rv32g' \ 
	    ASPP='riscv32-unknown-linux-gnu-gcc -march=rv32g -c' 
make -j8 world
#make -j4 opt
#cp /riscv-ocaml/bin/ocamlrun runtime 
#make install
#make clean
