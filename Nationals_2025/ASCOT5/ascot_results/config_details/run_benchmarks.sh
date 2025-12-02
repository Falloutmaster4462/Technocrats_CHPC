#!/bin/bash
# run_benchmarks_cluster.sh
# ASCOT5 Cluster Benchmarking Script
set -e

echo "=== ASCOT5 Cluster Benchmarking ==="
echo "Running across: headnode, com1, com2"
echo "Using shared directory: /shared/benchmarks"

# Configuration
SHARED_DIR="/shared/benchmarks"
INSTALL_DIR="$SHARED_DIR/ascot5"
VENV_DIR="$SHARED_DIR/ascot5-env"
HOSTFILE="$SHARED_DIR/hostfile"
TOTAL_PROCS=92  # 28 + 32 + 32
# Directory where benchmark scripts are located
BENCHMARK_SCRIPTS_DIR="/shared/benchmarks/ascotfive/multi"

# Network configuration for MPI
CLUSTER_NETWORK="192.168.0.0/24"

echo "Total MPI processes: $TOTAL_PROCS"
echo "Hostfile: $HOSTFILE"
echo "Benchmark scripts directory: $BENCHMARK_SCRIPTS_DIR"
echo "Cluster network: $CLUSTER_NETWORK"

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ Failed: $1"
        exit 1
    fi
}

# Function to check file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "✗ Required file not found: $1"
        return 1
    else
        echo "✓ Found: $1"
        return 0
    fi
}

# Function to test network connectivity
test_network_connectivity() {
    echo "=== Testing Network Connectivity ==="
    for node in com1 com2; do
        echo "Testing connectivity to $node..."
        ping -c 2 $node > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✓ $node is reachable"
        else
            echo "✗ Cannot reach $node"
            return 1
        fi
    done
    return 0
}

# Activate virtual environment from shared directory
echo "=== Activating Python Environment ==="
if [ ! -d "$VENV_DIR" ]; then
    echo "✗ Virtual environment not found: $VENV_DIR"
    echo "Please run the installation script first"
    exit 1
fi
source "$VENV_DIR/bin/activate"
check_success "Activated virtual environment"

# Verify ASCOT5 installation
echo "=== Verifying ASCOT5 Installation ==="
if [ -f "$INSTALL_DIR/build/ascot5_main" ]; then
    echo "✓ ASCOT5 executable found"
    ls -lh "$INSTALL_DIR/build/ascot5_main"
else
    echo "✗ ASCOT5 executable not found"
    exit 1
fi

# Test network connectivity
if ! test_network_connectivity; then
    echo "⚠ Network connectivity issues detected"
    echo "Checking /etc/hosts entries..."
    cat /etc/hosts | grep -E "(headnode|com1|com2)"
    exit 1
fi

# Test MPI connectivity across cluster
echo "=== Testing MPI Across Cluster ==="
cd "$SHARED_DIR"
mpirun --hostfile $HOSTFILE -np 3 \
    --mca btl tcp,self \
    --mca btl_tcp_if_include $CLUSTER_NETWORK \
    --mca pml ob1 \
    hostname
if [ $? -eq 0 ]; then
    echo "✓ MPI cluster connectivity verified"
else
    echo "✗ MPI cluster test failed"
    echo "Testing with simpler configuration..."
    
    # Try simpler MPI test
    mpirun --hostfile $HOSTFILE -np 3 \
        --mca btl ^openib \
        --mca btl ^ucx \
        --mca pml ob1 \
        hostname
    if [ $? -eq 0 ]; then
        echo "✓ MPI cluster connectivity verified (simple mode)"
    else
        echo "✗ MPI cluster test failed even in simple mode"
        echo "Testing individual nodes..."
        for node in headnode com1 com2; do
            echo "Testing $node..."
            ssh $node "hostname"
        done
        exit 1
    fi
fi

# Arrays to track which benchmarks were completed
COMPLETED_BENCHMARKS=()
START_TIME=$(date +%s)

# Change to directory where benchmark scripts are located
cd "$BENCHMARK_SCRIPTS_DIR"
echo "Changed to benchmark directory: $(pwd)"

# Function to run MPI simulation with proper network config
run_mpi_simulation() {
    local input_file=$1
    local description=$2
    local log_file="mpi_${input_file%.h5}_$(date +%Y%m%d_%H%M%S).log"
    
    echo "=== Running MPI Simulation ==="
    echo "Input: $input_file"
    echo "Description: $description"
    echo "MPI processes: $TOTAL_PROCS"
    echo "Start time: $(date)"
    echo "Log file: $log_file"
    
    # Run MPI with TCP transport to avoid UCX issues
    mpirun --hostfile $HOSTFILE \
           -np $TOTAL_PROCS \
           --mca btl tcp,self \
           --mca btl_tcp_if_include $CLUSTER_NETWORK \
           --mca pml ob1 \
           --mca oob tcp \
           --mca orte_base_help_aggregate 0 \
           --mca btl_base_warn_component_unused 0 \
           --bind-to core \
           "$INSTALL_DIR/build/ascot5_main" \
           --in="$input_file" \
           --d="$description" 2>&1 | tee "$log_file"
    
    local status=$?
    
    if [ $status -eq 0 ]; then
        echo "✓ MPI simulation completed successfully"
        return 0
    else
        echo "✗ MPI simulation failed with exit code: $status"
        
        # Try alternative configuration without UCX
        echo "Trying alternative MPI configuration (no UCX, no openib)..."
        
        mpirun --hostfile $HOSTFILE \
               -np $TOTAL_PROCS \
               --mca btl ^openib \
               --mca btl ^ucx \
               --mca btl tcp,self \
               --mca btl_tcp_if_include $CLUSTER_NETWORK \
               --mca pml ob1 \
               "$INSTALL_DIR/build/ascot5_main" \
               --in="$input_file" \
               --d="$description" 2>&1 | tee "${log_file}.alt"
        
        if [ $? -eq 0 ]; then
            echo "✓ MPI simulation completed with alternative configuration"
            return 0
        else
            echo "✗ All MPI configurations failed"
            echo "Last 20 lines of log:"
            tail -20 "$log_file"
            return 1
        fi
    fi
}

# Benchmark 1 - 8,000 markers
echo ""
echo "=== BENCHMARK 1: 8,000 Markers (Cluster) ==="
BENCH1_START=$(date +%s)

if check_file_exists "setup_benchmark1.py"; then
    # Generate input file
    echo "=== Generating Benchmark 1 Input ==="
    python3 setup_benchmark1.py
    check_success "Generated benchmark1 input"
    
    # Verify input file was created
    echo "=== Verifying Benchmark 1 Input File ==="
    if [ -f "benchmark1.h5" ]; then
        echo "✓ Benchmark1 input file created"
        ls -lh benchmark1.h5
        
        # Run simulation on cluster
        if run_mpi_simulation "benchmark1.h5" "Benchmark1 - 8,000 markers (Cluster: $TOTAL_PROCS cores)"; then
            BENCH1_END=$(date +%s)
            BENCH1_TIME=$((BENCH1_END - BENCH1_START))
            echo "✓ Completed benchmark1 simulation"
            echo "  Duration: $BENCH1_TIME seconds"
            
            # Check if output was created
            if [ -f "ascot5.h5" ]; then
                echo "✓ Output file created: ascot5.h5"
                ls -lh ascot5.h5
                # Rename to avoid overwriting
                mv ascot5.h5 "benchmark1_output_$(date +%Y%m%d_%H%M%S).h5"
            fi
        else
            echo "✗ Benchmark1 simulation failed"
            # Don't exit - try benchmark 2
            echo "Continuing to benchmark 2..."
        fi
        
        # Verify results if verification script exists
        if check_file_exists "verify_benchmark1.py"; then
            echo "=== Verifying Benchmark 1 Results ==="
            python3 verify_benchmark1.py | tee benchmark1_verification.txt
            if [ $? -eq 0 ]; then
                check_success "Verified benchmark1 results"
                COMPLETED_BENCHMARKS+=("Benchmark1-8000")
            else
                echo "⚠ Benchmark1 verification had issues"
            fi
        else
            echo "⚠ Skipping Benchmark 1 verification - verify_benchmark1.py not found"
        fi
    else
        echo "✗ Benchmark1 input file missing after running setup_benchmark1.py"
    fi
else
    echo "⚠ Skipping Benchmark 1 - setup_benchmark1.py not found"
fi

# Benchmark 2 - 200,000 markers
echo ""
echo "=== BENCHMARK 2: 200,000 Markers (Cluster) ==="
BENCH2_START=$(date +%s)

if check_file_exists "setup_benchmark2.py"; then
    # Generate input file
    echo "=== Generating Benchmark 2 Input ==="
    python3 setup_benchmark2.py
    check_success "Generated benchmark2 input"
    
    # Verify input file was created
    echo "=== Verifying Benchmark 2 Input File ==="
    if [ -f "benchmark2.h5" ]; then
        echo "✓ Benchmark2 input file created"
        ls -lh benchmark2.h5
        
        # Run simulation on cluster
        if run_mpi_simulation "benchmark2.h5" "Benchmark2 - 200,000 markers (Cluster: $TOTAL_PROCS cores)"; then
            BENCH2_END=$(date +%s)
            BENCH2_TIME=$((BENCH2_END - BENCH2_START))
            echo "✓ Completed benchmark2 simulation"
            echo "  Duration: $BENCH2_TIME seconds"
            
            # Check if output was created
            if [ -f "ascot5.h5" ]; then
                echo "✓ Output file created: ascot5.h5"
                ls -lh ascot5.h5
                # Rename to avoid overwriting
                mv ascot5.h5 "benchmark2_output_$(date +%Y%m%d_%H%M%S).h5"
            fi
        else
            echo "✗ Benchmark2 simulation failed"
        fi
        
        # Verify results if verification script exists
        if check_file_exists "verify_benchmark2.py"; then
            echo "=== Verifying Benchmark 2 Results ==="
            python3 verify_benchmark2.py | tee benchmark2_verification.txt
            if [ $? -eq 0 ]; then
                check_success "Verified benchmark2 results"
                COMPLETED_BENCHMARKS+=("Benchmark2-200000")
            else
                echo "⚠ Benchmark2 verification had issues"
            fi
        else
            echo "⚠ Skipping Benchmark 2 verification - verify_benchmark2.py not found"
        fi
    else
        echo "✗ Benchmark2 input file missing after running setup_benchmark2.py"
    fi
else
    echo "⚠ Skipping Benchmark 2 - setup_benchmark2.py not found"
fi

# Performance summary
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

echo ""
echo "=== PERFORMANCE SUMMARY ==="
echo "Total execution time: $TOTAL_TIME seconds"
echo "Completed benchmarks: ${#COMPLETED_BENCHMARKS[@]}"
for bench in "${COMPLETED_BENCHMARKS[@]}"; do
    echo "  - $bench"
done

echo "MPI Configuration: $TOTAL_PROCS processes across 3-node cluster"
echo "Cluster Configuration:"
echo "  Nodes: 3 (headnode, com1, com2)"
echo "  Total cores: 92"
echo "  headnode: 28 cores"
echo "  com1: 32 cores"
echo "  com2: 32 cores"
echo "  Network: 10Gb Ethernet"
echo "  Transport: TCP (UCX disabled)"

# Create submission package only if we have completed benchmarks
echo ""
if [ ${#COMPLETED_BENCHMARKS[@]} -eq 0 ]; then
    echo "=== No benchmarks completed - skipping submission package ==="
    echo "Please ensure at least one setup_benchmark*.py file exists"
    exit 1
fi

echo "=== Creating Submission Package ==="
SUBMISSION_DIR="ascot5_cluster_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SUBMISSION_DIR"

# Copy available files
FILES_COPIED=()
if [ -f "benchmark1.h5" ]; then
    cp benchmark1.h5 "$SUBMISSION_DIR/"
    FILES_COPIED+=("benchmark1.h5")
fi
if [ -f "benchmark1_verification.txt" ]; then
    cp benchmark1_verification.txt "$SUBMISSION_DIR/"
    FILES_COPIED+=("benchmark1_verification.txt")
fi
if [ -f "benchmark2.h5" ]; then
    cp benchmark2.h5 "$SUBMISSION_DIR/"
    FILES_COPIED+=("benchmark2.h5")
fi
if [ -f "benchmark2_verification.txt" ]; then
    cp benchmark2_verification.txt "$SUBMISSION_DIR/"
    FILES_COPIED+=("benchmark2_verification.txt")
fi

# Copy benchmark scripts
cp setup_benchmark*.py verify_benchmark*.py "$SUBMISSION_DIR/" 2>/dev/null || true

# Copy output files (if renamed)
for file in benchmark*_output_*.h5; do
    if [ -f "$file" ]; then
        cp "$file" "$SUBMISSION_DIR/"
        FILES_COPIED+=("$file")
    fi
done

# Verify we have files to submit
if [ ${#FILES_COPIED[@]} -eq 0 ]; then
    echo "✗ No benchmark files available for submission"
    rm -rf "$SUBMISSION_DIR"
    exit 1
fi

echo "✓ Copied files to submission directory:"
for file in "${FILES_COPIED[@]}"; do
    echo "  - $file"
done

# Create cluster info file
if [ -z "$HOSTFILE" ]; then
    # Single-node fallback info
    cat > "$SUBMISSION_DIR/cluster_info.txt" << EOF
ASCOT5 Single-Node Benchmark Results
====================================
Generated: $(date)
Hostname: $(hostname)
CPU: Intel Xeon Gold 6448H (32 cores @ 2.4GHz)
Memory: 96GB DDR5-4800
Storage: 240GB SATA SSD

MPI Configuration:
  Processes: $TOTAL_PROCS
  Host: localhost (fallback mode)
  Note: Cluster MPI failed, running in single-node mode

Completed Benchmarks:
$(for bench in "${COMPLETED_BENCHMARKS[@]}"; do echo "  - $bench"; done)

Execution Times:
  Total: $TOTAL_TIME seconds
EOF
else
    # Cluster info
    cat > "$SUBMISSION_DIR/cluster_info.txt" << EOF
ASCOT5 Cluster Benchmark Results
================================
Generated: $(date)
Cluster Size: 3 nodes, 92 cores

Node Configuration:
  headnode (192.168.0.1): Intel Xeon Gold 6448H, 28 cores, 96GB RAM
  com1 (192.168.0.2): Intel Xeon Gold 6448H, 32 cores, 96GB RAM  
  com2 (192.168.0.3): Intel Xeon Gold 6448H, 32 cores, 96GB RAM

MPI Configuration:
  Total processes: 92
  Hostfile: $HOSTFILE
  Working directory: $BENCHMARK_SCRIPTS_DIR

Benchmarks Completed:
$(for bench in "${COMPLETED_BENCHMARKS[@]}"; do echo "  - $bench"; done)

Execution Times:
  Total: $TOTAL_TIME seconds
EOF
fi

# Create archive
tar -czf "${SUBMISSION_DIR}.tar.gz" "$SUBMISSION_DIR"
check_success "Created submission package"

echo ""
echo "=== ASCOT5 Cluster Benchmarking Complete ==="
if [ -z "$HOSTFILE" ]; then
    echo "✓ Host: $(hostname) (single-node fallback)"
    echo "✓ CPU: 32-core Intel Xeon Gold 6448H"
    echo "✓ Memory: 96GB"
else
    echo "✓ 3-node cluster: headnode, com1, com2"
    echo "✓ 92 total compute cores"
    echo "✓ 10Gb Ethernet interconnect"
    echo "✓ NFS shared storage: $SHARED_DIR"
fi
echo "✓ Completed benchmarks: ${#COMPLETED_BENCHMARKS[@]}"
for bench in "${COMPLETED_BENCHMARKS[@]}"; do
    echo "  - $bench"
done
echo "✓ Total time: $TOTAL_TIME seconds"
echo "✓ Submission package: ${SUBMISSION_DIR}.tar.gz"
echo ""
echo "To submit: Upload ${SUBMISSION_DIR}.tar.gz"
