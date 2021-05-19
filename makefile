build:
	TAG=`git rev-parse --short=8 HEAD`; \
	docker build --rm -f build-tanzu-globals-se-devops.dockerfile -t fcarta29/build-tanzu-globals-se-devops:$$TAG .; \
	docker tag fcarta29/build-tanzu-globals-se-devops:$$TAG fcarta29/build-tanzu-globals-se-devops:latest

clean:
	docker stop build-tanzu-globals-se-devops
	docker rm build-tanzu-globals-se-devops

rebuild: clean build

run:
# Re-enable this when adding jupyter notebooks back in
	docker run --name build-tanzu-globals-se-devops -v $$PWD/deploy:/deploy -v $$PWD/config/kube.conf:/root/.kube/config -td fcarta29/build-tanzu-globals-se-devops:latest
	docker exec -it build-tanzu-globals-se-devops bash -l
join:
	docker exec -it build-tanzu-globals-se-devops bash -l
start:
	docker start build-tanzu-globals-se-devops
stop:
	docker stop build-tanzu-globals-se-devops

default: build
