# dok
## Nested Dockerfiles for remote multiuser dev. Projects are specific to torch & ML

This is intended for development, **not for deployment**.
* build scripts cache gits to local folders preventing unnecessary downloads.
* multiple users with sudo rights are created, ssh is set up for remote acess, common caching and data folders are exposed.
* to allow multiple access to same container, entrypoint is not specified by default instead specifying a command. This allows same container to be run by users using different entrypoints. 

Most Docker examples are intended for deployment, but containerization can also be useful for development, the purpose of this project. Deployment projects do not need sudo apt access or multiuser envinronments and require the small footprint. 
To create a deployment project based on this strip down to only the necessary installs, the images on this project would be too large for efficient deployment. 
## Installation
* image OS may be different or ahead from machine OS.
* requires docker installed and configured.
* machine graphic driver $\geq$ driver req'd. by image
* install cuda toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

## Project structure
OS and CUDA version are passed as baseimage at build time.

Every image takes in a baseimage arg to enable rebuilding and testing projects on new code easily.
```
ARG baseimage
FROM=${baseimage}
```
Designed to be modular with nested images.
```
$BASEIMAGE     OS and Graphics driver, can be passed to build scipts -b or 
    ssh                     auth. base (ssh, ports, users, .bashrc) rebuild stack on authorized_keys change
        mamba
            torch           torch base image (torch 2.0.1, nvdiffrast, drjit, transformers, diffusion, jupyter)
                diffuse:    Diffusion sandbox wip ( iadb wuerstchen )
                lang:       language  sandbox wip ( whisper llama )
                rf:         radiance fields sandbox wip ( kaloin )
                gans:       GAN sandbox wip ( stylegan3 )

xvdp/cuda:12.1.0-devel-ubuntu22.04
    ssh
        mamba
            torch       torch >= 2.1
                tts:        text to speech (coqui-ai/TTS, suno-ai/bark)
```
# images

## ./images/ssh 
Base to other images. Gives users authorized to access build machine ( from ~/.ssh/authorized_keys ) or -r authorized_keys
* access to the shared docker images.
* sudoer priviledge inside the docker images, necessary for develoment. 
* exposes port and adds to `/etc/ssh/sshd_config`.


Based on https://gist.github.com/mlamarre/a3ac761bb2e47162b73e72ac7d5cc395.

* **If autorized keys are modified, the entire stack requires rebuilding.**
Requires OS, docker and graphics driver on machines.

Build command: `./build.sh -b <baseimage>`  or `./images/buildall.sh`
Args. defaults, can be set in `dok/.confg.sh` or in `build.sh`
* `-b baseimage   ` e.g. nvidia/cuda:12.8.0-devel-ubuntu24.04 Tested with Ubuntu 18.04 to 24.04.
* `-r   `   authorized keys file, default .lo
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`
* `-p   `   port, default `32778`
*  `bashrc` file in Dockerfile folder. copies to `$HOME/.bashrc` if not present build.sh will create empty

Generates a `<mantainer>/<name>_shh:<tag>`
* with 3 users [`1001` `1002` `1003`] `z`, `harveer`, `srivinasa` part of `docker` group.
    * GID and usernames in `images/ssh/Dockerfile`
    * **if user gids exist in baseimage build fails, since ubuntu 24.04 user 1000 is generated**
* if `bashrc` file exists in Dockerfile parent folder -> `$HOME/.bashrc` 
* exposes `<port>`
    * to config (docker image inspect \<maintainer\>/\<name\>:\<tag\>  -f '{{ .Config.ExposedPorts }}') 
    * sets `ENV $PORT` for reference
    * see section on running 

Should be built before any docker image that requires `$HOME`.
### Test
```bash
$ ./build.sh -b "nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04"
$ image="xvdp/cuda1263-cudnn-ubuntu2404_ssh"
$ docker run --user 1001 -it --rm --gpus all $image # user z::1001 defined in Dockerfile

nvidia-smi        # shows cards, if fail debug cuda toolkit installation
cat /etc/passwd   # shows users including those defined in Dockerfile
dig=$(getent group | grep docker | cut -d: -f 3)    # docker group id
id -G             # shows user groups: 1001 and $dig
sudo apt update   # user 1001 is sudoer, should work
```

---
## ./images/mamba
Nested mamba image based on https://github.com/conda-forge/miniforge-images/blob/master/ubuntu/Dockerfile. Images are built on (base) env.

`./build.sh -b xvdp/cuda1180-ubuntu2204_ssh`
Adds mamba/conda -- used by all subsequent projects

creates: `xvdp/cuda1180-ubuntu2204_ssh_mamba:latest`

requires
* `-b baseimage   `  e.g. xvdp/cuda1180-ubuntu2204_ssh

optional
* `-m   `   maintainer, default: `xvdp`
* `-n   `   name,  default: baseimage
* `-t   `   tag, default `latest`

Adds mamba installation on /opt/conda and gives all users write permissions.

# Modifications:
 - added images/config.yaml for builds and running / not replaced builds yet. requires yq `snap install yq`
 - added images/docker_run.sh to 
    example `./docker_run.sh config.yaml deepseek`

## Build Scripts:

* `./config.sh` contains userinfo sourced by build.sh and buildall.sh Modify to own paths.
    * `BASEIMAGE="nvidia/cuda:12.1.0-devel-ubuntu22.04"` # OS and CUDA <= CUDA version on machine
    * `MAINTAINER=xvdp`
    * `DEFAULTTAG=latest`# image name will be $MAINTAINER/<ImageName>$DEFAULTTAG
* `./buildall.sh` Builds a pyramid of images sourcing varialbes from `config.sh`


* Example projects, **images/\<project\>**, contain a `build.sh` script and a `Dockerfile`

* `./images/utils.sh` common bash utilities, sourced by build.sh

To prevent unnecessary downloads:
* Github projects are downloaded and cached locally in `build.sh` scripts, instead of pulling on Dockerfile.
* Env variables (eg. TORCH_HOME, etc.) to cache container runtime installs are called `./dockerrun` and other shortcut scripts.

Run Scripts
* `./dockerrun <args> --cache <shared vol>:<mounted vol>` Similar to `docker run` with extra arg `--cache`.  The cache arg creates a volume argument and environenment variables inside the container which can be used as commond download loctions. Default environments are created for **TORCH_HOME, TORCH_EXTENSIONS_DIR, DNNLIB_CACHE_DIR, HUGGINGFACE_HOME, TTS_HOME**. 
* `./dockerglrun <args> --cache <shared vol>:<mounted vol>` Similar to `./dockerrun` for local .Xauth mapping for gl dependent projects, e.g. `_gans`
* `./dokrun -i ``./runrf`, `./runlang`, etc. shortcut scripts do `dockerrun` for specific projects to further simplify docker run verbosity

```bash
SHR=\mnt\MyDrive\weights
VOL=\home\weights
IMG=<maintainer\dockerimage:tag>
bash dockerrun --user 1001 -it --rm --cache $SHR:$VOL $IMG
# is similar to
docker run --user 1001 -it --rm -v $SHR:$VOLs -e TORCH_HOME="${VOL}\torch" -e HUGGINGFACE_HOME="${VOL}\huggingface" $IMG
# alternatively create shortcut, see example script
bash runlang
```

## TODO
* vscode development
* enable remote graphical interface, X11 forwarding thru ssh
<!-- * add local language docker images e.g. https://hub.docker.com/r/ollama/ollama -->

<!-- how to change docker tags and backup external image
docker tag nvidia/cuda:11.8.0-devel-ubuntu22.04  xvdp/cuda:11.8.0-devel-ubuntu22.04 
docker push xvdp/cuda:11.8.0-devel-ubuntu22.04
-->

---


---
## ./images/torch
`./build.sh -b xvdp/cuda1180-ubuntu2204_ssh_mamba`
Main workhorse of these projects, collection of  general conda/pip libraries required for pytorch based machine learning projects. As new projects are added, this file is updated to include new requirements, includes:
* pytorch, torchvision, torchaudio, numpy, ffmpeg, sckit &  other standard vision libs
* nvdiffrast, drjit differential rendering packages
* huggingface diffusers, transformers
* jupyter: contains an alias to run jupyter to port exposed in image/ssh: `jupy` enabling remote jupyter deployment
* **warning: this image is too heavy for deployment, build slim image without every library**

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

It can also be started in bash and attached from a different console to jupyter, e.g.

 `jupyter docker exec -it torch jupyter notebook --allow-root -y --no-browser --ip=0.0.0.0 --port=32778`

---
# sandbox images

## ./images/diffuse
Diffusion playground. Incipient, only 2 recent projects added.

* Pernias, Rampas, Aubrevile 2023 [Würstchen: Efficient Pretraining of Text-to-Image Models](https://arxiv.org/pdf/2306.00637.pdf)

fork -> https://github.com/xvdp/wuerstchen/tree/xdev
* Heitz, Belcour, Chambon 2023 [Iterative α-(de)Blending: a Minimalist Deterministic Diffusion Model](https://arxiv.org/pdf/2305.03486.pdf)

fork -> https://github.com/xvdp/IADB

`docker run --user 1000 --name d --gpus device=0 --cpuset-cpus="28-41" -v /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -v /mnt/Data/results:/home/results --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_diffuse`

---
## ./images/lang
Language models playground

`dockerrun --user 1000 --name lang --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -v /mnt/Data/results:/home/results --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_lang`


### whisper
Radford [Robust Speech Recognition via Large-Scale Weak Supervision](https://docs.google.com/document/d/1oiOcXcCM1rrx64EFAU03KUMkvlMW0hTANpkkOwCxJUQ/edit). Project and weights opensourced at https://github.com/openai/whisper

Build and run e.g.`   whisper myaudio.wav --model medium -o ~/results/whisper -f "srt"`.

For full set of args look at project README and code https://github.com/openai/whisper/blob/main/whisper/transcribe.py

### llama
Touvron 2023 [LLaMA Open and Efficient Foundation Language Models](https://arxiv.org/pdf/2302.13971.pdf). Weights must be requested from https://github.com/facebookresearch/llama

``` bash
# from llama readme
WTS=/home/weights/llama
model=(7B 13B 33B 65B)
nproc=(1 2 4 8)
i=0
torchrun --nproc_per_node "${nproc[$i]}" example.py --ckpt_dir "${WTS}/${model[$i]}" --tokenizer_path "${WTS}/tokenizer.model" 
```
Training Requires 80G, inference 24GB. Models are sharded and require
* 7B -  1GPU
* 13B - 2GPUS
* 33B - 4GPUS
* 65B - 8GPUS

### gpt
GPT-J 6B 275B 1.3B 2.7B 6.7B 13B 33B


---
## ./images/gans

* Karras et al 21 [Alias-Free Generative Adversarial Networks](https://arxiv.org/pdf/2106.12423.pdf)
Adapted from stylegan3 https://github.com/xvdp/stylegan3 Dockerfile. Can be run locally with GL visualiztion: example

`./dockerglrun --user 1000 --name torch --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data -network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_gans`

---
## ./images/rf

Randiance fields
* kaolin
* gaussian splatting
Todo: description add nerf models



---
# run reference
**` ./dockerrun <args>  `**

 similar to ` docker run <args>  ` with extra arg `--cache` which maps to env and volume: -e and -v with the purpose of replacing ~/.cache with a mounted volume for selected env variables.
 Modify `names` and `paths` inside script. <br>`names=(TORCH_HOME TORCH_EXTENSIONS_DIR DNNLIB_CACHE_DIR HUGGINGFACE_HOME)`<br>
 Example:

` ./dockerrun --user 1000 --name torch --gpus device=0 --cpuset-cpus="0-10" --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch`

calls command

` docker run --user 1000 --name torch --gpus device=0 --cpuset-cpus=0-10 --network=host -it --rm -v /mnt/Data/weights:/home/weights -e XDG_CACHE_HOME=/home/weights -e TORCH_HOME=/home/weights/torch -e TORCH_EXTENSIONS_DIR=/home/weights/torch_extensions -e DNNLIB_CACHE_DIR=/home/weights/dnnlib -e HUGGINGFACE_HOME=/home/weights/huggingface xvdp/cuda1180-ubuntu2204_ssh_mamba_torch `

**` ./dockerglrun <args> `**

similar to `.dockerrun` transferring .xauthority and $DISPLAY, only enabled for docker using locally.
Example:

`./dockerglrun --user 1000 --name torch --gpus all --cache /mnt/Data/weights:/home/weights -v /mnt/Data/data:/home/data --network=host -it --rm xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_gans`

calls command

`docker run --user 1000 --name torch --gpus all -v /mnt/Data/data:/home/data --network=host -it --rm -e DISPLAY=unix:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v /tmp/.docker.xauth:/tmp/.docker.xauth:rw -e XAUTHORITY=/tmp/.docker.xauth -v /dev:/dev -v /mnt/Data/weights:/home/weights -e XDG_CACHE_HOME=/home/weights -e TORCH_HOME=/home/weights/torch -e TORCH_EXTENSIONS_DIR=/home/weights/torch_extensions -e DNNLIB_CACHE_DIR=/home/weights/dnnlib -e HUGGINGFACE_HOME=/home/weights/huggingface xvdp/cuda1180-ubuntu2204_ssh_mamba_torch_gans`



https://docs.docker.com/engine/reference/commandline/run/  `docker run`

adds a command

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

jupyter notebook --no-browser


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
