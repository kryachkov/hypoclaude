FROM registry.fedoraproject.org/fedora:44

ENV COLORTERM=truecolor

RUN dnf update -y && dnf install -y autoconf bat bind-utils bzip2 curl fzf gcc gdbm-devel git helm libffi-devel libyaml-devel make man ncurses-devel nvim openssl-devel patch perl-FindBin procps-ng rbenv readline-devel ripgrep rust tree yq zlib-ng-compat-devel zoxide zsh

RUN echo "claude ALL=(ALL) NOPASSWD: /usr/bin/dnf" > /etc/sudoers.d/claude

RUN useradd -m claude -s /usr/bin/zsh

USER claude

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN rbenv init

WORKDIR /workspaces

CMD ["/usr/bin/zsh", "--login"]
