# Technocrats Nationals Preparation

**Repository Overview:**
This repository contains all code, scripts, documentation, and reports for our preparation for the HPC Nationals competition. It serves as our single source of truth for configurations, benchmarks, and team coordination.

---

## 🗓️ Meeting Schedule

| Day          | Time           | Mode       | Focus                                                               |
| :----------- | :------------- | :--------- | :------------------------------------------------------------------ |
| **Tuesday**  | 1:00 PM        | In-Person  | Hands-on labs, hardware work, deep-dive technical sessions.         |
| **Friday**   | 7:00 PM        | Online     | Weekly sync, code reviews, planning, and conceptual discussions.    |

*Attendance is mandatory. Please notify the team lead in advance if you cannot make a meeting.*

---

## 🚀 Sprint 1: Foundation & Tutorials (August - September)

The goal of this sprint is to solidify our understanding of the core HPC concepts covered in the initial tutorials and establish our team workflows.

### Weekly Breakdown

### Weekly Schedule & Progress

| Week | Dates | Topic | Tasks & Assignments |
| :--- | :--- | :--- | :--- |
| **1** | Aug 25 - 29 | **Tutorial 1 & 2** | **Hardware:** Document design pros/cons.<br>**Nina:** SSH, Package Mgmt, NixOS, HPL Compilation.<br>**Joey:** `nftables` Firewall, `chrony` NTP. |
| **2** | Sept 1 - 5 | **Tutorial 2 Part 2** | **Jazeel:** NFS, User Accounts.<br>**Nicoroy:** Ansible Control Node, Inventory, Playbook. |
| **3** | Sept 8 - 12 | **Tutorial 2 & 3 (Part 1)** | **Joey:** User Mgmt, ZeroTier VPN.<br>**Nicoroy & Nina:** LMOD, Build OpenBLAS/OpenMPI. |
| **4** | Sept 15 - 19 | **Tutorial 3 (Part 2)** | **Nina:** Intel oneAPI, LinPACK Perf, Final Design.<br>**Jazeel:** Hardware Topology, Vtune Profiling. |
| **5** | Sept 22 - 26 | **Tutorial 3 (Part 3)** | **TBD:** HPCG, GROMACS, LAMMPS, Qiskit. |
| **6** | Sept 29 - Oct 3 | **Tutorial 4 (Part 2)** | *Content to be evaluated closer to the time.* |

---

## 👥 Team Roles & Responsibilities

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


