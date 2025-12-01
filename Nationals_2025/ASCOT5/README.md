# ASCOT Benchmark - Technocrats Results

ASCOT5 (Accelerated Simulation of Charged particle Orbits in Tokamaks, version 5) is an advanced physics simulation tool used in fusion research. It models how charged particles move inside magnetic confinement fusion devices, such as:

- Tokamaks (e.g., ITER, JET)
- Stellarators
- Other magnetically confined plasma machines
----

We succesfully ran the ASCOT5 benchmark and compiled it with both gcc and Intel.
  
## ASCOT5 System Requirements

| Program                                   | Version / Minimum Requirement                 | Description                                       |
|-------------------------------------------|------------------------------------------------|---------------------------------------------------|
| **GCC / Intel / AMD Compiler**            | GCC ≥ 8.0 • Intel OneAPI ≥ 2022 • AOCC ≥ 4.1   | C compiler with OpenMP support                    |
| **OpenMPI**                               | 4.1.4                                          | MPI implementation for distributed computing      |
| **HDF5**                                  | 1.12.2 (parallel enabled)                      | Data storage library for ASCOT5                   |
| **Python**                                | 3.9                                            | Used for pre- and post-processing with a5py       |
| **CMake**                                 | 3.20                                           | Build system (required for HDF5 builds)           |
| **NumPy**                                 | 1.21                                           | Python numerical library                          |
| **h5py**                                  | 3.7                                            | Python HDF5 interface                             |
| **Matplotlib**                            | 3.5                                            | Python plotting library                           |
---
## Submission

Submit for both benchmarks:
- Your output file
- Benchmark verification text file
- Details of the configuration of how the benchmark was ran

