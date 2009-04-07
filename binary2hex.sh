#!/bin/sh
# Transforms a binary file into a string of comma-separated hexadecimal values
# appropriate for dumping into memory

hexdump -v $1 | awk '{for(i=2; i<=9; i=i+1) printf(0x%s,,); printf(n);}'

exit 0
