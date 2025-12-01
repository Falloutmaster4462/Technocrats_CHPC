# 🏆 CHPC Student Cluster Competition — Task Breakdown & Timeline  
**Competition Dates:** 29 November (Saturday) – 3 December (Wednesday), 2025  
**Location:** CHPC Nationals


## 📦 Benchmarks & Applications Overview

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

---
## Roles & Responsibilities

| **Member** | **Responsibilities** |
|------------|----------------------|
| **Nina** | Documentation • ZeroTier • SSH & System Access • Package/Compiler Setup • Build OpenBLAS/OpenMPI from source • Hardware Checklist |
| **Joey** | ZeroTier • Networking (iptables, NTP, Firewall) • **SLURM**  • Optimizations • Grafana |
| **Nic** | Ansible Control Node • Inventory • Playbooks • Documentation • LMOD • Intel oneAPI • LinPACK Peak Perf |
| **Jazz** | Hardware Topology (repo folder) •  Competition Day Hardware Setup Checklist • Package/Compiler Setup • OpenBLAS/OpenMPI compilation • Benchmark Execution (btop) • System Optimizations |

## 🗓 Competition Week Schedule

### Work Flow & Productivity:

| **Date** | **Activity** |
|---------|--------------|
| **29 Nov (Saturday)** | Teams arrive. Booths + hardware issued. Cluster deployment begins. |
| **30 Nov (Sunday, morning) → 3 Dec (Wednesday, midday)** | **Official Student Cluster Competition** |
| **3 Dec (Wednesday, midday–14:00)** | Hardware teardown + packing |
| **3 Dec (Wednesday, evening)** | Prize Giving & Awards |
| **4 Dec (Thursday)** | Booth teardown + hardware collection + departures |

## Work Schedule (At the competition)

A lightweight coordination system for our 4-person technical unit.

### 🧭 1. Sector Responsibility

Each member covers one sector to avoid duplication and maintain high situational awareness.  
Roles rotate depending on the task.

### **Sectors:**
- 🖥️ **Benchmark Operator** – Runs HPL/HPCG/HPCC or other tests  
- 📊 **System Monitor** – Watches Slurm, logs, utilisation, bottlenecks  
- 📝 **Documentation Lead** – Records configs, outputs, issues, and results  
- 🎙️ **Comms / Judge Liaison** – Handles updates, clarifications, and questions  

### **Rules:**
- Only **one person** runs a benchmark at a time.  
- Others support by monitoring, documenting, or communicating.

## 📡 2. 3-Level Communication Protocol

Fast, concise, military-style communication.

### **Level 1 — Activity Callouts**
Short, direct announcements when starting or performing actions.  
Examples:
- “Running xHPL”
- “Rebooting compute01”
- “Collecting logs”

### **Level 2 — Status Updates**
Clear indication of outcomes.  
Examples:
- “Successful run”
- “Error: Node timeout”
- “CPU bottleneck on node02”

### **Level 3 — Confirmed Communication**
Acknowledging received info.  
Examples:
- “Copy”
- “Loud and clear”
- “Received”

## 🔄 3. Workflow Movement (Rotation & Verification)

Ensures accuracy, reduces mistakes, and speeds up debugging.

- **Person A** runs the benchmark  
- **Person B** verifies results (fresh eyes)  
- **Person C** monitors system health  
- **Person D** documents + communicates  
- Roles **rotate every cycle** so everyone stays aligned  

This reinforces continuous awareness, redundancy, and team cohesion.

---

## Components and Hardware Checklist


---

## 📘 Project Timeline (20 - 29 November)

### **Tutorial 1**
- Team Workflow  
- SSH & System Access — ✅  
- Package Management & Compiler Setup — ✅  
- HPL Source Compilation — ✅  

### **Tutorial 2**
- Configure Stateful Firewall — ✅  
- Implement basic `nftables` / `iptables` ruleset — SSH kept open — ✅  
- Time Sync: install & configure **chrony** — ✅  
- Establish Ansible Control Node — ✅  
- Create & Test Ansible Inventory — ✅  
- Develop Complete Playbook — ✅  
- Execute, Validate & Document — ✅  

Additional:
- User Account Management  
- ZeroTier Setup + Documentation  

### **Tutorial 3**
- LMOD  
- Build & Compile **OpenBLAS** + **OpenMPI** from source — ✅  
- Intel oneAPI Toolkits + Compiler Suite  
- LinPACK Theoretical Peak Performance  
- SLURM  
- Run benchmarks across all nodes  
- Hardware Topology  
- Hardware Checklist (Nina)  
- Application Profiling (VTune)  
- Optimizations  
  - HPCG  
  - GROMACS  
  - LAMMPS  
  - Qiskit  

### **Tutorial 4**
- Grafana  
- Benchmark Result Evaluation Documentation  


## **21 November (Friday)**  
- Reconstruct Rocky Linux environment  


## **22 November (Saturday) — Campus Build Day**
👉 **Test the following:**  
- SSH connectivity (public keys added)  
- Networking stack complete (Firewall, iptables, NTP)  
- Ansible Playbooks  
- **ZeroTier setup (critical)**  


## **23 November (Sunday)**  
- **SLURM configuration (major priority)**  
- Grafana Dashboard (Joey)  


## **24 November (Monday)**  
- Review progress & update next tasks  


## **25 November (Tuesday)**  
- **Fully functional Rocky build ready for benchmarking**  
- Submit results to mentors  


## **26–28 November (Wed–Fri)**  
### **OPTIMIZE. OPTIMIZE. OPTIMIZE.**  
- Performance tuning  
- Power optimizations  
- CPU binding & NUMA tuning  
- Benchmark validation  
- Mini Interview (Presentation Prep)  

## **29 November (Saturday)**  
🎉 **Arrival at Competition**  

---
# 🏁 Competition Day — Hardware Setup Checklist
- Network cabling  
- BIOS checks + power profiles  
- OS verification  
- Compiler modules  
- MPI environment  
- Benchmark dry-runs  
- Monitoring stack (Grafana/Prometheus)  
- Node health checks  

---
