# ModelSim

ModelSim-Altera Starter Edition 16.0 is used for simulation.

## Prerequisites

### Fedora
    - `dnf install glibc.i686 lib{X11,Xft,Xext,Xrender}.i686 ncurses-compat-libs.i686`

## Installation

The following installation instructions are for Linux.

- Download [ModelSim-Altera Editon 16.0](http://dl.altera.com/15.0/?product=modelsim_ae#tabs-2)
- Make the installer executable and begin the installation
    - `$ cd ~/downloads`
    - `$ chmod +x ./ModelSimSetup-16.0.0.211-linux.run`
    - `$ sudo ./ModelSimSetup-16.0.0.211-linux.run --mode unattended --installdir /opt/altera/16.0/`
- Test the installation
    - `$ /opt/altera/16.0/modelsim_ase/bin/vsim -c -do exit`
    - If you receive the error `Error: cannot find "./bin/../linux_rh60/vsim"` then apply the following kludge.
      - `$ cd /opt/altera/16.0/modelsim_ase/`
      - `$ sudo ln -s linuxaloem linux_rh60`
