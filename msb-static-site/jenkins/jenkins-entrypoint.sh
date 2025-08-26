#!/bin/bash
set -e

# buildkitd daemon'ı arka planda başlat
buildkitd > /var/jenkins_home/buildkitd.log 2>&1 &

# 1-2 saniye bekle (buildkitd başlasın)
sleep 2

# Sonra Jenkins'i başlat
exec /usr/bin/tini -- /usr/local/bin/jenkins.sh "$@"
