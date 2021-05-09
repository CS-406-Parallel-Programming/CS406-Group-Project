//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>
#include <sstream>
#include <unordered_map>

using namespace std;
#define THREADS_PER_BLOCK 256

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
  if (code != cudaSuccess)
    {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
    }
}


void printArray(int *arr, int nov){
    for (int j=0;j<nov;j++)
    {
        cout << j << " " << arr[j] << endl;
    }
}
__device__ bool check(int marked[], int round, int val){
  for(int i = 0; i < round; i++){
    if(marked[i] == val){return false;}
  }
  return true;
}

__device__ void DFS_sparse(int xadj[], int adj[], int marked[], int n,
         int vert, int start, int &count, int round) //vert: bulundugu konum //start: baslangıc noktası
{
    marked[round] = vert;

    int start_index = xadj[vert];
    int path_length = xadj[vert+1];

    if (n == 0){
      marked[round] = -1;
        for(int i = start_index; i < path_length; i++){
            if(adj[i] == start){
                count++;
                break;
            }
        }
        return;
    }
    for(int i=start_index; i < path_length; i++){
        if(check(marked, round,adj[i])){
            DFS_sparse(xadj, adj, marked, n-1, adj[i], start, count, round + 1);
        }
    }
    marked[round] = -1;
}

__global__ void kernel(int* adj, int* xadj, int* output, int n, int nov){
  int index = threadIdx.x + (blockIdx.x * blockDim.x);
  __shared__ int marked[THREADS_PER_BLOCK][10];
  if(index < nov){
      //int *marked = new int[n];
      //memset(marked, -1, n * sizeof(int)); // bu belki silinebilir
      int localcount = 0;
      int round = 0;
      DFS_sparse(xadj, adj, marked[threadIdx.x], n - 1, index, index, localcount, round);
      output[index] = localcount;
    }
}

void wrapper(int *xadj, int *adj, int n,  int nov, int nnz){
  cudaSetDevice(0);
  int *adj_d;
  int *xadj_d;
  int *output_d;
  int *output_h = new int[nov];
  int numBlock = (nov + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
  cudaEvent_t start, stop;
  float elapsedTime;

  gpuErrchk(cudaMalloc((void**)&adj_d, (nnz) * sizeof(int)));
  gpuErrchk(cudaMalloc((void**)&xadj_d, (nov + 1) * sizeof(int)));

  gpuErrchk(cudaMalloc((void**)&output_d, (nov) * sizeof(int)));

  //gpuErrchk(cudaMallocHost((void **)&output_h, (nov) * sizeof(int)));

  gpuErrchk(cudaMemcpy(adj_d, adj, (nnz) * sizeof(int), cudaMemcpyHostToDevice));
  gpuErrchk(cudaMemcpy(xadj_d, xadj, (nov + 1) * sizeof(int), cudaMemcpyHostToDevice));

  cudaEventCreate(&start);
  cudaEventRecord(start, 0);

  kernel<<<numBlock, THREADS_PER_BLOCK>>>(adj_d, xadj_d, output_d, n, nov);

  gpuErrchk(cudaDeviceSynchronize());

  gpuErrchk(cudaMemcpy(output_h, output_d, (nov) * sizeof(int), cudaMemcpyDeviceToHost));
  //printArray(output_h,nov);
  cudaEventCreate(&stop);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);

  cudaEventElapsedTime(&elapsedTime, start, stop);
  //printf("GPU scale took: %f s\n", elapsedTime/1000);

  cudaFree(adj_d);
  cudaFree(xadj_d);
}


void  read_mtxbin(string fname, int k){
  //cout << "fname: " << fname << endl;
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
  //cout << end1-start1 << " -- ILK OKUMA SU (s).\n";

  int nov = maxElement +1;
  //cout <<"nov " << nov << endl;
  //cout <<"nnv " << nnv << endl;
  int * adj  = new int[nnv];
  int * xadj = new int[nov+1];
  xadj[0]=0;

  int j = 0;

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

  //cout << end-start << " -- OKUMA SURE (s).\n";
  wrapper(xadj,adj,k,nov,nnv);
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
