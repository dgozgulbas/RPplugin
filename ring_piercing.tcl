#======================================================
#										RING PIERCING 1.0
#======================================================

#package provide membranemixer 1.0

# package requirements
# if { [info exists tk_version] } {
#     package require tktooltip
# }
# package provide readcharmmpar
# package require pbctools
# package require chirality
# package require cispeptide
# package require mdff

package require psfgen
package require readcharmmpar
package require topotools
package require exectool

#======================================================
# set variables 

proc minimizestructures {directory namdbin namdargs {namdextraconf ""}} {

global env

#Copy over parameters from their respective directories.

#set paramlist [list [file join $env(CHARMMPARDIR) par_all36_carb.prm]  [file join $env(CHARMMPARDIR) par_all36_cgenff.prm] [file join $env(CHARMMPARDIR) par_all36_lipid.prm] [file join ring_piercing/par_all36m_prot.prm] [file join ring_piercing/minimize.namd]]

set paramlist [list [file join $env(CHARMMPARDIR) par_all36_carb.prm]  [file join $env(CHARMMPARDIR) par_all36_cgenff.prm] [file join $env(CHARMMPARDIR) par_all36_lipid.prm]]


puts $paramlist 

# Parameter settings
foreach par $paramlist {
	set f [open $par "r"]
	set out [open [file join $directory [file tail $par]] w ]
	set txt [read -nonewline ${f}]
	puts $out $txt
	close $f
	close $out
}

#Minimization command needs to be last.

#set psflist [lsort [glob [file join $directory "*psf"]]]

#foreach psf $psflist {

set psf ring_piercing/system_fl_rp.psf

set tail [file tail $psf]

set name [file rootname $tail]

set mid [mol new $psf]

mol addfile [file join $directory $name.pdb] waitfor all

set asel [atomselect $mid "all"]

$asel set beta 0

animate write psf [file join $directory system_fl_rp.psf] 

animate write pdb [file join $directory system_fl_rp.pdb] 

mdffi sim $asel -o [file join $directory grid_rp.dx] -res 10 -spacing 1

set finished 0

set counter 0

set fout [open [file join $directory "addenda.namd"] w ]

puts $fout $namdextraconf

close $fout

set othersel [atomselect $mid "within 4 of occupancy > 0 and not withinbonds 3 of occupancy > 0"]

set badbeta [atomselect $mid "beta > 0"]

puts "$namdbin $namdargs [file join $directory minimize.namd] $namdextraconf"

while { ! $finished } {

::ExecTool::exec $namdbin $namdargs [file join $directory minimize.namd] > [file join $directory $name.log]

animate delete all $mid

incr counter

incr finished

#mol addfile [file join $directory out.coor] type namdbin waitfor all
mol addfile ring_piercing/out.coor type namdbin waitfor all 0

set unfinished [vecsum [$asel get beta]]

$asel set beta 0

$asel set occupancy 0

foreach bond [topo getbondlist -molid $mid] { 

	if { [measure bond $bond molid $mid] > 1.85 } {
	
		set ssel [atomselect $mid "same residue as index $bond"]
		set segname [lindex [$ssel get segname] 0]
		set comp [string compare $segname PROT]
	
		if {$comp != 0} {
			$ssel set beta 1
			$ssel set occupancy 1	
			set finished 0	
			$ssel delete
		}
	}
}

$othersel update

#set fout [open [file join $directory "addenda.namd"] w ]

#puts $fout $namdextraconf

if { [$othersel num] } {
	puts $fout "colvars on\ncolvarsconfig colvars.conf\n"
}

close $fout

if { ! $finished && $counter > 100 } {
	error "Minimization $namd was not successful, even after 100 iterations."
}

if { ! $finished } {
	$badbeta update
	mdffi sim $badbeta -o [file join $directory grid_rp.dx] -res 10 -spacing 1
}

if { $unfinished } {
	set finished 0
}

$asel writepdb [file join $directory system_fl_rp.pdb]

}

$asel writepdb [file join $directory $name.pdb]

$asel delete

$othersel delete

$badbeta delete

mol delete $mid

#}

}

minimizestructures ring_piercing namd2 "+p16" "parameters par_all36m_prot.prm \n"
