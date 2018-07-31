#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Usage: $0 fichier.cpp"
  exit 1
fi
exe=`expr $1 : '\(.*\)\..*'`
\g++ -O -ansi -Wall -std=c++11 $1 -I/usr/local/include/soci -I/usr/include/oracle/12.1/client64 -L/usr/local/lib64 -L/u01/app/oracle/product/11.2.0/xe/lib -lclntsh -locci -lnnz11 -lsoci_core -lsoci_oracle -o ${exe}
