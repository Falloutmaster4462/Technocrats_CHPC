#!/bin/bash
#
# HPCC (HPC Challenge) Installation Script for Rocky Linux 9
# Run this script on head node, com1, and com2
# Usage: sudo bash install_hpcc.sh
#

set -e

echo "=========================================="
echo "HPCC Installation Script for Rocky Linux 9"
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
    openmpi \
    openmpi-devel \
    blas \
    blas-devel \
    lapack \
    lapack-devel \
    atlas \
    atlas-devel \
    openblas \
    openblas-devel

# Load OpenMPI module
echo "[3/6] Setting up OpenMPI environment..."
export PATH=/usr/lib64/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH

# Add OpenMPI to profile (permanent)
cat > /etc/profile.d/openmpi.sh << 'EOF'
export PATH=/usr/lib64/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH
EOF

chmod +x /etc/profile.d/openmpi.sh

# Create installation directory
INSTALL_DIR="/opt/hpcc"
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Clone HPCC repository
echo "[4/6] Cloning HPCC repository..."
if [ -d "hpcc" ]; then
    echo "HPCC directory already exists. Removing..."
    rm -rf hpcc
fi

git clone https://github.com/icl-utk-edu/hpcc.git
cd hpcc

# Create hpl directory for configuration
mkdir -p hpl

# Copy and modify the Make.Linux_PII_CBLAS configuration
echo "[5/6] Creating Makefile configuration..."
cat > hpl/Make.Linux << EOF
SHELL        = /bin/sh
CD           = cd
CP           = cp
LN_S         = ln -s
MKDIR        = mkdir
RM           = /bin/rm -f
TOUCH        = touch
ARCH         = Linux
TOPdir       = $INSTALL_DIR/hpcc/hpl
INCdir       = \$(TOPdir)/include
BINdir       = \$(TOPdir)/bin/\$(ARCH)
LIBdir       = \$(TOPdir)/lib/\$(ARCH)
HPLlib       = \$(LIBdir)/libhpl.a 
LAdir        = /usr/lib64
LAinc        = 
LAlib        = -L\$(LAdir) -lopenblas -lgfortran -lm
F2CDEFS      = -DAdd_ -DF77_INTEGER=int -DStringSunStyle
HPL_INCLUDES = -I\$(INCdir) -I\$(INCdir)/\$(ARCH) \$(LAinc) \$(MPinc)
HPL_LIBS     = \$(HPLlib) \$(LAlib) \$(MPlib)
HPL_OPTS     = -DHPL_CALL_CBLAS
HPL_DEFS     = \$(F2CDEFS) \$(HPL_OPTS) \$(HPL_INCLUDES)
CC           = mpicc
CCNOOPT      = \$(HPL_DEFS)
CCFLAGS      = \$(HPL_DEFS) -fomit-frame-pointer -O3 -funroll-loops -W -Wall
LINKER       = mpif77
LINKFLAGS    = \$(CCFLAGS)
ARCHIVER     = ar
ARFLAGS      = r
RANLIB       = echo
EOF

# Build HPCC
echo "[6/6] Building HPCC (this may take several minutes)..."
make arch=Linux

# Verify installation
if [ -f "hpcc" ]; then
    echo ""
    echo "=========================================="
    echo "HPCC Installation Complete!"
    echo "=========================================="
    echo ""
    echo "HPCC binary location: $INSTALL_DIR/hpcc/hpcc"
    echo ""
    echo "Next steps:"
    echo "1. Create a hostfile listing your nodes"
    echo "2. Copy and configure _hpccinf.txt for your cluster"
    echo "3. Run HPCC with: mpirun -np <num_procs> -hostfile <hostfile> /opt/hpcc/hpcc/hpcc"
    echo ""
    echo "Example _hpccinf.txt will be created at: $INSTALL_DIR/hpcc/_hpccinf.txt.example"
    
    # Create example configuration file
    cat > $INSTALL_DIR/hpcc/_hpccinf.txt.example << 'EOFCONFIG'
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
10000        Ns
1            # of NBs
128          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
2            Ps
2            Qs
16.0         threshold
1            # of panel fact
2            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
1            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOFCONFIG

    chmod 644 $INSTALL_DIR/hpcc/_hpccinf.txt.example
    
else
    echo ""
    echo "=========================================="
    echo "ERROR: HPCC build failed!"
    echo "=========================================="
    exit 1
fi

echo ""
echo "Note: Make sure to run this script on all nodes (head, com1, com2)"
echo ""
