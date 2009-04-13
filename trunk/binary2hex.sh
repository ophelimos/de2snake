#!/bin/sh 
# Transforms a binary file into a string of comma-separated
# 32-bit hexadecimal values appropriate for dumping into memory

hexdump -C -v $1 | awk '{printf("0x%s%s%s%s, 0x%s%s%s%s, 0x%s%s%s%s, 0x%s%s%s%s,\n", $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17);}'

exit 0
