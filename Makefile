.PHONY: build terraform terraform-destroy packer 

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

run: build packer terraform

clean: terraform-destroy
	rm -rf output/

build:
	docker build -t packer .

packer: 
	rm -rf output/
	mkdir output
	docker run --volume=$(ROOT_DIR)/output:/usr/src/app/output --env-file credentials.env -it packer /bin/bash -c "cd ./packer && packer build -machine-readable . | tee /usr/src/app/output/build.log"
	grep "artifact,0,id" output/build.log | cut -d, -f6 | cut -d: -f2 > output/ami-id.out

terraform:

	docker run --env-file credentials.env --volume=$(ROOT_DIR)/output:/usr/src/app/output -it packer /bin/bash  -c 'cd ./terraform && terraform init  && terraform apply -var="ami_id=$(shell cat "output/ami-id.out")" -var="region=$(shell tail -n 1 "credentials.env" | tr -d AWS_REGION=)" -auto-approve'

terraform-destroy:
	cd terraform && terraform destroy -var="ami_id=$(shell cat 'output/ami-id.out')" -auto-approve
