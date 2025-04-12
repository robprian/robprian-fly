#!/bin/bash
set -e

# Path user
USER_HOME="/ghazi"
USER_NAME="ghazi"

# Generate folder volume & beri permission
mkdir -p "$USER_HOME"
chmod 777 "$USER_HOME"

# Buat .bash_profile jika belum ada
if [ ! -f "$USER_HOME/.bash_profile" ]; then
    cat << 'EOF' > "$USER_HOME/.bash_profile"
# Load .bashrc jika ada
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
fi

# Buat atau tambahkan prompt custom ke .bashrc
if ! grep -q "get_screen_name" "$USER_HOME/.bashrc" 2>/dev/null; then
    cat << 'EOF' >> "$USER_HOME/.bashrc"

# === Custom Prompt with Screen Name ===
get_screen_name() {
    if [ -n "\$STY" ]; then
        echo "\${STY#*.}"
    fi
}

if [ -n "\$STY" ]; then
    export PS1='[\[\e[0;33m\]\$(get_screen_name)\[\e[0m\]] \u@\h:\w\$ '
else
    export PS1='\u@\h:\w\$ '
fi
EOF
fi

# Pastikan ownership
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"

# SSH key management
if [ ! -f "$USER_HOME/ssh_host_ed25519_key" ]; then
    echo "Generating new SSH host keys..."
    ssh-keygen -A >/dev/null
    cp /etc/ssh/ssh_host_* "$USER_HOME/"
fi

# Link ulang key host dari volume
rm -f /etc/ssh/ssh_host_*
ln -sf "$USER_HOME"/* /etc/ssh/

# Setup authorized_keys dari ENV jika ada
mkdir -p /root/.ssh
if [ -n "$AUTHORIZED_KEYS" ]; then
    echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Jalankan SSH
echo "Starting SSH server..."
exec /usr/sbin/sshd -D -o "ListenAddress 0.0.0.0:2222" -e
