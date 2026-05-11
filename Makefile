.PHONY: build run clean settings.json

build:
	podman build --no-cache -thypoclaude .

run:
	podman run --rm -it localhost/hypoclaude

./out/claude:
	podman create --name tmp-build-hypoclaude --replace localhost/hypoclaude:latest
	podman cp tmp-build-hypoclaude:/home/claude ./out/claude
	podman rm tmp-build-hypoclaude

clean:
	rm -rf ./out/claude

./out/claude/settings.json:
	cp ./settings.json ./out/claude/.claude/settings.json

rebuild: clean build ./out/claude ./out/claude/settings.json
