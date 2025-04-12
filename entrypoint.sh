#!/bin/bash
set -e

# Generate SSH keys jika belum ada
mkdir -p /robprian
chmod 777 /robprian

# Buat .bash_profile jika belum ada
if [ ! -f /robprian/.bash_profile ]; then
    cat << EOF > /robprian/.bash_profile
# Load .bashrc jika ada
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Alias contoh
alias ll="ls -lah"
EOF
fi

##################
cat << 'EOF' >> /robprian/.bashrc

# Custom Prompt for robprian-fly with screen name
get_screen_name() {
    if [ -n "$STY" ]; then
        echo "${STY#*.}"
    fi
}

if [ -n "$STY" ]; then
    export PS1='[\[\e[0;32m\]robprian-fly\[\e[0m\]][\[\e[0;33m\]$(get_screen_name)\[\e[0m\]] \u@\h:\w\$ '
else
    export PS1='[\[\e[0;32m\]robprian-fly\[\e[0m\]] \u@\h:\w\$ '
fi

EOF
###################

chown -R robprian:robprian /robprian

if [ ! -f /robprian/ssh_host_ed25519_key ]; then
  echo "Generating new SSH host keys..."
  ssh-keygen -A >/dev/null
  cp /etc/ssh/ssh_host_* /robprian/
fi

# Link keys dari volume
rm -f /etc/ssh/ssh_host_*
ln -sf /robprian/* /etc/ssh/

# Setup authorized_keys
mkdir -p /root/.ssh
if [ -n "$AUTHORIZED_KEYS" ]; then
  echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
fi

# Start SSH dengan opsi eksplisit
echo "Starting SSH server..."
exec /usr/sbin/sshd -D -o "ListenAddress 0.0.0.0:2222" -e

# Token & Chat ID Telegram (ganti dengan punyamu)
TELEGRAM_BOT_TOKEN="TOKEN_TELEGRAM_KAMU"
TELEGRAM_CHAT_ID="CHAT_ID_KAMU"
#MESSAGE_THREAD_ID="TREAD_ID_KAMU"  # ID topik di super grup

# Ambil hostname Fly.io
HOSTNAME_URL="https://$FLY_APP_NAME.fly.dev"

# Kirim notifikasi ke Telegram
curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    -d "chat_id=$TELEGRAM_CHAT_ID" \
    #-d "message_thread_id=$MESSAGE_THREAD_ID" \
    -d "text=🚀 Server di Fly.io aktif! Hostname: $HOSTNAME_URL" \
    -d "parse_mode=Markdown"
