
FROM ubuntu

###### INSTALLING ANSIBLE ###################################
RUN apt-get update && apt-get upgrade -y 
#&&  apt-get install -y curl
RUN apt-get install software-properties-common -y
RUN apt-add-repository ppa:ansible/ansible -y
RUN apt-get install ansible -y
RUN apt-get -y install openssh-client
RUN apt-get -y install unzip jq curl
#RUN apt-get install apt-transport-https

###### INSTALLING AWS CLI ######################################
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install


#### INSTALLING KUBECTL TOOLS ################################
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
RUN apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
RUN apt-get update
RUN apt-get install kubeadm kubelet kubectl kubernetes-cni -y


###### CONFIG FILES COPY #####################################

WORKDIR /usr/src/app
COPY ./packer/  /usr/src/app/packer
COPY ./ansible/ /usr/src/app/ansible
COPY ./terraform/ /usr/src/app/terraform
COPY ./kubernetes/ /usr/src/app/kubernetes
COPY ./helm-chart/ /usr/src/app/helm-chart
COPY ./datadog/ /usr/src/app/datadog
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
RUN apt update && apt-get install terraform -y

##### INSTALLING HELM  #########################

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


