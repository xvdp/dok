# @xvdp
# mod from https://gist.github.com/mlamarre/a3ac761bb2e47162b73e72ac7d5cc395
ARG baseimage
FROM ${baseimage}
ARG maintainer=xvdp
ARG port=32778
LABEL MAINTAINER $maintainer

# TODO: possible confusion, clarify sshd_config vs ufw 
# replace Port 22 -> 32778 in shd_config : to run with network=host
RUN apt-get update && apt-get install -y openssh-server
RUN sed -i "s/#Port 22/Port ${port}/g" /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE $port
ENV PORT $port
CMD ["sudo","/usr/sbin/sshd", "-D"]

# create 3 users 1000 1001 1002 with group 999 (docker) to their profiles
# if shared folders with rwx on group docker are accessible to all
# TODO could add --build-arg=sharedgroup ARG sharedgroup=999
# alt, can add to groups on docker run ... --group-add $(getent group docker | cut -d: -f3)
RUN groupadd docker -g 999 \
&& groupadd appuser -g 1000 && useradd -u 1000 appuser -g appuser && usermod -G 999 appuser \
&& groupadd appuser1 -g 1001 && useradd -u 1001 appuser1 -g appuser1 && usermod -G 999 appuser1 \
&& groupadd appuser2 -g 1002 && useradd -u 1002 appuser2 -g appuser2 && usermod -G 999 appuser1 \
&& mkdir -p /home/appuser/.vscode-server /home/appuser/.vscode-server-insiders \
&& chown appuser:appuser /home/appuser \
&& chown appuser:appuser /home/appuser/.vscode-server* \
&& mkdir -p /home/appuser1/.vscode-server /home/appuser1/.vscode-server-insiders \
&& chown appuser1:appuser1 /home/appuser1 \
&& chown appuser1:appuser1 /home/appuser1/.vscode-server* \
&& mkdir -p /home/appuser2/.vscode-server /home/appuser2/.vscode-server-insiders \
&& chown appuser2:appuser2 /home/appuser2 \
&& chown appuser2:appuser2 /home/appuser2/.vscode-server* \
&& apt-get update \
&& apt-get install -y sudo \
&& echo appuser ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/appuser \
&& chmod 0440 /etc/sudoers.d/appuser \
&& echo appuser1 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/appuser1 \
&& chmod 0440 /etc/sudoers.d/appuser1 \
&& echo appuser2 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/appuser2 \
&& chmod 0440 /etc/sudoers.d/appuser2 \
&& usermod -s /bin/bash appuser \
&& usermod -s /bin/bash appuser1 \
&& usermod -s /bin/bash appuser2

# bashrc needs could be different for all 3
ADD --chown=appuser:appuser bashrc /home/appuser/.bashrc
ADD --chown=appuser1:appuser1 bashrc /home/appuser1/.bashrc
ADD --chown=appuser2:appuser2 bashrc /home/appuser2/.bashrc

# TODO should everyone build their own? otherwise workdir for all is the same
# TODO add -u -> --build-arg USERNAME=  to the build process
ARG USERNAME=appuser
# add authorized_keys to user .ssh
# only allow log in from that user
USER $USERNAME

RUN mkdir -p /home/$USERNAME/.ssh
WORKDIR /home/$USERNAME
ADD --chown=appuser:appuser authorized_keys /home/$USERNAME/.ssh

RUN chmod 600 /home/$USERNAME/.ssh/authorized_keys
RUN chmod 700 /home/$USERNAME/.ssh
SHELL ["/bin/bash", "-c"]

CMD [ "/bin/bash" ]
