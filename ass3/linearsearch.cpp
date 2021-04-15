#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

void test_case(char* inputfile);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
void linearsearch(FileHandler &fh1, int num, FileHandler &fh2);
void print_file(FileHandler &fh, int num);


int main(int argc, char** argv){

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
    print_file(fh1,1);
    print_file(fh2,2);
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
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
            cout<<"---Page---"<<curr<<endl;
            myfile2<<"---Page---"<<curr<<endl;
            for(int i = 0; i<entries;i++){
                cout<<data[i]<<endl;
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