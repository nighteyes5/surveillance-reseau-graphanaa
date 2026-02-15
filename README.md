# GLENZ Stack - Network Security Surveillance Platform

**Grafana • Logstash • Elasticsearch • Nginx • Zeek**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Stack](https://img.shields.io/badge/stack-GLENZ-green.svg)](https://github.com/)

Plateforme de surveillance réseau basée sur l'analyse comportementale avec Zeek, transformation de données via Logstash, et visualisation avancée via Grafana.

---

## 🎯 Vue d'Ensemble

GLENZ est une stack de surveillance réseau conçue pour l'analyse comportementale du trafic réseau. Contrairement aux solutions basées sur des signatures (comme Suricata), cette stack utilise Zeek pour analyser le comportement du réseau et détecter les anomalies.

### Caractéristiques Principales

- 🛡️ **Analyse Comportementale** - Zeek 6.0 pour détecter les anomalies
- ⚙️ **Transformation de Données** - Logstash avec 5 pipelines dédiés
- 📊 **Visualisation Avancée** - Grafana 10.3 avec variables dynamiques
- 💾 **Capture PCAP** - Dumpcap avec ring buffer automatique
- 🔍 **Détection MITM** - Ettercap pour ARP/DNS spoofing
- 📈 **Stockage Scalable** - Elasticsearch 8.11.0

### Architecture

```
Network Traffic → Zeek (Behavioral Analysis)
                → Dumpcap (PCAP)
                → Ettercap (MITM Detection)
                  ↓
                Logstash (5 Pipelines)
                  ↓
                Elasticsearch (Storage)
                  ↓
                Grafana (Visualization)
```

---

## 🚀 Quick Start

### Prérequis

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommandé)
- 50GB disque libre
- Interface réseau en mode promiscuité

### Installation Rapide

```bash
# 1. Cloner le projet
git clone <REPO_URL>
cd surveillance-reseau

# 2. Configuration
cp .env.example .env
nano .env  # Modifier CAPTURE_INTERFACE

# 3. Configuration système (requis pour Elasticsearch)
sudo sysctl -w vm.max_map_count=262144

# 4. Démarrage
docker compose up -d

# 5. Vérification
bash scripts/tests.sh
```

### Accès aux Interfaces

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Elasticsearch** | http://localhost:9200 | - |
| **Nginx** | http://localhost | - |

---

## 📦 Composants

### Zeek 6.0 (IDS Behavioral)

Analyse comportementale du trafic réseau avec génération de 20+ types de logs.

**Logs générés:**
- `conn.log` - Connexions réseau (src, dst, proto, bytes, duration)
- `dns.log` - Requêtes DNS (query, answer, rcode)
- `http.log` - Trafic HTTP (method, uri, user_agent, status)
- `ssl.log` - Certificats SSL/TLS
- `notice.log` - Alertes comportementales

**Configuration:** `configs/zeek/local.zeek`

### Logstash 8.11.0 (Data Processing)

Transformation des logs Zeek (TSV → JSON) avec 5 pipelines dédiés.

**Pipelines:**
1. `01-zeek-conn.conf` - Parse connexions réseau
2. `02-zeek-dns.conf` - Parse requêtes DNS
3. `03-zeek-http.conf` - Parse trafic HTTP
4. `04-zeek-notice.conf` - Parse alertes Zeek
5. `05-ettercap.conf` - Parse détections Ettercap

**Configuration:** `configs/logstash/pipelines/`

### Elasticsearch 8.11.0 (Storage)

Stockage et indexation des événements avec rotation quotidienne.

**Index créés:**
- `zeek-conn-YYYY.MM.DD` - Connexions réseau
- `zeek-dns-YYYY.MM.DD` - Requêtes DNS
- `zeek-http-YYYY.MM.DD` - Trafic HTTP
- `zeek-alerts-YYYY.MM.DD` - Alertes comportementales
- `ettercap-YYYY.MM.DD` - Détections MITM

### Grafana 10.3.0 (Visualization)

Dashboards interactifs avec variables dynamiques et alerting.

**Dashboards disponibles:**
- Zeek Network Overview
- DNS Analysis
- HTTP Traffic Analysis
- Security Alerts
- MITM Detection

**Configuration:** `configs/grafana/provisioning/`

### Dumpcap (PCAP Capture)

Capture PCAP avec ring buffer automatique (10 fichiers × 1GB).

**Fonctionnalités:**
- Rotation automatique
- Rétention configurable (7 jours par défaut)
- Meilleure gestion mémoire que tcpdump

### Ettercap (MITM Detection)

Détection passive d'attaques ARP/DNS spoofing.

**Détections:**
- ARP spoofing
- DNS poisoning
- MAC address conflicts

---

## 📊 Données et Stockage

### Structure des Données

```
data/
├── elasticsearch/      # Index Elasticsearch (~1GB/jour)
├── grafana/           # Dashboards et config (10MB)
├── logs/
│   ├── zeek/         # Logs Zeek TSV (500MB/jour)
│   │   └── current/
│   │       ├── conn.log
│   │       ├── dns.log
│   │       ├── http.log
│   │       └── notice.log
│   └── ettercap/     # Logs Ettercap JSON (10MB/jour)
└── pcap/             # PCAP ring buffer (10GB max)
    └── YYYY-MM-DD/
        ├── capture_00001.pcap
        ├── capture_00002.pcap
        └── ... (10 files max)
```

### Consommation Estimée

| Type | Taille/jour | Rétention | Total |
|------|-------------|-----------|-------|
| Zeek logs | 500MB | 30 jours | 15GB |
| Elasticsearch | 1GB | 30 jours | 30GB |
| PCAP | 10GB | 7 jours | 70GB |
| Grafana | 10MB | Permanent | 10MB |
| **Total** | | | **~115GB** |

---

## 🔧 Configuration

### Variables d'Environnement (.env)

```bash
# Interface réseau à surveiller
CAPTURE_INTERFACE=ens33

# Mémoire Elasticsearch
ES_JAVA_OPTS=-Xms2g -Xmx2g

# Mémoire Logstash
LOGSTASH_JAVA_OPTS=-Xms1g -Xmx1g

# Mot de passe Grafana
GRAFANA_PASSWORD=admin

# Rétention PCAP
PCAP_RETENTION_DAYS=7
PCAP_MAX_SIZE=1000  # MB par fichier
PCAP_FILES=10       # Nombre de fichiers

# Rétention logs
LOGS_RETENTION_DAYS=30
```

### Configuration Zeek

Modifier `configs/zeek/local.zeek` pour:
- Changer les réseaux locaux (`Site::local_nets`)
- Activer/désactiver des protocoles
- Ajouter des détections personnalisées

### Configuration Logstash

Modifier les pipelines dans `configs/logstash/pipelines/` pour:
- Ajouter des filtres
- Enrichir les données (GeoIP, DNS lookup)
- Créer de nouveaux pipelines

### Configuration Grafana

Modifier `configs/grafana/provisioning/` pour:
- Ajouter des datasources
- Provisionner des dashboards
- Configurer l'alerting

---

## 📖 Documentation

- **[Architecture Publique](docs/architecture-publique.md)** - Vue d'ensemble de l'architecture
- **[Guide d'Installation](docs/installation-privee.md)** - Instructions détaillées d'installation
- **[Guide Rapide](GUIDE-RAPIDE-V2.0.md)** - Démarrage rapide (obsolète - v2.0)
- **[Changelog](CHANGELOG.md)** - Historique des versions

---

## 🧪 Tests

```bash
# Exécuter tous les tests
bash scripts/tests.sh

# Tests individuels
docker compose ps              # Vérifier les containers
docker compose logs -f         # Voir les logs
curl http://localhost:9200/_cluster/health  # Elasticsearch
curl http://localhost:3000/api/health       # Grafana
```

---

## 🛠️ Maintenance

### Démarrage/Arrêt

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer un service
docker compose restart zeek
```

### Logs

```bash
# Tous les services
docker compose logs -f

# Service spécifique
docker compose logs -f zeek
docker compose logs -f logstash
docker compose logs -f grafana
```

### Nettoyage

```bash
# Nettoyer les anciens index (>30 jours)
curl -X DELETE "http://localhost:9200/zeek-*-$(date -d '30 days ago' +%Y.%m.%d)"

# Nettoyer les PCAP (automatique via script)
find data/pcap -type d -mtime +7 -exec rm -rf {} \;

# Nettoyer tout (ATTENTION: perte de données)
docker compose down -v
rm -rf data/*
```

---

## 🐛 Dépannage

### Elasticsearch ne démarre pas

```bash
# Vérifier vm.max_map_count
sysctl vm.max_map_count

# Augmenter si nécessaire
sudo sysctl -w vm.max_map_count=262144

# Vérifier les permissions
sudo chown -R 1000:1000 data/elasticsearch
```

### Zeek ne capture pas

```bash
# Vérifier l'interface
ip link show ens33

# Activer mode promiscuité
sudo ip link set ens33 promisc on

# Vérifier les logs
docker compose logs zeek
```

### Logstash ne parse pas

```bash
# Vérifier que les logs Zeek existent
ls -la data/logs/zeek/current/

# Tester les pipelines
docker compose exec logstash logstash -f /usr/share/logstash/pipeline/01-zeek-conn.conf --config.test_and_exit

# Vérifier les logs
docker compose logs logstash | grep -i error
```

---

## 📈 Exemples de Requêtes

### Elasticsearch (curl)

```bash
# Top 10 IPs source
curl -X GET "http://localhost:9200/zeek-conn-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 0,
    "aggs": {
      "top_ips": {
        "terms": {
          "field": "src_ip.keyword",
          "size": 10
        }
      }
    }
  }'

# Requêtes DNS suspectes
curl -X GET "http://localhost:9200/zeek-dns-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "query_string": {
        "query": "dns_query:*.exe OR dns_query:*.dll"
      }
    }
  }'

# Alertes récentes
curl -X GET "http://localhost:9200/zeek-alerts-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "range": {
        "@timestamp": {
          "gte": "now-1h"
        }
      }
    }
  }'
```

### Grafana (Dashboard Queries)

```
# Top 10 protocols
Index: zeek-conn-*
Query: *
Metric: Count
Group by: proto.keyword

# DNS failures
Index: zeek-dns-*
Query: rcode_name:NXDOMAIN
Metric: Count over time

# HTTP errors
Index: zeek-http-*
Query: status_code:[400 TO 599]
Metric: Count by status_code
```

---

## 🤝 Contribution

Les contributions sont les bienvenues! Pour contribuer:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amélioration`)
3. Commit vos changements (`git commit -m 'Ajout d'une fonctionnalité'`)
4. Push vers la branche (`git push origin feature/amélioration`)
5. Ouvrir une Pull Request

---

## 📝 Différences avec v2.0

| Aspect | v2.0 (Suricata Stack) | v3.0 (GLENZ Stack) |
|--------|----------------------|-------------------|
| **IDS** | Suricata (signatures) | Zeek (behavioral) |
| **Processing** | Filebeat (forward) | Logstash (transform) |
| **Visualization** | Kibana | Grafana |
| **PCAP** | Tcpdump | Dumpcap (ring buffer) |
| **ARP** | ARPWatch | Ettercap (MITM) |
| **Data** | EVE JSON | TSV → JSON |
| **Services** | 7 | 8 |
| **RAM** | ~3.2GB | ~3.5GB |

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Auteurs

**Département Génie Informatique - UCAD ESP**
- Projet IntroSSI - DIC-2-SSI
- École Supérieure Polytechnique

---

## 📧 Support

Pour toute question ou problème:
- Ouvrir une issue sur GitHub
- Consulter la [documentation](docs/)
- Exécuter `bash scripts/tests.sh` pour diagnostiquer

---

**Version**: 3.0 - GLENZ Stack
**Date**: Février 2024
#   s u r v e i l l a n c e - r e s e a u - g r a p h a n a  
 