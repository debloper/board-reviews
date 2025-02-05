#!/bin/bash

# Check if repository is already configured
echo "Checking if Vicharak repository is already configured..."
if grep -q "https://apt.vicharak.in/ stable-axon axon" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo -e "Repository is already configured in /etc/apt/sources.list.d\n\nNothing to do."
    exit 0
fi
echo "No conflict; proceeding with installation."

# NOTE: USE EITHER METHOD 0 or METHOD 1, NOT BOTH AT THE SAME TIME
#       by default, method 0 is enabled; as it's versatile, even if not most secure
#       you can change that, by commenting method 0 section, and uncommenting method 1
# ALSO: you probably shouldn't need to change this; if facing issues, report it on GitHub.

# [METHOD 0] Setup repository; warn of the apt-key deprecation
echo "Setting up repository (using the older apt-key method, by default)..."
echo "Adding GPG key..."
curl -fsSL https://apt.vicharak.in/pgp-key.public | sudo apt-key add -
echo "GPG key added."

echo "Adding repo list..."
echo "deb https://apt.vicharak.in/ stable-axon axon" | \
    sudo tee /etc/apt/sources.list.d/vicharak.list
echo "Repo list added."
# [/METHOD 0]

# [METHOD 1] Setup repository, using apt signed-by directive
# echo "Setting up repository (using the newer exclusive keyrings method)..."
# echo "Adding GPG key..."
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://apt.vicharak.in/pgp-key.public | \
#     sudo gpg --dearmor -o /etc/apt/keyrings/vicharak.gpg
# echo "GPG key added."

# echo "Adding repo list..."
# echo "deb [signed-by=/etc/apt/keyrings/vicharak.gpg] https://apt.vicharak.in/ stable-axon axon" | \
#     sudo tee /etc/apt/sources.list.d/vicharak.list
# echo "Repo list added."
# [/METHOD 1]

# Update package lists
echo "Updating package lists..."
sudo apt update
echo "Package lists updated."

# Install vicharak-chat
echo "Installing vicharak-chat..."
sudo apt install vicharak-chat
echo "vicharak-chat installed."

echo -e "You can start the server by simply running: \033[1;32mvicharak-chat --console_run DeepSeek-R1-1.5B-Q8\033[0m"
echo -e "Run \033[5;31m vicharak-chat --help \033[0m for more detailed guidance."
