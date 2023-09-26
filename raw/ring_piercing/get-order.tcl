mol new system_fl_rp-pre.psf
mol addfile order.dcd waitfor all 

set all [atomselect 0 all]
$all writepsf system_fl_rp.psf
$all writepdb system_fl_rp.pdb


