# Singularity
Singularity is a container platform focused on supporting "Mobility of Compute"

Mobility of Compute encapsulates the development to compute model where developers can work in an environment of their choosing and creation and when the developer needs additional compute resources, this environment can easily be copied and executed on other platforms. Additionally as the primary use case for Singularity is targeted towards computational portability, many of the barriers to entry of other container solutions do not apply to Singularity making it an ideal solution for users (both computational and non-computational) and HPC centers.

*licensed under BSD-3-Clause*

Ofical web page and documentation on [Singularity.lbl.gov](http://singularity.lbl.gov/)

## Installing Singularity
Since you are reading this from the Singualrity source code, it will be
assumed that you are building/compiling.

To start off with you must first
install the development tools and libraries to your host.

```
$ sudo dnf groupinstall "Development Tools"
```

## To compile and install Singularity from a released tarball:
Assuming a 2.3.1 released tarball...
```
$ version=2.3.1
$ wget "https://github.com/singularityware/singularity/releases/download/${version}/singularity-${version}.tar.gz"
$ tar -xvzf singularity-${version}.tar.gz
$ cd singularity-${version}
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

note: The `sudo` is very important for the `make install`. Failure to do this
will result in a non-functioning or semi-functioning installation.

## To compile and install Singularity from a Git clone:

```
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ git checkout tags/2.3.1 -b 2.3.1
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

note: The `sudo` is very important for the `make install`. Failure to do this
will result in a non-functioning or semi-functioning installation.

## To compile and install Singularity from an existing Git clone:

```
$ cd singularity
$ git fetch --tags origin
$ git checkout tags/2.3.1 -b 2.3.1
$ ./autogen.sh
$ ./configure --prefix=/usr/local
$ make
$ sudo make install
```

note: The `sudo` is very important for the `make install`. Failure to do this
will result in a non-functioning or semi-functioning installation.

## To build an RPM of Singularity from a Git clone:

```
$ git clone https://github.com/singularityware/singularity.git
$ cd singularity
$ git checkout tags/2.3.1 -b 2.3.1
$ ./autogen.sh
$ ./configure
$ make dist
$ rpmbuild -ta singularity-*.tar.gz
```

### Troubleshooting

> Error running Singularity with sudo (For Fedora or Centos hosts)

This fix solves the following error when Singularity is installed into the default compiled prefix of /usr/local:

$ sudo singularity create /tmp/centos.img
sudo: singularity: command not found
The cause of the problem is that sudo sanitizes the PATH environment variable and does not include /usr/local/bin in the default search path. Considering this program path is by default owned by root, it is reasonable to extend the default sudo PATH to include this directory.

To add /usr/local/bin to the default sudo search path, run the program visudo which will edit the sudoers file, and search for the string ‘secure_path’. Once found, append :/usr/local/bin to that line so it looks like this:

```bash
Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
```

<!--
EOF!
-->
