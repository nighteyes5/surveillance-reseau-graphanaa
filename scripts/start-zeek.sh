#!/bin/bash

INTERFACE=${CAPTURE_INTERFACE:-ens33}

echo "========================================="
echo "Démarrage de Zeek sur l'interface $INTERFACE"
echo "========================================="

# Créer les répertoires
mkdir -p /data/logs/zeek/current
mkdir -p /data/extracted-files

echo "Répertoires créés:"
echo "  - /data/logs/zeek/current"
echo "  - /data/extracted-files"

# Démarrer Zeek en mode standalone
echo "Lancement de Zeek..."
/usr/local/zeek/bin/zeek \
    -i $INTERFACE \
    -C \
    /usr/local/zeek/share/zeek/site/local.zeek &

ZEEK_PID=$!
echo "Zeek démarré avec PID $ZEEK_PID"

# Garder le container actif et afficher les logs
echo "Surveillance des logs Zeek..."
sleep 5
tail -f /data/logs/zeek/current/*.log
