package require psfgen
package require autoionize
package require solvate

topology /Scr/defne/toppar/top_all36_prot.rtf
topology /Scr/defne/toppar/top_all36_na.rtf
topology /Scr/defne/toppar/toppar_water_ions.str
topology /Scr/defne/toppar/top_all36_lipid.rtf
#topology ../../../toppar/patches.top
#topology ../../../toppar/toppar_all36_na_nad_ppi.str
#topology ../../../toppar/toppar_all36_lipid_hmmm.str
topology /Scr/defne/toppar/top_all36_cgenff.rtf
topology /Scr/defne/toppar/toppar_all36_lipid_cholesterol.str

pdbalias residue HIS HSE 
pdbalias atom ILE CD1 CD
pdbalias residue HOH TIP3
pdbalias atom TIP3 O OH2 

mol new system_fl_rp.psf
mol addfile system_fl_rp.pdb

set sel [atomselect top "segname MEMB and not resname CHL1"]
$sel writepdb lipid_rp.pdb
$sel writepsf lipid_rp.psf

set sel [atomselect top "resname CHL1"]
$sel writepdb chl_rp.pdb

set sel [atomselect top "protein"]
$sel writepdb protein_rp.pdb

resetpsf

segment PROT {pdb protein_rp.pdb}
coordpdb protein_rp.pdb PROT

segment MEMB {pdb lipid_rp.pdb}
#add_patches lipid_rp.pdb
#readpsf lipid_rp.psf
coordpdb lipid_rp.pdb MEMB

segment CHL {pdb chl_rp.pdb}
coordpdb chl_rp.pdb CHL

guesscoord
regenerate angles dihedrals

writepsf no_ions_nowat_rp.psf
writepdb no_ions_nowat_rp.pdb

solvate no_ions_nowat_rp.psf no_ions_nowat_rp.pdb -minmax {{-45 -45 -65} {45 45 65}} -o noions_rp 
#solvate no_ions_nowat_rp.psf no_ions_nowat_rp.pdb -z 17 +z 17 -o noions
mol load psf noions_rp.psf pdb noions_rp.pdb
set sel [atomselect top "not (water and same residue as ((x<-60 or x>60) or (z>-16 and z<16) or (y<-60 or y>60)))"]
$sel writepdb solvate_rp.pdb
$sel writepsf solvate_rp.psf
 
autoionize -psf solvate_rp.psf -pdb  solvate_rp.pdb -sc 0.15 -cation SOD -o system_fl_cor

set sel [atomselect top "all"]
$sel writepdb system_fl_cor.pdb
$sel writepsf system_fl_cor.psf
