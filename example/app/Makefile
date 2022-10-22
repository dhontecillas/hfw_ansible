dockerbuild:
	docker build --rm -t papp:$$(git rev-parse HEAD) .

dockerrun:
	docker run --name testtest \
		-d --restart unless-stopped \
		--label autoheal=true \
		-p 7777:8000 papp:$$(git rev-parse HEAD)
