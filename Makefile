help:
	@echo
	@echo "| Help"
	@echo "+======"
	@echo
	@echo "Available targets:"
	@echo  "    help:               the default, this help message"
	@echo  "    build:              build the container"
	@echo  "    run:                run the latest container"
	@echo  "    stop:               stop the running container"
	@echo  "    push:               push the image to dockerhub"
.PHONY: help


V:=$(shell git describe --tags --dirty --always --long --match='v[0-9]*.[0-9]*' | sed 's/^v\([0-9.]*\)-.*/\1/')


build:
	podman build --tag devpi:latest --tag devpi:$(V) .
.PHONY: build


run:
	cat /etc/subuid
	test -d data || mkdir data
	chcon -R system_u:object_r:container_file_t:s0 data || true
	podman run --rm \
		--userns=keep-id \
		--detach \
		--name devpi --publish 3141:3141 \
		--env=DEVPI_PASSWORD=localhost_password \
		--mount "type=bind,source=./data,destination=/data" \
		devpi:latest devpi
.PHONY: run


shell:
	podman exec -u 0 -it devpi /bin/su -
.PHONY: shell


stop:
	podman stop devpi
.PHONY: stop


push:
	podman push --creds=$(USER) localhost/devpi:$(V) docker.io/$(USER)/devpi:$(V)
	podman push --creds=$(USER) localhost/devpi:latest docker.io/$(USER)/devpi:latest
.PHONY: push
