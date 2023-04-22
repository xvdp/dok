# dok
## nested Dockerfile for remote multiuser development
### images for torch develoment with cuda

Docker images created here are meant to be used as a stack avoiding env passing in docker multistage. A baseimage can be passed into every new image.

WIP: requires netowrk validation and could benefit from some local caching.

```
ARG baseimage
FROM=${baseimage}
```
All Dockerfiles are built to be nested. For instance
```
nvidia/cuda:11.8.0-devel-ubuntu22.04
    ssh
        mamba
            torch
                other ...
```
Every folder under `.images/` contains files: `Dockerfile, build.sh`. For convenience `images/buildall.sh` files can be added to rebuild entire stack. 

When the `Dockerfile` requires external data for `ADD` or `COPY`, `build.sh` picks a location. Temporarily copies them into the `image\<name>` folder context to embeds into the image.  

## images
1. ssh: built over OS and graphic driverrs, defines users incorporates shh authorized_keys in folder, adds .bashrc, exposes port and adds to `/etc/ssh/sshd_config`
2. mamba: based on https://github.com/conda-forge/miniforge-images/blob/master/ubuntu/Dockerfile modified for nested builds.
3. torch: adds pytorch and mitsuba dev # requires correct cuda context
4. other projects: any project built on top of the the stack 

If ssh authorized_keys changes, the entire stack needs to be rebuilt.

---
## images/ssh

`./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04`

creates: `xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh:latest`

requires
* `-b baseimage   ` e.g. nvidia/cuda:11.8.0-devel-ubuntu22.04
* `-r` local root with `authorized_keys` file with valid public keys

If keys are modified, the entire stack requires rebuilding. 

optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`
* `-p   `   port, default `32778`
*  `bashrc` file in Dockerfile folder. copies to `$HOME/.bashrc` if not present build.sh will create empty

Generates a `<mantainer>/<name>_shh:<tag>`
* with Creates 3 users [`1000` `1001` `1002`] `appuser`, `appuser1`, `appuser2` part of `docker` group '999'
* if `bashrc` file exists in Dockerfile parent folder -> `$HOME/.bashrc` 
* exposes `<port>`
    * to config (docker image inspect \<maintainer\>/\<name\>:\<tag\>  -f '{{ .Config.ExposedPorts }}') 
    * sets `ENV $PORT` for reference
    * see section on running 

Should be built before any docker image that requires `$HOME`

...
## images/mamba
`./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh`

creates: `xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh

optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`

Adds mamba installation on /opt/conda and gives all users write permissions.

**TODO** save mamba to local cache, for robustness

...
## images/torch
`./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba`

creates: `xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba

optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`

Generates a docker image with latest pytorch. Baseimage needs to have appuser user, correct graphics divers to match torch build.

cmd is `bin/bash`; 

Default entry point to jupyter notebook headless, to run as bash or python run with `--entrypoint /bin/bash` or `--entrypoint python`

...
## images/diffrast_example
Example file how to add local projects

1. choose a pip installbable project eg. `cd git <projects_parent> clone https://github.com/NVlabs/nvdiffrast `
2. `./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch -i nvdiffrast -r <projects_parent>`

generates -> `xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch_diffrast_example:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch
* `-i "${ar[*]}" or <myproject>` e.g. `ar=(nvdiffrast, <myproject>)` every project requires an `ADD <myproject>` to the Dockerfile
* `-r <projects_parent>` as written `build.sh` requires every project to be inside same folder.
---
## To run from clients

1. add valid autorized_keys file on client user ` ssh-keygen -t rsa `. Save to ` cat id_rsa.pub >> <mydir_with_authorized_keys>/authorized_keys`
2. expose server port to ufw `sudo ufw enable && sudo ufw allow <port> && sudo ufw allow ssh`  **# TODO validate**
3. create and switch to remote context on client machine https://docs.docker.com/engine/security/protect-access/

```bash
docker context create --docker host=ssh://<user>@<server>--description='Remote Image' <my_remote_image>
docker context use <my_remote_image>
docker context ls
```
4. If images are built in order (only required optargs included):
``` bash
# having created a file with ssh pub keys in  <mydir_with_authorized_keys>/autorized_keys
cd ssh && ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04  -r <mydir_with_authorized_keys>
cd ../mamba && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh
cd ../torch && ./build.sh -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba
# having git cloned a pip installable project eg, https://github.com/NVlabs/nvdiffrast t0 a <myprojects_dir>
cd ../diffrast_example && ./build -b xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch -i nvdiffrast -r <myprojects_dir>
```
If furthermore the server has a mounted folder `/mnt/share` added to `docker` or 999 group with rwx to the group,

```
docker run --gpus all -it --network=host --user 1000 -v /mnt/share:/home/share --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch_diffrast_example
(base) appuser@<myservername>:~$ cd ..
(base) appuser@<myservername>:/home$ ls -lah
total 28K
drwxr-xr-x  1 root     root     4.0K Apr 21 20:35 .
drwxr-xr-x  1 root     root     4.0K Apr 21 20:35 ..
drwxr-xr-x  1 appuser  appuser  4.0K Apr 21 20:37 appuser
drwxr-xr-x  1 appuser1 appuser1 4.0K Apr 21 19:45 appuser1
drwxr-xr-x  1 appuser2 appuser2 4.0K Apr 21 19:45 appuser2
drwxrwxrwx+ 7 root     docker   4.0K Apr 21 18:08 share


(base) appuser@<myservername>:~$ python

Python 3.9.16 | packaged by conda-forge | (main, Feb  1 2023, 21:39:03) 
[GCC 11.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import nvdiffrast
>>> nvdiffrast.__version__
'0.3.0'
```
The `network=host` solution appears to enable any number of users to login sharing environments.

# WIP network tunneling and access require validation
Per port access can be also run passing -p 32728:32778 but then more need to be ufw allowed for more users.

`docker run --gpus all -it -p 32728:32778 --user 1000 -v /mnt/share:/home/share --rm xvdp/cuda_11.8.0-devel-ubuntu22.04_ssh_mamba_torch_diffrast_example`