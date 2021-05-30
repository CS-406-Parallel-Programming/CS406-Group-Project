//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <omp.h>
#include <algorithm>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>
#include <sstream>
#include <unordered_map>

using namespace std;

int flag;
int numThreads;

void printArray(int *arr, int nov){
    for (int j=0;j<nov;j++)
    {
        cout << j << " " << arr[j] << endl;
    }
}

int sparse3(int xadj[], int adj[], int index) //vert: bulundugu konum //start: baslangıc noktası
{
    int localcount = 0;
    int s0 = xadj[index];
    int e0 = xadj[index+1];
    for(int i=s0; i < e0; i++){
    // 0 --> 1
        int neighbour_1 = adj[i];
        int s1  = xadj[neighbour_1];
        int e1  = xadj[neighbour_1+1];

        for(int j=s1;j < e1; j++){
            // 0 --> 1 --> 2
            int neighbour_2 =  adj[j];
            if (neighbour_2 == index) continue;
            int s2  = xadj[neighbour_2];
            int e2  = xadj[neighbour_2+1];

            for(int k=s2; k < e2; k++){
                // 0 --> 1 --> 2 --> 3
                int neighbour_3 =  adj[k];
                if (neighbour_3 == index){
                    localcount+=1;
                    break;
                }
            }
        }
    }
    return localcount;
}

int sparse4(int xadj[], int adj[], int index) //vert: bulundugu konum //start: baslangıc noktası
{
    int localcount = 0;

      int s0 = xadj[index];
      int e0 = xadj[index+1];
      for(int i=s0; i < e0; i++){
        int neighbour_1 = adj[i];
        int s1  = xadj[neighbour_1];
        int e1  = xadj[neighbour_1+1];
        for(int j=s1;j < e1; j++){
          int neighbour_2 =  adj[j];
          if (neighbour_2 == index) continue;
          int s2  = xadj[neighbour_2];
          int e2  = xadj[neighbour_2+1];
          for(int k=s2; k < e2; k++){
            // 0 --> 1 --> 2 --> 3
            int neighbour_3 =  adj[k];
            if (neighbour_3 == index) continue;
            if (neighbour_3 == neighbour_1) continue;
            int s3  = xadj[neighbour_3];
            int e3  = xadj[neighbour_3+1];
            for(int n=s3; n < e3; n++){
              //0 -->1 -->2 -->3 -->4
              int neighbour_4 =  adj[n];
              if (neighbour_4 == index){
                localcount+=1;
                break;
              }
            }
          }
        }
      }
      return localcount;
}

int sparse5(int xadj[], int adj[], int index) //vert: bulundugu konum //start: baslangıc noktası
{
      int localcount = 0;
      int s0 = xadj[index];
      int e0 = xadj[index+1];

      for(int i=s0; i < e0; i++){
        int neighbour_1 = adj[i];
        int s1  = xadj[neighbour_1];
        int e1  = xadj[neighbour_1+1];
        for(int j=s1;j < e1; j++){
          int neighbour_2 =  adj[j];
          if (neighbour_2 == index) continue;
          int s2  = xadj[neighbour_2];
          int e2  = xadj[neighbour_2+1];
          for(int k=s2; k < e2; k++){
            int neighbour_3 =  adj[k];
            if (neighbour_3 == index) continue;
            if (neighbour_3 == neighbour_1) continue;
            int s3  = xadj[neighbour_3];
            int e3  = xadj[neighbour_3+1];
            for(int n=s3; n < e3; n++){
              //0 -->1 -->2 -->3 -->4
              int neighbour_4 =  adj[n];
              if (neighbour_4 == index) continue;
              if (neighbour_4 == neighbour_1) continue;
              if (neighbour_4 == neighbour_2) continue;
              int s4  = xadj[neighbour_4];
              int e4  = xadj[neighbour_4+1];
              for(int o=s4; o < e4; o++){
                int neighbour_5 =  adj[o];
                if (neighbour_5 == index){
                  localcount+=1;
                  break;
                }
              }
            }
          }
        }
      }
      return localcount;
}

void countCycles_sparse(int *xadj, int *adj, int n,  int nov)
{
    double start, end;
    start = omp_get_wtime();
    int *arr = new int[nov];

    #pragma omp parallel num_threads(numThreads)
    {
        if(n==3){
            #pragma omp for schedule(guided)
            for(int i = 0; i < nov; i++){
                arr[i] =sparse3(xadj, adj, i);
            }
        }
        else if(n==4){
            #pragma omp for schedule(guided)
            for(int i = 0; i < nov; i++){
                arr[i] = sparse4(xadj, adj, i);
            }
        }else if(n==5){
            #pragma omp for schedule(guided)
            for(int i = 0; i < nov; i++){
                arr[i] = sparse5(xadj, adj, i);
            }
        }
    }
    end = omp_get_wtime();

    if(flag == 0)	printArray(arr, nov);
    if(flag == 1)	cout << end-start << " -- TOTAL SURE (s).\n";
}

void  read_mtxbin(string fname, int k){
  //cout << "fname: " << fname << endl;
  ifstream infile(fname);
  int a, b;
  int counter =0;
  int nnv = 0;
  unordered_map<int, vector<int> > hashmap;

  int  maxElement  = -1;
  double start1 = omp_get_wtime();

  while (infile >> a >> b)
  {
      nnv+=2;
      hashmap[a].push_back(b);
      hashmap[b].push_back(a);

      if(b > maxElement){
        maxElement = b;
      }
  }
  double end1 = omp_get_wtime();
  //cout << end1-start1 << " -- ILK OKUMA SU (s).\n";

  int nov = maxElement +1;
  //cout <<"nov " << nov << endl;
  //cout <<"nnv " << nnv << endl;
  int * adj  = new int[nnv];
  int * xadj = new int[nov+1];
  xadj[0]=0;

  int j = 0;
  double start = omp_get_wtime();

  for(int i=0; i < nov ; i++ ){
    auto current = hashmap.find(i);
    if (current == hashmap.end()){
        xadj[i+1] = xadj[i];
    }
    else{
        int size = current->second.size();
        xadj[i+1] = xadj[i] + size;
        for(auto val : current->second) {
            adj[j] = val;
            j++;
        }
    }
  }
  double end = omp_get_wtime();
  //cout << end-start << " -- OKUMA SURE (s).\n";
    countCycles_sparse(xadj, adj,k,nov);
  //cout<<"CYCLES: --> "<<countCycles_sparse(xadj, adj,k,nov)<<endl;

  double end2 = omp_get_wtime();
  //cout << end2-start << " -- TOTAL SURE (s).\n";
}

int main(int argc, char *argv[]){
    char* fname = argv[1];
    int k = atoi(argv[2]); // cycle length
    numThreads = atoi(argv[3]); //number of threads
    flag = atoi(argv[4]); //print flag
    read_mtxbin(fname,k);
    return 0;
}
