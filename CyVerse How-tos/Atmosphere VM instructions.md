# Using RStudio Server on Atmosphere

## Setting up the instance

In [Atmosphere](https://atmo.cyverse.org/application/images), we're going to be using a predefined instance type. Pick **Ubuntu 18.04 NoGUI NoDesktop Base** from the list of options, it should be near the top of the list.

The next page will give you an option to 'Add To Project' or 'Launch'. Click 'Add To Project' if you'd like to categorize the project, otherwise select 'Launch'.

In the popup, the only option to change is the "Instance Size" option. 'tiny2' should work OK for most simple tasks, but a larger instances up to a storage size of 128 GB are valid for our NEON accounts.

Hitting 'Launch' in the lower right will begin setting up the machine, which takes a little while. The next page after selecting Launch will list the machine status, once it is listed _Active_ the machine is ready.

## Accessing the instance

### On Linux/macOS
in the terminal, enter `ssh <user>@<vm.ip.address>`, where `<user>` is your CyVerse username, and the vm.ip.address is the IP Address of the instance listed on the status page of the instance. When prompted, input your CyVerse password

The first time you access the machine, you'll get a warning:

>`The authenticity of host '<vm.ip.address> (<vm.ip.address>)' can't be established.
ECDSA key fingerprint is ############.
Are you sure you want to continue connecting (yes/no)?`

Enter `yes`, and you will be connected to the instance and placed in the directory `/home/<user>/`.

### On Windows

Using a tool like PuTTY, add your CyVerse username and password to the input, as well as the IP Address of the virtual machine. The IP Address is listed under the instance status page on Atmosphere.

Once connected, a bash terminal should open with the working directory of `/home/<user>/`.

## Setting up R and RStudio

From here, we're working with a Linux operating system flavor called Ubuntu Bionic. There are some special considerations needed to get R/RStudio up and running, and the installs can take a long time.

### A Crash Course in Bash (optional)
- `ls <directory>` - List all files in a directory. Add the `-l` operator to the command (`ls -l <directory>`) for additional info on the files, like owner and permissions. This and all other commands accept tilde expansion (`~/`), which is a shorthand for `/home/<user>/`.
- `cd <directory>` - Change the current working directory to the specified path.
- `mkdir <path-to/new-dir>` - Make a directory at the specified path.
- `vim <path/to/text/file>` - Enter the vim editor (a kind of text editor) in the terminal. See below for a cheatsheet on using vim.
- `sudo apt install <package-name>` - used to install a package in Linux (more info below).
- `sudo su -` - log in as super user ('root' user). Used to edit core operating system files, exercise caution!

### vim Cheatsheet  

vim is a powerful, but annoying, means to perform text editing from the terminal. It is not very intuitive to use, but we are won't need to use it very much. Below is a quick reference to key vim commands:

- `esc` `esc` - Hitting the escape key twice will ready vim to accept commands. Used to escape a 'mode' such as edit mode or insert mode.
- `I` - Enter 'insert mode'. in this mode, use arrow keys to navigate the text, then enter text at the cursor location.
- `:q!` - Quit without saving. Must be in command accept mode (hit `esc` `esc`).
- `:w` - write your changes to the file to disk.
- `:wq` - write and quit vim.

Much more help is available [here](https://www.fprintf.net/vimCheatSheet.html)!

## Installing R
### Update Everything
To start, we will update the operating system and existing packages. Enter `sudo apt update`, then  `sudo apt upgrade` once the first command is done. You may be asked to confirm the install if the package is large, simply enter `Y` to continue the install/updates.

### Adding the right install path for R to Ubuntu
First we have to tell the machine where to get the correct files for R. This is where we use vim! Enter `sudo vim /etc/apt/sources.list` to begin editing the package source document. Vim will launch in the bash shell window.
1. use the arrow keys on your keyboard to navigate to the very end of the document (last character of the last line)
1. Enter `I` to enter insert mode (`-- INSERT --` will show up in the lower left, if all goes well)
1. Hit return and paste `deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/` into the new line of the file.
1. Hit the Escape key twice.
1. Enter `:w` to save your changes. If you messed up, hit `:q!` to abandon your changes, and try again from the top.
1. If you are done and everything is saved, hit `:q` to leave vim and go back to the bash shell.

### Getting R Installed
Now we know where to get the insall files for R. For power users such as ourselves, we'll get the dev package of R, using `sudo apt-get install r-base-dev`.

A lot of stuff will install, and you may need to confirm you'd like the packages installed. Keep an eye on the progress.

### Getting RStudio Installed
Before we can install RStudio we need the package `gdebi-core`. Use `sudo apt-get install gdebi-core` to install that.

Once that is done, use `wget https://download2.rstudio.org/rstudio-server-1.1.463-amd64.deb`, which will download a .deb package of RStudio server to your home directory.

Once the file is successfully saved, run `sudo gdebi rstudio-server-1.1.463-amd64.deb` to initiate install from the file.

After the install is completed, RStudio Server will immediately launch!

Right below some server status stuff, you will see lines that look like:
>`Feb 11 14:26:18 vm##-##.cyverse.org systemd[1]: Starting RStudio Server...
Feb 11 14:26:18 vm##-##.cyverse.org systemd[1]: Started RStudio Server.`

**Make note of the `vm##-##.cyverse.org` address listed!** This is the address you need to access RStudio sever's GUI. RStudio Server always launches on port 8787, so to access it go to `vm##-##.cyverse.org:8787`.

You can also confirm the server is running with the command `rstudio-server status`.

### Installing other key stuff for R
Before some key R packages will install, we need to add a few more Linux packages. For API-calling packages this is important; rcurl, rnoaa, httr, RNRCS, and some other packages won't install without these steps.

1. Start out by updating your linux packages, some of the stuff that came with R/RStudio may be out of date: `sudo apt update`.
1. `sudo apt-get install libcurl4-gnutls-dev` - need the libcurl package for rcurl.
1. `sudo apt-get install libxml2-dev` - need the libxml package for httr.
1. `sudo apt-get install libssl-dev` - needed for other web-interface R packages.


After these steps are done, you can use the usual `install.packages` command in the RStudio console to get packages as normal.

### GitHub

Git works the same on the VM as elsewhere, just a few pointers.

- Make a file for your git repos with `mkdir ~/GitHub/`. This will make a GitHub directory in your home direcotry. `cd ~/GitHub/` to make sure it happened.
- SSH is a very nice way to deal with authentication on GitHub! To implement this (and skip the hassle of typing your password all the time) by:
  1. Generating a new SSH key: use the command `ssh-keygen -t rsa`.
  1. View and copy the public key: enter `cat ~/.ssh/id_rsa.pub`, and copy all the junk starting with `ssh-rsa` that comes out.
  1. Go to [GitHub Keys](https://github.com/settings/keys), and click 'New SSH Key'.
  1. Title and paste the public key into the new fields. This lets the VM access GitHub without a lot of fuss.
  1. Clone new repos as needed to the vm using the SSH option.
