#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);
const int buffer_size = BUFFER_SIZE;
using namespace std;

void test_case(char* inputfile);
void join1(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
void print_file(FileHandler &fh, int num);

int main(int argc, char** argv){

    char* inputfile1 = argv[1];
    char* inputfile2 = argv[2];
    char* outputfile = argv[3];
    
    FileManager fm;
    
    FileHandler fh1 = fm.OpenFile(inputfile1);
    FileHandler fh2 = fm.OpenFile(inputfile2);
    FileHandler fh3 = fm.CreateFile(outputfile);
    PageHandler ph3 = fh3.NewPage();
    fh3.UnpinPage(0);
    fh3.FlushPage(0);

    print_file(fh1,41);
    print_file(fh2,42);
    join1(fh1,fh2,fh3);
    
    print_file(fh3,43);
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    fm.CloseFile(fh3);

    return 0;
}

void join1(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3){
    PageHandler ph1;
    PageHandler ph2;
    PageHandler ph3=fh3.FirstPage();

    int firstpage1=0;
    ph1=fh1.LastPage();
    int lastpage1=ph1.GetPageNum();
    fh1.FlushPages();
    int* data1;

    int firstpage2=0;
    ph2=fh2.LastPage();
    int lastpage2=ph2.GetPageNum();
    fh2.FlushPages();
    int* data2;

    int start_appending = 0;
    int out_pagenum = 0;
    int* data3 = (int*)ph3.GetData();

    for(int i=firstpage1;i<=lastpage1;i++){
        ph1=fh1.PageAt(i);
        data1 = (int*)ph1.GetData();
        for(int j=firstpage2;j<=lastpage2;j++){            
            ph2=fh2.PageAt(j);
            data2 = (int*)ph2.GetData();
            for(int k=0;k<entries;k++){
                for(int l=0;l<entries;l++){
                    if(data1[k]==data2[l] && data1[k]!=INT_MIN && data2[l]!=INT_MIN){
                        write(ph3,fh3,&start_appending,data1[k],&out_pagenum,data3);
                    }
                }
            }
            fh2.UnpinPage(j);
            if(j % (buffer_size-2)==0){
                fh2.FlushPages();
            }
        }
        fh1.UnpinPage(i);
        fh1.FlushPage(i);
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

void print_file(FileHandler &fh, int num){
    PageHandler ph;
    int* data;
    ph = fh.LastPage();
    int lastpage = ph.GetPageNum();
    fh.UnpinPage(lastpage);
    fh.FlushPage(lastpage);
    int curr = 0;

    string out_file = to_string(num);
    out_file = "./sample/out"+out_file+".txt";
    ofstream myfile2(out_file);
    if (myfile2.is_open())
    {
        while(curr<=lastpage){
            ph = fh.PageAt(curr);
            data = (int*)ph.GetData();
            //cout<<"---Page---"<<curr<<endl;
            myfile2<<"---Page---"<<curr<<endl;
            for(int i = 0; i<entries;i++){
                //cout<<data[i]<<endl;
                myfile2<<data[i]<<endl;
            }
            fh.UnpinPage(curr);
            fh.FlushPage(curr);
            curr++;
        }        
        myfile2.close();
    }    
    return;
}