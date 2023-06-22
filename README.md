# dok
## Nested Dockerfile for remote multiuser development

This project is a stack of Docker image shells for multiuser development. OS and cuda are passed as baseimage at build time. Adding or replacing projects is modular. 

Notes:
* follow installation instructions for docker
* for deployment a ligher image with exact control of versions is preferred.


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
1. ssh: built over OS and graphic driverrs, defines users incorporates shh authorized_keys in folder, adds .bashrc, exposes port and adds to `/etc/ssh/sshd_config`. Based on https://gist.github.com/mlamarre/a3ac761bb2e47162b73e72ac7d5cc395.
2. mamba: Nested mamba image based on https://github.com/conda-forge/miniforge-images/blob/master/ubuntu/Dockerfile.
3. torch: adds pytorch and mitsuba dev # requires correct cuda context.
4. other projects, internal or github (eg. nvdiffrast) any project built on top of the the stack.

If ssh authorized_keys changes, the entire stack needs to be rebuilt.

**Notes /Caveats:**
* Build scripts are more complicated than needed, with known environments options can be hardcoded into a couple bash lines.
* The mamba/ conda is designed to run on (base) environment. With persistent multiuser containers one probably outght to run named envs.
* If the `docker context` is a remote server, `docker build` command processes the image context locally and creates the image in the server.

## TODO
* detail remote vscode/jupyter development.
* validate caching --no-cache on local projects

---
## images/ssh

`./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04`

creates: `xvdp/cuda1180-ubuntu2204_ssh:latest`

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
`./build.sh -b xvdp/cuda1180-ubuntu2204_ssh`

creates: `xvdp/cuda1180-ubuntu2204_ssh_mamba:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda1180-ubuntu2204_ssh

optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`

Adds mamba installation on /opt/conda and gives all users write permissions.

**TODO** save mamba to local cache, for robustness

...
## images/torch
`./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba`

creates: `xvdp/cuda1180-ubuntu2204_ssh_mamba_torch:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda1180-ubuntu2204_ssh_mamba
* `-r` local project root *torchvision.0.15 breaks ffmpeg unless cloned and installed*


optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`

Generates a docker image with latest pytorch. Baseimage needs to have appuser user, correct graphics divers to match torch build.

run example

`docker run --user 1000 --name torch --gpus device=1 --cpuset-cpus="14-27" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data  --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch`

Default entry point is `bin/bash`. Entry point can be redirected to python with `--entrypoint python` or jupyter. 

It can also be started in bash and attached from a differetn console to jupyter, e.g.

 `jupyter docker exec -it torchcontainer jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=32778`

...
## images/diffuse
Diffusion playground

* Pernias, Rampas, Aubrevile 2023 [Würstchen: Efficient Pretraining of Text-to-Image Models](https://arxiv.org/pdf/2306.00637.pdf)

fork -> https://github.com/xvdp/wuerstchen/tree/xdev
* Heitz, Belcour, Chambon 2023 [Iterative α-(de)Blending: a Minimalist Deterministic Diffusion Model](https://arxiv.org/pdf/2305.03486.pdf)

fork -> https://github.com/xvdp/IADB

`docker run --user 1000 --name d --gpus device=0 --cpuset-cpus="28-41" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -v /mnt/Data/results:/home/results --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_diffuse`

...
## images/diffrast_example  # TODO replace: project with different example, nvdiffrast has been included in torch image above
Example file how to add local projects.

1. choose a pip installbable project eg. `cd git <projects_parent> clone https://github.com/NVlabs/nvdiffrast `
2. `./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -i nvdiffrast -r <projects_parent>`. 
This could be used for any local project; the build.sh script, copies the project to the Dockerfile context then cleans it up. Adding or changing the project requires the Dockerfile to be modified as well.

The build sript can also clone and keep a local cache of the project. Alternatively one could clone and install every time from repository which may be more suitable in some cases.

3. `./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -g NVlabs/nvdiffrast -r <projects_parent>`.

Note. Notice that the `docker build` in build.sh is run with `--no-cache` option. This ensures that local changes to projects are propagated into the image. While the build cache is important when downloading data from cloud which could require multiple GB of data to be transferred, it is less onerous with local data. The --no-cache flags should be avoided when possible in images which are base to other images.

generates -> `xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_diffrast_example:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
* `-r <projects_parent>` as written `build.sh` requires every project to be inside same folder.
* `-i "${ar[*]}" or <myproject>` e.g. `ar=(nvdiffrast, <myproject>)` every project requires an `ADD <myproject>` to the Dockerfile
* `-g "${ar[*]}" or <gitproject>` e.g. `ar=(NVlabs/nvdiffrast, <gituser>/<gitproject>)` every project requires an `ADD <gitproject>` to the Dockerfile

---

## TODO regarding weights and data for git and local projects:
Many projects require data files or files with weigths, too large to be stored on github. These files may be distributed in many forms: github large file storage, google drives, model zoos and hubs, huggingface, etc. 

This repository does not provide a general solution. We tested three approaches for storing large data:
* son the machine where the docker images are built and copying it with the project.
* on a server drive and mounting in on docker run
* on a docker volume.

---

## run reference
https://docs.docker.com/engine/reference/commandline/run/  `docker run`

* `--user=1000 ` as user 1000  
* `--user=$(id -u):$(getent group docker | cut -d: -f3)` as current user on docker group
* `--group-add $(getent group docker | cut -d: -f3)` add to docker group
* `-it` interactive transfer signals
* `-d` detached  
* `--name` container name
* `--entrypoint /bin/bash` | `-entrypoint python` overwrite cmd 
* `--rm` autoremove on exit

network
* `-p 32778:32778` port mapping, port must be allowed thru firewall
* `--network=host` if sshd set up (as in dok/images/ssh/Dockerfile)


resources ram and cpu
* `docker info | grep "Total Memory"`  # RAM, (equivalent to `free -g` in docker)
* `docker info | grep CPU` # num CPUs
    * or `lscpu | grep "CPU(s)"` # CPUs and distribution on NUMA nodes

resources gpu https://nvidia.github.io/nvidia-container-runtime/ 
* `apt-get install nvidia-container-runtime && which nvidia-container-runtime-hook`
* `docker run -it --rm --gpus all ubuntu nvidia-smi` (equivalent to `nvidia-smi` in docker)
* `nvidia-smi topo -m `  connection matrix, cpus, gpus, links, numa affinities.
* `nvidia-smi topo -p2p rw` read write peer to peer connections (ie. are gpus nvilinked)

resource allocation # https://docs.docker.com/config/containers/resource_constraints/
* `--gpus all` or `--gpus device=0  ` or `--gpus '"device=0,1"'` 
* `--cpuset-cpus="0-13"` # when assigning cpu and gpus, check topology to ensure they are on the same numa nodes.
* `--cpus=0.5   `  # 50% of CPU time
* `--memory=32g`   # limits memory (in this case to 32G) a container can use regardless of other processes, default: unlimited
* `--kernel-memory`# limits memory a container can use of the free memory, containers wait for availability, default: unlimited

volumes: shared memory, drives, data backup  https://docs.docker.com/storage/volumes/ 
* `-v /mnt/share:/home/share` mount shared volumes (`physical:container`)

shared volume e.g. /mnt/share has to have read and write permisions to every user in shared group
* `cd /mnt/share && sudo chown -R root:docker /mnt/share && sudo chmod -R 775 /mnt/share`

interaction
* `Ctrl+P,Ctrl+Q` Detach sequence if run with `-it` without stopping container
* `exit` exits and stops container
* `docker start $name`

Multiple services from one container https://docs.docker.com/config/containers/multi-service_container/
* It is not recommended as some processes can remain services can remain hanging, but it is possible
* **TODO: use tmux**
* connecting to entrypoint from more than one client, mirrors consoles
* exec different commands on the same detached container is possible, see `exec` and `attach` example  below

---

## run examples

To run from clients on images stored in server
1. add valid autorized_keys file on client user ` ssh-keygen -t rsa `. Save to ` cat id_rsa.pub >> <mydir_with_authorized_keys>/authorized_keys`
2. expose server port to ufw `sudo ufw enable && sudo ufw allow <port> && sudo ufw allow ssh`  **# TODO validate**
3. create and switch to remote context on client machine https://docs.docker.com/engine/security/protect-access/

```bash
docker context create --docker host=ssh://<user>@<server>--description='Remote Image' <my_remote_image>
docker context use <my_remote_image>
docker context ls
```
4. Build: `images/buildall.sh`
```bash
# having created a file with ssh pub keys in $AUTH_ROOT/autorized_keys
# having a local folder with projects $PROJ_ROOT
cd ssh && ./build.sh -b nvidia/cuda:11.8.0-devel-ubuntu22.04  -r $AUTH_ROOT
cd ../mamba && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh
cd ../torch && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba
# local pip installable projects can be run with -i $myproject or -g ${gituser/gitproject} - clones and caches locally
cd ../diffrast_example && ./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba_torch -g  NVlabs/nvdiffrast -r $PROJ_ROOT
```
Run with locally shared folder `-v`
```bash
# runs -i interactive -t transfering key shortcuts --rm removed container on exit
docker run --gpus all -it --network=host --user 1000 -v /mnt/share:/home/share --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_diffrast_example

# ssh Dockerfile creates 3 users. Container /home/share links to prior created, root:docker chowned /mnt/share
(base) appuser@<myservername>:~$ ls -lah /home
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

Run detached (-d) named (--name) persistent container on partial cpu/gpu

```bash
# explicitly name container, with -dit: detached, interactive, tty
docker run --user=1000 --name VQDemo --gpus device=1 --cpuset-cpus="26-52" -v /mnt/share:/home/share --network=host -dit xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face
# attach 2 services, on one console, jupyter on the other the default entry point
docker exec -it VQDemo_changed jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=32778 # console 1
docker attach VQDemo # console 2
```

* to remove `docker container rm --force $IMAGE_ID`
* `docker rm VQDemo`

Development

committing https://docs.docker.com/engine/reference/commandline/commit/ creates a new image
``` bash
# if container add63186840f is open
docker commit add63186840f xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face_commit
# can be then be loaded w other options, e.g. different mounted volume, different resources, etc
docker run --user=1000 --name VQDemo_with_changes --gpus device=0 --cpuset-cpus="0-13" -v /mnt/OTHERFOLDER:/home/NEWSHARE --network=host -dit xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face_commit
docker ps -a
CONTAINER ID   IMAGE                                                       COMMAND                  CREATED          STATUS                      PORTS     NAMES
b50a7b37b123   xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face_commit   "/opt/nvidia/nvidia_…"   14 seconds ago   Up 13 seconds                         VQDemo_with_changes
add63186840f   xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_face          "/opt/nvidia/nvidia_…"   21 hours ago     Exited (130) 1 hour ago               VQDemo
# since run as -dit, attach to open container
docker attach VQDemo_with_changes
```

Networking
* The `network=host` solution appears to enable any number of users to login sharing environments.
* per port access can be also run passing -p 32728:32778 but then more need to be ufw allowed for more users.

```bash
# run on specific port
docker run --gpus all -it -p 32728:32778 --user 1000 -v /mnt/share:/home/share --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch
# run leveraging sshd config
docker run --gpus all -it -v /mnt/share:/home/share --network=host --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch:latest
```


# References
Docker Documentation referenced in this project
* Docker Install https://docs.docker.com/engine/install/
* Post Installation https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
* Remote Access https://docs.docker.com/config/daemon/remote-access/
* Protect Socket https://docs.docker.com/engine/security/protect-access/
* Docker context https://docs.docker.com/engine/context/working-with-contexts/
* Networking https://docs.docker.com/network/network-tutorial-host/
* Multistage Builds https://docs.docker.com/build/building/multi-stage/ (not used by this project)
* Docker Compose https://docs.docker.com/compose/ (not used by this project)
* Run reference https://docs.docker.com/engine/reference/run/
* Command Reference https://docs.docker.com/engine/reference/commandline/docker/ 

Visual Studio with Docker
* Visual Studio Remote Docker SSH https://code.visualstudio.com/docs/containers/ssh 
* Visual Studio Code Remote https://code.visualstudio.com/remote/advancedcontainers/develop-remote-host
* https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh

User Comments and Examples
* SSHD example  https://git.iitd.ac.in/cs1140221/docker/blob/85988b33d299697f410a3a92db5d537fdbee955b/docs/examples/running_ssh_service.md 
* SSHD example  https://gist.github.com/mlamarre/a3ac761bb2e47162b73e72ac7d5cc395
* SSH ports https://www.baeldung.com/linux/ssh-multiple-ports 

Ports
* enable firewall  &nbsp;  `sudo ufw enable && sudo ufw status`
* expose port &nbsp;  `sudo ufw allow $PORTN`
* check port status  &nbsp; `nmap localhost -p $PORTN`
* Check open ports  &nbsp; `netstat -lntu` (-l listening -n port number -t tcp ports -u udp ports)
