#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

void test_case(string inputfile);
void binarysearch(FileHandler &fh1, int num, FileHandler &fh2);
void search(FileHandler &fh1, int num, FileHandler &fh2);
int binary_search_page(FileHandler &fh1, int num);
void write(PageHandler &ph, FileHandler &fh, int *append, int value,int *pagenum,int* data);

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
    string text;
    ifstream qfile(query);
    while (getline(qfile, text)){
        search(fh1,stoi(text),fh2);
    }
    qfile.close();
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

// void binarysearch(FileHandler &fh1, int num, FileHandler &fh2){
//     PageHandler ph1;
//     int* data;
//     int firstpage = fh1.FirstPage().GetPageNum();
//     int lastpage = fh1.LastPage().GetPageNum();

//     PageHandler ph2 = fh2.LastPage(); 
//     int* out_data = (int*)ph2.GetData();
//     int out_pagenumber;
//     int start_appending = entries;
//     for(int i=0;i<entries;i++){
//         if(out_data[i]==INT_MIN){
//             start_appending = i;
//             break;
//         }
//     }
    
//     int mid;
//     bool found=false;

//     while(firstpage<=lastpage){
//         mid=(firstpage+lastpage)/2;
//         ph1=fh1.PageAt(mid);
//         data=(int*)ph1.GetData();
//         for(int i=0;i<entries;i++){
//             if(num==data[i]){
//                 found=true;
                
//                 if(start_appending==entries){
//                     fh2.MarkDirty(out_pagenumber);
//                     fh2.UnpinPage(out_pagenumber);
//                     ph2 = fh2.NewPage();
//                     out_pagenumber = ph2.GetPageNum();
//                     out_data = (int*)ph2.GetData;
//                     out_data[0]=curr;
//                     out_data[1]=i;
//                     start_appending = 2;
//                 }
//                 else{
//                     out_data[start_appending] = curr;
//                     out_data[start_appending+1] = i;
//                     start_appending+=2;
//                 }
//             }
//         }
//         fh1.UnpinPage(mid);
//         if(found){
//             fh1.FlushPage(mid);
//             break;
//         }
//         else{
//             if(num<data[0]){
//                 lastpage=mid-1;
//             }
//             else{
//                 firstpage=mid+1;
//             }
//         }
//         fh1.FlushPage(mid);
//     }
//     out_data[start_appending]=-1;
//     out_data[start_appending+1]=-1;
//     start_appending+=2;    
//     for(int i=start_appending; i<entries; i++){
//         out_data[i] = INT_MIN;
//     }
//     fh2.MarkDirty(out_pagenumber);
//     fh2.UnpinPage(out_pagenumber);
//     fh2.FlushPage(out_pagenumber);
//     fh1.FlushPages();
//     return;
// }

void search(FileHandler &fh1, int num, FileHandler &fh2){
    PageHandler ph1;
    int* data;
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
    
    int mid;
    bool present=true;
    int curr = binary_search_page(fh1,num);
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