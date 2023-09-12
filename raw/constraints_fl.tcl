mol new system_fl_cor.psf
mol addfile system_fl_cor.pdb

set all [atomselect top all]
$all set beta 0


set lipid [atomselect top "segname MEMB and name P"]
$lipid set beta 1

set chl [atomselect top "resname CHL1 and name O3"]
$chl set beta 1

$all writepdb constraints_lipid_fl.pdb

$lipid delete
$chl delete
$all delete 

set all [atomselect top all]
$all set beta 0

set protein [atomselect top "protein"]
$protein set beta 1

set lipid [atomselect top "segname MEMB and name P"]
$lipid set beta 1

set chl [atomselect top "resname CHL1 and name O3"]
$chl set beta 1

$all writepdb constraints_fl.pdb

$protein delete
$chl delete
$all delete

set all [atomselect top all]
$all set beta 0

set lipend [atomselect top "name C218 C316"]
$lipend set beta 1

$all writepdb lip-tails.pdb

$all delete
$lipend delete

mol new ring_piercing/system_fl_rp.psf
mol addfile ring_piercing/system_fl_rp.pdb

set all [atomselect top all]
$all set beta 0

set protein [atomselect top "protein"]
$protein set beta 1

set lipid [atomselect top "segname MEMB and name P"]
$lipid set beta 1

set chl [atomselect top "resname CHL1 and name O3"]
$chl set beta 1

$all writepdb constraints_fl-pre.pdb

set all [atomselect top all]
$all set beta 0

set lipend [atomselect top "name C218 C316"]
$lipend set beta 1

$all writepdb lip-tails-pre.pdb

$all delete
$lipend delete

