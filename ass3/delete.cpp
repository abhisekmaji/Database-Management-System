#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

void test_case(char* inputfile);
int binary_search_page(FileHandler &fh1, int num);
void deletion(FileHandler &fh1, int num);
void next(int *page_num, int *offset, FileHandler &fh, PageHandler &ph, int num, int* data);
void write(PageHandler &ph, FileHandler &fh, int *append, int value, int *pagenum, int* data);

int main(int argc, char** argv){
    char* inputfile = argv[1];
    char* query = argv[2];
    FileManager fm;
    FileHandler fh1 = fm.OpenFile(inputfile);
    
    string text;
    ifstream qfile(query);
    while (getline(qfile, text)){
        deletion(fh1,stoi(text));
    }
    qfile.close();
    fm.CloseFile(fh1);
    return 0;
}

void test_case(char* inputfile){
    string input_cases = inputfile;
    input_cases+=".txt";
    char* temp;
    strcpy(temp,input_cases.c_str());
    ifstream readfile(input_cases);

    FileManager fm;
    FileHandler fh = fm.CreateFile(inputfile);
    PageHandler ph = fh.NewPage();
    int* data = (int*)ph.GetData();
    int pagenumber = ph.GetPageNum();

    string text;
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
            data = (int*)ph.GetData();
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

void deletion(FileHandler &fh1, int num){
    FileHandler fh2 = fh1;
    PageHandler ph1;
    PageHandler ph2;
    int* data1;
    int* data2;
    int lastpage = fh1.LastPage().GetPageNum();

    int page_p = binary_search_page(fh1,num);
    int offset_p;
    int page_q= page_p;
    int offset_q;
    if(page_p==-1){
        return;
    }
    
    ph1 = fh1.PageAt(page_p);
    data1 = (int*)ph1.GetData();
    for(int i=0;i<entries;i++){
        if(num==data1[i]){
            offset_p=i;
            break;
        }
    }
    
    offset_q=offset_p;
    ph2 = fh2.PageAt(page_q);
    data2 = (int*)ph2.GetData();
    next(&page_q,&offset_q,fh2,ph2,num,data2);

    while(page_q<=lastpage){
        data1[offset_p]=data2[offset_q];
        if(offset_p==entries){
            fh1.MarkDirty(page_p);
            fh1.UnpinPage(page_p);
            fh1.NextPage(page_p);
            page_p+=1;
            offset_p=0;
        }
        else{
            offset_p+=1;
        }
        if(offset_q==entries){
            fh2.UnpinPage(page_q);
            fh2.NextPage(page_q);        // X check the lastpage condition pagehandler for nextpage
            page_q+=1;
            offset_q=0;
        }
        else{
            offset_q+=1;
        }
    }

    fh2.FlushPages();
    
    for(int i=offset_p;i<entries;i++){
        data1[i]=INT_MIN;
    }
    fh1.MarkDirty(page_p);
    fh1.UnpinPage(page_p);
    ph1=fh1.NextPage(page_p);
    page_p++;
    while(page_p<=lastpage){
        fh1.DisposePage(page_p);
        page_p++;
    }
    return;    
}

void next(int *page_num, int *offset, FileHandler &fh, PageHandler &ph, int num, int* data){
    while(data[*offset]==num){
        if(*offset==entries){            
            fh.UnpinPage(*page_num);
            ph=fh.NextPage(*page_num);
            *page_num = *page_num + 1;
            *offset=0;
            data = (int*)ph.GetData();
        }
        else{
            *offset = *offset +1;
        }
    }
    return;
}

int binary_search_page(FileHandler &fh1, int num){
    PageHandler ph1;
    int* data;
    int firstpage = fh1.FirstPage().GetPageNum();
    int lastpage = fh1.LastPage().GetPageNum();
    
    int mid;

    while(firstpage<=lastpage){
        mid=(firstpage+lastpage)/2;
        ph1=fh1.PageAt(mid);
        data=(int*)ph1.GetData();

        bool present=false;
        for(int i=0;i<entries;i++){
            if(data[0]==num){
                present=true;
                break;
            }
        }
        if(num<=data[0]){
            if(firstpage==lastpage){
                fh1.UnpinPage(mid);
                return mid;
            }
            lastpage=mid;
        }
        else if(present){
            fh1.UnpinPage(mid);
            return mid;
        }
        else{
            firstpage=mid+1;
        }
        fh1.UnpinPage(mid);
        fh1.FlushPage(mid);
    }
    fh1.FlushPages();
    return -1;
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