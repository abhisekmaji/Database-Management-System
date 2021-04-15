#!/bin/bash
#run the application

make clean
make linearsearch
rm -f output_search1 || true
./linearsearch sorted_input query_search.txt output_search1
