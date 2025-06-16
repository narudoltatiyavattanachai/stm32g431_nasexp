#!/bin/bash

# === CONFIG ===
LANG_SET="en_US.UTF-8"

echo "=== Step 1: Generate locale if missing ==="
sudo locale-gen $LANG_SET
sudo update-locale

echo "=== Step 2: Set /etc/default/locale ==="
sudo bash -c "cat > /etc/default/locale <<EOF
LANG=$LANG_SET
LANGUAGE=en_US:en
LC_ALL=$LANG_SET
EOF"

echo "=== Step 3: Set /etc/environment ==="
sudo bash -c "cat > /etc/environment <<EOF
LANG=$LANG_SET
LANGUAGE=en_US:en
LC_ALL=$LANG_SET
EOF"

echo "=== Step 4: Append to ~/.profile ==="
cat <<EOF >> ~/.profile

# Force English language
export LANG=$LANG_SET
export LANGUAGE=en_US:en
export LC_ALL=$LANG_SET
EOF

echo "=== All done! Please reboot to apply: ==="
echo "    sudo reboot"
