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
int binary_search_page(FileHandler &fh1, int num);
void join2(FileHandler &fh1, FileHandler &fh2, FileHandler &fh3);
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

    print_file(fh1,51);
    print_file(fh2,52);
    join2(fh1,fh2,fh3);
    print_file(fh3,53);

    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    fm.CloseFile(fh3);

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
            q=binary_search_page(fh2,data1[j]);
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