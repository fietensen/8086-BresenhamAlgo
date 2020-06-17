#!/bin/sh

nasm -f bin src/main.asm -o out
qemu-system-i386 -drive format=raw,file=out
