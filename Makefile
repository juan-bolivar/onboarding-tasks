.PHONY: build run clean

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CRED_FILE= credentials.env
DOCKER_COMMAND= docker run --volume=$(ROOT_DIR)/output:/usr/src/app/output --env-file $(CRED_FILE) -it packer /bin/bash 
REGION= $(shell tail -n 1 "$(CRED_FILE)" | tr -d AWS_REGION=)

run: build output/ami-id.out terraform

build:
	docker build -t packer .

output/ami-id.out:
	rm -rf output/
	mkdir output
	$(DOCKER_COMMAND) -c "cd ./packer && packer build -machine-readable . | tee /usr/src/app/output/build.log"
	grep "artifact,0,id" output/build.log | cut -d, -f6 | cut -d: -f2 > output/ami-id.out

terraform: output/ami-id.out 
	$(DOCKER_COMMAND) -c 'cd ./terraform && terraform init  && terraform apply -var="ami_id=$(shell cat "output/ami-id.out")" -var="region=$(REGION)" -auto-approve'

terraform-destroy: output/ami-id.out
	$(DOCKER_COMMAND) -c 'cd terraform &&  terraform init && terraform destroy -var="ami_id=$(shell cat "output/ami-id.out")" -var="region=$(REGION)" -auto-approve'

clean: terraform-destroy
	rm -rf output/
