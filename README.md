# Ring Piercing Resolver - VMD Plugin

## Overview

This VMD plugin is designed to resolve ring piercings that can occur in molecular dynamics simulations systems. Ring piercings may arise from various scenarios, such as lipid tails passing through rings (e.g., in cholesterol), long protein side chains penetrating rings of other side chains (e.g., tryptophan), or lipids infiltrating protein side chains with rings. To address this issue, the plugin utilizes combination of methods such as the alchemical mode of NAMD, known as thermodynamic integration and volumetric repulsive grid forces.


<!-- [![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme) -->

<!-- 
This repository contains:

1. [The specification](spec.md) for how a standard README should look.
2. A link to [a linter](https://github.com/RichardLitt/standard-readme-preset) you can use to keep your README maintained ([work in progress](https://github.com/RichardLitt/standard-readme/issues/5)).
3. A link to [a generator](https://github.com/RichardLitt/generator-standard-readme) you can use to create standard READMEs.
4. [A badge](#badge) to point to this spec.
5. [Examples of standard READMEs](example-readmes/) - such as this file you are reading.

Standard Readme is designed for open source libraries. Although it’s [historically](#background) made for Node and npm projects, it also applies to libraries in other languages and package managers. -->


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

   add these lines to your .vmdrc
    ```sh   
    source [local-directory]/RPplugin/ringpiercing.tcl
    vmd_install_extension ringpiercingpackage ringpiercingpackage_tk "Modeling/Ring Piercing Resolver"
    ```

## Input Files

- **PSF (Protein Structure File):** The topology file representing the molecular structure.

- **PDB (Protein Data Bank):** The coordinate file containing atomic coordinates of the system.

- **Custom Parameter Files:** Optionally, you can provide custom parameter files for specific force fields or interactions in your simulation.

- **Custom Simulation Configuration File:** Optionally, you can specify a custom simulation configuration file for the minimization step.

### Generator

To use the generator, look at [generator-standard-readme](https://github.com/RichardLitt/generator-standard-readme). There is a global executable to run the generator in that package, aliased as `standard-readme`.

## Badge

If your README is compliant with Standard-Readme and you're on GitHub, it would be great if you could add the badge. This allows people to link back to this Spec, and helps adoption of the README. The badge is **not required**.

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

To add in Markdown format, use this code:

```
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
```

## Example Readmes

To see how the specification has been applied, see the [example-readmes](example-readmes/).

## Related Efforts

- [Art of Readme](https://github.com/noffle/art-of-readme) - 💌 Learn the art of writing quality READMEs.
- [open-source-template](https://github.com/davidbgk/open-source-template/) - A README template to encourage open-source contributions.

## Maintainers

[@DefneGorgunOzgulbas](https://github.com/dgozgulbas).

### Contributors

This project exists thanks to all the people who contribute. 
<a href="https://github.com/RichardLitt/standard-readme/graphs/contributors"><img src="https://opencollective.com/standard-readme/contributors.svg?width=890&button=false" /></a>


## License

[MIT](LICENSE) © Richard Littauer

![alt text](https://github.com/dgozgulbas/RPplugin/blob/develop/img.png?raw=true)
