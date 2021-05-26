//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>
#include <sstream>
#include "omp.h"
#include <unordered_map>

using namespace std;
#define THREADS_PER_BLOCK 256
#define PARALEL_THREAD_COUNT 32
#define GPU_MULTIPLIER 10
#define PARALEL_CPU 28

// #define VIRTUAL_THREAD_COUNT 68
// 4  10 40
// 28 1  28

int flag;

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
  if (code != cudaSuccess)
    {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
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

// if(path_length-start_index <=1) return;

    for(int i=start_index; i < path_length; i++){
        if(!marked[adj[i]]){
            DFS_sparse(xadj, adj, marked, n-1, adj[i], start, count);
        }
    }
    marked[vert] = false;
}

void printArray(int *arr, int nov){
    for (int j=0;j<nov;j++)
    {
        cout << j << " " << arr[j] << endl;
    }
}
              
__global__ void kernel3(int* adj, int* xadj, int* output, int nov, int novStart){

  int index = novStart + threadIdx.x + (blockIdx.x * blockDim.x);
  if(index < nov){
      // if(index ==0)printf("called gpu \n");
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
      output[index-novStart] = localcount;
    }
}

__global__ void kernel4(int* adj, int* xadj, int* output, int nov,int novStart ){
  int index =novStart + threadIdx.x + (blockIdx.x * blockDim.x);
  if(index < nov){
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
      output[index-novStart] = localcount;
    }
}
__global__ void kernel5(int* adj, int* xadj, int* output, int nov, int novStart){
  int index = novStart + threadIdx.x + (blockIdx.x * blockDim.x);
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
      output[index-novStart] = localcount;
    }
}


void wrapper(int *xadj, int *adj, int n,  int nov, int nnz){

  int *output_h = new int[nov];

 // double start_cpu, end_cpu;
 // start_cpu = omp_get_wtime();


  #pragma omp parallel num_threads(PARALEL_THREAD_COUNT)
  {

    int threadId=omp_get_thread_num ();
    // cout<< threadId<<endl;

    int virtual_thread_count  = GPU_MULTIPLIER *4 + PARALEL_CPU;
    int novForThread = (nov+virtual_thread_count-1)/virtual_thread_count;



    if(threadId <=3)
    {
      int novStart = GPU_MULTIPLIER * novForThread * threadId;
      int novEnd   = GPU_MULTIPLIER * novForThread * (threadId+1);
      if (novEnd > nov) novEnd = nov;
      int numBlock = (novEnd-novStart + THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK;
      // printf("nov s %d e %d \n", novStart,novEnd);


      cudaSetDevice(threadId);

      int *adj_d;
      int *xadj_d;
      int *output_d;
      cudaEvent_t start, stop;
      float elapsedTime;

      gpuErrchk(cudaMalloc((void**)&adj_d, (nnz) * sizeof(int)));
      gpuErrchk(cudaMalloc((void**)&xadj_d, (nov + 1) * sizeof(int)));

      gpuErrchk(cudaMalloc((void**)&output_d, (novEnd-novStart) * sizeof(int)));

      //gpuErrchk(cudaMallocHost((void **)&output_h, (nov) * sizeof(int)));

      gpuErrchk(cudaMemcpy(adj_d, adj, (nnz) * sizeof(int), cudaMemcpyHostToDevice));
      gpuErrchk(cudaMemcpy(xadj_d, xadj, (nov + 1) * sizeof(int), cudaMemcpyHostToDevice));

      cudaEventCreate(&start);
      cudaEventRecord(start, 0);
      double start_gpu = omp_get_wtime();
      cudaStream_t stream1;
      cudaStreamCreate ( &stream1) ;

        // printf("threadId entry to kernel %d GPU \n", threadId );
      if      (n==3)kernel3<<<numBlock, THREADS_PER_BLOCK,0,stream1>>>(adj_d, xadj_d, output_d, novEnd,novStart);
      else if (n==4)kernel4<<<numBlock, THREADS_PER_BLOCK,0,stream1>>>(adj_d, xadj_d, output_d, novEnd,novStart);
       else if (n==5)kernel5<<<numBlock, THREADS_PER_BLOCK,0,stream1>>>(adj_d, xadj_d, output_d, novEnd,novStart);
      //combination<<<numBlocks, threadsPerBlock>>>(adj_d, xadj_d, output_d, n, nov);
      // printf("threadId exit to kernel %d GPU \n", threadId );
   //   double end_gpu = omp_get_wtime();


      gpuErrchk(cudaDeviceSynchronize());
      cudaEventCreate(&stop);
      cudaEventRecord(stop, 0);
      cudaEventSynchronize(stop);
      cudaEventElapsedTime(&elapsedTime, start, stop);

      if(flag == 1)	printf("GPU scale took: %f s on gpu  %d \n", elapsedTime/1000, threadId);

      gpuErrchk(cudaMemcpy(output_h+novStart, output_d, (novEnd-novStart) * sizeof(int), cudaMemcpyDeviceToHost));
      cudaFree(adj_d);
      cudaFree(xadj_d);


    }
    else{
      // printf("Entered \n" );

      // int novForThread = (nov+PARALEL_THREAD_COUNT-1)/PARALEL_THREAD_COUNT;
      // int novStart = novForThread * threadId;
      // int novEnd   = novForThread * (threadId+1);
      // if (novEnd> nov) novEnd = nov;
      // int numBlock = (novEnd-novStart + THREADS_PER_BLOCK-1) / THREADS_PER_BLOCK;
      int novStart = 4 * GPU_MULTIPLIER*novForThread +  1 * novForThread * (threadId-4);
      int novEnd   =  novStart + 1*  novForThread ;
      if (novEnd> nov) novEnd = nov;


      // printf("nov s %d e %d  -cpu \n", novStart,novEnd);

      bool *marked = new bool[nov];
      memset(marked, false, nov * sizeof(bool)); // bu belki silinebilir

      double start_thread = omp_get_wtime();
      for(int i = novStart; i < novEnd; i++){
          int localcount = 0;
          DFS_sparse(xadj, adj, marked, n - 1, i, i, localcount);
          output_h[i ] = localcount;


      }
      double end_thread = omp_get_wtime();
      printf("Took %f secs \n", end_thread -start_thread );


    }


  }
//  end_cpu = omp_get_wtime();

   // printf("Took %f secs \n", end_cpu - start_cpu);
  	if(flag == 0)	printArray(output_h,nov);
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
    flag = atoi(argv[3]);
    read_mtxbin(fname,k);
    return 0;
}
