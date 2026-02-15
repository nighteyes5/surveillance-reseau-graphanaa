#!/bin/bash

INTERFACE=${CAPTURE_INTERFACE:-ens33}

echo "========================================="
echo "Démarrage d'Ettercap (Mode passif)"
echo "========================================="

# Installation d'Ettercap
echo "Installation d'Ettercap..."
apt-get update -qq && apt-get install -y -qq ettercap-text-only jq 2>/dev/null

mkdir -p /data/logs/ettercap

echo "Interface: $INTERFACE"
echo "Mode: Passif (détection ARP/DNS sans injection)"
echo "Logs: /data/logs/ettercap/"
echo "========================================="

# Ettercap en mode passif (détection ARP/DNS sans injection)
ettercap \
    -T \
    -i "$INTERFACE" \
    -P autoadd \
    -L /data/logs/ettercap/ettercap \
    -q &

ETTERCAP_PID=$!
echo "Ettercap démarré avec PID $ETTERCAP_PID"

# Attendre que le fichier de log soit créé
sleep 5

# Parser les logs et générer du JSON pour Logstash
echo "Démarrage du parser de logs..."
if [ -f /data/logs/ettercap/ettercap.eci ]; then
    tail -f /data/logs/ettercap/ettercap.eci | \
    while read line; do
        echo "{\"timestamp\":\"$(date -Iseconds)\",\"event\":\"$line\",\"interface\":\"$INTERFACE\"}" >> /data/logs/ettercap/ettercap.log
    done
else
    echo "AVERTISSEMENT: Fichier ettercap.eci non trouvé, création d'un fichier vide"
    touch /data/logs/ettercap/ettercap.log
    tail -f /data/logs/ettercap/ettercap.log
fi
