linearobjects = buffer_manager.o file_manager.o linearsearch.o
binaryobjects = buffer_manager.o file_manager.o binarysearch.o
deleteobjects = buffer_manager.o file_manager.o delete.o
join1objects = buffer_manager.o file_manager.o join1.o
join2objects = buffer_manager.o file_manager.o join2.o

all: linearsearch binarysearch delete join1 join2

linearsearch : $(linearobjects)
	     g++ -std=c++11 -o linearsearch $(linearobjects)

linearsearch.o : linearsearch.cpp
	g++ -std=c++11 -c linearsearch.cpp

binarysearch : $(binaryobjects)
	     g++ -std=c++11 -o binarysearch $(binaryobjects)

binarysearch.o : binarysearch.cpp
	g++ -std=c++11 -c binarysearch.cpp

delete : $(deleteobjects)
	     g++ -std=c++11 -o delete $(deleteobjects)

delete.o : delete.cpp
	g++ -std=c++11 -c delete.cpp

join1 : $(join1objects)
	     g++ -std=c++11 -o join1 $(join1objects)

join1.o : join1.cpp
	g++ -std=c++11 -c join1.cpp

join2 : $(join2objects)
	     g++ -std=c++11 -o join2 $(join2objects)

join2.o : join2.cpp
	g++ -std=c++11 -c join2.cpp

buffer_manager.o : buffer_manager.cpp
	g++ -std=c++11 -c buffer_manager.cpp

file_manager.o : file_manager.cpp
	g++ -std=c++11 -c file_manager.cpp

clean :
	rm -f *.o
	rm -f linearsearch || true
	rm -f binarysearch || true
	rm -f delete || true
	rm -f join1 || true
	rm -f join2 || true
