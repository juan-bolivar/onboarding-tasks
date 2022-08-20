.PHONY: build run clean kubernetes

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CRED_FILE= credentials.env
DOCKER_COMMAND= docker run --volume=$(ROOT_DIR)/output:/usr/src/app/output --env-file $(CRED_FILE) -it packer /bin/bash 
REGION= $(shell tail -n 1 "$(CRED_FILE)" | sed 's/REGION=//g' )

AWS_ACCESS_KEY_ID=$(shell head -n 1 "$(CRED_FILE)" | sed 's/AWS_ACCESS_KEY_ID=//g'  )
AWS_SECRET_ACCESS_KEY=$(shell head -n 2 "$(CRED_FILE)" | tail -n 1 | sed 's/AWS_SECRET_ACCESS_KEY=//g' )

AWS_REGION=$(shell head -n 3 "$(CRED_FILE)" | tail -n 1 | sed 's/AWS_REGION=//g')
AWS_DEFAULT_REGION=$(shell head -n 4 "$(CRED_FILE)" | tail -n 1 | sed 's/AWS_DEFAULT_REGION=//g' )

#run: build output/ami-id.out terraform


concourse:
	curl -O https://concourse-ci.org/docker-compose.yml
	docker-compose up -d
	curl 'http://localhost:8080/api/v1/cli?arch=amd64&platform=linux' -o fly  && chmod +x ./fly 
	./fly -t infra-concourse login -c http://localhost:8080 -u test -p test
	./fly -t infra-concourse set-pipeline -p infra -c concurseCI/pipeline.yaml \
		-v AWS_KEY=$(AWS_ACCESS_KEY_ID)\
		-v AWS_SECRET=$(AWS_SECRET_ACCESS_KEY)\
		-v AWS_REGION=$(AWS_REGION)\
		-v AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)\

run:
	fly -t infra-concourse trigger-job -j infra/build-and-run --output output_terraform=./output

build:
	docker build --no-cache -t packer .

output/ami-id.out:
	rm -rf output/
	mkdir output
	$(DOCKER_COMMAND) -c "cd ./packer && packer build -machine-readable . | tee /usr/src/app/output/build.log"
	grep "artifact,0,id" output/build.log | cut -d, -f6 | cut -d: -f2 > output/ami-id.out

terraform: output/ami-id.out 
	$(DOCKER_COMMAND) -c 'cd ./terraform && terraform init  && terraform apply -var="ami_id=$(shell cat "output/ami-id.out")" -var="region=$(REGION)" -auto-approve'

terraform-destroy: output/ami-id.out
	$(DOCKER_COMMAND) -c 'cd terraform &&  terraform init && terraform destroy -var="ami_id=$(shell cat "output/ami-id.out")" -var="region=$(REGION)" -auto-approve'


kubernetes:
	$(DOCKER_COMMAND) -c 'cd kubernetes && bash ./script.sh'


clean: terraform-destroy
	rm -rf output/
