#!/bin/sh
set -x

# Start RAC Plugin
cd /usr/local/HiPKILocalSignServerApp && ./start.sh &

# Start plugin for health insurance card
/usr/local/share/NHIICC/mLNHIICC

tail -f /dev/null
