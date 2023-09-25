#==============================================================================
#                      RING PIERCING RESOLVER 1.0
#==============================================================================
# This plugin resolvs ring piercings within a structural model. It utilizes the 
# alchemical module to lower the energetic barrier for relocating atoms that are
# piercing through the ring structure. Additionally, a volumetric grid is 
# employed to exert forces that push these atoms away from the ring. The entire
# system is then subjected to minimization through short molecular dynamics 
# simulations. It requires psf/pdb input, configuration file to run NAMD 
# minimization and special parameter/topology files if needed. It outputs 
# the psf/pdb of the fixed structure.

# $Id: RPresolver.tcl,v 1.3 2023/10/06 03:35:45 johns Exp $
#
# Authors: Defne Gorgun Ozgulbas, Josh Vermaas, v1.0, 11-2023
#
# gir clone https://github.com/dgozgulbas/RPplugin.git

# Citation: 
# in preparation.  
#==============================================================================

package provide RPresolver 1.0

# package requirements
if { [info exists tk_version] } {
    package require tktooltip
}
package provide readcharmmpar
package require pbctools
package require chirality
package require cispeptide
package require mdff

#======================================================
namespace eval ::RingPiercing:: {
    variable dirPackage $env(MMPDIR)
    variable dirCharmmPar $env(CHARMMPARDIR)

    variable w 
    
    variable psffile "system.psf"
    variable pdbfile "system.pdb"
    variable custom_conffile 0
    variable addtopfile 0
    variable conffile "configuration.inp"; # this configuration file must already run properly in the current directory
    #variable conffile {}; # this configuration file must already run properly in the current directory
    variable name_dir "ring_piercing"
    variable outputpath [pwd]; #output directory, default is current directory
    # Specify atomselect containing lipid residues that one wants to exchange
    variable lselection "segname MEMB"
    # Add colvar to restrain phosphorus atoms plane in each leaflet. If cholesterol is present, then also its oxygen plane is restrain.
    # This is useful when not using a membrane generated by the CHARMM-GUI, which contains already these restraints. 
    # You can also specify the force constant for the restraints. Any other "colvar" in the file is removed if "restrPhos" is activated.
    # If the force constant for P-P distance is too low you might observe separation of the two leaflets.
    variable forceconstbilayer 50
    # You can also specify some groupd of atoms to be restrain (and relative force constant). You may want to restrain the protein for example,
    # but if the force constant is too high it might crash the simulation. Any other "constraint" in the file is removed if "restrGroup" is activated.
    variable restrained 0
    variable restrainedselection  "protein and noh"
    variable forceconst 30
    # Set if want to exchange full center of mass (0) and only XY, keeping Z (1). Suggested setting is 1
    variable ExProc 1
    variable exchange 50; 	# Exchanging almost all lipids may result in bad membranes
    # Number of replicas to generate
    variable nreplicas 1
    variable namdbin "namd2"
    variable namdargs 
    # Other variables
    variable consoleMaxHistory 100
    variable consoleMessageCount 0
    variable progressFile
    variable BuildScript
    variable ChangeFreqOut 0
    variable parfiles {}
    variable setGridForceOn 1; # Internal use only. Should always be set to 1
}


proc rpr {} {
    return [eval ::RingPiercing::ringpiercing]
}

proc ringpiercing_tk {} {
    ::RingPiercing::ringpiercing
    return $RingPiercing::w
}
#UNCOMMENT HERE
# proc ::RingPiercing::ringpiercing {} {
variable psffile

    # ::RingPiercing::init_default_topology
    variable w
    if { [winfo exists .ringpiercing] } {
        wm deiconify .ringpiercing
        return
    }
    
    set w [toplevel ".ringpiercing"]
    wm title $w "Ring Piercing Resolver"
    wm resizable $w 1 1
    
    trace add variable ::RingPiercing::restrained write ::RingPiercing::write_state
    trace add variable ::RingPiercing::custom_conffile write ::RingPiercing::write_state_1
    trace add variable ::RingPiercing::restrainedbilayer write ::RingPiercing::write_state_2

    trace add variable ::RingPiercing::psffile write ::RingPiercing::psffileCheck
    trace add variable ::RingPiercing::pdbfile write ::RingPiercing::pdbfileCheck
    trace add variable ::RingPiercing::conffile write ::RingPiercing::conffileCheck
    trace add variable ::RingPiercing::outputpath write ::RingPiercing::outputpathCheck
    trace add variable ::RingPiercing::lselection write ::RingPiercing::lselectionCheck
    trace add variable ::RingPiercing::forceconstbilayer write ::RingPiercing::forceconstbilayerCheck
    trace add variable ::RingPiercing::forceconst write ::RingPiercing::forceconstCheck
    trace add variable ::RingPiercing::restrainedselection write ::RingPiercing::restrainedselectionCheck
    trace add variable ::RingPiercing::exchange write ::RingPiercing::exchangeCheck
    trace add variable ::RingPiercing::nreplicas write ::RingPiercing::nreplicasCheck
    trace add variable ::RingPiercing::num_min1 write ::RingPiercing::min1Check
    trace add variable ::RingPiercing::num_min2 write ::RingPiercing::min2Check
    trace add variable ::RingPiercing::num_md1 write ::RingPiercing::md1Check
    trace add variable ::RingPiercing::num_md2 write ::RingPiercing::md2Check
    trace add variable ::RingPiercing::namdbin write ::RingPiercing::namdbinCheck
    
    # set namdargs $::RingPiercing::namdargs
    # set psf  $::RingPiercing::psffile
    # set pdb  $::RingPiercing::pdbfile
    # set conf $::RingPiercing::conffile
    # set MembSelection $::RingPiercing::lselection
    # set restrGroupSelect $::RingPiercing::restrainedselection
    # set custom_conffile $::RingPiercing::custom_conffile
    # set namdcommand $::RingPiercing::namdcommand
    # set namdcommandOpt $::RingPiercing::namdcommandOpt
    # set restrainedbilayer $::RingPiercing::restrainedbilayer
    # set forceconstbilayer $::RingPiercing::forceconstbilayer
    # set restrained $::RingPiercing::restrained
    # set forceconst $::RingPiercing::forceconst
    # set exchange $::RingPiercing::exchange
    # set nreplicas $::RingPiercing::nreplicas
    # set num_min1 $::RingPiercing::num_min1
    # set num_md1 $::RingPiercing::num_md1
    # set num_min2 $::RingPiercing::num_min2
    # set num_md2 $::RingPiercing::num_md2
    # set ExProc $::RingPiercing::ExProc
    # set outputpath $::RingPiercing::outputpath
    set f $w
    
    # Add a menu bar
    frame $f.menubar -relief raised -bd 2 
    grid $f.menubar -column 0 -row 0 -sticky e -padx 4 -pady "2 0"
    grid columnconfigure $f 0 -weight 1 ;###
    
    menubutton $f.menubar.help -text Help -underline 0 -menu $f.menubar.help.menu
    # XXX - set menubutton width to avoid truncation in OS X
    $f.menubar.help config -width 5 
    
    # Help menu
    menu $f.menubar.help.menu -tearoff no
    $f.menubar.help.menu add command -label "About" \
    -command {tk_messageBox -type ok -title "About Ring Piercing Resolver" \
    -message "This plugin finds and resolves ring piercings caused by systemic clashes using alchemical methods and grid-force potentials.\n \nAuthors:\nDefne Gorgun Ozgulbas\nJosh Vermaas"}
    $f.menubar.help.menu add command -label "Help..." \
    -command "vmd_open_url [string trimright [vmdinfo www] /]/plugins/ringpiercing"
    grid $f.menubar.help -column 0 -row 0 -sticky e -padx 0 -pady 0
    grid columnconfigure $f.menubar 0 -weight 1
    

    # Input 
    frame $f.input -bd 2 -relief ridge
    grid $f.input -column 0 -row 1 -sticky nsew -padx 4 -pady "3 4"
    grid rowconfigure $f 1 -weight 1
    
    grid [label $f.input.label -text "Input files:"] -row 0 -column 0 -columnspan 1 -sticky nw
    grid [label $f.input.psflabel -text "PSF file: "] -row 1 -column 0 -sticky nw
    grid [entry $f.input.psfpath -width 30 -textvariable ::RingPiercing::psffile] -row 1 -column 1 -columnspan 2 -sticky nwe
    grid [button $f.input.psfbutton -text "Browse" \
        -command {
            set tempfile [tk_getOpenFile -title "Select a PSF file"]
            if {![string equal $tempfile ""]} { set ::RingPiercing::psffile $tempfile }
        }] -row 1 -column 3 -sticky ne
    grid columnconfigure $f.input 1 -weight 1 -minsize 140
    foreach l {"label" "path" "button"} {::TKTOOLTIP::balloon $f.input.psf${l} "Select the .psf file containing the topology information of your initial system"}
    grid [label $f.input.pdblabel -text "PDB file: "] -row 2 -column 0 -sticky nw
    grid [entry $f.input.pdbpath -width 30 -textvariable ::RingPiercing::pdbfile] -row 2 -column 1 -columnspan 2 -sticky nwe
    grid [button $f.input.pdbbutton -text "Browse" \
        -command {
            set tempfile [tk_getOpenFile -title "Select a PDB file"]
            if {![string equal $tempfile ""]} { set ::RingPiercing::pdbfile $tempfile }
        }] -row 2 -column 3 -sticky nw
    foreach l {"label" "path" "button"} {::TKTOOLTIP::balloon $f.input.pdb${l} "Select the .pdb file containing the coordinate information of your initial system"}
    
    grid [checkbutton $f.input.dconff -text "Use a custom configuration file" -variable ::RingPiercing::custom_conffile] -row 3 -column 0 -columnspan 2 -sticky nw
    ::TKTOOLTIP::balloon $f.input.dconff "If active, a custom NAMD configuration file can be selected.\nOtherwise the plugin uses default simulation options with CHARMM36 parameters."
    
    grid [label $f.input.conflabel -text "conf file: " -state disabled] -row 4 -column 0 -sticky w
    grid [entry $f.input.confpath -width 30 -textvariable ::RingPiercing::conffile -state disabled] -row 4 -column 1 -columnspan 2 -sticky ew
    grid [button $f.input.confbutton -text "Browse" \
        -command {
            set tempfile [tk_getOpenFile -title "Select a custom configuration file"]
            if {![string equal $tempfile ""]} { set ::RingPiercing::conffile $tempfile }
        } -state disabled] -row 4 -column 3 -sticky w
    foreach l {"label" "path" "button"} {::TKTOOLTIP::balloon $f.input.conf${l} "Provide a configuration file to run the equilibration of the membrane.\nCheck if it is already usable with the selected system without errors.\nThe file will be modified by the plugin to account for other settings."}
    
    listbox $f.input.list -activestyle dotbox -yscroll "$f.input.scroll set" -width 60 -height 2  -setgrid 1 -selectmode browse -selectbackground white \
    -listvariable ::RingPiercing::parfiles -relief sunken -exportselection 0 \
    -selectbackground lightsteelblue -selectmode extended
    scrollbar $f.input.scroll -command "$f.input.list yview"

    button $f.input.add -text "Add" -command [namespace code {
        set toptypes {
        {{CHARMM Topology Files} {.top .inp .rtf .prm .str}}
        {{All Files} {*}}
        }
        set temploc [tk_getOpenFile -title "Select additional parameter file(s)" -filetypes $toptypes -multiple true]
            if {$temploc!=""} {
                foreach f $temploc {
                    lappend ::RingPiercing::parfiles $f
                }
            }
    }]
    button $f.input.delete -text "Delete" -command [namespace code {
        set lisDel [lreverse [.RingPiercing.input.list curselection]]
        foreach i $lisDel {
            .RingPiercing.input.list delete $i
        }
    }]
    grid [label $f.input.toplabel -text "Additional parameter files: "] -row 5 -column 0 -columnspan 2  -sticky w
    grid $f.input.list -column 0 -row 6 -columnspan 3 -rowspan 2 -sticky nswe 
    grid $f.input.scroll -column 2 -row 6 -rowspan 2 -sticky nsw 
    grid $f.input.add -column 3 -row 6 -sticky nswe
    grid $f.input.delete -column 3 -row 7 -sticky nswe
    grid rowconfigure $f.input "6 7" -weight 1
    foreach l {"list" "scroll" "add"} {::TKTOOLTIP::balloon $f.input.${l} "If needed, include additional parameter files to run NAMD simulations.\nFor instance, you can use the default configuration file and\ninclude additional parameters for residues that are not in CHARMM."}
    ::TKTOOLTIP::balloon $f.input.delete "Remove selected parameter files."

    grid [label $f.input.outputlabel -text "Output: "] -row 8 -column 0 -sticky w
    grid [entry $f.input.outputpath -width 30 -textvariable ::RingPiercing::outputpath] -row 8 -column 1 -columnspan 2 -sticky ew
    grid [button $f.input.outputbutton -text "Browse" \
        -command {
            set tempdir [tk_chooseDirectory -title "Select an output path"]
            if {![string equal $tempdir ""]} { set ::RingPiercing::outputpath $tempdir }
        }] -row 8 -column 3 -sticky ew
    foreach l {"label" "path" "button"} {::TKTOOLTIP::balloon $f.input.output${l} "Provide an output path that specifies the master folder for running the simulations.\nMembrane replicas will be moved in separate folders within the master folder."}

     # Run plugin
    frame $f.run -bd 2 -relief ridge
    grid $f.run -column 0 -row 5 -sticky nsew -padx 4 -pady 4
    
    grid [label $f.run.label -text "Run:"] -row 0 -column 0 -columnspan 1 -sticky w
    
    #variable namdbin "/Projects/namd2/bin/2.13/Linux64-multicore/namd2"
    grid [label  $f.run.namdlabel -text "NAMD path:"] -row 1 -column 0 -sticky w
    grid [entry  $f.run.namdbin -width 30 -textvariable ::RingPiercing::namdbin] -row 1 -column 1 -sticky ew
    #grid [button $f.run.namdbutton -text "Browse" \
    #    -command {
    #        set tempfile [tk_getOpenFile -title "Select NAMD executable"]
    #        if {![string equal $tempfile ""]} { set ::RingPiercing::namdbin $tempfile }
    #    }] -row 1 -column 2 -sticky w

#MOVE THIS LATER OUT OF THE CURRENT FUNCTION
proc ::RingPiercing::getProcs {} {
    global tcl_platform env
    if {$::tcl_platform(os) == "Darwin"} {
        catch {exec sysctl -n hw.ncpu} proce
        return $proce
    } elseif {$::tcl_platform(os) == "Linux"} {
        catch {exec grep -c "model name" /proc/cpuinfo} proce
        return $proce
    } elseif {[string first "Windows" $::tcl_platform(os)] != -1} {
        catch {HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor } proce
        set proce [llength $proce]
        return $proce
    }
}



    foreach l {"label" "bin" } {::TKTOOLTIP::balloon $f.run.namd${l} "Specify the path to NAMD executable."}
    #variable namdargs "-gpu +p[::RingPiercing::getProcs]"
    variable namdargs "+idlepoll +setcpuaffinity +p[::RingPiercing::getProcs]"
    grid [label  $f.run.namdlabelOpt -text "NAMD options:"] -row 2 -column 0 -sticky w
    grid [entry  $f.run.namdargs -width 30 -textvariable namdargs] -row 2 -column 1 -columnspan 2 -sticky ew
    # grid [entry  $f.run.namdargs -width 30 -textvariable ::RingPiercing::namdargs] -row 2 -column 1 -columnspan 2 -sticky ew
    foreach l {"labelOpt" "args"} {::TKTOOLTIP::balloon $f.run.namd${l} "Specify options used to run NAMD."}
    grid columnconfigure $f.run 1 -weight 1 -minsize 55

    grid [button $f.button1 -text "RUN!" -width 20 -state normal \
    -command {set ::RingPiercing::BuildScript 0; ::RingPiercing::run_exchange}]  -row 6 -column 0 -padx 4 -pady 4 -sticky we
    ::TKTOOLTIP::balloon $f.button1 "Start membrane generation in current VMD session."
    grid [button $f.button2 -text "Build script" -width 20 -state normal \
    -command {set ::RingPiercing::BuildScript 1; ::RingPiercing::prepareRunScript}]  -row 7 -column 0 -padx 4 -pady 4 -sticky we
    ::TKTOOLTIP::balloon $f.button2 "Prepare script to run Membrane Mixer later.\nThis is particularly useful if one wants to\nrun in another computer or in a cluster."
    
    
    # Statusbar
    frame $f.statusbar -bd 2 -relief ridge
    grid $f.statusbar -column 0 -row 8 -sticky nsew -padx 4 -pady 4
    grid [label $f.statusbar.label -text "IDLE" -anchor w] -row 0 -column 0 -sticky w
    
    # Console
    frame $f.console -bd 2 -relief ridge 
    ttk::treeview $f.console.log -selectmode none -yscrollcommand "$f.console.scroll set"
    $f.console.log configure -columns {num msg time} -show {} -height 3
    $f.console.log heading num -text "num"
    $f.console.log heading msg -text "msg"
    $f.console.log heading time -text "time"
    $f.console.log column num -width 30 -stretch 0 -anchor w
    $f.console.log column msg -width 100 -stretch 1 -anchor w
    $f.console.log column time -width 80 -stretch 0 -anchor e
    ttk::scrollbar $f.console.scroll -orient vertical -command "$f.console.log yview"
    grid $f.console -column 0 -row 10 -sticky nswe -padx 4 -pady 4
    grid columnconfigure $f.console 0 -weight 1
    grid $f.console.log -column 0 -row 9 -sticky nswe
    grid $f.console.scroll -column 1 -row 9 -sticky nswe
    
    
    return $w
#}
#UNCOMMENT HERE



proc ::RingPiercing::psffileCheck {args} {
    variable w
     set test_var [string trim $::RingPiercing::psffile]
     if {$test_var eq ""} {
        $w.input.psfpath configure -background tomato
     } else {
        $w.input.psfpath configure -background white
     }
}

proc ::RingPiercing::pdbfileCheck {args} {
    variable w
     set test_var [string trim $::RingPiercing::pdbfile]
     if {$test_var eq ""} {
        $w.input.pdbpath configure -background tomato
     } else {
        $w.input.pdbpath configure -background white
     }
}

proc ::RingPiercing::conffileCheck {args} {
    variable w
     set test_var [string trim $::RingPiercing::conffile]
     if {$test_var eq ""} {
        $w.input.confpath configure -background tomato
     } else {
        $w.input.confpath configure -background white
     }
}

proc ::RingPiercing::outputpathCheck {args} {
    variable w
     set test_var [string trim $::RingPiercing::outputpath]
     if {$test_var eq ""} {
        $w.input.outputpath configure -background tomato
     } else {
        $w.input.outputpath configure -background white
     }
}

proc ::RingPiercing::write_state_1 {args} {
    variable w
    if {$::RingPiercing::custom_conffile == 0} {
    	$w.input.conflabel  configure -state disabled
    	$w.input.confpath   configure -state disabled
    	$w.input.confbutton configure -state disabled
    
    } else {
    	$w.input.conflabel  configure -state normal
    	$w.input.confpath   configure -state normal
    	$w.input.confbutton configure -state normal
    }
}

# Procedure to add representation for piercing atoms
proc ::RingPiercing::add_rep_piercing {ser molid} {
    mol color Name
    mol representation VDW 0.8 12.0
    mol selection "serial $ser"
    mol material Opaque
    mol addrep $molid
    mol color ResName
    mol representation Licorice 0.1 12.0 12.0
    mol selection "same residue as(within 3 of (serial $ser))"
    mol material Opaque
    mol addrep $molid
}

#MOVE THIS ABOVE
proc ::RingPiercing::param_settings {args} {
	# Parameter settings
	foreach par $paramlist {
		set f [open $par "r"]
		set out [open [file join $directory [file tail $par]] w ]
		set txt [read -nonewline ${f}]
		puts $out $txt
		close $f
		close $out
	}
}

proc ::RingPiercing::resolve_piercing {outputpath namdbin namdargs {namdextraconf ""}} {

#The code starts by checking if the PSF file is named "ring_piercing/system.psf" and performs several actions based on this condition.
#It extracts the filename part from the PSF file path and stores it in the "tail" variable. 
#For example, if the PSF file path is "ring_piercing/system.psf," the "tail" variable would contain "system.psf."
#It further extracts the root name of the file (without the extension) and stores it in the "name" variable. 
#In this example, "name" would contain "system."
#if psf is ring_piercing/system.psf

    set psf $::RingPiercing::psffile
    set pdb $::RingPiercing::pdbfile

    set tail [file tail $psf]
    set name [file rootname $tail]
    set outpath [file join $outputpath $::RingPiercing::name_dir]
    cp $psf $outpath
    cp $pdb $outpath
    puts $outputpath
    # Creates a new molecular object ("mol") named "mid" using the PSF file.
    # It adds a PDB file to the molecular object "mid" by joining the output path and the "name.pdb" file name. 
    # This PDB file contains coordinates and serves as an initial structure.
    set mid [mol new $psf] 
    mol addfile [file join $outpath $name.pdb] waitfor all
    puts "here1"
    # An atom selection ("asel") is created for all atoms in the "mid" object.
    # The beta value for all atoms in the "asel" selection is set to 0.
    set asel [atomselect $mid "all"]
    $asel set beta 0

    # The code writes a PSF/PDB file to the specified output path using the "animate" command. 
    # This PSF/PDB file is given the name specified in the ::RingPiercing::psffile variable.
    animate write psf [file join $outpath ::RingPiercing::psffile] 
    animate write pdb [file join $outpath ::RingPiercing::pdbfile] 

    # A molecular dynamics flexible fitting (MDFF) simulation is initiated on the "asel" selection. 
    # The resulting potential energy grid is saved in a file named "grid_rp.dx" within the output path.
    mdffi sim $asel -o [file join $outpath grid_rp.dx] -res 10 -spacing 1

    # The "finished" variable is initialized to 0, and a "counter" variable is set to 0 for tracking 
    # the number of iterations.
    set finished 0
    set counter 0
    set othersel [atomselect $mid "within 4 of occupancy > 0 and not withinbonds 3 of occupancy > 0"]
    set badbeta [atomselect $mid "beta > 0"]

    #puts "$namdbin $namdargs [file join $outputpath minimize.namd] $namdextraconf"

    while { ! $finished } {

    ::ExecTool::exec $namdbin $namdargs [file join $outpath $::RingPiercing::conffile] > [file join $outpath $name.log]

    animate delete all $mid

    incr counter
    incr finished

    #mol addfile [file join $directory out.coor] type namdbin waitfor all
    mol addfile $outpath/out.coor type namdbin waitfor all 0

    set unfinished [vecsum [$asel get beta]]

    $asel set beta 0
    $asel set occupancy 0

    foreach bond [topo getbondlist -molid $mid] { 

        if { [measure bond $bond molid $mid] > 2.3 } {
        
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
        mdffi sim $badbeta -o [file join $outpath grid_rp.dx] -res 10 -spacing 1
    }

    if { $unfinished } {
        set finished 0
    }

    $asel writepdb [file join $outpath ::RingPiercing::pdbfile]

    }

    $asel writepdb [file join $outpath ::RingPiercing::pdbfile]

    $asel delete

    $othersel delete

    $badbeta delete

    mol delete $mid

}

#minimizestructures ring_piercing namd2 "+p16" "parameters par_all36m_prot.prm \n"
::RingPiercing::resolve_piercing $::RingPiercing::outputpath namdbin namdargs "parameters par_all36m_prot.prm \n"
# minimizestructures ::RingPiercing::outputpath ::RingPiercing::namdbin ::RingPiercing::namdargs "parameters par_all36m_prot.prm \n"

# Procedure to start and follow a NAMD simulation run
proc ::MembraneMixer::StartFollowNAMD {root conf NAMDPATH OPTS} {
    file delete ${root}.log
    eval ::ExecTool::exec \"${NAMDPATH}\" ${OPTS} \"${conf}\" > \"${root}.log\" &
    after 2000
    # Wait until the simulation is done
    set control [lindex [::MembraneMixer::GrepEmu "End of program" ${root}.log 0] 1]
    puts3 -nonewline  "Waiting for NAMD job to finish..."
    set c 0
    while {!$control} {
        display update ui
        after 20
        incr c
        if {[expr {($c % 150) == 0}]} {
            puts3 -nonewline "."
            set control [lindex [::MembraneMixer::GrepEmu "End of program" ${root}.log 0] 1]
            set control2 [lindex [::MembraneMixer::GrepEmu "FATAL ERROR" ${root}.log 0] 1]
            # Check if fatal errors
            if {$control2} {
		set SKIPREP [::MembraneMixer::ErrorMessRun "   A FATAL ERROR occurred during NAMD job! SKIPPING THIS REPLICA!"]
		return $SKIPREP
            }
        }
    }
    puts2 "Done."
    display update ui
    # Check if errors were found during simulations (e.g. Constraint failure)
    set control3 [lindex [::MembraneMixer::GrepEmu "ERROR:" ${root}.log 0] 1]
    if {$control3} {
        puts2 "   AN ERROR WAS REPORTED IN NAMD LOG FILE! It might be related to ring piercing and might be corrected in next equilibration."
    }
    return 0
}
