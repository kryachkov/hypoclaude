.PHONY: build run clean settings.json

build:
	podman build --no-cache -tcclaude .

run:
	podman run --rm -it localhost/cclaude

./out/claude:
	podman create --name tmp-build-cclaude --replace localhost/cclaude:latest
	podman cp tmp-build-cclaude:/home/claude ./out/claude
	podman rm tmp-build-cclaude

clean:
	rm -rf ./out/claude

./out/claude/settings.json:
	cp ./settings.json ./out/claude/.claude/settings.json

rebuild: clean build ./out/claude ./out/claude/settings.json
