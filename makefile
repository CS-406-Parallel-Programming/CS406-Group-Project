all: OMP GPU_Non_Recursive_Implementation Multi_GPU_Non_Recursive_Implementation Multi_GPU_and_CPU_Non_Recursive_Implementation Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue

OMP: openmp_nonrecursive.cpp
	g++ -o omp openmp_nonrecursive.cpp -O3 -fopenmp

GPU_Non_Recursive_Implementation: non_recursive.cu
	nvcc -o non_recursive_out non_recursive.cu -O3 -Xcompiler -fopenmp -Xcompiler -O3

Multi_GPU_Non_Recursive_Implementation: multi_gpu_non_recursive.cu
	nvcc -o multi_gpu_out multi_gpu_non_recursive.cu -O3 -Xcompiler -fopenmp -Xcompiler -O3

Multi_GPU_and_CPU_Non_Recursive_Implementation: multi_gpu_non_recursive_cpu32.cu
	nvcc -o gpu_and_cpu_out multi_gpu_non_recursive_cpu32.cu -O3 -Xcompiler -fopenmp -Xcompiler -O3

Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue: multi_gpu_non_recursive_cpu32_dynamic.cu
	nvcc -o gpu_and_cpu_dynamic_out multi_gpu_non_recursive_cpu32_dynamic.cu -O3 -Xcompiler -fopenmp -Xcompiler -O3

run_all_amazon_3: run_omp_amz_3 run_gpu_nonrec_amz_3 run_multigpu_non_rec_amz_3 run_multigpu_and_cpu_non_rec_amz_3 run_multigpu_and_cpu_non_rec_dynamic_amz_3

run_all_amazon_4: run_omp_amz_4 run_gpu_nonrec_amz_4 run_multigpu_non_rec_amz_4 run_multigpu_and_cpu_non_rec_amz_4 run_multigpu_and_cpu_non_rec_dynamic_amz_4

run_all_amazon_5: run_omp_amz_5 run_gpu_nonrec_amz_5 run_multigpu_non_rec_amz_5 run_multigpu_and_cpu_non_rec_amz_5 run_multigpu_and_cpu_non_rec_dynamic_amz_5

run_time_all_amazon_3: run_time_omp_amz_3 run_time_gpu_nonrec_amz_3 run_time_multigpu_non_rec_amz_3 run_time_multigpu_and_cpu_non_rec_amz_3 run_time_multigpu_and_cpu_non_rec_dynamic_amz_3

run_time_all_amazon_4: run_time_omp_amz_4 run_time_gpu_nonrec_amz_4 run_time_multigpu_non_rec_amz_4 run_time_multigpu_and_cpu_non_rec_amz_4 run_time_multigpu_and_cpu_non_rec_dynamic_amz_4

run_time_all_amazon_5: run_time_omp_amz_5 run_time_gpu_nonrec_amz_5 run_time_multigpu_non_rec_amz_5 run_time_multigpu_and_cpu_non_rec_amz_5 run_time_multigpu_and_cpu_non_rec_dynamic_amz_5

run_all_dblp_3: run_omp_dblp_3 run_gpu_nonrec_dblp_3 run_multigpu_non_rec_dblp_3 run_multigpu_and_cpu_non_rec_dblp_3 run_multigpu_and_cpu_non_rec_dynamic_dblp_3

run_all_dblp_4: run_omp_dblp_4 run_gpu_nonrec_dblp_4 run_multigpu_non_rec_dblp_4 run_multigpu_and_cpu_non_rec_dblp_4 run_multigpu_and_cpu_non_rec_dynamic_dblp_4

run_all_dblp_5: run_omp_dblp_5 run_gpu_nonrec_dblp_5 run_multigpu_non_rec_dblp_5 run_multigpu_and_cpu_non_rec_dblp_5 run_multigpu_and_cpu_non_rec_dynamic_dblp_5

run_time_all_dblp_3: run_time_omp_dblp_3 run_time_gpu_nonrec_dblp_3 run_time_multigpu_non_rec_dblp_3 run_time_multigpu_and_cpu_non_rec_dblp_3 run_time_multigpu_and_cpu_non_rec_dynamic_dblp_3

run_time_all_dblp_4: run_time_omp_dblp_4 run_time_gpu_nonrec_dblp_4 run_time_multigpu_non_rec_dblp_4 run_time_multigpu_and_cpu_non_rec_dblp_4 run_time_multigpu_and_cpu_non_rec_dynamic_dblp_4

run_time_all_dblp_5: run_time_omp_dblp_5 run_time_gpu_nonrec_dblp_5 run_time_multigpu_non_rec_dblp_5 run_time_multigpu_and_cpu_non_rec_dblp_5 run_time_multigpu_and_cpu_non_rec_dynamic_dblp_5

run_omp_amz_3: OMP
	./omp amazon.txt 3 16 0

run_omp_amz_4: OMP
	./omp amazon.txt 4 16 0

run_omp_amz_5: OMP
	./omp amazon.txt 5 16 0

run_omp_dblp_3: OMP
	./omp dblp.txt 3 16 0

run_omp_dblp_4: OMP
	./omp dblp.txt 4 16 0

run_omp_dblp_5: OMP
	./omp dblp.txt 5 16 0

run_gpu_nonrec_amz_3: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 3 0

run_gpu_nonrec_amz_4: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 4 0

run_gpu_nonrec_amz_5: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 5 0

run_gpu_nonrec_dblp_3: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 3 0

run_gpu_nonrec_dblp_4: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 4 0

run_gpu_nonrec_dblp_5: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 5 0

run_multigpu_non_rec_amz_3: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 3 0

run_multigpu_non_rec_amz_4: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 4 0

run_multigpu_non_rec_amz_5: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 5 0

run_multigpu_non_rec_dblp_3: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 3 0

run_multigpu_non_rec_dblp_4: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 4 0

run_multigpu_non_rec_dblp_5: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 5 0

run_multigpu_and_cpu_non_rec_amz_3: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 3 0

run_multigpu_and_cpu_non_rec_amz_4: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 4 0

run_multigpu_and_cpu_non_rec_amz_5: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 5 0

run_multigpu_and_cpu_non_rec_dblp_3: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 3 0

run_multigpu_and_cpu_non_rec_dblp_4: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 4 0

run_multigpu_and_cpu_non_rec_dblp_5: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 5 0

run_multigpu_and_cpu_non_rec_dynamic_amz_3: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 3 0

run_multigpu_and_cpu_non_rec_dynamic_amz_4: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 4 0

run_multigpu_and_cpu_non_rec_dynamic_amz_5: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 5 0

run_multigpu_and_cpu_non_rec_dynamic_dblp_3: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 3 0

run_multigpu_and_cpu_non_rec_dynamic_dblp_4: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 4 0

run_multigpu_and_cpu_non_rec_dynamic_dblp_5: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 5 0

run_time_omp_amz_3: OMP
	./omp amazon.txt 3 16 1

run_time_omp_amz_4: OMP
	./omp amazon.txt 4 16 1

run_time_omp_amz_5: OMP
	./omp amazon.txt 5 16 1

run_time_omp_dblp_3: OMP
	./omp dblp.txt 3 16 1

run_time_omp_dblp_4: OMP
	./omp dblp.txt 4 16 1

run_time_omp_dblp_5: OMP
	./omp dblp.txt 5 16 1

run_time_gpu_nonrec_amz_3: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 3 1

run_time_gpu_nonrec_amz_4: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 4 1

run_time_gpu_nonrec_amz_5: GPU_Non_Recursive_Implementation
	./non_recursive_out amazon.txt 5 1

run_time_gpu_nonrec_dblp_3: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 3 1

run_time_gpu_nonrec_dblp_4: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 4 1

run_time_gpu_nonrec_dblp_5: GPU_Non_Recursive_Implementation
	./non_recursive_out dblp.txt 5 1

run_time_multigpu_non_rec_amz_3: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 3 1

run_time_multigpu_non_rec_amz_4: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 4 1

run_time_multigpu_non_rec_amz_5: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  amazon.txt 5 1

run_time_multigpu_non_rec_dblp_3: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 3 1

run_time_multigpu_non_rec_dblp_4: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 4 1

run_time_multigpu_non_rec_dblp_5: Multi_GPU_Non_Recursive_Implementation
	./multi_gpu_out  dblp.txt 5 1

run_time_multigpu_and_cpu_non_rec_amz_3: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 3 1

run_time_multigpu_and_cpu_non_rec_amz_4: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 4 1

run_time_multigpu_and_cpu_non_rec_amz_5: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  amazon.txt 5 1

run_time_multigpu_and_cpu_non_rec_dblp_3: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 3 1

run_time_multigpu_and_cpu_non_rec_dblp_4: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 4 1

run_time_multigpu_and_cpu_non_rec_dblp_5: Multi_GPU_and_CPU_Non_Recursive_Implementation
	./gpu_and_cpu_out  dblp.txt 5 1

run_time_multigpu_and_cpu_non_rec_dynamic_amz_3: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 3 1

run_time_multigpu_and_cpu_non_rec_dynamic_amz_4: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 4 1

run_time_multigpu_and_cpu_non_rec_dynamic_amz_5: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out   amazon.txt 5 1

run_time_multigpu_and_cpu_non_rec_dynamic_dblp_3: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 3 1

run_time_multigpu_and_cpu_non_rec_dynamic_dblp_4: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 4 1

run_time_multigpu_and_cpu_non_rec_dynamic_dblp_5: Multi_GPU_and_CPU_NonRecursive_Dynamic_Workqueue
	./gpu_and_cpu_dynamic_out dblp.txt 5 1
