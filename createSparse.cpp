#include<iostream>
#include <map>
#include <unordered_map>
#include <omp.h>
#include <algorithm>

#include <vector>
#include <fstream>
#include <sstream>



using namespace std;

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

  double end = omp_get_wtime();
  cout << end-start << " -- execution time (s).\n";

  countCycles_sparse(xadj, adj,k,nov);
  return 0;
}

int main(int argc, char* argv[]){
  char* fname = argv[1];
  int k = atoi(argv[2]);
  read_mtxbin(fname,k);

  return 0;
}
