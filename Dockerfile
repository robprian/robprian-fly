FROM debian:bookworm-slim

# Install paket dasar dan dependensi
RUN apt-get update && apt-get install -y \
    build-essential software-properties-common \
    ca-certificates locales wget curl git \
    unzip zip tar nano vim screen htop sudo \
    neofetch tmux fail2ban ufw openssh-server \
    supervisor net-tools iptables gnupg2 \
    lsb-release dnsutils tree bash-completion \
    python3.11-venv php php-curl php-cli coreutils \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.1.0
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    node -v

# Konfigurasi locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Konfigurasi SSH
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    mkdir /var/run/sshd && \
    chmod 755 /var/run/sshd

COPY sshd_config /etc/ssh/sshd_config
RUN chmod 600 /etc/ssh/sshd_config

RUN ssh-keygen -A

RUN rm -f /etc/ssh/ssh_host_* && \
    mkdir -p /robprian && \
    chmod 777 /robprian

# Buat user robprian
RUN mkdir -p /robprian && \
    useradd -m -s /bin/bash -d /robprian robprian && \
    echo "robprian:passwordmu" | chpasswd && \
    usermod -aG sudo robprian && \
    echo "robprian ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R robprian:robprian /robprian

# remove motd
RUN rm -f /etc/motd && \
    rm -f /etc/update-motd.d/*

# Create custom MOTD script
RUN echo '#!/bin/bash' > /etc/update-motd.d/99-flyio && \
    echo 'echo "Welcome to Fly.io Server!"' >> /etc/update-motd.d/99-flyio && \
    echo 'echo "Machine ID: $(hostname)"' >> /etc/update-motd.d/99-flyio && \
    chmod +x /etc/update-motd.d/99-flyio

# Install logrotate & cron
RUN apt-get update && apt-get install -y logrotate cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy konfigurasi logrotate yang benar
COPY logrotate.conf /etc/logrotate.d/custom_logs
RUN chmod 644 /etc/logrotate.d/custom_logs

# Setup cronjob untuk bersihin /tmp setiap jam
RUN echo "0 * * * * root rm -rf /tmp/* /var/tmp/* /root/.cache" >> /etc/crontab && \
    chmod 644 /etc/crontab


COPY entrypoint.sh /entrypoint.sh

# Setup volume untuk kunci SSH persisten
VOLUME ["/robprian"]

# Setup entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Default command (jika diperlukan)
CMD []
