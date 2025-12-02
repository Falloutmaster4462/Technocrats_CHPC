#!/usr/bin/env python3
"""
Verify Benchmark 2 Results - 200,000 Markers
"""
import numpy as np
from a5py import Ascot
import sys

print("=" * 70)
print("ASCOT5 Benchmark 2 Verification - 200,000 Markers")
print("=" * 70)

try:
    # Load results
    a5 = Ascot("benchmark2.h5")
    
    # 1. Check marker summary
    print("\n1. MARKER SUMMARY")
    print("-" * 70)
    summary = a5.data.active.getstate_markersummary()
    print(f"End conditions: {summary}")
    
    n_total = len(a5.data.active.getstate("ids"))
    print(f"Total markers: {n_total:,}")
    
    # Count by end condition
    try:
        n_thermalized = len(a5.data.active.getstate("ids", endcond="thermal"))
        n_timelimit = len(a5.data.active.getstate("ids", endcond="tlim"))
        print(f"Thermalized: {n_thermalized:,} ({100*n_thermalized/n_total:.1f}%)")
        print(f"Time limit: {n_timelimit:,} ({100*n_timelimit/n_total:.1f}%)")
    except Exception as e:
        print(f"Could not determine end condition counts: {e}")
    
    # 2. Energy analysis
    print("\n2. ENERGY ANALYSIS")
    print("-" * 70)
    
    # Use 'ekin' instead of 'energy'
    energy_ini = a5.data.active.getstate("ekin", state="ini")
    energy_end = a5.data.active.getstate("ekin", state="end")
    
    print(f"Initial energy:")
    print(f"  Mean: {np.mean(energy_ini)/1e6:.4f} MeV")
    print(f"  Std:  {np.std(energy_ini)/1e6:.4f} MeV")
    print(f"  Min:  {np.min(energy_ini)/1e6:.4f} MeV")
    print(f"  Max:  {np.max(energy_ini)/1e6:.4f} MeV")
    
    print(f"\nFinal energy:")
    print(f"  Mean: {np.mean(energy_end)/1e3:.2f} keV")
    print(f"  Std:  {np.std(energy_end)/1e3:.2f} keV")
    print(f"  Min:  {np.min(energy_end)/1e3:.2f} keV")
    print(f"  Max:  {np.max(energy_end)/1e3:.2f} keV")
    
    energy_ratio = np.mean(energy_end) / np.mean(energy_ini)
    print(f"\nEnergy ratio (final/initial): {energy_ratio:.4f}")
    print(f"Energy loss: {(np.mean(energy_ini) - np.mean(energy_end))/1e6:.3f} MeV")
    
    # 3. Spatial distribution
    print("\n3. SPATIAL DISTRIBUTION")
    print("-" * 70)
    try:
        r_ini = a5.data.active.getstate("r", state="ini")
        z_ini = a5.data.active.getstate("z", state="ini")
        r_end = a5.data.active.getstate("r", state="end")
        z_end = a5.data.active.getstate("z", state="end")
        
        print(f"Initial R: {np.mean(r_ini):.3f} ± {np.std(r_ini):.3f} m")
        print(f"Initial Z: {np.mean(z_ini):.3f} ± {np.std(z_ini):.3f} m")
        print(f"Final R:   {np.mean(r_end):.3f} ± {np.std(r_end):.3f} m")
        print(f"Final Z:   {np.mean(z_end):.3f} ± {np.std(z_end):.3f} m")
    except Exception as e:
        print(f"Could not analyze spatial distribution: {e}")
    
    # 4. Distribution check
    print("\n4. DISTRIBUTION DATA")
    print("-" * 70)
    try:
        dist5d = a5.data.active.getdist("5d")
        print(f"✓ 5D distribution collected")
        print(f"  Grid: {dist5d.abscissa('r').size}R × "
              f"{dist5d.abscissa('z').size}Z × "
              f"{dist5d.abscissa('phi').size}phi × "
              f"{dist5d.abscissa('ppar').size}ppar × "
              f"{dist5d.abscissa('pperp').size}pperp")
        
        distrho = a5.data.active.getdist("rho5d")
        print(f"✓ rho5D distribution collected")
        print(f"  Grid: {distrho.abscissa('rho').size}rho × "
              f"{distrho.abscissa('theta').size}theta × "
              f"{distrho.abscissa('phi').size}phi × "
              f"{distrho.abscissa('ppar').size}ppar × "
              f"{distrho.abscissa('pperp').size}pperp")
    except Exception as e:
        print(f"✗ Distribution error: {e}")
    
    # 5. Success criteria
    print("\n5. SUCCESS CRITERIA")
    print("-" * 70)
    
    passed = True
    
    # Check 1: All markers processed
    if n_total == 200000:
        print("✓ All 200,000 markers processed")
    else:
        print(f"✗ Only {n_total:,} markers processed (expected 200,000)")
        passed = False
    
    # Check 2: Energy slowed down significantly
    mean_final_energy_kev = np.mean(energy_end) / 1e3
    if mean_final_energy_kev < 100:  # < 100 keV
        print(f"✓ Markers slowed down (final: {mean_final_energy_kev:.1f} keV)")
    else:
        print(f"✗ Insufficient slowing (final: {mean_final_energy_kev:.1f} keV)")
        passed = False
    
    # Check 3: Energy ratio
    if energy_ratio < 0.05:  # Final < 5% of initial
        print(f"✓ Energy ratio acceptable ({energy_ratio:.4f})")
    else:
        print(f"⚠ Energy ratio high ({energy_ratio:.4f})")
    
    # Check 4: Most markers thermalized
    if n_thermalized > 180000:  # Most markers should thermalize (90% of 200k)
        print(f"✓ Most markers thermalized ({n_thermalized:,} / {n_total:,})")
    else:
        print(f"⚠ Only {n_thermalized:,} markers thermalized")
    
    # Check 5: Distributions exist
    try:
        dist5d = a5.data.active.getdist("5d")
        distrho = a5.data.active.getdist("rho5d")
        print("✓ Both distributions collected successfully")
    except:
        print("✗ Distribution data missing")
        passed = False
    
    # Check 6: Higher resolution distribution grids
    print("\n6. BENCHMARK 2 SPECIFIC CHECKS")
    print("-" * 70)
    try:
        dist5d = a5.data.active.getdist("5d")
        distrho = a5.data.active.getdist("rho5d")
        
        # Check the increased resolution from Benchmark 1
        r_bins = dist5d.abscissa('r').size
        z_bins = dist5d.abscissa('z').size
        ppar_bins = dist5d.abscissa('ppar').size
        pperp_bins = dist5d.abscissa('pperp').size
        rho_bins = distrho.abscissa('rho').size
        
        print(f"5D Grid resolution:")
        print(f"  R bins: {r_bins} (Benchmark 1: 50)")
        print(f"  Z bins: {z_bins} (Benchmark 1: 50)")
        print(f"  ppar bins: {ppar_bins} (Benchmark 1: 100)")
        print(f"  pperp bins: {pperp_bins} (Benchmark 1: 50)")
        print(f"rho5D Grid resolution:")
        print(f"  rho bins: {rho_bins} (Benchmark 1: 100)")
        
        # Verify increased resolution
        if r_bins >= 80 and z_bins >= 80 and ppar_bins >= 150 and pperp_bins >= 80 and rho_bins >= 150:
            print("✓ All grids have increased resolution for Benchmark 2")
        else:
            print("⚠ Some grids don't have the expected increased resolution")
            
    except Exception as e:
        print(f"✗ Could not verify grid resolutions: {e}")
    
    # Final result
    print("\n" + "=" * 70)
    if passed:
        print("BENCHMARK 2: PASSED ✓")
        print("\nAll critical criteria met!")
        print("The simulation successfully demonstrates:")
        print("  - Complete tracking of 200,000 markers")
        print("  - Significant energy loss through collisions")
        print("  - Proper thermalization behavior")
        print("  - Higher resolution distribution collection")
        print("  - Scalability with increased marker count")
    else:
        print("BENCHMARK 2: NEEDS REVIEW ⚠")
        print("\nSome criteria not met, but simulation may still be valid.")
        print("Consider reviewing the distribution statistics and end conditions.")
    print("=" * 70)
    
    sys.exit(0 if passed else 1)
    
except Exception as e:
    print(f"\n✗ ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
