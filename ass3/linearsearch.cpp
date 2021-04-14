#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;
void test_case(string inputfile);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
void linearsearch(FileHandler &fh1, int num, FileHandler &fh2);


int main(int argc, char** argv){
    string inputfile = argv[0];
    string query = argv[1];
    query+=".txt";
    string outputfile = argv[2];
    FileManager fm;
    FileHandler fh1 = fm.OpenFile(inputfile);
    FileHandler fh2 = fm.CreateFile(outputfile);
    PageHandler ph2 = fh2.NewPage();
    int* data = ph2.GetData();
    for(int i=0;i<entries;i++){
        data[i]=INT_MIN;
    }
    ifstream qfile1(query);
    while (getline(qfile1, text)){
        linearsearch(fh1,stoi(text),fh2);
    }
    qfile.close();
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
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

void linearsearch(FileHandler &fh1, int num, FileHandler &fh2){
    PageHandler ph1 = fh1.FirstPage();
    int* data = (int*)ph1.GetData();
    int curr = ph1.GetPageNum();
    int lastpage = fh1.LastPage().GetPageNum();

    PageHandler ph2 = fh2.LastPage(); 
    int* out_data = (int*)ph2.GetData();
    int out_pagenumber;
    int start_appending = entries;
    for(int i=0;i<entries;i++){
        if(out_data[i]==INT_MIN){
            start_appending = i;
            break;
        }
    }
    while(curr<=lastpage){
        for(int i=0;i<entries;i++){
            if(num==data[i]){
                write(ph2,fh2,&start_appending,curr,&out_pagenumber,out_data);
                write(ph2,fh2,&start_appending,i,&out_pagenumber,out_data);
            }
        }
        fh1.UnpinPage(curr);
        if(curr<lastpage){
            ph1 = fh1.NextPage(curr);
            curr = ph1.GetPageNum;
            data = ph1.GetData();
        }
        curr+=1;
    }
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);    
    for(int i=start_appending; i<entries; i++){
        out_data[i] = INT_MIN;
    }
    fh2.MarkDirty(out_pagenumber);
    fh2.UnpinPage(out_pagenumber);
    fh2.FlushPage(out_pagenumber);
    fh1.FlushPage(curr);
    return;
}

void write(PageHandler &ph, FileHandler &fh, int *append, int value, int *pagenum, int* data){
    if (*append == entries){
        fh.MarkDirty(*pagenum);
        fh.UnpinPage(*pagenum);
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