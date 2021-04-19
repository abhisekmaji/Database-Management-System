#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);
const int buffer_size = BUFFER_SIZE;

using namespace std;


int binary_search_page(FileHandler &fh1, int num, int lastpage);
void join2(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
// void print_file(FileHandler &fh, int num);

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

    // print_file(fh1,1);
    // print_file(fh2,2);
    
    join2(fh1,fh2,fh3);
    
    // print_file(fh3,3);

    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    fm.CloseFile(fh3);

    return 0;
}

void join2(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3){
    PageHandler ph1;
    PageHandler ph2;
    PageHandler ph3;

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

    ph3 = fh3.FirstPage();
    int start_appending = 0;
    int out_pagenum = 0;
    int* data3 = (int*)ph3.GetData();

    int offset;
    int q;
    for(int i=firstpage1;i<=lastpage1;i++){
        ph1=fh1.PageAt(i);
        data1=(int*)ph1.GetData();
        for(int j=0;j<entries;j++){
            offset=0;
            q=binary_search_page(fh2,data1[j],lastpage2);
            if(q==-1){
                continue;
            }
            else{
                ph2=fh2.PageAt(q);
                data2=(int*)ph2.GetData();
                while(data2[offset]!=data1[j]){
                    offset++;
                }
                while(q<=lastpage2 && data2[offset]==data1[j]){
                    write(ph3,fh3,&start_appending,data1[j],&out_pagenum,data3);
                    if(offset==entries-1){
                        if(q<lastpage2){
                            fh2.UnpinPage(q);
                            fh2.FlushPage(q);
                            ph2=fh2.NextPage(q);
                            data2=(int*)ph2.GetData();
                            offset=0;
                        }
                        q++;
                    }
                    else{
                        offset++;
                    }
                }
                fh2.UnpinPage(q);
                fh2.FlushPage(q);
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

int binary_search_page(FileHandler &fh1, int num, int lastpage){
    PageHandler ph1;
    int* data;
    int firstpage = 0;
    
    int mid;

    while(firstpage<=lastpage){
        mid=(firstpage+lastpage)/2;
        ph1=fh1.PageAt(mid);
        data=(int*)ph1.GetData();

        bool present=false;
        for(int i=0;i<entries;i++){
            if(data[i]==num){
                present=true;
                break;
            }
        }
        if(present){
            if(data[0]==num){
                if(lastpage==firstpage){
                    fh1.UnpinPage(mid);
                    fh1.FlushPage(mid);
                    return mid;
                }
                lastpage=mid;
            }
            else{
                fh1.UnpinPage(mid);
                fh1.FlushPage(mid);
                return mid;
            }            
        }
        else{
            if(num<data[0]){
                lastpage=mid-1;
            }
            else{
                firstpage=mid+1;
            }
        }
        fh1.UnpinPage(mid);
        fh1.FlushPage(mid);
    }
    fh1.FlushPages();
    return -1;
}