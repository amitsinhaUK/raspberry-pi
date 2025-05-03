#!/bin/bash

# This script will setup a Raspberry PI as a DNS server using dnsmasq

# Check if the script is run as root

echo "Checking if the script is run as root..."

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Not running as root"
    exit 1
else
    echo "INFO: Script is running as root"
fi

# Check if dnsmasq is installed
if ! command -v dnsmasq &> /dev/null; then
    echo "INFO: dnsmasq could not be found"
    echo "INFO: Installing dnsmasq"
    apt-get update
    apt-get install -y dnsmasq
else
    echo "INFO: dnsmasq is already installed"
fi

echo "INFO: Configuring dnsmasq"

# Backup the original dnsmasq configuration file
if [ -f /etc/dnsmasq.conf ]; then
    echo "INFO: Backing up original dnsmasq configuration file"
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
else
    echo "INFO: No original dnsmasq configuration file found"
fi

# Copy the new dnsmasq configuration file
echo "INFO: Copying dnsmasq configuration file"
cp ./dnsmasq.conf /etc/dnsmasq.conf
    
echo "INFO: Setting permissions for dnsmasq configuration file"

#Chmod 644 based on the original manual installation after doing stat -c "%a" /etc/dnsmasq.conf
chmod 644 /etc/dnsmasq.conf
chown root:root /etc/dnsmasq.conf

echo "INFO: dnsmasq configuration file copied and permissions set"
echo "INFO: Setting up dnsmasq to listen on all interfaces"

# Checking dnsmasq service status
echo "INFO: Checking dnsmasq service status"

# Check if the dnsmasq service is running
if systemctl is-active --quiet dnsmasq; then
    echo "INFO: dnsmasq service is already running"
else
    echo "INFO: dnsmasq service not running"
    echo "INFO: Starting dnsmasq service..."
    systemctl start dnsmasq
    
    if systemctl is-active --quiet dnsmasq; then
        echo "INFO: dnsmasq service started successfully"
    else
        echo "ERROR: Failed to start dnsmasq service"
        exit 1
    fi
fi

# Check if the dnsmasq service is enabled to start on boot  
if systemctl is-enabled --quiet dnsmasq; then
    echo "INFO: dnsmasq service is already enabled to start on boot"
else
    echo "INFO: Enabling dnsmasq service to start on boot..."
    systemctl enable dnsmasq
fi

echo "INFO: dnsmasq configured successfully"
exit 0
# End of script