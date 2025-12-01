# HPCC Benchmark - Technocrats Results

We succesfully ran an HPCC benchmark and compiled it with both gcc and Intel.

---
For each of your respective build(s) and run(s), you must submit your:

README.md a file describing the versions of the software you used to build HPCC,
- Makefile,
- hpccinf.txt input files,
- hpccoutf.txt formatted output files, and
- hpcc executable binaries.

## Input Files
We used an input file
```
_hpccinf.txt
``` 
## How we ran the benchmark

Our executable installation script:
```hpcc_install.sh```

HPCC was executed using Slurm via:
```sbatch run_hpcc.slurm```

## Below is our software stack for GCC & Intel and Versions 

| Component       | GCC Stack                                 |     Version     |
| --------------- | ------------------------------------------|-----------------|
| Compiler        | gcc, g++, gfortran  (gcc --version)       |                 |
| MPI             | OpenMPI (                                 |                 |
| Math libs       | OpenBLAS / BLIS / LAPACK                  |                 |
| FFT             | FFTW                                      |                 |
| Process pinning | hwloc, numactl                            |                 |
| HPL/HPCC        | Builds with Make.Linux_GCC                |                 |

| Component       | Intel Stack                          |      Version     |
| --------------- | -------------------------------------|------------------|
| Compiler        | icc / icx, icpc / icpx, ifort / ifx  |                  |
| MPI             | Intel MPI                            |                  | 
| Math libs       |  MKL                                 |                  |
| FFT             | MKL FFT                              |                  |
| Process pinning | hwloc, numactl                       |                  |
| HPL/HPCC        | Builds with Make.Linux_Intel         |                  |

## Results 

| Component      | Result    |
|----------------|-----------|
|                |           |
|                |           |
|                |           |

---
