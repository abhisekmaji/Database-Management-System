#include <bits/stdc++.h>
#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

int binary_search_page(FileHandler &fh1, int num);
void deletion(FileHandler &fh1, int num);
int next(int *page_num, int *offset, FileHandler &fh, PageHandler &ph, int num, int* data, int lastpage);
void write(PageHandler &ph, FileHandler &fh, int *append, int value, int *pagenum, int* data);
void print_file(FileHandler &fh, int num);

int main(int argc, char** argv){
    char* inputfile = argv[1];
    char* query = argv[2];
    FileManager fm;
    FileHandler fh1 = fm.OpenFile(inputfile);
    
    print_file(fh1,31);
    string text;
    string words;
    ifstream qfile(query);
    while (getline(qfile, text)){
        istringstream ss(text);
        ss >> words;
        ss >> words;
        deletion(fh1,stoi(words));
    }    
    qfile.close();
    print_file(fh1,32);
    fm.CloseFile(fh1);
    return 0;
}

void deletion(FileHandler &fh1, int num){
    FileHandler fh2 = fh1;
    PageHandler ph1;
    PageHandler ph2;
    int* data1;
    int* data2;
    ph1 = fh1.LastPage();
    int lastpage = ph1.GetPageNum();
    fh1.UnpinPage(lastpage);
    fh1.FlushPage(lastpage);

    int page_p = binary_search_page(fh1,num);
    cout<<"------------at page-------------"<<page_p<<endl;
    if(page_p==-1){
        return;
    }
    int offset_p;
    int page_q = page_p;
    int offset_q;    
    
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
    int choice = next(&page_q,&offset_q,fh2,ph2,num,data2,lastpage);
    cout<<page_p<<"\t"<<offset_p<<"\t"<<page_q<<"\t"<<offset_q<<endl;

    if(choice==0){
        while(page_q<=lastpage){
            data1[offset_p]=data2[offset_q];
            if(offset_p==entries-1){
                if(page_p<lastpage){
                    fh1.MarkDirty(page_p);
                    fh1.UnpinPage(page_p);
                    fh1.FlushPage(page_p);
                    ph1==fh1.NextPage(page_p);
                    data1=(int*)ph1.GetData();
                    offset_p=0;
                }
                page_p++;
            }
            else{offset_p++;}
            if(offset_q==entries-1){
                if(page_q<lastpage){
                    fh2.UnpinPage(page_q);
                    fh2.FlushPage(page_q);
                    ph2=fh2.NextPage(page_q);        // X check the lastpage condition pagehandler for nextpage
                    data2=(int*)ph2.GetData();
                    offset_q=0;
                }
                page_q++;
            }
            else{offset_q++;}
        }
    }
    fh2.FlushPages();
    
    for(int i=offset_p;i<entries;i++){
        data1[i]=INT_MIN;
    }
    if(page_p<lastpage){
        fh1.MarkDirty(page_p);
        fh1.UnpinPage(page_p);
        fh1.FlushPage(page_p);
        ph1=fh1.NextPage(page_p);
    }
    page_p++;
    while(page_p<=lastpage){
        fh1.DisposePage(page_p);
        page_p++;
    }
    return;    
}

int next(int *page_num, int *offset, FileHandler &fh, PageHandler &ph, int num, int* data, int lastpage){
    while(data[*offset]==num && *page_num<=lastpage){
        if(*offset==entries-1){
            if(*page_num==lastpage){
                return -1;
            }
            else{            
                fh.UnpinPage(*page_num);
                fh.FlushPage(*page_num);
                ph=fh.NextPage(*page_num);
                *page_num = *page_num + 1;
                *offset=0;
                data = (int*)ph.GetData();
            }
        }
        else{
            *offset = *offset + 1;
        }
    }
    return 0;
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