#!/bin/sh

# Checkout code before the inline assembly updates
git checkout 403042794068d29583e8b30e22bde94abaf27192
./configure --disable-ocamldoc --disable-debugger --disable-ocamltest --prefix=/riscv-ocaml \
	    --build=x86_64-pc-linux-gnu --host=i386-linux \
            CC='gcc -m32' AS='as --32' ASPP='gcc -m32 -c' \
            PARTIALLD='ld -r -melf_i386'
make -j8 world.opt && make install
export PATH="/riscv-ocaml/bin:${PATH}"
# Checkout the latest code with the inline assembly
git checkout rv32g
make clean
./configure --host=riscv32-unknown-linux-gnu --prefix=/riscv-ocaml \ 
	    --disable-ocamldoc --disable-debugger --disable-ocamltest \ 
	    --with-target-bindir=/riscv-ocaml/bin \
	    CC='riscv32-unknown-linux-gnu-gcc -g -march=rv32g -mabi=ilp32d' \ 
	    AS='riscv32-unknown-linux-gnu-as -g -march=rv32g' \ 
	    ASPP='riscv32-unknown-linux-gnu-gcc -g -march=rv32g -c' 
make -j8 world
make -j4 opt
cp /riscv-ocaml/bin/ocamlrun runtime 
make install
