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
// __device__ bool check(int marked[], int round, int val){
//   for(int i = 0; i < round; i++){
//     if(marked[i] == val){return false;}
//   }
//   return true;
// }
//
// __device__ void DFS_sparse(int xadj[], int adj[], int marked[], int n,
//          int vert, int start, int &count, int round) //vert: bulundugu konum //start: baslangıc noktası
// {
//     marked[round] = vert;
//
//     int start_index = xadj[vert];
//     int path_length = xadj[vert+1];
//
//     if (n == 0){
//       marked[round] = -1;
//         for(int i = start_index; i < path_length; i++){
//             if(adj[i] == start){
//                 count++;
//                 break;
//             }
//         }
//         return;
//     }
//
//     for(int i=start_index; i < path_length; i++){
//         if(check(marked, round,adj[i])){
//             DFS_sparse(xadj, adj, marked, n-1, adj[i], start, count, round + 1);
//         }
//     }
//     marked[round] = -1;
// }


__global__ void kernel3(int* adj, int* xadj, int* output, int nov){
  int index = threadIdx.x + (blockIdx.x * blockDim.x);
  if(index < nov){
      //int *marked = new int[n];
      //memset(marked, -1, n * sizeof(int)); // bu belki silinebilir
      int localcount = 0;
      // int round = 0;

      // 0-->
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
      output[index] = localcount;
    }
}

__global__ void kernel4(int* adj, int* xadj, int* output, int nov){
  int index = threadIdx.x + (blockIdx.x * blockDim.x);
  if(index < nov){
      //int *marked = new int[n];
      //memset(marked, -1, n * sizeof(int)); // bu belki silinebilir
      int localcount = 0;
      // int round = 0;

      // 0-->
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
          //eliminate 0 == 2
          if (neighbour_2 == index) continue;
          int s2  = xadj[neighbour_2];
          int e2  = xadj[neighbour_2+1];

          for(int k=s2; k < e2; k++){

            // 0 --> 1 --> 2 --> 3

            int neighbour_3 =  adj[k];
            //eliminate 3 == 0
            if (neighbour_3 == index) continue;
            // eliminate 3 ==1
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
      output[index] = localcount;
    }
}
__global__ void kernel5(int* adj, int* xadj, int* output, int nov){
  int index = threadIdx.x + (blockIdx.x * blockDim.x);
  if(index < nov){
      //int *marked = new int[n];
      //memset(marked, -1, n * sizeof(int)); // bu belki silinebilir
      int localcount = 0;
      // int round = 0;

      // 0-->
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
          //eliminate 0 == 2
          if (neighbour_2 == index) continue;
          int s2  = xadj[neighbour_2];
          int e2  = xadj[neighbour_2+1];

          for(int k=s2; k < e2; k++){

            // 0 --> 1 --> 2 --> 3

            int neighbour_3 =  adj[k];
            //eliminate 3 == 0
            if (neighbour_3 == index) continue;
            // eliminate 3 ==1
            if (neighbour_3 == neighbour_1) continue;
            int s3  = xadj[neighbour_3];
            int e3  = xadj[neighbour_3+1];


            for(int n=s3; n < e3; n++){
              //0 -->1 -->2 -->3 -->4


              int neighbour_4 =  adj[n];
              //eliminate 4 == 0
              if (neighbour_4 == index) continue;
              // eliminate 4 ==1
              if (neighbour_4 == neighbour_1) continue;
              // eliminate 4 ==2
              if (neighbour_4 == neighbour_2) continue;

              int s4  = xadj[neighbour_4];
              int e4  = xadj[neighbour_4+1];


              for(int o=s4; o < e4; o++){

                //0 -->1 -->2 -->3 -->4--> 5

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
      output[index] = localcount;
    }
}




// __global__ void combination(int* adj, int* xadj, int* output, int n, int nov){
//
//
//   int v =  blockDim.x * blockIdx.x +  threadIdx.x;
//   int i =  blockDim.y * blockIdx.y +  threadIdx.y;
//   int j =  blockDim.z * blockIdx.z +  threadIdx.z;
//
//  // accessVertex
//   // if (v==0 && i == 0 && j ==0) {printf("running");}
//   int start = adj[v];
//   int end   = adj[v+1];
//
//   int neighbourCount = end-start;
//
//
//   if (i>=neighbourCount) return;
//   int first_neighbour = xadj[adj[start + i]];
//
//   int first_neighbour_start = adj[first_neighbour];
//   int first_neighbour_end = adj[first_neighbour+1];
//   int first_neighbour_neighbourCount = first_neighbour_end-first_neighbour_start;
//
//   if(j>=first_neighbour_neighbourCount) return;
//
//   int second_neighbour = xadj[adj[first_neighbour_start+j]];
//
//
//   // check all of them unique
//   if (v == second_neighbour) return;
//
//   // check first -> second -> third has connection
//
//
//   for(int k = start; k < end; k ++){
//      if (xadj[adj[start + k]] == second_neighbour){
//        // AtomicAdd(&output[v],1);
//        break;
//      }
//   }
// }



void wrapper(int *xadj, int *adj, int n,  int nov, int nnz){

  // int X = nov;
  // int Y = maxSize;
  // int Z = maxSize;
  //
  // dim3 threadsPerBlock(8, 8, 8);
  // dim3 numBlocks(X/threadsPerBlock.x,  /* for instance 512/8 = 64*/
  //                Y /threadsPerBlock.y,
  //                Z/threadsPerBlock.z);
  //





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

  kernel5<<<numBlock, THREADS_PER_BLOCK>>>(adj_d, xadj_d, output_d, nov);
  //combination<<<numBlocks, threadsPerBlock>>>(adj_d, xadj_d, output_d, n, nov);

  gpuErrchk(cudaDeviceSynchronize());

  gpuErrchk(cudaMemcpy(output_h, output_d, (nov) * sizeof(int), cudaMemcpyDeviceToHost));

  cudaEventCreate(&stop);
  cudaEventRecord(stop, 0);
  cudaEventSynchronize(stop);

  cudaEventElapsedTime(&elapsedTime, start, stop);
  // printf("GPU scale took: %f s\n", elapsedTime/1000);
  printArray(output_h,nov);
  cudaFree(adj_d);
  cudaFree(xadj_d);
}


void  read_mtxbin(string fname, int k){
  //cout << "fname: " << fname << endl;
  ifstream infile(fname);
  int a, b;
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
  int maxSize = -1;

  for(int i=0; i < nov ; i++ ){
    auto current = hashmap.find(i);
    if (current == hashmap.end()){
        xadj[i+1] = xadj[i];
    }
    else{
        int size = current->second.size();
        maxSize = max(size,maxSize);

        xadj[i+1] = xadj[i] + size;
        for(auto val : current->second) {
            adj[j] = val;
            j++;
        }
    }
  }
  // cout << "maxSize: "<<maxSize<<endl;
  // cout << end-start << " -- OKUMA SURE (s).\n";
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
