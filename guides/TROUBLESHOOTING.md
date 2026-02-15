# Guide de Dépannage Rapide

## Problème: Filebeat ne démarre pas

**Symptôme**: `docker compose logs filebeat` affiche "config file must be owned by root"

**Solution**:
```bash
# 1. Corriger les permissions du fichier de config
sudo chown root:root configs/filebeat/filebeat.yml
sudo chmod 644 configs/filebeat/filebeat.yml

# 2. Supprimer le conteneur Filebeat
docker compose rm -f filebeat

# 3. Recréer le conteneur
docker compose up -d filebeat

# 4. Vérifier que Filebeat démarre sans erreur
docker compose logs filebeat

# 5. Vérifier que les données arrivent dans Elasticsearch
curl -s "http://localhost:9200/suricata-*/_count" | jq '.'
```

**Vérification**:
- Les logs Filebeat ne doivent plus afficher d'erreur de permission
- Le nombre de documents dans Elasticsearch doit augmenter
- Dans Kibana, rafraîchir la page Discover pour voir les nouveaux événements

---

## Problème: Suricata ne capture pas

**Symptôme**: Le fichier `data/logs/suricata/eve.json` ne grossit pas

**Solution**:
```bash
# 1. Vérifier que Suricata tourne
docker compose ps suricata

# 2. Vérifier les logs
docker compose logs suricata | tail -50

# 3. Vérifier l'interface réseau
ip link show

# 4. Redémarrer Suricata
docker compose restart suricata

# 5. Générer du trafic de test
ping -c 10 google.com

# 6. Vérifier que le fichier grossit
wc -l data/logs/suricata/eve.json
sleep 5
wc -l data/logs/suricata/eve.json
```

---

## Problème: Elasticsearch ne démarre pas

**Symptôme**: `docker compose ps` montre elasticsearch en "Restarting"

**Solution**:
```bash
# 1. Augmenter vm.max_map_count
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# 2. Vérifier les permissions
chmod -R 777 data/elasticsearch

# 3. Redémarrer
docker compose restart elasticsearch

# 4. Attendre 30 secondes et vérifier
sleep 30
curl http://localhost:9200/_cluster/health?pretty
```

---

## Problème: Pas assez de mémoire

**Symptôme**: Système lent, OOM (Out of Memory)

**Solution**:
```bash
# 1. Vérifier l'utilisation mémoire
free -h
docker stats

# 2. Réduire la RAM d'Elasticsearch
nano .env
# Changer: ES_MEMORY=2g → ES_MEMORY=1g

# 3. Redémarrer
docker compose restart elasticsearch
```

---

## Problème: ARPWatch ne génère pas de logs JSON

**Symptôme**:
- `data/logs/arpwatch/arpwatch.log` est vide
- `data/logs/arpwatch/arp.dat` est vide ou ne grossit pas
- Aucun événement ARP visible dans Kibana

**Diagnostic**:
```bash
# 1. Vérifier que le container tourne
docker compose ps arpwatch

# 2. Vérifier les logs du container
docker logs arpwatch --tail 30

# 3. Vérifier les fichiers générés
sudo ls -lh data/logs/arpwatch/

# 4. Vérifier que ARPWatch détecte le trafic
docker exec arpwatch ps aux | grep arpwatch
```

**Solution 1 - Vérifier le format du script**:
```bash
# Le script doit avoir des fins de ligne Unix (LF), pas Windows (CRLF)
sed -i 's/\r$//' scripts/start-arpwatch.sh

# Redémarrer ARPWatch
docker compose restart arpwatch
```

**Solution 2 - Générer du trafic ARP**:
```bash
# Forcer du trafic ARP sur le réseau
ping -c 10 192.168.158.1
ping -c 10 8.8.8.8

# Attendre 15 secondes (le moniteur tourne toutes les 10 sec)
sleep 15

# Vérifier les logs générés
sudo cat data/logs/arpwatch/arpwatch.log
```

**Solution 3 - Vérifier les permissions**:
```bash
# Corriger les permissions du volume
sudo chown -R root:root data/logs/arpwatch/
sudo chmod 755 data/logs/arpwatch/
sudo chmod 644 data/logs/arpwatch/*.log

# Redémarrer
docker compose restart arpwatch
```

**Vérification**:
```bash
# arp.dat doit se remplir (> 0 bytes)
sudo wc -c data/logs/arpwatch/arp.dat

# arpwatch.log doit contenir du JSON
sudo cat data/logs/arpwatch/arpwatch.log | tail -5

# Les événements doivent arriver dans Elasticsearch
curl -s "http://localhost:9200/arpwatch-*/_count" | jq '.'

# Vérifier dans Kibana
# → Discover → Data View: arpwatch-*
```

**Note technique**:
ARPWatch ne peut pas streamer ses événements sur stdout en temps réel. Le script `start-arpwatch.sh` utilise un système de monitoring périodique qui surveille le fichier `arp.dat` toutes les 10 secondes et génère du JSON pour chaque nouvel événement détecté.

---

## Commandes de diagnostic

```bash
# Voir l'état de tous les services
docker compose ps

# Voir les logs en temps réel
docker compose logs -f

# Voir les erreurs uniquement
docker compose logs | grep -i error

# Vérifier l'espace disque
df -h

# Vérifier la mémoire
free -h

# Vérifier les ressources Docker
docker stats

# Compter les événements capturés
wc -l data/logs/suricata/eve.json

# Compter les documents dans Elasticsearch
curl -s "http://localhost:9200/_cat/count/suricata-*?v"

# Voir les index Elasticsearch
curl -s "http://localhost:9200/_cat/indices?v"
```

---

## Réinitialisation complète

**Si rien ne fonctionne**:

```bash
# ATTENTION: Supprime toutes les données!
cd /opt/surveillance-reseau

# Arrêter et supprimer tout
docker compose down -v

# Nettoyer les données
sudo rm -rf data/elasticsearch/* data/logs/* data/pcap/*

# Reconfigurer les permissions
chmod -R 777 data/elasticsearch
sudo chown root:root configs/filebeat/filebeat.yml
sudo chmod 644 configs/filebeat/filebeat.yml

# Redémarrer
docker compose up -d

# Attendre 2 minutes
sleep 120

# Vérifier
docker compose ps
```
