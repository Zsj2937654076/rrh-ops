#!/bin/bash

# Create user it-common
useradd it-common
useradd it-read
useradd it-ops

# Create .ssh directory and authorized_keys file
mkdir /home/it-common/.ssh
mkdir /home/it-read/.ssh
mkdir /home/it-ops/.ssh

touch /home/it-common/.ssh/authorized_keys
touch /home/it-read/.ssh/authorized_keys
touch /home/it-ops/.ssh/authorized_keys

# Set permissions for .ssh directory and authorized_keys file
chown -R it-common:it-common /home/it-common/.ssh
chown -R it-read:it-read /home/it-read/.ssh
chown -R it-ops:it-ops /home/it-ops/.ssh

chmod 700 /home/it-common/.ssh
chmod 700 /home/it-read/.ssh
chmod 700 /home/it-ops/.ssh

chmod 600 /home/it-common/.ssh/authorized_keys
chmod 600 /home/it-read/.ssh/authorized_keys
chmod 600 /home/it-ops/.ssh/authorized_keys

# Add SSH public key to authorized_keys file
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1YSQk2bB0U9cVhX7Woq3upURMQ54ppbvWWaGNhn3ELruhX4mXWzEm9DlLyp99Ld/PDs8n6t0ufmNILSse3evty24XBnNWkAqb+coeHow51wBeYdV1pn0VLae095MxLaT2cH0rGQWt2LvJPa5Vlc2K3OUJyqWBoaCbEtHWNBd0jHBzOeob2DUROCXbyWlbOoLieyOJB1sb+mfTvor5yTo9SmRHgBILylhMgxxnwBFd/+oF5zoxvx/CF1bpWRxT0jnGIE42DCDGNhg29YJbtpriLNPLFp0M1MXn51yFC+OZMyX1pGtpU6CdnRM20CyDUnd5QYOlsEBd8RNEAr9eqHwN root@itn-jumpserver-209" | sudo tee -a /home/it-common/.ssh/authorized_keys

# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1YSQk2bB0U9cVhX7Woq3upURMQ54ppbvWWaGNhn3ELruhX4mXWzEm9DlLyp99Ld/PDs8n6t0ufmNILSse3evty24XBnNWkAqb+coeHow51wBeYdV1pn0VLae095MxLaT2cH0rGQWt2LvJPa5Vlc2K3OUJyqWBoaCbEtHWNBd0jHBzOeob2DUROCXbyWlbOoLieyOJB1sb+mfTvor5yTo9SmRHgBILylhMgxxnwBFd/+oF5zoxvx/CF1bpWRxT0jnGIE42DCDGNhg29YJbtpriLNPLFp0M1MXn51yFC+OZMyX1pGtpU6CdnRM20CyDUnd5QYOlsEBd8RNEAr9eqHwN root@itn-jumpserver-209" | sudo tee -a /home/it-read/.ssh/authorized_keys

# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1YSQk2bB0U9cVhX7Woq3upURMQ54ppbvWWaGNhn3ELruhX4mXWzEm9DlLyp99Ld/PDs8n6t0ufmNILSse3evty24XBnNWkAqb+coeHow51wBeYdV1pn0VLae095MxLaT2cH0rGQWt2LvJPa5Vlc2K3OUJyqWBoaCbEtHWNBd0jHBzOeob2DUROCXbyWlbOoLieyOJB1sb+mfTvor5yTo9SmRHgBILylhMgxxnwBFd/+oF5zoxvx/CF1bpWRxT0jnGIE42DCDGNhg29YJbtpriLNPLFp0M1MXn51yFC+OZMyX1pGtpU6CdnRM20CyDUnd5QYOlsEBd8RNEAr9eqHwN root@itn-jumpserver-209" | sudo tee -a /home/it-ops/.ssh/authorized_keys



# Add it-common to sudoers file using visudo
# echo "it-common ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
# echo "it-read ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
echo "it-ops ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

echo "User it-common created successfully."
echo "User it-read created successfully."
echo "User it-ops created successfully."
