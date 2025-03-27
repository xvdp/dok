# @xvdp
# mod from https://gist.github.com/mlamarre/a3ac761bb2e47162b73e72ac7d5cc395
ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
ARG port=32778
# set pass docker gid docker run ... --group-add $(getent group docker | cut -d: -f3)
ARG dockerGID=999
# USERS: build will fail if these conflcit with
# getent group | cut -d: -f 3 
# since ubuntu 24.04 ubuntu docker image sets usergroupid 1000
ARG userGID1=1001
ARG userGID2=1002
ARG userGID3=1003
ARG userNAME1=z
ARG userNAME2=harveer
ARG userNAME3=srinivasa


LABEL MAINTAINER $maintainer

RUN echo ${baseimage}

# TODO: possible confusion, clarify sshd_config vs ufw 
# replace Port 22 -> 32778 in shd_config : to run with network=host
RUN apt-get update && apt-get install -y openssh-server




RUN mkdir /var/run/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE $port
ENV PORT $port
CMD ["sudo","/usr/sbin/sshd", "-D"]

# create users specifie in ARGS
# if shared folders with rwx on group docker are accessible to all
# alt, can add to groups on docker run ... --group-add $(getent group docker | cut -d: -f3)
RUN groupadd docker -g $dockerGID \
&& groupadd $userNAME1 -g $userGID1 && useradd -u $userGID1 $userNAME1 -g $userNAME1 && usermod -G $dockerGID $userNAME1 \
&& groupadd $userNAME2 -g $userGID2 && useradd -u $userGID2 $userNAME2 -g $userNAME2 && usermod -G $dockerGID $userNAME2 \
&& groupadd $userNAME3 -g $userGID3 && useradd -u $userGID3 $userNAME3 -g $userNAME3 && usermod -G $dockerGID $userNAME3
RUN mkdir -p /home/$userNAME1/.vscode-server /home/$userNAME1/.vscode-server-insiders \
&& chown $userNAME1:$userNAME1 /home/$userNAME1 \
&& chown $userNAME1:$userNAME1 /home/$userNAME1/.vscode-server* \
&& mkdir -p /home/$userNAME2/.vscode-server /home/$userNAME2/.vscode-server-insiders \
&& chown $userNAME2:$userNAME2 /home/$userNAME2 \
&& chown $userNAME2:$userNAME2 /home/$userNAME2/.vscode-server* \
&& mkdir -p /home/$userNAME3/.vscode-server /home/$userNAME3/.vscode-server-insiders \
&& chown $userNAME3:$userNAME3 /home/$userNAME3 \
&& chown $userNAME3:$userNAME3 /home/$userNAME3/.vscode-server* 
RUN apt-get update \
&& apt-get install -y sudo \
&& echo $userNAME1 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$userNAME1 \
&& chmod 0440 /etc/sudoers.d/$userNAME1 \
&& echo $userNAME2 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$userNAME2 \
&& chmod 0440 /etc/sudoers.d/$userNAME2 \
&& echo $userNAME3 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$userNAME3 \
&& chmod 0440 /etc/sudoers.d/$userNAME3 \
&& usermod -s /bin/bash $userNAME1 \
&& usermod -s /bin/bash $userNAME2 \
&& usermod -s /bin/bash $userNAME3

# bashrc needs could be different for all 3
ADD --chown=$userNAME1:$userNAME1 bashrc /home/$userNAME1/.bashrc
ADD --chown=$userNAME2:$userNAME2 bashrc /home/$userNAME2/.bashrc
ADD --chown=$userNAME3:$userNAME3 bashrc /home/$userNAME3/.bashrc

# TODO
# users 2 and 3 need to also be declared 
ARG USERNAME=$userNAME1
USER $USERNAME

RUN mkdir -p /home/$USERNAME/.ssh
WORKDIR /home/$USERNAME
ADD --chown=$userNAME1:$userNAME1 authorized_keys /home/$USERNAME/.ssh

RUN chmod 600 /home/$USERNAME/.ssh/authorized_keys
RUN chmod 700 /home/$USERNAME/.ssh
SHELL ["/bin/bash", "-c"]

# CMD [ "/bin/bash" ]
# if need to run docker run --rm -it --gpus device=0 xvdp/cuda1241-cudnn-ubuntu2204_ssh -c /bin/bash

