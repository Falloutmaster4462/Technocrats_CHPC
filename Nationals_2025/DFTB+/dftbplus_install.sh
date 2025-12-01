#!/bin/bash
#
# DFTB+ Installation Script for Rocky Linux 9
# Run this script on head node, com1, and com2
# Usage: sudo bash install_dftbplus.sh
#

set -e

echo "=========================================="
echo "DFTB+ Installation Script for Rocky Linux 9"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Disable problematic HPCC Systems repo if it exists
if [ -f /etc/yum.repos.d/hpccsystems.repo ]; then
    echo "Disabling conflicting HPCC Systems repository..."
    sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/hpccsystems.repo
fi

# Update system
echo "[1/6] Updating system packages..."
dnf update -y --skip-broken

# Install development tools and dependencies
echo "[2/6] Installing development tools and dependencies..."
dnf groupinstall -y "Development Tools"
dnf install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    make \
    cmake \
    git \
    wget \
    python3 \
    python3-pip \
    openmpi \
    openmpi-devel \
    openblas \
    openblas-devel \
    lapack \
    lapack-devel \
    scalapack-openmpi \
    scalapack-openmpi-devel

# Load OpenMPI module
echo "[3/6] Setting up OpenMPI environment..."
export PATH=/usr/lib64/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH

# Add OpenMPI to profile (permanent)
if [ ! -f /etc/profile.d/openmpi.sh ]; then
    cat > /etc/profile.d/openmpi.sh << 'EOF'
export PATH=/usr/lib64/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH
EOF
    chmod +x /etc/profile.d/openmpi.sh
fi

# Create installation directory
INSTALL_DIR="/opt/dftbplus"
BUILD_DIR="/tmp/dftbplus-build"
mkdir -p $INSTALL_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Clone DFTB+ repository
echo "[4/6] Cloning DFTB+ repository..."
if [ -d "dftbplus" ]; then
    echo "DFTB+ directory already exists. Removing..."
    rm -rf dftbplus
fi

git clone https://github.com/dftbplus/dftbplus.git
cd dftbplus

# Get the latest stable release
echo "Checking out latest stable release..."
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
git checkout $LATEST_TAG

# Create build directory
mkdir -p _build
cd _build

# Configure DFTB+ with CMake
echo "[5/6] Configuring DFTB+ with CMake..."
cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
      -DCMAKE_BUILD_TYPE=Release \
      -DWITH_MPI=ON \
      -DWITH_OMP=ON \
      -DCMAKE_C_COMPILER=mpicc \
      -DCMAKE_CXX_COMPILER=mpicxx \
      -DCMAKE_Fortran_COMPILER=mpifort \
      -DSCALAPACK_LIBRARY=/usr/lib64/openmpi/lib/libscalapack.so \
      -DLAPACK_LIBRARY=/usr/lib64/libopenblas.so \
      ..

# Build DFTB+
echo "[6/6] Building DFTB+ (this may take 10-20 minutes)..."
make -j$(nproc)

# Install DFTB+
echo "Installing DFTB+..."
make install

# Create symbolic links in /usr/local/bin
ln -sf $INSTALL_DIR/bin/dftb+ /usr/local/bin/dftb+

# Verify installation
if [ -f "$INSTALL_DIR/bin/dftb+" ]; then
    echo ""
    echo "=========================================="
    echo "DFTB+ Installation Complete!"
    echo "=========================================="
    echo ""
    echo "DFTB+ binary location: $INSTALL_DIR/bin/dftb+"
    echo "Symbolic link created: /usr/local/bin/dftb+"
    echo ""
    echo "Test installation with: dftb+ --version"
    echo ""
    echo "Note: You will need Slater-Koster parameter sets to run calculations."
    echo "Download from: https://dftb.org/parameters/download"
    echo ""
    
    # Clean up build directory
    echo "Cleaning up build directory..."
    cd /
    rm -rf $BUILD_DIR
    
else
    echo ""
    echo "=========================================="
    echo "ERROR: DFTB+ build failed!"
    echo "=========================================="
    echo "Build directory preserved at: $BUILD_DIR"
    exit 1
fi

echo "Note: Run this script on all nodes (head, com1, com2)"
echo ""
