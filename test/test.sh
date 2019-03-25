#!/bin/bash

# Network Configuration
sudo ./grm-sac-tool.sh -s4 -t4

# Gooroom Control Cent - Printer
sudo ./grm-sac-tool.sh -s16 -t4

# File System Mount by udisk
sudo ./grm-sac-tool.sh -s10 -t4

# Remove All Pkla Policy
sudo ./grm-sac-tool.sh -d



