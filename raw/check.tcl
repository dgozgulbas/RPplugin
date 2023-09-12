package require psfgen
package require readcharmmpar
package require topotools
package require exectool

set all [mol new ring_piercing/system_fl_rp.psf]
mol addfile ring_piercing/system_fl_rp.pdb

#set all [mol new system_fl_rp.psf]
#mol addfile system_fl_rp.pdb
#
#set all [mol new system_fl_cor.psf]
#mol addfile system_fl_cor.pdb
#mol addfile namd/step8.1_production.dcd step 100 waitfor all
#mol addfile namd/minimize.dcd waitfor all

#set all [atomselect top "not protein"]
#set out [open check-out.txt w]

foreach bond [topo getbondlist -molid $all] {
	if { [measure bond $bond molid $all] > 1.7 } {
		set ssel [atomselect $all "same residue as index $bond"]
		set segname [lindex [$ssel get segname] 0]		
		set comp [string compare $segname PROT]
		if {$comp != 0} {
			set ssel [atomselect $all "same residue as index $bond"]
			set res [$ssel get resid]
			set bnd [measure bond $bond]
			set seg [$ssel get segname]
			puts $res
			puts $seg
			puts $bnd 

}}}

set sel [atomselect top "segname MEMB and name N"]
set mm [measure minmax $sel]
set ll [vecsub [lindex $mm 1] [lindex $mm 0]]
puts "MEMBRANE: [lindex $ll 0] [lindex $ll 1]"

set sel [atomselect top all]
set mm [measure minmax $sel]
set ll [vecsub [lindex $mm 1] [lindex $mm 0]]
puts "Z DIMENSION: [lindex $ll 2]"

