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

// CPP Program to count cycles of length n
// in a given graph.
//#include <bits/stdc++.h>
using namespace std;

void DFS_sparse(int xadj[], int adj[], bool marked[], int n,
         int vert, int start, int &count) //vert: bulundugu konum //start: baslangıc noktası
{
    // mark the vertex vert as visited
    marked[vert] = true;

    int start_index = xadj[vert];
    int path_length = xadj[vert+1] - start_index;
    
    if (n == 0){
        // mark vert as un-visited to make
        // it usable again.
        marked[vert] = false;
        // Check if vertex vert can end with
        // vertex start       
        for(int i=0; i < path_length; i++){
            if(adj[i+start_index] == start){
                count++;
                break;
            }
        }
        return;
    }

    for(int i=0; i < path_length; i++){
        if(!marked[adj[i+start_index]])
        {
            DFS_sparse(xadj, adj, marked, n-1, adj[i+start_index], start, count);
        }      
    }
    marked[vert] = false;
}
// Counts cycles of length N in an undirected
// and connected graph.
int countCycles_sparse(int *xadj, int *adj,int n,  int nov ) //(bool graph[][V], int n)
{
    //cout << "7"<<"\n";
    double start, end;
    start = omp_get_wtime();
    int totalCount = 0;
#pragma omp parallel num_threads(32)
{
    bool *marked = new bool[nov];
    memset(marked, false, nov * sizeof(bool));
    int threadId = omp_get_thread_num();

    #pragma omp for
    for(int i = 0; i < nov; i++){
        int localcount = 0;
        DFS_sparse(xadj, adj, marked, n - 1, i, i, localcount);
        #pragma omp critical
            cout<<"i:-- "<<i<<" local count:--"<<localcount<<endl;
    }
}
    end = omp_get_wtime();
    printf("Took %f secs \n", end - start);
    return totalCount / 2;
}

void  read_mtxbin(string fname, int k){

  double start = omp_get_wtime();
  cout << "fname: " << fname << endl;
  // const char* fname = bin_name.c_str();
  ifstream infile(fname);
  int a, b;
  int counter =0;
  int nnv = 0;
  unordered_map<int, vector<int> > hashmap;

  int  maxElement  = -1;

  while (infile >> a >> b)
  {
      nnv+=2;
      hashmap[a].push_back(b);
      hashmap[b].push_back(a);

      if(b > maxElement){
        maxElement = b;
      }

   }
  //
  // std::vector<int> keys;
  // keys.reserve (hashmap.size());
  // for (auto& it : hashmap) {
  //   keys.push_back(it.first);
  // }
  // std::sort (keys.begin(), keys.end());



  int nov =maxElement +1;
   // int nov =keys[keys.size() -1 ] +1;

  cout <<"nov " << nov << endl;
  cout <<"nnv " << nnv << endl;


  int * adj  = new int[nnv];
  int * xadj = new int[nov+1];
  xadj[0]=0;


  // int i = 1;
  // int j = 0;
  // for(auto& it : keys){
  //
  //
  //   vector<int> currentList = hashmap[it];
  //   int size = currentList.size();
  //
  //   while (i-1 != it){
  //
  //     xadj[i] = xadj[i-1];
  //     i++;
  //   }
  //
  //
  //   xadj[i] =  xadj[i-1] +size;
  //
  //   for(auto val : currentList) {
  //         adj[j] = val;
  //         j++;
  //   }
  //   i++;
  //
  // }



  int j = 0;
  for(int i=0; i < nov ; i++ ){

    auto current = hashmap.find(i);
    if (current == hashmap.end()){
      xadj[i+1] =xadj[i];
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
    cout<<"READYYYYY: --> "<<endl;

  cout<<"CYCLES: --> "<<countCycles_sparse(xadj, adj,k,nov)<<endl;

  double end = omp_get_wtime();
  //cout << end-start << " -- execution time (s).\n";
}
int main(int argc, char *argv[])
{
    char* fname = argv[1];
    int k = atoi(argv[2]);
    read_mtxbin(fname,k);
    return 0;
}