#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);
const int buffer_size = BUFFER_SIZE;
using namespace std;

void test_case(string inputfile);
void join1(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);

int main(int argc, char** argv){

    string inputfile1 = argv[0];
    string inputfile2 = argv[1];
    string outputfile = argv[2];
    
    FileManager fm;
    
    FileHandler fh1 = fm.OpenFile(inputfile1);
    FileHandler fh2 = fm.OpenFile(inputfile2);
    FileHandler fh3 = fm.CreateFile(outputfile);
    PageHandler ph3 = fh3.NewPage();

    join1(fh1,fh2,fh3);
    
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    fm.CloseFile(fh3);

    return 0;
}

void test_case(string inputfile){
    
    string input_cases = inputfile + ".txt";
    ifstream readfile(input_cases);

    FileManager fm;
    FileHandler fh = fm.CreateFile(inputfile);
    PageHandler ph = fh.NewPage();
    int* data = (int*)ph.GetData;
    int pagenumber = ph.GetPageNum;

    int count = 0;
    while(getline(readfile, text)){
        if(count<entries){
            data[count] = stoi(text);
            count+=1;
        }
        else{
            fh.MarkDirty(pagenumber);
            fh.UnpinPage(pagenumber);
            ph = fh.NewPage();
            data = ph.GetData();
            pagenumber+=1;
            data[0] = stoi(text);
            count=1;
        }
    }
    readfile.close();
    while(count<entries){
        data[count]=INT_MIN;
        count+=1;
    }
    fh.MarkDirty(pagenumber);
    fh.UnpinPage(pagenumber);
    fh.FlushPages();
    fm.CloseFile(fh);
    return;
}

void join1(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3){
    PageHandler ph1;
    PageHandler ph2;
    PageHandler ph3=fh3.FirstPage();

    int firstpage1=fh1.FirstPage().GetPageNum();
    int lastpage1=fh1.LastPage().GetPageNum();
    fh1.FlushPages();
    int* data1;

    int firstpage2=fh2.FirstPage().GetPageNum();
    int lastpage2=fh2.LastPage().GetPageNum();
    fh2.FlushPages();
    int* data2;

    int start_appending = 0;
    int out_pagenum = ph3.GetPageNum();
    int* data3 = (int*)ph3.GetData();

    for(int i=firstpage1;i<lastpage1;i++){
        fh1.FlushPages();
        ph1=fh1.PageAt(i);
        data1 = (int*)ph1.GetData();
        for(int j=firstpage2;j<lastpage2;j++){
            if(j % (buffer_size-2)==0){
                fh2.FlushPages();
            }
            ph2=fh2.PageAt(j);
            data2 = (int*)ph2.GetData();
            for(int k=0;k<entries;k++){
                for(int l=0;l<entries;l++){
                    if(data1[k]=data2[l] && data1[k]!=INT_MIN &&data2[l]!=INT_MIN){
                        write(ph3,fh3,&start_appending,data1[i],out_pagenum,data3);
                    }
                }
            }
        }
    }
    for(int i=start_appending;i<entries;i++){
        data3[i]=INT_MIN;
    }
    fh3.MarkDirty(out_pagenum);
    fh3.UnpinPage(out_pagenum);
    
    fh1.FlushPages();
    fh2.FlushPages();
    fh3.FlushPages();
    return;
}

void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data){
    if (*append == entries){
        fh.MarkDirty(*pagenum);
        fh.UnpinPage(*pagenum);
        fh.FlushPage(*pagenum);
        ph=fh.NewPage();
        *pagenum = *pagenum + 1;
        data = (int*)ph.GetData();
        data[0] = value;
    }
    else{
        data[*append]= value;
    }
    *append = *append + 1;
    return;
}