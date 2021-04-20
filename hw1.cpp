//#include "scale.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <omp.h>
#include <math.h> /* fabs */
#include <string.h>
#include <stdlib.h>

int nt;
int iter;
go int parallel_sk(int *xadj, int *adj, int *txadj, int *tadj,
                   double *rv, double *cv, int nov)
{
    double start = omp_get_wtime();
    omp_set_num_threads(nt);
#pragma omp parallel for schedule(static)
    for (int num = 0; num < nov; num++)
    {
        rv[num] = 1.0;
        cv[num] = 1.0;
    }

    for (int x = 0; x < iter; x++)
    {
        double max = 0.0;
#pragma omp parallel shared(rv, cv, max)
        {
            int i1, i2, j1, j2, t, k, tt, temp;
            double totalSum = 0.0, localMax = 0.0, rsum = 0.0, csum = 0.0;
#pragma omp for private(i2, rsum, temp, tt) schedule(guided)
            for (i1 = 0; i1 < nov; i1++)
            {
                rsum = 0;
                temp = xadj[i1];
                tt = (xadj[i1 + 1] - temp - 1);
                for (i2 = 0; i2 <= tt; i2++)
                    rsum += cv[adj[temp + i2]];
                rv[i1] = 1 / rsum;
            }
#pragma omp for private(j2, csum, temp, tt) schedule(guided)
            for (j1 = 0; j1 < nov; j1++)
            {
                csum = 0;
                temp = txadj[j1];
                tt = (txadj[j1 + 1] - temp - 1);
                for (j2 = 0; j2 <= tt; j2++)
                    csum += rv[tadj[temp + j2]];
                cv[j1] = 1 / csum;
            }
#pragma omp for private(k, totalSum, temp, tt) schedule(guided)
            for (t = 0; t < nov; t++)
            {
                totalSum = 0.0;
                temp = xadj[t];
                tt = (xadj[t + 1] - temp - 1);
                for (k = 0; k <= tt; k++)
                    totalSum += rv[t] * cv[adj[temp + k]];
                totalSum = fabs(1.0 - totalSum);
                localMax = (totalSum > localMax) ? totalSum : localMax;
            }
#pragma omp critical
            max = (localMax > max) ? localMax : max;
        }
        std::cout << "Iter: " << x << " - ERROR: " << max << std::endl;
    }
    double end = omp_get_wtime();
    std::cout << nt << " Threads  --  "
              << "Time: " << end - start << " s." << std::endl;
    return 1;
}

void *read_mtxbin(std::string bin_name)
{
    const char *fname = bin_name.c_str();
    FILE *bp;
    bp = fopen(fname, "rb");

    int *nov = new int;
    int *nnz = new int;

    fread(nov, sizeof(int), 1, bp);
    fread(nnz, sizeof(int), 1, bp);

    int *adj = new int[*nnz];
    int *xadj = new int[*nov];
    int *tadj = new int[*nnz];
    int *txadj = new int[*nov];

    fread(adj, sizeof(int), *nnz, bp);
    fread(xadj, sizeof(int), *nov + 1, bp);

    fread(tadj, sizeof(int), *nnz, bp);
    fread(txadj, sizeof(int), *nov + 1, bp);

    int inov = *nov + 1;

    double *rv = new double[inov];
    double *cv = new double[inov];

    parallel_sk(xadj, adj, txadj, tadj, rv, cv, *nov);
}

int main(int argc, char *argv[])
{
    nt = atoi(argv[3]);
    iter = atoi(argv[2]);
    read_mtxbin(argv[1]);
}
