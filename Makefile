.PHONY: concourse

include credentials.env
export $(shell sed 's/=.*//' credentials.env)

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
		-v DATA_DOG_API_KEY=$(DATA_DOG_API_KEY)\
