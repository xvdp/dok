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
ARG userID1=1001
ARG userID2=1002
ARG userN1=z
ARG userN2=harveer

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
&& groupadd $userN1 -g $userID1 && useradd -u $userID1 $userN1 -g $userN1 && usermod -G $dockerGID $userN1 \
&& groupadd $userN2 -g $userID2 && useradd -u $userID2 $userN2 -g $userN2 && usermod -G $dockerGID $userN2


RUN mkdir -p /home/$userN1/.vscode-server /home/$userN1/.vscode-server-insiders /home/$userN1/.ssh \
&& chown -R $userID1:$userID1 /home/$userN1 \
&& mkdir -p /home/$userN2/.vscode-server /home/$userN2/.vscode-server-insiders /home/$userN2/.ssh \
&& chown -R $userID2:$userID2 /home/$userN2


RUN apt-get update \
&& apt-get install -y sudo \
&& echo $userN1 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$userN1 \
&& chmod 0440 /etc/sudoers.d/$userN1 \
&& echo $userN2 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$userN2 \
&& chmod 0440 /etc/sudoers.d/$userN2 \
&& usermod -s /bin/bash $userN1 \
&& usermod -s /bin/bash $userN2

# bashrc needs could be different for all 3
ADD --chown=$userID1:$userID1 bashrc /home/$userN1/.bashrc
ADD --chown=$userID2:$userID2 bashrc /home/$userN2/.bashrc


# TODO
# users 2 and 3 need to also be declared 
ARG USERNAME=$userN1
USER $USERNAME
WORKDIR /home/$USERNAME
ADD --chown=$userID1:$dockerGID authorized_keys /home/$USERNAME/.ssh

RUN chmod 600 /home/$USERNAME/.ssh/authorized_keys
RUN chmod 700 /home/$USERNAME/.ssh
SHELL ["/bin/bash", "-c"]

# CMD [ "/bin/bash" ]
# if need to run docker run --rm -it --gpus device=0 xvdp/cuda1241-cudnn-ubuntu2204_ssh -c /bin/bash

