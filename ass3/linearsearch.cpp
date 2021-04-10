#include<iostream>
#include"file_manager.h"
#include"errors.h"
#include"constants.h"
#include<cstring>
#include<fstream>

const int entries = PAGE_CONTENT_SIZE/sizeof(int);

using namespace std;

void linearsearch(FileHandler &fh1, int num, FileHandler &fh2){
    //int entries = PAGE_CONTENT_SIZE/sizeof(int);
    PageHandler ph1 = fh1.FirstPage();
    int* data = (int*)ph1.GetData();
    int curr = ph1.GetPageNum();
    int lastpage = fh1.LastPage().GetPageNum();

    PageHandler ph2 = fh2.LastPage(); 
    int* out_data = (int*)ph2.GetData();
    int out_pagenumber;
    int start_appending = 0;
    for(int i=0;i<entries;i++){
        if(out_data[i]==INT_MIN){
            start_appending = i;
            break;
        }
    }
    while(curr<=lastpage){
        for(int i=0;i<entries;i++){
            if(num==data[i]){
                out_data[start_appending] = curr;
                out_data[start_appending+1] = i;
                start_appending+=2;
                if(start_appending==entries){
                    fh2.MarkDirty();
                    fh2.UnpinPage();
                    ph2 = fh2.NewPage();
                    out_pagenumber = ph2.GetPageNum();
                    out_data = (int*)ph2.GetData;
                    start_appending = 0;
                }
            }
        }
        fh1.UnpinPage();
        if(curr<lastpage){
            ph1 = fh1.NextPage(curr);
            curr = ph1.GetPageNum;
            data = ph1.GetData();
        }
        curr+=1;
    }
    out_data[start_appending]=-1;
    out_data[start_appending+1]=-1;
    start_appending+=2;    
    for(int i=start_appending; i<entries; i++){
        out_data[i] = INT_MIN;
    }
    return;
}

int main(int argc, char** argv){
    string inputfile = argv[0];
    string query = (string)argv[1]+".txt";
    string outputfile = argv[2];
    FileManager fm;
    FileHandler fh1 = fm.OpenFile(inputfile);
    FileHandler fh2 = fm.CreateFile(outputfile);
    PageHandler ph2 = fh2.NewPage();
    int* data = ph2.GetData();
    for(int i=0;i<entries;i++){
        data[i]=INT_MIN;
    }
    ifstream qfile1(filename1);
    while (getline(qfile1, text)){
        linearsearch(fh1,stoi(text),fh2);
    }
    qfile.close();
    fm.CloseFile(fh1);
    fm.CloseFile(fh2);
    return 0;
}
