#!/bin/bash
#run the application

make clean
make binarysearch
rm -f output_search1 || true
./binarysearch sorted_input query_search.txt output_search1

