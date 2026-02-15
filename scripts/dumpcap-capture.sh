#!/bin/bash

# Installation de tshark/dumpcap si nécessaire
if ! command -v dumpcap &> /dev/null; then
    echo "Installation de tshark/dumpcap..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq tshark > /dev/null 2>&1
    echo "Installation terminée."
fi

INTERFACE=${CAPTURE_INTERFACE:-ens33}
RING_BUFFER_SIZE=${PCAP_MAX_SIZE:-1000}  # MB
RING_BUFFER_FILES=${PCAP_FILES:-10}      # Nombre de fichiers
RETENTION_DAYS=${PCAP_RETENTION_DAYS:-7}

DATE=$(date +%Y-%m-%d)
PCAP_DIR="/data/pcap/$DATE"
mkdir -p "$PCAP_DIR"

echo "========================================="
echo "Démarrage de Dumpcap"
echo "========================================="
echo "Interface: $INTERFACE"
echo "Taille buffer: ${RING_BUFFER_SIZE}MB"
echo "Nombre de fichiers: $RING_BUFFER_FILES"
echo "Rétention: ${RETENTION_DAYS} jours"
echo "Répertoire: $PCAP_DIR"
echo "========================================="

# Dumpcap avec ring buffer automatique (meilleur que tcpdump)
dumpcap \
    -i "$INTERFACE" \
    -b filesize:${RING_BUFFER_SIZE} \
    -b files:${RING_BUFFER_FILES} \
    -w "$PCAP_DIR/capture.pcap" \
    -P \
    -q &

DUMPCAP_PID=$!
echo "Dumpcap démarré avec PID $DUMPCAP_PID"

# Nettoyage des anciens fichiers en arrière-plan
while true; do
    find /data/pcap -type d -mtime +${RETENTION_DAYS} -exec rm -rf {} \; 2>/dev/null
    sleep 3600  # Toutes les heures
done
