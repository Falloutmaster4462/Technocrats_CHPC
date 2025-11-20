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

## 🚀 Sprint 2: Foundation & Tutorials (20 Nov - 29 Nov)

Have a fully functional, optimized, production-ready HPC cluster that can run all required benchmarks reliably and efficiently.

| Week | Dates | Topic | Tasks & Assignments |
| :--- | :--- | :--- | :--- |
| **1** | **Nov 20 (Thu)** | **Tutorial 1 & 2** | **Docs:** Start repo documentation.<br>**SSH/Compile:** SSH Access ✅, Package Mgmt & Compiler Setup ✅, HPL Compilation ✅.<br>**Firewall/NTP:** Stateful firewall ✅, iptables/nftables ruleset ✅, chrony time sync ✅.<br>**Ansible:** Control Node, Inventory, Playbook Dev + Execution ✅.<br>**Pending:** User Accounts, ZeroTier Setup. |
| **2** | **Nov 21 (Fri)** | **System Rebuild** | Reconstruct Rocky Linux environment from scratch. |
| **3** | **Nov 22 (Sat)** | **Full Campus Build Day** | Meet on campus.<br>Test SSH keys, Networking (Firewall/NTP), Ansible Playbooks.<br>**Critical:** ZeroTier setup. |
| **4** | **Nov 23 (Sun)** | **SLURM + Monitoring** | SLURM Completion (#1).<br>Grafana Dashboard setup (Joey). |
| **5** | **Nov 24 (Mon–Tue)** | **Rocky Finalization** | Evaluate progress & next tasks.<br>Fully functional Rocky build ready for benchmarks.<br>Submit to mentors. |
| **6** | **Nov 25–28 (Wed–Sat)** | **Optimization & Prep** | System + Benchmark Optimization!!!<br>Mini Interview Preparation.<br>HPC tuning & final system checks. |
| **7** | **Nov 29 (Sun)** | **Competition Arrival** | Travel to venue & settle in. |

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



