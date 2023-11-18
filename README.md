# Apollo guide

Assorted guides on using the Apollo cluster at the London Centre for Nanotechnology. Contributions welcome, especially from those who use Windows.
>[!IMPORTANT]
>You should first read the manual by executing `man apollo`.

## Login
To login, run
```
ssh <linux-username>@apollo.lcn.ucl.ac.uk
```
from a linux machine. For example, you may need to first `ssh` into one of the linux workstations before you can `ssh` into apollo. To automate this, add 
```
Host apollo
    User <linux-username>
    HostName apollo.lcn.ucl.ac.uk
    ProxyJump <your-workstation>

Host <your-workstation>
    User <linux-username>
    HostName <your-workstation>.phys.ucl.ac.uk
    ProxyJump gateway

Host gateway
    User <ucl-username>
    HostName ssh-gateway.ucl.ac.uk
```
to you `~/.ssh/config` file on your local computer. Now you should be able to use `ssh apollo` to directly login to Apollo. Note you will be asked to enter passwords multiple times, and the password and username used for `gateway` is your UCL username and password, whereas the other two will be your *linux* username and password. If you do not want to add enter your password then you can authenticate using SSH keys by following the guide at the bottom of [this page](https://www.rc.ucl.ac.uk/docs/Remote_Access/). I found this to be only somewhat reliable, but usually cuts out at least two of the three password entries. Alternatively, one can login via galaxy
```
Host apollo
    User <linux-username>
    HostName apollo.lcn.ucl.ac.uk
    ProxyJump galaxy.lcn.ucl.ac.uk
```
which also works outside of the network. 

## Submitting jobs
Jobs can be queued using a jobscript and the `qsub` command. Options can be provided to the command directly or put into the jobscript. For example
```bash
#!/bin/bash -f     
# ---------------------------
#$ -M <my-email-address>            
#$ -m be
#$ -V
#$ -cwd
#$ -N main
#$ -S /bin/bash
#$ -l vf=600M   
#$ -pe ompi-local 40
#$ -q I_40T_64G_GPU.q            
#
echo "Got ${NSLOTS} slots."
IPWD=`pwd`
echo "in ${IPWD}"
nsys launch --wait=primary --trace=cuda,nvtx julia --project -g2 -t auto main.jl        
exit 0    
```
passes the options listed on the lines starting with `#$` to `qsub`, and executes the bash commands in the body. Use `qsub -help` to list all the options available. 
>[!IMPORTANT]
>You should check `man apollo` for an explanation on how to set the `-l` and `-pe` options. Setting these incorrectly can cause the job to sit in the queue eternally. 

This particular jobscript executes
```
julia --project -g2 -t auto main.jl
```
under the Nvidia NSight Systems GPU profiler found in the `apps/nvhpc` module. Assuming this script is called `submit.sh`, to queue the job I would first load the required modules using `module load apps/nvhpc` and then run `qsub submit.sh` to submit to the `I_40T_64G_GPU.q` queue. 

## XMDS
This section will walk you through building XMDS as user. This guide has been adapted from [the documentation](http://www.xmds.org/installation.html).
### Loading and installing prerequisites
1.  **FFTW, MPI, MLK** and a **C++ compiler**. To load these, do 
	``` bash
	module load libs/fftw
	module load libs/mkl
	```
	Loading FFTW will load MPI and a compiler as prerequisites.

2. **Python 3.** We also require Python 3:
	```
	module load apps/python
	```
	Make sure the following packages are installed: **numpy, setuptools, lxml, h5py, pyparsing, cheetah3**. 	If any are missing, install using:
	```bash
	pip3 install <package> --user
	```
	The `--user` option is required as some packages will attempt to install system wide which will fail due to lack of permissions.

4. **HDF5.** This is another c library, however it may not be pre-installed (available in the module list). If that is thew case, we need to install it from source.  Download the [HDF5 source code](https://www.hdfgroup.org/downloads/hdf5/source-code/) choosing the `tar.gz` file from the list, then move this file to your home directory using something like `scp`. I suggest you make a directory called `~/software` or something if you don't have one already. Move into the directory containing the tar ball and extract it using 
	```bash
	tar -xf hdf5-X.X.X.tar.gz
	```
	with the Xs replaced with the version number you are installing. 

	Now we need to compile HDF5. Move into the extracted directory. Then run 
    ```
    ./configure --prefix=$HOME/.local
    ```
    This may take a few seconds. If you install your binaries, libraries, and header files in some other directory then change `--prefix` appropriately. If you don't know what   these means, then just use tha above.  Then do:
    ```
    make
    ```
    which may take a while, so go make a cup of tea or something similar. Once this completes, run 
    ```
    make install
    ```
    to install HDF5.

This should be all the prerequisites required for installing XMDS. 
### Update environment variables 
If you followed the above steps to install HDF5, then you should have some files in the directories located in `~/.local/`. We know need to add these directories to the corresponding path environment variables such that software relying on these files know where to look for them. Add
```bash
export PATH=$HOME/.local/bin:$PATH
export LIBRARY_PATH=$HOME/.local/lib:$LIBRARY_PATH
export INCLUDE_PATH=$HOME/.local/include:$INCLUDE_PATH
```
to your `~/.bashrc` to prepend each `.local` directory to the appropriate list that should be searched. You should now run
```bash
source ~/.bashrc
```
to reload this file. If you use a different directory for this then you can ignore this part as you probably know what you are doing. 
### Build XMDS
  1. Download the [XMDS source code](https://sourceforge.net/projects/xmds/) then move and extract it on Apollo as you did with HDF5. 
  2. Move into this directory containing the source code and run
	  ```bash
	  ./setup.py develop --prefix=$HOME/.python3local
	  ```
	  Note we use a different prefix here as the files that will be installed need to be locateable by Python. 

3. Run `make` to compile the Cheetah templates.

4. Run `xmds2 --reconfigure` and hopefully everything is in order!

## Julia

### Installation

As with everything regarding Julia, the installation is straightforward. Simply download and install [`juliaup`](https://github.com/JuliaLang/juliaup) by running
```bash
curl -fsSL https://install.julialang.org | sh
```
This should install the latest version of Julia as well as the `juliaup` version multiplexer. 

### Julia on the GPU
When loading the `CUDA` package, Julia will attempt to download a suitable version of the CUDA toolkit based on the devices it finds. The problem is that nodes do not have internet access, so this fails. As such, we must tell Julia to use locally installed CUDA toolkit. This can be done by launching a Julia REPL and executing  
```julia
julia> using CUDA
julia> CUDA.set_runtime_version!(v"12.2"; local_toolkit=true)
```
This will create a file named `LocalPreferences.toml` in the working directory. It is not strictly necessary to pass the version CUDA runtime version to this function, however it allows packages to precompile and may be required for some. The version passed should match the CUDA runtime version on the node which at the time of writing was `12.2`.


