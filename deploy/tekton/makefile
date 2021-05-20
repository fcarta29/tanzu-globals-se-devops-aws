build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f build-tekton-task.dockerfile -t harbor.tanzu.frankcarta.com/builders/tekton-task:$$TAG .; \
	docker tag harbor.tanzu.frankcarta.com/builders/tekton-task:$$TAG harbor.tanzu.frankcarta.com/builders/tekton-task:latest

clean:
	docker stop build-tekton-task \
	docker rm build-tekton-task

rebuild: clean build

run:
	docker run --name build-tekton-task -td harbor.tanzu.frankcarta.com/builders/tekton-task:latest \
	docker exec -it build-tekton-task bash -l
join:
	docker exec -it build-tekton-task bash -l
start:
	docker start build-tekton-task
stop:
	docker stop build-tekton-task

push:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker push harbor.tanzu.frankcarta.com/builders/tekton-task:$$TAG; \
	docker push harbor.tanzu.frankcarta.com/builders/tekton-task:latest

default: build
