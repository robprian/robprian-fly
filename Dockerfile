FROM debian:bookworm-slim

LABEL maintainer="robprian@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/robprian/robprian-fly"

# ARG untuk password
ARG USER_PASSWORD=ISI_DENGAN_PASSWORDMU

RUN apt-get update && apt-get install -y \
    build-essential software-properties-common \
    ca-certificates locales wget curl git \
    unzip zip tar nano vim screen htop sudo \
    neofetch tmux fail2ban ufw openssh-server \
    supervisor net-tools iptables gnupg2 \
    lsb-release dnsutils tree bash-completion \
    python3.11-venv php php-curl php-cli coreutils \
    logrotate cron \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    node -v

# Locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Direktori & permission dasar
RUN mkdir -p /root/.ssh /var/run/sshd /ghazi && \
    chmod 700 /root/.ssh && chmod 755 /var/run/sshd && chmod 777 /ghazi

# Buat user ghazi
RUN useradd -m -s /bin/bash -d /ghazi ghazi && \
    echo "ghazi:$USER_PASSWORD" | chpasswd && \
    usermod -aG sudo ghazi && \
    echo "ghazi ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R ghazi:ghazi /ghazi

# SSH Config
COPY sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config && sshd -T > /dev/null

# Hapus motd & custom welcome
RUN rm -f /etc/motd && rm -f /etc/update-motd.d/* && \
    echo -e '#!/bin/bash\necho "Welcome to Fly.io Server!"\necho "Machine ID: $(hostname)"' > /etc/update-motd.d/99-flyio && \
    chmod +x /etc/update-motd.d/99-flyio

# Cron & Logrotate
COPY logrotate.conf /etc/logrotate.d/custom_logs
RUN chmod 644 /etc/logrotate.d/custom_logs && \
    echo "0 * * * * root rm -rf /tmp/* /var/tmp/* /root/.cache" >> /etc/crontab

# Volume SSH keys
VOLUME ["/ghazi"]

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD []
