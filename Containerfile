FROM registry.fedoraproject.org/fedora:44

ENV COLORTERM=truecolor
ENV EDITOR=nvim

RUN dnf update -y && dnf install -y autoconf bat bind-utils bzip2 curl fzf gcc gdbm-devel git helm jq libffi-devel libyaml-devel make man ncurses-devel nvim openssl-devel patch perl-FindBin procps-ng rbenv readline-devel ripgrep rust tree yq zlib-ng-compat-devel zoxide zsh shellcheck xxd kubernetes1.37-client

ARG TARGETARCH
ARG TALOSCTL_VERSION=v1.14.2
RUN case "${TARGETARCH:-amd64}" in \
        amd64) sha=c6c9552b0e5f767352c595fa1c0af4f186f697488646872955057d23990a66c4 ;; \
        arm64) sha=5b7119f9cc68c1e6dcd394564208a9ae417c5cc9e8e2585fa173082e53f5e6d7 ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/talosctl "https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-${TARGETARCH:-amd64}" && \
    echo "${sha}  /usr/local/bin/talosctl" | sha256sum -c - && \
    chmod 0755 /usr/local/bin/talosctl

RUN echo "claude ALL=(ALL) NOPASSWD: /usr/bin/dnf" > /etc/sudoers.d/claude

RUN useradd -m claude -s /usr/bin/zsh

USER claude

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN rbenv init

WORKDIR /workspaces

CMD ["/usr/bin/zsh", "--login"]
