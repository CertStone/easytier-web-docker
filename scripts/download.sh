#!/bin/bash
set -e

VERSION=$1
TARGETARCH=$2
TARGETVARIANT=$3

if [ -z "$VERSION" ] || [ "$VERSION" = "latest" ]; then
  echo "Fetching latest version..."
  VERSION=$(curl -sS https://api.github.com/repos/EasyTier/EasyTier/releases/latest \
    | grep '"tag_name":' | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "Failed to fetch latest version"
    exit 1
  fi
fi

ARCH=""
case $TARGETARCH in
  "amd64") ARCH="x86_64" ;;
  "arm64") ARCH="aarch64" ;;
  "arm")
    if [ "$TARGETVARIANT" = "v7" ]; then ARCH="armv7"; else ARCH="arm"; fi
    ;;
  *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;;
esac

echo "Downloading EasyTier $VERSION for $ARCH..."
URL="https://github.com/EasyTier/EasyTier/releases/download/${VERSION}/easytier-linux-${ARCH}-${VERSION}.zip"
echo "URL: $URL"

curl -L -o easytier.zip "$URL"
unzip easytier.zip

if [ -d "easytier-linux-${ARCH}" ]; then
    mv easytier-linux-${ARCH}/* /usr/local/bin/
    rm -rf easytier-linux-${ARCH}
else
    echo "Unexpected zip structure. Listing files:"
    ls -R
    exit 1
fi

rm easytier.zip
chmod +x /usr/local/bin/easytier-core /usr/local/bin/easytier-cli

if [ -f /usr/local/bin/easytier-web-embed ]; then
    chmod +x /usr/local/bin/easytier-web-embed
fi
