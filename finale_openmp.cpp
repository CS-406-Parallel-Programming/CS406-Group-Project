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

void printArray(int *arr, int nov){
    for (int j=0;j<nov;j++)
    {
        cout << j << " " << arr[j] << endl;
    }
}

void DFS_sparse(int xadj[], int adj[], bool marked[], int n,
         int vert, int start, int &count) //vert: bulundugu konum //start: baslangıc noktası
{
    marked[vert] = true;
    int start_index = xadj[vert];
    int path_length = xadj[vert+1];  
    if (n == 0){
        marked[vert] = false;
        for(int i = start_index; i < path_length; i++){
            if(adj[i] == start){
                count++;
                break;
            }
        }
        return;
    }
    for(int i=start_index; i < path_length; i++){
        if(!marked[adj[i]]){
            DFS_sparse(xadj, adj, marked, n-1, adj[i], start, count);
        }      
    }
    marked[vert] = false;
}

void countCycles_sparse(int *xadj, int *adj, int n,  int nov) 
{
    double start, end;
    start = omp_get_wtime();
    int *arr = new int[nov];

    #pragma omp parallel num_threads(16)
    { 
        bool *marked = new bool[nov];
        memset(marked, false, nov * sizeof(bool)); // bu belki silinebilir

        #pragma omp for schedule(guided)
        for(int i = 0; i < nov; i++){
            int localcount = 0;
            DFS_sparse(xadj, adj, marked, n - 1, i, i, localcount);
            arr[i] = localcount;
        }
    }
    end = omp_get_wtime();
    printArray(arr, nov);
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

  /*double end2 = omp_get_wtime();
  cout << end2-start << " -- TOTAL SURE (s).\n";*/
}

int main(int argc, char *argv[]){
    char* fname = argv[1];
    int k = atoi(argv[2]);
    read_mtxbin(fname,k);
    return 0;
}