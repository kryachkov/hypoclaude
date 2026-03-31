.PHONY: build run clean

build:
	podman build -thypoclaude .

run:
	podman run --rm -it localhost/hypoclaude

./out/claude:
	podman create --name tmp-build-hypoclaude --replace localhost/hypoclaude:latest
	podman cp tmp-build-hypoclaude:/home/claude ./out/claude
	podman rm tmp-build-hypoclaude

clean:
	rm -rf ./out/claude

rebuild: build ./out/claude
