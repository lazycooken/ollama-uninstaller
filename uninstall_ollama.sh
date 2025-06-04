#!/bin/sh

set -eu

echo ">>> Stopping and disabling Ollama service (if exists)..."
if systemctl --user list-units --full -all | grep -q ollama.service; then
    systemctl --user stop ollama.service || true
    systemctl --user disable ollama.service || true
    systemctl --user daemon-reload || true
fi

echo ">>> Removing Ollama binary..."
sudo rm -f /usr/local/bin/ollama

echo ">>> Removing Ollama configuration and cache..."
rm -rf "$HOME/.ollama"
sudo rm -rf /etc/ollama 2>/dev/null || true

echo ">>> Verifying removal..."

# Check binary
if [ ! -f /usr/local/bin/ollama ]; then
    echo "✓ Ollama binary removed."
else
    echo "✗ Ollama binary still exists at /usr/local/bin/ollama"
fi

# Check service
if systemctl --user list-units --type=service | grep -q ollama.service; then
    echo "✗ Ollama service still active."
else
    echo "✓ Ollama service not running."
fi

# Check config/cache
if [ ! -d "$HOME/.ollama" ]; then
    echo "✓ User config (~/.ollama) removed."
else
    echo "✗ User config (~/.ollama) still exists."
fi

if [ ! -d "/etc/ollama" ]; then
    echo "✓ System config (/etc/ollama) removed or not present."
else
    echo "✗ System config (/etc/ollama) still exists."
fi

echo ">>> Ollama has been fully uninstalled."
