#!/bin/bash
# install_ascot5_cluster.sh
# ASCOT5 Automated Installation for Cluster (NFS Shared Directory)
set -e

echo "=== ASCOT5 Cluster Installation ==="
echo "Installing to shared directory: /shared/benchmarks/ascot5"
echo "Cluster nodes: headnode, com1, com2"

# Configuration
SHARED_DIR="/shared/benchmarks"
INSTALL_DIR="$SHARED_DIR/ascot5"
VENV_DIR="$SHARED_DIR/ascot5-env"

echo "Installation directory: $INSTALL_DIR"
echo "Virtual environment: $VENV_DIR"

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ Failed: $1"
        exit 1
    fi
}

# Install dependencies on all nodes
echo "=== Installing Dependencies on All Nodes ==="
for node in headnode com1 com2; do
    echo "Installing on $node..."
    ssh $node "sudo dnf groupinstall -y 'Development Tools' && \
               sudo dnf install -y cmake python3.11 python3.11-devel python3.11-pip \
               openmpi openmpi-devel hdf5 hdf5-devel hdf5-openmpi git wget"
done

# Download ASCOT5 source code to shared directory
echo "=== Downloading ASCOT5 Source Code ==="
cd "$SHARED_DIR"
if [ -d "$INSTALL_DIR" ]; then
    echo "ASCOT5 directory exists, cleaning..."
    rm -rf "$INSTALL_DIR"
fi

git clone https://github.com/ascot4fusion/ascot5.git "$INSTALL_DIR"
check_success "Cloned ASCOT5 repository"

cd "$INSTALL_DIR"

# Build ASCOT5 library with MPI support
echo "=== Building ASCOT5 Library ==="
make libascot -j 92 MPI=1  # Use all cluster cores
check_success "Built ASCOT5 library"

# Verify library was created
if [ -f "build/libascot.so" ]; then
    echo "✓ Library created successfully"
    ls -lh build/libascot.so
else
    echo "✗ Library not found"
    exit 1
fi

# Build main executable
echo "=== Building ASCOT5 Main Executable ==="
make ascot5_main -j 92 MPI=1
check_success "Built ASCOT5 main executable"

# Verify executable was created
if [ -f "build/ascot5_main" ]; then
    echo "✓ Executable created successfully"
    ls -lh build/ascot5_main
else
    echo "✗ Executable not found"
    exit 1
fi

# Install Python interface in shared location
echo "=== Installing Python Interface ==="

# Remove old virtual environment if exists
if [ -d "$VENV_DIR" ]; then
    rm -rf "$VENV_DIR"
fi

# Use Python 3.11 for virtual environment
python3.11 -m venv "$VENV_DIR"
check_success "Created virtual environment"

source "$VENV_DIR/bin/activate"
check_success "Activated virtual environment"

# Install Python packages
pip install --upgrade pip
pip install wheel setuptools

# Install a5py with dependency resolution
pip install -e . --use-pep517
check_success "Installed a5py package"

pip install numpy scipy matplotlib h5py ipython pandas
check_success "Installed Python dependencies"

# Verify Python installation
python -c "from a5py import Ascot; print('✓ a5py installed successfully')"
check_success "Verified Python installation"

# Create hostfile
echo "=== Creating MPI Hostfile ==="
cat > "$SHARED_DIR/hostfile" << EOF
# ASCOT5 Cluster MPI Hostfile
# headnode: 28 cores (32 total - 4 for system)
# com1: 32 cores
# com2: 32 cores
# Total: 92 cores

headnode slots=28
com1 slots=32
com2 slots=32
EOF

echo "Hostfile created: $SHARED_DIR/hostfile"
cat "$SHARED_DIR/hostfile"

echo ""
echo "=== Installation Complete ==="
echo "ASCOT5 is now installed on the cluster"
echo "Shared directory: $SHARED_DIR"
echo "Run benchmarks with: bash $SHARED_DIR/run_benchmarks_cluster.sh"
echo ""
echo "Cluster Configuration:"
echo "  headnode: 28 compute cores"
echo "  com1: 32 compute cores"
echo "  com2: 32 compute cores"
echo "  Total: 92 MPI processes"
