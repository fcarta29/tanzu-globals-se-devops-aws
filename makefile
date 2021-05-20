build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f build-tanzu-globals-se-devops.dockerfile -t harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:$$TAG .; \
	docker tag harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:$$TAG harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:latest

clean:
	docker stop build-tanzu-globals-se-devops
	docker rm build-tanzu-globals-se-devops

rebuild: clean build

run:
	docker run --name build-tanzu-globals-se-devops -v $$PWD/deploy:/deploy -v $$PWD/config/kube.conf:/root/.kube/config -td harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:latest
	docker exec -it build-tanzu-globals-se-devops bash -l
demo: 
	docker run --name build-tanzu-globals-se-devops -p 8080-8090:8080-8090 -v $$PWD/deploy:/deploy -v $$PWD/config/kube.conf:/root/.kube/config -td harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:latest
	docker exec -it build-tanzu-globals-se-devops bash -l
join:
	docker exec -it build-tanzu-globals-se-devops bash -l
start:
	docker start build-tanzu-globals-se-devops
stop:
	docker stop build-tanzu-globals-se-devops

push:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker push harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:$$TAG; \
	docker push harbor.tanzu.frankcarta.com/builders/tanzu-globals-se-devops:latest

default: build
