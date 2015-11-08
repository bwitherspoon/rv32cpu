# ModelSim

ModelSim-Altera Starter Edition 15.0 is used for simulation.

## Installation

The following installation instructions are for Linux.

- Download [ModelSim-Altera Editon 15.0](http://dl.altera.com/15.0/?product=modelsim_ae#tabs-2)
- Make the installer executable and begin the installation
    - `$ cd ~/downloads`   
    - `$ chmod +x ./ModelSimSetup-15.0.0.145-linux.run`  
    - `$ sudo ./ModelSimSetup-15.0.0.145-linux.run --mode unattended --installdir=/opt/altera/15.0/`
- Test the installation
    - `$ /opt/altera/15.0/modelsim_ase/bin/vsim -c -do exit`
    - If you receive the error `Error: cannot find "./bin/../linux_rh60/vsim"` then apply the following kludge.
      - `$ cd /opt/altera/15.0/modelsim_ase/vco`
      - `$ sudo ln -s linuxaloem linux_rh60`
