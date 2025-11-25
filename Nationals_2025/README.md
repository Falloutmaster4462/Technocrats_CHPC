# Technocrats Nationals Preparation

**Repository Overview:**
This repository contains all code, scripts, documentation, and reports for our preparation for the HPC Nationals competition. It serves as our single source of truth for configurations, benchmarks, and team coordination.

---

# Technocrats SCC 2025 - Complete Deployment Guide

> **Student Cluster Competition 2025 - CSIR CHPC**  
> Team: Technocrats ("Shaka Zulu")  
> Hardware: 3-node Intel Xeon Gold 6448H cluster (92 cores, 280GB RAM)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Hardware Overview](#hardware-overview)
3. [Software Stack](#software-stack)
4. [Benchmark Applications](#benchmark-applications)
5. [Performance Targets](#performance-targets)
6. [Team Roles & Responsibilities](#team-roles-&-responsibilities)

---

## Executive Summary

### Cluster Configuration

**Technocrats Cluster Specifications:**
- **Total Cores**: 92 (28 head + 32 + 32 compute) (+4 management)
- **Total Memory**: 280GB (88GB + 96GB + 96GB) (+8GB management)
- **Storage**: 1.92TB NVMe (head), 2× 240GB SATA SSD (compute)
- **Network**: 10GbE SFP+ with RDMA support
- **OS**: NixOS 24.05 (declarative, reproducible)

### Competitive Position

**Expected Results (with Intel oneAPI):**
- **Technocrats Wins**: 4/7 official benchmarks (HPCG, ASCOT5, DFTB+, + secret)
- **Strategy**: Dominate memory-intensive applications, optimize MD performance

### Key Advantages

1. **Memory Architecture**: 3GB per core average
2. **NVMe I/O**: 3500 MB/s on head node
3. **Uniform Configuration**: All nodes 96GB RAM (simplified management)
4. **Dual Compiler Strategy**: Intel oneAPI + GCC for optimal performance

---

## Hardware Overview

### Node Specifications

#### Head Node (10.0.0.1)
```
Hostname: head-node
CPU: 1× Intel Xeon Gold 6448H (32 cores @ 2.4GHz)
  - Architecture: Sapphire Rapids (4th Gen Xeon Scalable)
  - ISA: AVX-512, AMX (Advanced Matrix Extensions)
Memory: 96GB DDR5-4800
Storage: 1.92TB NVMe Gen4 SSD (HPE)
Network: Broadcom BCM57412 10Gb 2-port SFP+
Role: Management + Compute (28 cores for compute after overhead)
```

#### Compute Node 1 (10.0.0.2)
```
Hostname: compute-01
CPU: 1× Intel Xeon Gold 6448H (32 cores @ 2.4GHz)
Memory: 96GB DDR5-4800
Storage: 240GB SATA SSD
Network: Broadcom BCM57412 10Gb 2-port SFP+
Role: Pure compute
```

#### Compute Node 2 (10.0.0.3)
```
Hostname: compute-02
CPU: 1× Intel Xeon Gold 6448H (32 cores @ 2.4GHz)
Memory: 96GB DDR5-4800
Storage: 240GB SATA SSD
Network: Broadcom BCM57412 10Gb 2-port SFP+
Role: Pure compute
```

### Network Topology

```
Internet
    │
    │
    └───── head-node (10.0.0.1) - Master
            │   │
            │   └─── NFS Server (/nvme/shared)
            │
            │
            ├─── compute-01 (10.0.0.2)
            │     │
            │     └─── NFS Client (mount /shared)
            │
            └── compute-02 (10.0.0.3)
                  │
                  └─── NFS Client (mount /shared)

Direct Attach Copper Cables: 3× 1m SFP+ DAC
RDMA Support: Enabled on all NICs
```
---

## Software Stack

### Operating System

**NixOS 24.05**
- Declarative configuration
- Reproducible builds
- Atomic upgrades/rollbacks
- Binary caching support

### Deployment Tools

1. **nixos-anywhere**: Initial OS installation from bare metal
2. **Colmena**: Configuration management and updates during competition
3. **disko**: Declarative disk partitioning
4. **Nix Flakes**: Package management and build system

### Compilers & Libraries

**Primary (Intel oneAPI):**
- Intel C++ Compiler (icx/icpx)
- Intel Fortran Compiler (ifx)
- Intel MPI Library
- Intel MKL (Math Kernel Library)

**Secondary (GCC):**
- GCC 12.2 (C/C++/Fortran)
- OpenMPI 4.1.6
- OpenBLAS (multithreaded)

### Job Scheduling

**Slurm 23.02**
- Head node: Controller (slurmctld)
- All nodes: Compute daemons (slurmd)
- Partitions: highmem, compute, all, management

### File Sharing

**NFS over RDMA**
- Server: head-node (/nvme/shared)
- Clients: compute nodes (mount at /shared)
- Optimized for 10GbE with RDMA

---

## Benchmark Applications 

### **Synthetic Benchmarks**

- **HPCC (HPC Challenge)** — https://github.com/icl-utk-edu/hpcc  
- **HPCG (High Performance Conjugate Gradients)** — https://www.hpcg-benchmark.org/

### **Application Benchmarks**

- **AmberMD** — https://ambermd.org  
- **ASCOT5** — https://ascot4fusion.github.io/ascot5/  
- **DFTB+** — https://dftbplus.org  
- **HemeLB** — https://hemelb-dev.github.io/HemeLB-Carpentries/  
- **MathWorks (MATLAB / Simulink)** — https://www.mathworks.com/products/parallel-computing.html  
- **Secret Application(s)** — Revealed at Nationals  

## Performance Targets

### Official Benchmark Targets

| Benchmark | Minimum (Pass) | Target (Competitive) | Stretch (Excellence) |
|-----------|----------------|----------------------|----------------------|
| **HPL** | 1.5 TFLOPS | 2.3 TFLOPS | 2.8 TFLOPS |
| **HPCG** | 50 GFLOPS | 65 GFLOPS | 75 GFLOPS |
| **AmberMD** | 400 ns/day | 520 ns/day | 580 ns/day |
| **ASCOT5** | 6M p/hr | 9M p/hr | 11M p/hr |
| **DFTB+** | 1200 atoms | 1700 atoms | 1900 atoms |
| **HemeLB** | 900 MLUPS | 1100 MLUPS | 1250 MLUPS |
| **MATLAB** | 92 workers | Quality focus | Accuracy emphasis |

---
### Competitive Analysis

**Technocrats Should Win:**
- HPCG (memory bandwidth)
- ASCOT5 (NVMe I/O)
- DFTB+ (system size)
- Secret (if memory-intensive)

**Technocrats Should Compete:**
- HPL (with Intel MKL)
- AmberMD (with optimization)

**Technocrats May Trail:**
- HemeLB (fewer cores)
- MATLAB (fewer workers)

### Scoring Strategy

**Maximize Points:**
1. **Dominate strength benchmarks** - Full points on HPCG, ASCOT5, DFTB+
2. **Be competitive on HPL** - Intel MKL closes gap
3. **Optimize AmberMD aggressively** 
4. **Quality over quantity** - MATLAB emphasize accuracy
5. **Secret benchmark** 

---
## Team Roles & Responsibilities

| Name           | Primary Focus Area      | Secondary Focus       |
| :------------- | :---------------------- | :-------------------- |
| Nina Meyer (Team Lead)     | Project Management      | Documentation, Installations(Optimize Linux for HPC) |
| Nikaj Jazeel Nilraj         | Hardware Lead     | Computer Architecture & Performance Optimization   |
| Nicoroy Lehlohonolo Zwane         | Software & Benchmarks   | HPL Benchmark Analysis, Automation and deployment       |
| Joseph Alamenhe         | Software & Benchmarks   | Manage Slurm/PBS job scheduling, Networking         |

*Roles are fluid; everyone is expected to help outside their primary area.*

---

## ✅ Definition of Done (DoD)
For a task to be considered complete, it must meet the following criteria:
1.  **Code:** Written, reviewed, and merged into the main branch.
2.  **Documentation:** Any changes are documented in the relevant `README.md` or technical report.
3.  **Testing:** Functionality has been validated on a test system if possible or a screenshot of the functioning system.
4.  **Report:** A Technical Post-Operation Report (Tech-POR) is filed in the `/docs` directory for significant changes. (Pushed to the Repo to the appropriate branch)

---

## 📝 Workflow
1.  **Create an Issue:** Before starting work, create a GitHub Issue describing the task.
2.  **Create a Branch:** Create a feature branch named `Report/Problem Name'.
3.  **Commit & Push:** Make commits with clear messages. Push your branch.
4.  **Open a Pull Request (PR):** Open a PR for review. Link it to the original issue.


## License & Acknowledgments

**Repository License**: MIT License (or as required by competition)

**Acknowledgments:**
- CSIR CHPC for hosting the competition
- Intel for oneAPI toolkit
- All open-source benchmark developers

**Team**: Technocrats - "Shaka Zulu"  
**Competition**: CSIR CHPC Student Cluster Competition 2025  
**Hardware**: HPE ProLiant Gen11 Servers with Intel Xeon Gold 6448H


