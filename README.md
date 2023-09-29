# Ring Piercing Resolver - VMD Plugin

## Overview

This VMD plugin is designed to resolve ring piercings that can occur in molecular dynamics simulations systems. Ring piercings may arise from various scenarios, such as lipid tails passing through rings (e.g., in cholesterol), long protein side chains penetrating rings of other side chains (e.g., tryptophan), or lipids infiltrating protein side chains with rings. To address this issue, the plugin utilizes combination of methods such as the alchemical mode of NAMD, known as thermodynamic integration and volumetric repulsive grid forces.

![alt text](https://github.com/dgozgulbas/RPplugin/blob/develop/img.png?raw=true)


## Table of Contents

- [Overview](#background)
- [Features](#features)
- [Installation](#installation)
- [Input Files](#inputfiles)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Ring Piercing Resolution:** The plugin identifies and resolves ring piercings by selectively modifying the lambda values of the atoms involved, reducing their impact, and applying repulsive forces to disentangle the piercer from the ring.

- **Compatibility:** Compatible with VMD, one of the most widely used visualization and analysis tools for molecular dynamics simulations.

- **Customizable:** Easily configurable to adapt to different scenarios and simulation setups.

## Installation

To use this plugin, follow these installation steps:

1. Clone this repository to your local machine:

   ```shell
   git clone https://github.com/dgozgulbas/RPplugin.git
    ```
2. Add these lines to your .vmdrc
    ```shell   
    source [local-directory]/RPplugin/ringpiercing.tcl
    vmd_install_extension ringpiercingpackage ringpiercingpackage_tk "Modeling/Ring Piercing Resolver"
    ```

## Input/Output Files

- **PSF (Protein Structure File):** The topology file representing the molecular structure.

- **PDB (Protein Data Bank):** The coordinate file containing atomic coordinates of the system.

- **Custom Parameter Files:** Optionally, you can provide custom parameter files for specific force fields or interactions in your simulation.

- **Custom Simulation Configuration File:** Optionally, you can specify a custom simulation configuration file for the minimization step.

- **Output Files**: The plugin generates corrected PDB and PSF files, representing the system after resolving ring piercings.


## Maintainers

[@DefneGorgunOzgulbas](https://github.com/dgozgulbas).

### Contributors

This project exists thanks to all the people who contribute. 
- Defne Gorgun Ozgulbas
- Dr. Josh Vermaas


## License

<!-- [MIT](LICENSE) © Richard Littauer -->


