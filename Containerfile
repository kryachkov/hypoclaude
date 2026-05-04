FROM registry.fedoraproject.org/fedora:43

ENV COLORTERM=truecolor

RUN dnf update -y
RUN dnf install -y bat curl fzf git helm man ripgrep zoxide nvim zsh tree \
  bind-utils yq

RUN echo "claude ALL=(ALL) NOPASSWD: /usr/bin/dnf" > /etc/sudoers.d/claude

RUN useradd -m claude -s /usr/bin/zsh

USER claude

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN curl -fsSL https://claude.ai/install.sh | bash
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /workspaces

CMD ["/usr/bin/zsh", "--login"]
