server:
	go build -o ./gs -ldflags "-X main.GitCommit=$$(git rev-parse HEAD)" ./goserver/main.go

dockerbuild:
	docker build --rm \
		--build-arg GIT_COMMIT=$(git rev-parse HEAD) \
		-t localhost:5000/papp:$$(git rev-parse HEAD) .

dockerrun:
	docker run --name testtest \
		-d --restart unless-stopped \
		--label autoheal=true \
		-p 7777:8000 papp:$$(git rev-parse HEAD)
