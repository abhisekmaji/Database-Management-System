#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;


void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
void linearsearch(FileHandler &fh1, int num, FileHandler &fh2);
//void print_file(FileHandler &fh, int num);


int main(int argc, char** argv){


    //cout<<"-------BUFFER_SIZE------->>>"<<BUFFER_SIZE<<endl;
    char* inputfile = argv[1];
    char* query = argv[2];
    char* outputfile = argv[3];
    FileManager fm;
    FileHandler fh1 = fm.OpenFile(inputfile);
    FileHandler fh2 = fm.CreateFile(outputfile);
    PageHandler ph2 = fh2.NewPage();
    int* data = (int*)ph2.GetData();
    for(int i=0;i<entries;i++){
        data[i]=INT_MIN;
    }
    fh2.MarkDirty(0);
    fh2.UnpinPage(0);
    fh2.FlushPage(0);
    string text;
    string word;
    ifstream qfile(query);
    while (getline(qfile, text)){
        istringstream ss(text);
        ss >> word;
        ss >> word;
        linearsearch(fh1,stoi(word),fh2);
    }
    qfile.close();
    // print_file(fh1,1);
    // print_file(fh2,2);
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    return 0;
}



void linearsearch(FileHandler &fh1, int num, FileHandler &fh2){
    
    PageHandler ph1;
    ph1 = fh1.LastPage();
    int lastpage = ph1.GetPageNum();
    fh1.UnpinPage(lastpage);
    fh1.FlushPage(lastpage);

    int curr = 0;
    int* data;

    PageHandler ph2 = fh2.LastPage(); 
    int* out_data = (int*)ph2.GetData();
    int out_pagenumber = ph2.GetPageNum();
    int start_appending = entries;
    for(int i=0;i<entries;i++){
        if(out_data[i]==INT_MIN){
            start_appending = i;
            break;
        }
    }

    while(curr<=lastpage){
        ph1=fh1.PageAt(curr);
        data = (int*)ph1.GetData();

        for(int i=0;i<entries;i++){
            if(num==data[i]){
                write(ph2,fh2,&start_appending,curr,&out_pagenumber,out_data);
                write(ph2,fh2,&start_appending,i,&out_pagenumber,out_data);
            }
        }
        fh1.UnpinPage(curr);
        fh1.FlushPage(curr);
        curr++;
        
    }
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);    
    for(int i=start_appending; i<entries; i++){
        out_data[i] = INT_MIN;
    }
    fh2.MarkDirty(out_pagenumber);
    fh2.UnpinPage(out_pagenumber);
    fh2.FlushPage(out_pagenumber);
    return;
}

void write(PageHandler &ph, FileHandler &fh, int *append, int value, int *pagenum, int* data){
    if (*append == entries){
        fh.MarkDirty(*pagenum);
        fh.UnpinPage(*pagenum);
        fh.FlushPage(*pagenum);
        ph=fh.NewPage();
        *pagenum = *pagenum + 1;
        data = (int*)ph.GetData();
        data[0] = value;
        *append = 1;
    }
    else{
        data[*append]= value;
        *append = *append + 1;
    }    
    return;
}