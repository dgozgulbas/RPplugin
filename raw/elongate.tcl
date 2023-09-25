mol load psf system_hmmm.psf pdb system_hmmm.pdb  

[atomselect top "segname MEMB or resname CHL1"] writepdb ring_piercing/memb.pdb
[atomselect top "protein"] writepdb ring_piercing/protein.pdb

mol delete all

proc writePDBformat {in OutFile} {

	set elem1 [lindex $in 0]
        set elem2 [lindex $in 1]
        set elem3 [lindex $in 2]
        set elem4 [lindex $in 3]
        set elem5 [lindex $in 4]
        set elem6 [lindex $in 5]
        set elem7 [lindex $in 6]
        set elem8 [lindex $in 7]
        set elem9 [lindex $in 8]
        set elem10 [lindex $in 9]
        set elem11 [lindex $in 10]

	puts $OutFile [format "%-*4s  %*5d %*4s %-*5s%*4d    %*.3f%*.3f%*.3f%*.2f%*.2f      %-*4s" 4 $elem1 5 $elem2 4 $elem3 5 $elem4 4 $elem5 8 $elem6 8 $elem7 8 $elem8 6 $elem9 6 $elem10 4 $elem11]

}

 
set InFile [open ring_piercing/memb.pdb r]
set OutFile [open ring_piercing/memb2.pdb w]
gets $InFile line

set atmNum 1
while {[gets $InFile line] >=0} {
	if { [lindex $line 3]!="CHL1M" &&  [lindex $line 2]=="C26"} {
                set newLine $line
		lset newLine 2 C26
              writePDBformat $newLine $OutFile
		incr atmNum
		set xValue [lindex $line 5]
                set yValue [lindex $line 6]
                set zValue [lindex $line 7]

		gets $InFile line
		set newLine $line
		lset newLine 2 H6R
		lset newLine 1 $atmNum
		writePDBformat $newLine $OutFile
		incr atmNum
                gets $InFile line
                set newLine $line
                lset newLine 2 H6S
                lset newLine 1 $atmNum
                writePDBformat $newLine $OutFile
                incr atmNum
 
		gets $InFile line
	    puts 1
		if {$zValue > 0} {
		set c27zValue [expr $zValue-1.5 ]
		set c28zValue [expr $zValue-3 ]
		} else {
		set c27zValue [expr $zValue+1.5 ]
		set c28zValue [expr $zValue+3 ]
		}
		lset newLine 1 $atmNum
		lset newLine 7 $c27zValue
		lset newLine 2 C27
		writePDBformat $newLine $OutFile
		
		incr atmNum
                lset newLine 1 $atmNum
                lset newLine 7 $c28zValue
                lset newLine 2 C28
		writePDBformat $newLine $OutFile                
	      puts 2

		} elseif {[lindex $line 3]!="CHL1M" &&  [lindex $line 2]=="C36"} {
                set newLine $line
		lset newLine 2 C36
                writePDBformat $newLine $OutFile
                incr atmNum

                set xValue [lindex $line 5]
                set yValue [lindex $line 6]
                set zValue [lindex $line 7]
		    puts 3
                gets $InFile line
                set newLine $line
                lset newLine 2 H6X
                lset newLine 1 $atmNum
                writePDBformat $newLine $OutFile
                incr atmNum
                gets $InFile line
                set newLine $line
                lset newLine 2 H6Y
                lset newLine 1 $atmNum
                writePDBformat $newLine $OutFile
                incr atmNum

                gets $InFile line
		   puts 4
                if {$zValue > 0} {
                set c37zValue [expr $zValue-1.5 ]
                set c38zValue [expr $zValue-3 ]
                } else {
                set c37zValue [expr $zValue+1.5 ]
                set c38zValue [expr $zValue+3 ]
                }
                lset newLine 1 $atmNum
                lset newLine 7 $c37zValue
                lset newLine 2 C37
                writePDBformat $newLine $OutFile
                puts 5
                incr atmNum
                lset newLine 1 $atmNum
                lset newLine 7 $c38zValue
                lset newLine 2 C38
                writePDBformat $newLine $OutFile
		} else {
		set newLine $line
		lset newLine 1 $atmNum
		writePDBformat $newLine $OutFile
		}
incr atmNum
}

close $OutFile
close $InFile


package require psfgen
resetpsf

psfgen_logfile "ring_piercing/load_topology.log"

topology /Scr/defne/toppar/top_all36_prot.rtf
topology /Scr/defne/toppar/top_all36_lipid.rtf
topology /Scr/defne/toppar/toppar_water_ions_namd.str
topology /Scr/defne/toppar/top_all36_cgenff.rtf
topology /Scr/alirasouli/toppar/toppar_all36_lipid_cholesterol_namd.str

psfgen_logfile close


psfgen_logfile "ring_piercing/structure_preparation.log"

segment P {
	pdb ring_piercing/protein.pdb
}
coordpdb ring_piercing/protein.pdb P

segment MEMB {
	pdb ring_piercing/memb2.pdb
}
coordpdb ring_piercing/memb2.pdb MEMB



guesscoord

writepsf ring_piercing/system_fl_rp.psf
writepdb ring_piercing/system_fl_rp.pdb


