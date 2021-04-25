//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <omp.h>
#include <algorithm>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>

// CPP Program to count cycles of length n
// in a given graph.
//#include <bits/stdc++.h>
using namespace std;

// Number of vertices
//const int V = 5;

/*void DFS(bool graph[][V], bool marked[], int n,
         int vert, int start, int &count) //vert: bulundugu konum //start: baslangıc noktası
{
    // mark the vertex vert as visited
    marked[vert] = true;
    // if the path of length (n-1) is found
    if (n == 0)
    {
        // mark vert as un-visited to make
        // it usable again.
        marked[vert] = false;
        // Check if vertex vert can end with
        // vertex start
        if (graph[vert][start])
        {
            count++;
            return;
        }
        else
            return;
    }
    // For searching every possible path of
    // length (n-1)
    for (int i = 0; i < V; i++)
        if (!marked[i] && graph[vert][i])
            // DFS for searching path by decreasing
            // length by 1
            DFS(graph, marked, n - 1, i, start, count);

    // marking vert as unvisited to make it
    // usable again.
    marked[vert] = false;
}


// Counts cycles of length N in an undirected
// and connected graph.
int countCycles(bool graph[][V], int n)
{
    // all vertex are marked un-visited initially.
    bool marked[V];
    memset(marked, 0, sizeof(marked));
  
    // Searching for cycle by using v-n+1 vertices
    int count = 0;
    for (int i = 0; i < V - (n - 1); i++) {
        DFS(graph, marked, n-1, i, i, count);
  
        // ith vertex is marked as visited and
        // will not be visited again.
        marked[i] = true;
    }
  
    return count/2;
}

// sparse DFS format
*/
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
int countCycles_sparse(int xadj[], int adj[],int n,  int nov ) //(bool graph[][V], int n)
{
    //cout << "7"<<"\n";
    double start, end;
    start = omp_get_wtime();
    int totalCount=0;
#pragma omp parallel
{
    bool *marked = new bool[nov];
    memset(marked, 0, sizeof(marked));
    int localcount = 0;
#pragma omp for schedule(dynamic)
    for (int i = 0; i < nov - (n-1) ; i++)
    {
        if(i%30000==0)
        cout <<"ITER: "<< i<<"\n";

        memset(marked, 1, i*sizeof(bool)); // HALA BILMIYORUZ
        DFS_sparse(xadj, adj, marked, n - 1, i, i, localcount);
        //marked[i] = true;
    }
#pragma omp atomic
    totalCount+=localcount;
}
 end = omp_get_wtime();
  printf("Took %f secs \n", end - start);
    return totalCount / 2;
}

void read_mtxbin(std::string bin_name)
{
    cout << "READYYYYYY!!!!!"<<"\n";

    const char *fname = bin_name.c_str();
    FILE *bp;
    bp = fopen(fname, "rb");
    int *nov = new int;
    int *nnz = new int;
    cout << "1"<<"\n";

    fread(nov, sizeof(int), 1, bp);
    fread(nnz, sizeof(int), 1, bp);
    cout << "2"<<"\n";

    int *adj = new int[*nnz];
    int *xadj = new int[*nov];
    fread(adj, sizeof(int), *nnz, bp);
    fread(xadj, sizeof(int), *nov + 1, bp);
    cout << "3"<<"\n";
   
    int n = 3;
    cout << "Total cycles of length with sparse "
         << n << " are " << countCycles_sparse(xadj,adj, n, *nov) << "\n";

    /*cout << "Total cycles of length " << n << " are "
         << countCycles(graph, n)<< "\n";*/
}
int main(int argc, char *argv[])
{
   /* bool graph[][V] = {{0, 1, 0, 1, 0},
                       {1, 0, 1, 0, 1},
                       {0, 1, 0, 1, 0},
                       {1, 0, 1, 0, 1},
                       {0, 1, 0, 1, 0}};

   

    int xadj [6] = { 0, 2, 5, 7, 10, 12 };
    int adj [12] = { 1, 3, 0, 2, 4, 1, 3, 0, 2, 4, 1, 3 };*/
    read_mtxbin(argv[1]);
    return 0;
}