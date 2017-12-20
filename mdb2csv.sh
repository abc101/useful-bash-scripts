#!/bin/bash
# Requirement: mdbtools
# ./mdb2csv.sh [file-name.mdb]

TABLES=$(mdb-tables -1 $1)

for t in $TABLES
do
  mdb-export $1 $t > $t.csv
done
