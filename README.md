# Apollo guide

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

As with everything regarding Julia, the installation is straightforward. Simply download and install [`juliaup`](https://github.com/JuliaLang/juliaup) by running
```bash
curl -fsSL https://install.julialang.org | sh
```
This should install the latest version of Julia as well as the `juliaup` version multiplexer. 
