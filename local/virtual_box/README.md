# Create local server with [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

- [Download and install VirtualBox for your OS](https://www.virtualbox.org/wiki/Downloads)
- [Download the latest Debian Image](https://www.debian.org/download)

## Create a server instance

- Name the VM: `hfw_server` and the host and domain `hfwserver`
- Create user for deployment: `webdev`
- When prompted install only:
    - ssh-access
    - standard system utilities
- Once prompted with the shell, login as root and do:
    - `apt-get update`
    - `apt-get upgrade`
    - `shutdown -h now`
- In the `Network` settings, change the Adapter from attached to `NAT` to
    `Bridged Adapter` so it will get an IP that you can access from your
    local environment.
- Start the VM and check the ip with `ip address`

You can create an entry in your `/etc/hosts` to not have to use
the IP for the VM directly:

```
192.168.1.36    hfwserver.lh
```

(I use `.lh` for VM servers running in localhost)


Now you can check you can login from your computer to the VM, using
the webdev user and password.

```
ssh webdev@hfwserver.lh
```


Usually for a server, you will be provided with ssh access through
a private / public key pair (one provided by you at instance creation
time, or perhaps some default one for your account).

So we need to disable user/password login through ssh and force it to
use only a key pair.

In order to keep public / private keys independently, we generate a
new one. Remember to give it a password, so the experience will be
the same as when you use a key pair for a real server.

```
ssh-keygen -t ed25519 -C "yourname@yourdomain.com" ~/.ssh/hfw_local_server
```

And copy it to the `authorized_keys` file for `webdev` user under the `.ssh` dir in your
VM webdev user home directory:

```
ssh webdev@hfwserver.lh 'mkdir .ssh'
scp ~/.ssh/hfw_local_server.pub webdev@hfwserver:/home/webdev/.ssh/authorized_keys
```

### Disable password login

Edit `/etc/ssh/sshd_config` and find `AuthorizedKeysFile` and `PasswordAuthentication` and change it to:

```
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
```

### Create an snapshot of the VM

At his point the VM should be in a state similar to what you would get from a Virtual Server provider.
Take a snapshot of the VM so you can restore it back to a "clean" setup easily.
