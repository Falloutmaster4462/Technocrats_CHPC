# Rocky HPC Cluster Setup Documentation

## Table of Contents
1. [SSH & User Management](#ssh--user-management)  
2. [Firewall & Time Synchronization](#firewall--time-synchronization)  
3. [NFS (Network File Sharing) Setup](#nfs-network-file-sharing-setup)  
4. [Ansible Automation](#ansible-automation)  
5. [LMOD Modules](#lmod-modules)  
6. [Compiling OpenBLAS & OpenMPI](#compiling-openblas--openmpi)  
7. [SLURM Setup](#slurm-setup)  
9. [Benchmarks](#benchmarks)  

---
## 1. SSH & User Management

**SSH & ProxyJump – Quick Reference**

| **Task**                   | **Command**                                             | **Notes**                               |
|----------------------------|----------------------------------------------------------|-------------------------------------------|
| Basic SSH                  | `ssh user@headnode`                                      |                                           |
| SSH with ProxyJump         | `ssh -J user@headnode user@compute1`                     | Jump through headnode                     |
| SCP with ProxyJump         | `scp -o ProxyJump=user@headnode file user@compute:/dir` | Copy via headnode                         |
| Generate SSH key           | `ssh-keygen -t ed25519`                                  | Recommended key type                      |
| Copy SSH key to node       | `ssh-copy-id user@node`                                  | Enables passwordless login                |


**Head Node Access & ProxyJump**

```bash
ssh -i <ssh_key> -J <user>@<headnode_ip> <user>@<compute_ip>
```

**Password Setup (Fallback)**

```bash
sudo passwd <username>
```

**SSH Key Generation**

```bash
ssh-keygen -t ed25519

ssh-copy-id -i ~/.ssh/ansible_key.pub rocky@10.0.0.51
ssh-copy-id -i ~/.ssh/ansible_key.pub rocky@10.0.0.52
```

**/etc/hosts Setup**

Add hostnames for all nodes:

```
<headnode_ip>     <headnode_name>
<compute_ip>      <compute_node_name>
```

**Package Management - Install TMUX & BTOP**

```bash
sudo dnf update -y
sudo dnf install -y tmux btop
```

### TMUX Quick Reference

* Start: `tmux new -s mysession`
* Detach: `Ctrl+b then d`
* Reattach: `tmux attach -t mysession`

---

## 2. Firewall & Time Synchronization

* Configure **nftables/iptables** to allow SSH.
* Install **chrony** to synchronize time across nodes:

```bash
sudo dnf install -y chrony
sudo systemctl enable --now chronyd
```

---

## 3. NFS (Network File Sharing) Setup

**Head Node (Server)**

```bash
sudo dnf install -y nfs-utils
sudo mkdir -p /shared
sudo chmod 755 /shared
```

**Configure Exports**

```bash
sudo nano /etc/exports
```

```
/shared 10.0.0.28(rw,sync,no_root_squash,no_subtree_check)
/shared 10.0.0.80(rw,sync,no_root_squash,no_subtree_check)
```

**Start & Enable NFS Services**

```bash
sudo systemctl enable --now nfs-server rpcbind
sudo exportfs -arv
sudo firewall-cmd --permanent --add-service={nfs,rpc-bind,mountd}
sudo firewall-cmd --reload
```

#### Compute Nodes (Clients)

```bash
sudo dnf install -y nfs-utils
sudo mkdir -p /shared
sudo mount -t nfs 10.0.0.10:/shared /shared
echo "10.0.0.10:/shared /shared nfs defaults 0 0" | sudo tee -a /etc/fstab
df -h | grep shared
```

### Test NFS

```bash
echo "Hello from Headnode" | sudo tee /shared/test.txt
cat /shared/test.txt  # Should appear on compute nodes
```

---

## 4. Ansible Automation

**Install Ansible on the control node:**

```bash
sudo dnf install epel-release -y

sudo dnf install -y ansible
```

**Create an inventory file listing all nodes.**

**Created a simple inventory file /etc/ansible/hosts:**
```
sudo mkdir -p /etc/ansible
sudo nano /etc/ansible/hosts
```

**Check public keys available**
``` ls -l ~/.ssh/*.pub ```

**Copy key ids to the other compute nodes(shouldn't have to if NFS is enabled**
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub rocky@<compute1_ip>
ssh-copy-id -i ~/.ssh/id_ed25519.pub rocky@<compute2_ip>
```

**Test ssh using this key**
```
ssh -i ~/.ssh/id_ed25519 rocky@10.0.0.162
ssh -i ~/.ssh/id_ed25519 rocky@10.0.0.94

```
**Edit /etc/ansible/hosts**
```
[compute]
compute01 ansible_host=10.0.0.51
compute02 ansible_host=10.0.0.52

[compute:vars]
ansible_user=rocky
ansible_ssh_private_key_file=/home/rocky/.ssh/id_ed25519 

```
** Generated an SSH key pair and copied the public key to the compute nodes:**

Joey will do this with ssh scripts

** Test connectivity using:
**
```bash
ansible all -m ping
```
```
compute01 | SUCCESS => {"changed": false, "ping": "pong"}
compute02 | SUCCESS => {"changed": false, "ping": "pong"}
```

✅ This confirms:
- Inventory is correct
- SSH keys work
- Nodes are reachable

**Develop playbooks to automate cluster setup and package installation.**
```
mkdir -p ~/ansible/playbooks
cd ~/ansible/playbooks
```
**Developed a master playbook cluster_setup.yml
**
<details>
<summary><h2>cluster_setup.yml (Version 1)</h2></summary>

```
  ---
- name: Configure HPC Headnode
  hosts: headnode
  become: yes
  vars:
    module_root: "/opt/modules"
  tasks:
    #########################################################
    # 1. Install core packages including LMOD
    #########################################################
    - name: Install core packages and LMOD on headnode
      dnf:
        name:
          - chrony
          - Lmod
          - wget
          - make
          - gcc
          - gcc-c++
          - gcc-gfortran
          - git
          - nftables
          - lua
          - lua-posix
          - tcl
          - tcl-devel
        state: present

    #########################################################
    # 2. Configure Chrony as NTP server
    #########################################################
    - name: Allow local network to sync
      lineinfile:
        path: /etc/chrony.conf
        line: "allow 10.0.0.0/24"
        create: yes

    - name: Ensure chronyd is running
      systemd:
        name: chronyd
        enabled: yes
        state: started

    #########################################################
    # 3. LMOD setup
    #########################################################
    - name: Add LMOD initialization script
      copy:
        dest: /etc/profile.d/lmod.sh
        mode: '0755'
        content: |
          # Enable LMOD (custom HPC cluster)
          export MODULEPATH=/opt/modules:$MODULEPATH
          source /usr/share/lmod/lmod/init/bash

    #########################################################
    # 4. Create module root directory
    #########################################################
    - name: Create module root directory
      file:
        path: "{{ module_root }}"
        state: directory
        mode: '0755'

    #########################################################
    # 5. Create shared directory for cluster storage
    #########################################################
    - name: Create shared HPC directory
      file:
        path: /shared
        state: directory
        mode: '0775'

- name: Configure HPC Compute Nodes
  hosts: compute
  become: yes
  vars:
    headnode_ip: "10.0.0.80"
    module_root: "/opt/modules"
  tasks:
    #########################################################
    # 1. Install core packages including LMOD
    #########################################################
    - name: Install core utilities and dependencies
      dnf:
        name:
          - chrony
          - openmpi
          - openmpi-devel
          - atlas
          - atlas-devel
          - wget
          - make
          - gcc
          - gcc-c++
          - gcc-gfortran
          - git
          - nftables
          - Lmod
          - lua
          - lua-posix
          - tcl
          - tcl-devel
        state: present

    #########################################################
    # 2. Configure Chrony to sync from headnode
    #########################################################
    - name: Remove default chrony pool entries
      lineinfile:
        path: /etc/chrony.conf
        regexp: '^pool '
        state: absent

    - name: Add headnode as primary NTP server
      lineinfile:
        path: /etc/chrony.conf
        line: "server {{ headnode_ip }} iburst"
        create: yes
      notify: restart chrony

    - name: Ensure chronyd is running
      systemd:
        name: chronyd
        enabled: yes
        state: started

    #########################################################
    # 3. Configure nftables
    #########################################################
    - name: Ensure nftables is enabled and running
      systemd:
        name: nftables
        state: started
        enabled: yes

    #########################################################
    # 4. Create module root and deploy MPI modulefile
    #########################################################
    - name: Create module root directory
      file:
        path: "{{ module_root }}/mpi"
        state: directory
        mode: '0755'

    - name: Create OpenMPI modulefile
      copy:
        dest: "{{ module_root }}/mpi/openmpi.lua"
        mode: '0644'
        content: |
          help([[
          OpenMPI module autogenerated by Ansible
          ]])

          whatis("Name: OpenMPI")
          whatis("Version: system")
          whatis("Description: System-installed OpenMPI")

          prepend_path("PATH", "/usr/lib64/openmpi/bin")
          prepend_path("LD_LIBRARY_PATH", "/usr/lib64/openmpi/lib")

    #########################################################
    # 5. Make LMOD available in /etc/profile.d
    #########################################################
    - name: Add LMOD initialization script
      copy:
        dest: /etc/profile.d/lmod.sh
        mode: '0755'
        content: |
          # Enable LMOD (custom HPC cluster)
          export MODULEPATH=/opt/modules:/opt/modules/mpi:$MODULEPATH
          source /usr/share/lmod/lmod/init/bash

    #########################################################
    # 6. Create shared directory for cluster storage
    #########################################################
    - name: Create shared compute directory
      file:
        path: /shared
        state: directory
        mode: '0775'

  #########################################################
  # HANDLERS
  #########################################################
  handlers:
    - name: restart chrony
      systemd:
        name: chronyd
        state: restarted

    - name: restart network
      systemd:
        name: network
        state: restarted

    - name: restart nftables
      systemd:
        name: nftables
        state: restarted

```
</details>

<details>
<summary><h2>cluster_setup.yml (Version 2):</h2></summary>

```
- name: Configure HPC Compute Nodes
  hosts: compute
  become: yes

  vars:
    headnode_ip: "<headnode_ip>"
    module_root: "/opt/modules"

  tasks:

    #########################################################
    # 1. Install core packages, build tools, MPI, LMOD
    #########################################################
    - name: Install core utilities and dependencies
      dnf:
        name:
          - chrony
          - openmpi
          - openmpi-devel
          - atlas
          - atlas-devel
          - wget
          - make
          - gcc
          - gcc-c++
          - gcc-gfortran
          - git
          - nftables
          - Lmod
          - lua
          - lua-posix
          - tcl
          - tcl-devel
        state: present

    #########################################################
    # 2. Configure Chrony (NTP) to sync from head node
    #########################################################
    - name: Remove default chrony pool entries
      lineinfile:
        path: /etc/chrony.conf
        regexp: '^pool '
        state: absent

    - name: Add headnode as primary NTP server
      lineinfile:
        path: /etc/chrony.conf
        line: "server {{ headnode_ip }} iburst"
        create: yes
      notify: restart chrony

    - name: Ensure chronyd is enabled and running
      systemd:
        name: chronyd
        enabled: yes
        state: started

    #########################################################
    # 3. Configure static route via head node
    #########################################################
    - name: Set default route via head node
      lineinfile:
        path: /etc/sysconfig/network-scripts/ifcfg-eth1
        regexp: "^GATEWAY="
        line: "GATEWAY={{ headnode_ip }}"
      notify: restart network

    #########################################################
    # 4. Configure NFTABLES basic HPC rules
    #########################################################
    - name: Ensure nftables is enabled and running
      systemd:
        name: nftables
        state: started
        enabled: yes
    
    #########################################################
    # 5. Create module root and deploy MPI modulefile
    #########################################################
    - name: Create module root directory
      file:
        path: "{{ module_root }}/mpi"
        state: directory
        mode: '0755'

    - name: Create OpenMPI modulefile
      copy:
        dest: "{{ module_root }}/mpi/openmpi.lua"
        mode: '0644'
        content: |
          help([[
          OpenMPI module autogenerated by Ansible
          ]])

          whatis("Name: OpenMPI")
          whatis("Version: system")
          whatis("Description: System-installed OpenMPI")

          prepend_path("PATH", "/usr/lib64/openmpi/bin")
          prepend_path("LD_LIBRARY_PATH", "/usr/lib64/openmpi/lib")

    #########################################################
    # 6. Make LMOD available in /etc/profile.d
    #########################################################
    - name: Add LMOD initialization script
      copy:
        dest: /etc/profile.d/lmod.sh
        mode: '0755'
        content: |
          # Enable LMOD
          export MODULEPATH={{ module_root }}:$MODULEPATH
          source /usr/share/lmod/lmod/init/bash

  #########################################################
  # HANDLERS
  #########################################################
  handlers:
    - name: restart chrony
      systemd:
        name: chronyd
        state: restarted

    - name: restart network
      systemd:
        name: network
        state: restarted

    - name: restart nftables
      systemd:
        name: nftables
        state: restarted

```
</details>

**Executed the playbook to configure the nodes:**

Dry Run
```
ansible-playbook setup.yml --check --diff -i /etc/ansible/hosts

ansible-playbook setup.yml --check
```

Official Run 
```
ansible-playbook -i /etc/ansible/hosts setup.yml
```

Test:



**Ansible – Quick Reference**

| **Task**              | **Command**                                  | **Notes**                                       |
|-----------------------|-----------------------------------------------|-------------------------------------------------|
| Install Ansible       | `sudo dnf install ansible`                    | Rocky Linux 8/9                                 |
| Check ansible version | `ansible --version`                           |                                                 |
| Test connection       | `ansible all -m ping -i hosts`                | Inventory file required                         |
| Run playbook          | `ansible-playbook play.yaml -i hosts`         |                                                 |
| Dry-run test          | `ansible-playbook play.yaml --check`          | No changes applied                              |
| Ad-hoc command        | `ansible all -i hosts -m command -a "uptime"` | Runs a one-liner on all nodes                   |

---

## 6. LMOD Modules

* Create `.lua` files for MPI and benchmarks.
* Load modules dynamically on compute nodes using:

```bash
module load <module>
```
**LMOD Module System – Quick Reference**

| **Task**             | **Command**                     | **Notes**                               |
|----------------------|----------------------------------|-----------------------------------------|
| List available mods  | `module avail`                  | Shows all modules                       |
| Load module          | `module load <module>`          | ex: `module load openmpi`               |
| Unload module        | `module unload <module>`        |                                         |
| List loaded modules  | `module list`                   |                                         |
| Search module        | `module spider <name>`          | Helps find versions & instructions      |
| Clear all modules    | `module purge`                  | Good before building software           |

---

## 7. Compiling OpenBLAS & OpenMPI

* Install **Intel oneAPI toolkits** for optimized compilation.
* Build **OpenBLAS** and **OpenMPI** from source.
* Install binaries in `/HPC_scripts/benchmarks/`.

---

## 8. SLURM Setup

* Configure **slurm.conf** for head and compute nodes.
* Set partitions and node resources.
* Submit test jobs using `.sbatch` scripts.

**Slurm Job Management – Quick Reference**

| **Task**            | **Command**                | **Notes**                                 |
|---------------------|----------------------------|---------------------------------------------|
| Submit job          | `sbatch job_script.sh`     | Script must contain `#SBATCH` directives   |
| Interactive job     | `srun --pty bash`          | Useful for testing/interactive sessions    |
| Check job status    | `squeue -u $USER`          | Shows only your jobs                       |
| Cancel job          | `scancel <job_id>`         | Terminates a running or pending job        |
| View node info      | `sinfo`                    | Lists partitions and node states           |
| Job logs            | `cat slurm-<job_id>.out`   | Default output log from Slurm              |


---

## 9. Grafana Monitoring

* Install **Prometheus + Grafana** on the head node.
* Configure exporters to monitor node performance.
* Set dashboards for CPU, memory, network, and job statistics.

---

## 10. Benchmarks (Order of Setup)

1. HPCC
2. HPCG
3. AMBERMD
4. ASCOT5
5. DFTB+
6. MATLAB
7. OpenFOAM

**Benchmarking – Quick Reference**

| **Benchmark** | **How to Run**                         | **Notes**                                      |
|---------------|----------------------------------------|------------------------------------------------|
| HPL           | `sbatch run_hpl.slurm`                 | Needs correct HPL.dat + BLAS/MPI modules       |
| HPCG          | `sbatch run_hpcg.slurm`                | CPU-intensive, tests memory & compute          |
| HPCC          | `sbatch run_hpcc.slurm`                | Includes DGEMM, FFT, STREAM                    |
| STREAM        | `sbatch run_stream.slurm`              | Memory bandwidth test                          |
| IMB/OSU       | `sbatch run_imb.slurm`                 | MPI latency/bandwidth                          |

**Each benchmark should include:**

* Slurm job scripts: `benchmarks/<benchmark>/slurm`
* Config files: `benchmarks/<benchmark>/config`
* Dataset inputs: `/HPC_scripts/datasets/<benchmark>`
* Results: `/HPC_scripts/results/<benchmark>`

## Useful Commands for Linux

**Disk Usage – Quick Reference**

| **Task**               | **Command**                                     | **Notes**                             |
|------------------------|--------------------------------------------------|---------------------------------------|
| Check disk space       | `df -h`                                          | Human-readable                        |
| Directory size summary | `du -sh /path/*`                                 | Summaries of all subdirs              |
| Find large files       | `du -ah ~ | sort -hr | head -20`                 | Most common space-debug command       |
| Check inode usage      | `df -i`                                          | Useful when disk "full" but space left |

---

