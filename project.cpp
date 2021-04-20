//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>

// CPP Program to count cycles of length n
// in a given graph.
//#include <bits/stdc++.h>
using namespace std;

// Number of vertices
const int V = 5;

void DFS(bool graph[][V], bool marked[], int n,
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
        /* A.Enes
        int start_index = xadj[vert];
        int path_length = xadj[vert+1] - start_index;
        for(int i=start_index; i < path_length; i++){
            if(adj[i] == start){
                count++;
                break;
            }
        }
        return;
        */
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
        /*
 
        int start_index = xadj[vert];
        int path_length = xadj[vert+1] - start_index;
        for(int i=start_index; i < path_length; i++){
            if(!marked[i])
            DFS();
        }
        */
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
int countCycles_sparse(int xadj[], int adj[],int n) //(bool graph[][V], int n)
{
    bool marked[V];
    memset(marked, 0, sizeof(marked));
    int count = 0;
    for (int i = 0; i < V - (n-1) ; i++)
    {
        DFS_sparse(xadj, adj, marked, n - 1, i, i, count);
        marked[i] = true;
    }
    return count / 2;
}

int main()
{
    bool graph[][V] = {{0, 1, 0, 1, 0},
                       {1, 0, 1, 0, 1},
                       {0, 1, 0, 1, 0},
                       {1, 0, 1, 0, 1},
                       {0, 1, 0, 1, 0}};

    int n = 4;

    int xadj [6] = { 0, 2, 5, 7, 10, 12 };
    int adj [12] = { 1, 3, 0, 2, 4, 1, 3, 0, 2, 4, 1, 3 };

    cout << "Total cycles of length with sparse "
         << n << " are " << countCycles_sparse(xadj,adj, n) << "\n";

    cout << "Total cycles of length " << n << " are "
         << countCycles(graph, n)<< "\n";
    return 0;
}