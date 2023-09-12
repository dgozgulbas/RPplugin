#!/bin/bash

#cp -ru ../60-3new/ring_piercing .
#cp -ru ../60-3new/ring_piercing.tcl .
#cp -ru ../60-3new/elongate.tcl .
#cp -ru ../60-3new/namd/system_fl.str namd/
#cp -ru ../60-3new/regenerate.tcl .
#cp -ru ../60-3new/solvate.tcl .
#cp -ru ../60-3new/constraints_fl.tcl .
#cp -ru ../60-3new/check.tcl .
#for repeat runs
#rm -rf ring_piercing/*dcd
#rm -rf ring-piercing/*coor
#rm -rf ring_piercing/*psf
#rm -rf ring_piercing/*pdb
mkdir ring-piercing
echo "*****************************************************"
echo "** Write system_hmmm.p{sf,db} from the last frame! **"
echo "*****************************************************"
#your system with hmmm tails, loaded dcd etc.
vmd step5_assembly.p{sf,db}
wait
echo "*************************************************************"
echo "** Converting to full lipid. Write it as system_fl.p{sf,db}**"
echo "*************************************************************"
vmd -dispdev text -e elongate.tcl
wait
#echo "*****************************************************************************"
# echo "** Strip the system from ions and water! Write it as system_fl_rp.p{sf,db} **"
# echo "*****************************************************************************"
 vmd ring_piercing/system_fl.p{sf,db}
 wait
 cp system_fl_rp.psf ring_piercing/
 cp system_fl_rp.pdb ring_piercing/
echo "**************************"
echo "** Run rin_piercing.tcl **"
echo "**************************"
vmd -dispdev text -e ring_piercing.tcl
wait
echo "***********************************************************"
echo "** Copying correct structures over to the parent directory. **"
echo "***********************************************************"
cp -ru ring_piercing/system_fl_rp.psf .
cp -ru ring_piercing/system_fl_rp.pdb .
echo "*************************************************************************"
echo "** Check if you got rid of the pierced rings! Better safe than sorry.. **"
echo "*************************************************************************"
vmd -dispdev text -e check.tcl
wait
echo "**********************************************************************" 
echo "** Readjust your system size from the output from check.tcl script. **"
echo "**********************************************************************"
vim namd/system_fl.str
wait
echo "****************************************************************" 
echo "** Solvating the system again. Writing system_fl_cor.p{sf,db} **"
echo "****************************************************************"
vmd -dispdev text -e solvate.tcl
echo "*******************************************************************"
echo "** Generating the constraint files. So close to the finish line! **"
echo "*******************************************************************"
vmd -dispdev text -e constraints_fl.tcl
echo "******************************************************************"
echo "** DONE. You can start simulations using system_fl_cor.p{sf,db} **"
echo "******************************************************************"




