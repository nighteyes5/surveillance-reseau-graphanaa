# 🚀 Déploiement Zero-Configuration

## Installation en 3 commandes

```bash
# 1. Cloner ou télécharger le projet
git clone <repo> surveillance-reseau
cd surveillance-reseau

# 2. (Optionnel) Changer l'interface réseau
nano docker-compose.yml
# Remplacer "ens33" par votre interface (ex: eth0, wlan0)

# 3. Démarrer TOUT automatiquement
docker compose up -d
```

**C'est tout!** 🎉

---

## Ce qui se passe automatiquement

### Au premier `docker compose up -d`:

1. **Création automatique des dossiers**
   - `data/elasticsearch/` → Base de données
   - `data/logs/suricata/` → Logs IDS
   - `data/logs/arpwatch/` → Logs ARP
   - `data/pcap/` → Captures réseau

2. **Démarrage des 7 services**
   - Elasticsearch (stockage)
   - Kibana (visualisation)
   - Suricata (IDS)
   - Tcpdump (capture PCAP)
   - ARPWatch (surveillance ARP)
   - Filebeat (collecte logs)
   - Nginx (page d'accueil)

3. **Configuration automatique de Kibana**
   - Data View "Suricata Events" (suricata-*)
   - Data View "ARPWatch Events" (arpwatch-*)
   - Définition du Data View par défaut

4. **Début de la capture** immédiat

---

## Accès aux interfaces (après ~2 minutes)

| Service | URL | Description |
|---------|-----|-------------|
| **Page d'accueil** | http://localhost | Portail principal |
| **Kibana** | http://localhost:5601 | Analyse et visualisation |
| **Elasticsearch** | http://localhost:9200 | API données |

---

## Prérequis système

### Système d'exploitation
- Ubuntu 22.04 LTS (recommandé)
- Ubuntu 20.04 LTS
- Debian 11+
- Tout Linux avec Docker

### Logiciels requis
```bash
# Docker
curl -fsSL https://get.docker.com | bash

# Docker Compose (si pas installé avec Docker)
sudo apt-get install docker-compose-plugin
```

### Configuration système requise

**Elasticsearch a besoin de `vm.max_map_count` >= 262144**

```bash
# Configuration temporaire
sudo sysctl -w vm.max_map_count=262144

# Configuration permanente
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Ressources minimales
- **CPU**: 2 cores
- **RAM**: 4 GB (8 GB recommandé)
- **Disque**: 50 GB
- **Réseau**: Interface avec accès réseau à surveiller

---

## Changer l'interface réseau

### Méthode 1: Fichier `.env` (Recommandé)

```bash
# Créer un fichier .env
cat > .env << 'EOF'
CAPTURE_INTERFACE=eth0
ARPWATCH_INTERFACE=eth0
EOF

# Redémarrer
docker compose restart
```

### Méthode 2: Modifier `docker-compose.yml`

```yaml
# Chercher ces lignes et remplacer "ens33"
environment:
  - CAPTURE_INTERFACE=eth0  # ← Changez ici
  - ARPWATCH_INTERFACE=eth0  # ← Changez ici
```

### Trouver votre interface

```bash
# Lister toutes les interfaces
ip link show

# Voir l'interface par défaut
ip route | grep default
```

Interfaces courantes:
- `ens33`, `ens192` → VMware
- `eth0`, `eth1` → Serveurs physiques
- `enp0s3` → VirtualBox
- `wlan0` → WiFi

---

## Vérifications après déploiement

### 1. Tous les containers tournent

```bash
docker compose ps
```

**Attendu**: 8 containers (7 services + 1 init terminé)

### 2. Suricata capture du trafic

```bash
# Attendre 30 secondes
sleep 30

# Vérifier les événements capturés
wc -l data/logs/suricata/eve.json
```

**Attendu**: Nombre croissant de lignes

### 3. ARPWatch capture ARP

```bash
# Générer du trafic ARP
ping -c 5 8.8.8.8

# Attendre 15 secondes
sleep 15

# Vérifier les logs
cat data/logs/arpwatch/arpwatch.log
```

**Attendu**: Événements JSON

### 4. Données dans Elasticsearch

```bash
# Compter les événements Suricata
curl -s http://localhost:9200/suricata-*/_count | jq '.count'

# Compter les événements ARPWatch
curl -s http://localhost:9200/arpwatch-*/_count | jq '.count'
```

**Attendu**: Nombres > 0

### 5. Kibana accessible

```bash
# Vérifier l'API
curl -s http://localhost:5601/api/status | jq '.status.overall.state'
```

**Attendu**: `"green"`

---

## Utilisation de Kibana

### Accéder aux données

1. Ouvrir http://localhost:5601
2. Menu (☰) → **Discover**
3. Sélectionner un Data View:
   - **Suricata Events** → Tous les événements réseau
   - **ARPWatch Events** → Événements ARP uniquement

### Recherches utiles

**Événements DNS**:
```
event_type: "dns"
```

**Requêtes vers Google**:
```
dns.rrname: *google*
```

**Connexions TLS/HTTPS**:
```
event_type: "tls"
```

**Alertes de sécurité**:
```
event_type: "alert"
```

**Nouvelles stations ARP**:
```
action: "new_station"
```

**Changements de MAC (ARP spoofing)**:
```
action: "mac_changed"
```

---

## Commandes de gestion

### Démarrer/Arrêter

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Redémarrer un service spécifique
docker compose restart suricata
```

### Logs et debug

```bash
# Voir tous les logs
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f suricata
docker compose logs -f arpwatch

# Logs des 50 dernières lignes
docker compose logs --tail 50
```

### Maintenance

```bash
# Voir l'utilisation disque
du -sh data/*

# Nettoyer les vieux PCAP (> 7 jours)
find data/pcap -type f -mtime +7 -delete

# Supprimer TOUTES les données (ATTENTION!)
docker compose down -v
sudo rm -rf data/elasticsearch/* data/logs/* data/pcap/*
```

---

## Troubleshooting rapide

### Elasticsearch ne démarre pas

```bash
# Vérifier vm.max_map_count
sysctl vm.max_map_count

# Si < 262144, configurer:
sudo sysctl -w vm.max_map_count=262144
docker compose restart elasticsearch
```

### Pas assez de RAM

```bash
# Réduire la mémoire d'Elasticsearch
nano docker-compose.yml
# Changer: ES_JAVA_OPTS=-Xms2g -Xmx2g
# En:      ES_JAVA_OPTS=-Xms1g -Xmx1g

docker compose restart elasticsearch
```

### Suricata ne capture rien

```bash
# Vérifier l'interface
docker compose logs suricata | grep "interface"

# Vérifier que l'interface existe
ip link show ens33  # Remplacer par votre interface

# Si erreur, changer l'interface dans docker-compose.yml
```

### ARPWatch vide

```bash
# Générer du trafic ARP
ping -c 10 8.8.8.8

# Attendre 15 secondes
sleep 15

# Vérifier
cat data/logs/arpwatch/arpwatch.log
```

### Kibana ne montre pas de données

```bash
# Vérifier Filebeat
docker compose logs filebeat | grep -i error

# Vérifier les index Elasticsearch
curl -s http://localhost:9200/_cat/indices?v

# Recréer les Data Views
docker compose restart kibana-init
```

---

## Désinstallation

```bash
# Arrêter et supprimer tout
docker compose down -v

# Supprimer les données (optionnel)
sudo rm -rf data/

# Supprimer les configs (optionnel)
sudo rm -rf configs/
```

---

## Support

- **Documentation complète**: `README.md`
- **Troubleshooting**: `TROUBLESHOOTING.md`
- **Fix ARPWatch**: `docs/fix-arpwatch-v2.1.md`
- **Architecture**: `docs/architecture-publique.md`

---

## 🎯 Résumé - Déploiement en 1 minute

```bash
# Sur un serveur Ubuntu 22.04 avec Docker installé

# 1. Configurer le système
sudo sysctl -w vm.max_map_count=262144

# 2. Cloner le projet
cd /opt
git clone <repo> surveillance-reseau
cd surveillance-reseau

# 3. Démarrer (TOUT est automatique)
docker compose up -d

# 4. Attendre 2 minutes
sleep 120

# 5. Ouvrir Kibana
firefox http://localhost:5601
```

**Fait! 🚀**

Vous avez maintenant:
- ✅ Capture réseau temps réel
- ✅ Détection d'intrusions (64k+ règles)
- ✅ Surveillance ARP
- ✅ Analyse Kibana
- ✅ Rétention 7j PCAP / 30j logs

**Zero configuration requise!**
