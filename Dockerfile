
FROM ubuntu

###### INSTALLING ANSIBLE ###################################

RUN apt-get update && apt-get upgrade -y &&  apt-get install -y curl
RUN apt install software-properties-common -y
RUN apt-add-repository ppa:ansible/ansible -y
RUN apt-get install ansible -y
RUN apt-get -y install openssh-client

###### CONFIG FILES COPY ####################################

WORKDIR /usr/src/app
COPY ./packer/  /usr/src/app/packer
COPY ./ansible/ /usr/src/app/ansible
COPY ./terraform/ /usr/src/app/terraform
VOLUME output
CMD ["/sbin/init"]


###### INSTALLING ANSIBLE GALAXY COLLECTION ##################
RUN mkdir -p /usr/src/app/ansible/roles
RUN ansible-galaxy collection install devsec.hardening -p .
RUN ansible-galaxy install geerlingguy.docker -p /usr/src/app/ansible/roles
RUN ansible-galaxy install geerlingguy.kubernetes -p /usr/src/app/ansible/roles


##### INSTALLING PACKER & TERRAFORM  #########################

RUN apt-get install packer 
RUN apt-get install -y gnupg wget software-properties-common
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt-get install terraform 

