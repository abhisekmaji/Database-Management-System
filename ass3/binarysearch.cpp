#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

//void test_case(string inputfile);
void search(FileHandler &fh1, int num, FileHandler &fh2);
int binary_search_page(FileHandler &fh1, int num);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);
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
    string words;
    ifstream qfile(query);
    while (getline(qfile, text)){
        istringstream ss(text);
        ss >> words;
        ss >> words;
        search(fh1,stoi(words),fh2);
    }
    qfile.close();
    print_file(fh1,3);
    print_file(fh2,4);
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    return 0;
}

void search(FileHandler &fh1, int num, FileHandler &fh2){
    PageHandler ph1;
    int* data;
    ph1 = fh1.LastPage();
    int lastpage = ph1.GetPageNum();
    fh1.UnpinPage(lastpage);
    fh1.FlushPage(lastpage);

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
    
    int mid;
    bool present=true;
    int curr = binary_search_page(fh1,num);
    cout<<curr<<endl;
    
    if(curr!=-1){
        while(present && curr<=lastpage){
            ph1=fh1.PageAt(curr);
            data = (int*)ph1.GetData();

            for(int i=0;i<entries;i++){
                if(num==data[i]){
                    write(ph2,fh2,&start_appending,curr,&out_pagenumber,out_data);
                    write(ph2,fh2,&start_appending,i,&out_pagenumber,out_data);
                    present=true;
                }
                else{
                    present=false;
                }
            }
            fh1.UnpinPage(curr);
            fh1.FlushPage(curr);
            curr+=1;
        }
    }
    
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);
    write(ph2,fh2,&start_appending,-1,&out_pagenumber,out_data);   
    for(int i=start_appending; i<entries; i++){
        out_data[i] = INT_MIN;
    }
    fh2.MarkDirty(out_pagenumber);
    fh2.UnpinPage(out_pagenumber);
    fh2.FlushPage(out_pagenumber);
    fh1.FlushPages();
    return;
}

int binary_search_page(FileHandler &fh1, int num){
    PageHandler ph1;
    int* data;
    int firstpage = 0;
    ph1 = fh1.LastPage();
    int lastpage = ph1.GetPageNum();
    fh1.UnpinPage(lastpage);
    fh1.FlushPage(lastpage);
    
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