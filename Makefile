help:
	@echo
	@echo "| Help"
	@echo "+======"
	@echo
	@echo "Available targets:"
	@echo  "    help:               the default, this help message"
	@echo  "    build:              build the Alpine Linux based container"
	@echo  "    build_fedora:       build the Fedora Linux based container"
	@echo  "    run:                run the latest Alpine Linux container"
	@echo  "    run_fedora:         run the latest Fedora Linux container"
	@echo  "    shell:              run a root shell in the running container"
	@echo  "    stop:               stop the running container"
	@echo  "    push:               push the Alpine Linux based image to dockerhub"
	@echo  "    push_fedora:        push the Fedora Linux based image to dockerhub"
.PHONY: help


V:=$(shell git describe --tags --dirty --always --long --match='v[0-9]*.[0-9]*' | sed 's/^v\([0-9.]*\)-.*/\1/')


build:
	podman build --tag devpi:latest --tag devpi:$(V) .
.PHONY: build


build_fedora:
	podman build --tag devpi:latest-fedora --tag devpi:$(V)-fedora fedora
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


run_fedora:
	cat /etc/subuid
	test -d data || mkdir data
	chcon -R system_u:object_r:container_file_t:s0 data || true
	podman run --rm \
		--userns=keep-id \
		--detach \
		--name devpi --publish 3141:3141 \
		--env=DEVPI_PASSWORD=localhost_password \
		--mount "type=bind,source=./data,destination=/data" \
		devpi:latest-fedora devpi
.PHONY: run_fedora


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


push_fedora:
	podman push --creds=$(USER) localhost/devpi:$(V)-fedora docker.io/$(USER)/devpi:$(V)-fedora
	podman push --creds=$(USER) localhost/devpi:latest-fedora docker.io/$(USER)/devpi:latest-fedora
.PHONY: push_fedora
