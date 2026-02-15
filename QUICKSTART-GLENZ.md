# Quick Start - GLENZ Stack

Démarrez la stack GLENZ en **5 minutes** ⚡

---

## Prérequis ✅

```bash
# Vérifier Docker
docker --version  # 20.10+
docker compose version  # 2.0+

# Vérifier les ressources
free -h  # Au moins 4GB RAM disponible
df -h    # Au moins 50GB disque libre
```

---

## Installation Express (3 commandes)

```bash
# 1. Configuration système (REQUIS pour Elasticsearch)
sudo sysctl -w vm.max_map_count=262144

# 2. Configuration de l'interface réseau
cp .env.example .env
nano .env  # Modifier CAPTURE_INTERFACE (par défaut: ens33)

# 3. Démarrage
docker compose up -d
```

**C'est tout!** ✨

---

## Vérification

```bash
# Attendre 2-3 minutes que tous les services démarrent

# Vérifier l'état
docker compose ps

# Devrait afficher 8 services "Up":
# - surveillance-elasticsearch (healthy)
# - surveillance-grafana (healthy)
# - surveillance-zeek
# - surveillance-logstash
# - surveillance-dumpcap
# - surveillance-ettercap
# - surveillance-nginx
# - surveillance-grafana-init (exited 0)
```

---

## Accès aux Interfaces

### 1. Grafana (Dashboards)

```
URL: http://localhost:3000
User: admin
Pass: admin
```

**Première connexion:**
1. Aller dans **Configuration** → **Data Sources**
2. Vérifier que "Elasticsearch-Zeek" est présent et connecté
3. Aller dans **Dashboards** → **New Dashboard**
4. Créer votre premier dashboard!

### 2. Elasticsearch (API)

```bash
# Santé du cluster
curl http://localhost:9200/_cluster/health?pretty

# Lister les index
curl http://localhost:9200/_cat/indices/zeek-*?v

# Compter les documents
curl http://localhost:9200/zeek-conn-*/_count?pretty
```

### 3. Nginx (Page d'accueil)

```
URL: http://localhost
```

---

## Tests Automatiques

```bash
# Exécuter tous les tests
bash scripts/tests.sh

# Résultat attendu:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ✓ TOUS LES TESTS SONT PASSÉS !
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Vérification des Données

### Zeek génère des logs?

```bash
# Vérifier les logs Zeek
ls -lh data/logs/zeek/current/

# Devrait afficher:
# conn.log   - Connexions réseau
# dns.log    - Requêtes DNS
# http.log   - Trafic HTTP
# notice.log - Alertes

# Voir le contenu (sans les commentaires #)
grep -v "^#" data/logs/zeek/current/conn.log | head -5
```

### Logstash parse les logs?

```bash
# Vérifier les logs Logstash
docker compose logs logstash | tail -20

# Devrait afficher des messages comme:
# [INFO] Pipeline started successfully
```

### Elasticsearch reçoit les données?

```bash
# Lister les index créés
curl http://localhost:9200/_cat/indices/zeek-*?v

# Devrait afficher:
# health status index              docs.count
# yellow open   zeek-conn-2024.02.15  1234
# yellow open   zeek-dns-2024.02.15   567
# yellow open   zeek-http-2024.02.15  89
```

### PCAP sont capturés?

```bash
# Vérifier les PCAP
ls -lh data/pcap/$(date +%Y-%m-%d)/

# Devrait afficher des fichiers .pcap
# -rw-r--r-- 1 root root 50M Feb 15 10:00 capture_00001.pcap
```

---

## Premier Dashboard Grafana

### 1. Créer un dashboard "Connexions Réseau"

1. Ouvrir Grafana: http://localhost:3000
2. Cliquer sur **Dashboards** → **New Dashboard**
3. Cliquer sur **Add visualization**
4. Sélectionner **Elasticsearch-Zeek**
5. Configurer:
   - **Query**: `log_type:zeek AND event_type:connection`
   - **Metric**: Count
   - **Time field**: @timestamp
   - **Group by**: Time histogram (@timestamp)
6. Cliquer sur **Apply**
7. Cliquer sur **Save dashboard**

### 2. Ajouter un panel "Top 10 IPs"

1. Cliquer sur **Add** → **Visualization**
2. Sélectionner **Elasticsearch-Zeek**
3. Configurer:
   - **Query**: `log_type:zeek AND event_type:connection`
   - **Metric**: Count
   - **Group by**: Terms (src_ip.keyword)
   - **Size**: 10
   - **Visualization**: Table
4. Cliquer sur **Apply**

---

## Commandes Utiles

### Gestion des Services

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer tout
docker compose restart

# Redémarrer un service
docker compose restart zeek

# Voir les logs
docker compose logs -f
docker compose logs -f zeek
docker compose logs -f logstash
```

### Vérification

```bash
# État des containers
docker compose ps

# Utilisation des ressources
docker stats

# Espace disque
df -h
du -sh data/*
```

### Nettoyage

```bash
# Nettoyer les anciens index (>30 jours)
curl -X DELETE "http://localhost:9200/zeek-*-$(date -d '30 days ago' +%Y.%m.%d)"

# Nettoyer les PCAP (>7 jours)
find data/pcap -type d -mtime +7 -exec rm -rf {} \;
```

---

## Problèmes Courants

### Elasticsearch ne démarre pas

```bash
# Erreur: "vm.max_map_count too low"
sudo sysctl -w vm.max_map_count=262144

# Rendre permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Redémarrer
docker compose restart elasticsearch
```

### Zeek ne capture pas

```bash
# Vérifier l'interface existe
ip link show ens33

# Modifier .env si nécessaire
nano .env
# CAPTURE_INTERFACE=votre_interface

# Redémarrer
docker compose restart zeek
```

### Pas de données dans Elasticsearch

```bash
# Vérifier les logs Zeek existent
ls -la data/logs/zeek/current/

# Vérifier Logstash
docker compose logs logstash | grep -i error

# Redémarrer Logstash
docker compose restart logstash
```

### Grafana ne se connecte pas à Elasticsearch

```bash
# Vérifier qu'Elasticsearch répond
curl http://localhost:9200/_cluster/health

# Recréer la datasource
curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Elasticsearch-Zeek",
    "type": "elasticsearch",
    "url": "http://elasticsearch:9200",
    "access": "proxy",
    "database": "zeek-*",
    "jsonData": {
      "timeField": "@timestamp",
      "esVersion": "8.0.0"
    }
  }'
```

---

## Prochaines Étapes

### 1. Configuration Réseau

Configurer le port mirroring (SPAN) sur votre switch pour capturer tout le trafic réseau.

**Exemple Cisco:**
```
monitor session 1 source interface GigabitEthernet0/1
monitor session 1 destination interface GigabitEthernet0/24
```

### 2. Personnalisation Zeek

Modifier `configs/zeek/local.zeek` pour:
- Ajouter vos réseaux locaux
- Activer des protocoles supplémentaires
- Créer des détections personnalisées

### 3. Créer des Dashboards

Exemples de dashboards utiles:
- Vue d'ensemble du trafic réseau
- Analyse des requêtes DNS
- Trafic HTTP par user-agent
- Alertes de sécurité
- Détections MITM

### 4. Configurer l'Alerting

Dans Grafana:
1. Aller dans **Alerting** → **Alert rules**
2. Créer des alertes sur:
   - Trafic anormal
   - Requêtes DNS suspectes
   - Connexions vers des IPs blacklistées
   - Détections Ettercap

---

## Documentation Complète

- **[README.md](README.md)** - Vue d'ensemble
- **[Architecture](docs/architecture-publique.md)** - Architecture détaillée
- **[Installation](docs/installation-privee.md)** - Guide d'installation complet
- **[Migration](MIGRATION-v2-to-v3.md)** - Migrer depuis v2.0

---

## Support

Besoin d'aide?
- Exécuter `bash scripts/tests.sh` pour diagnostiquer
- Vérifier les logs: `docker compose logs -f`
- Consulter la documentation dans `docs/`

---

**🎉 Félicitations! Votre stack GLENZ est opérationnelle!**

**Accès rapide:**
- Grafana: http://localhost:3000 (admin/admin)
- Elasticsearch: http://localhost:9200
- Page d'accueil: http://localhost

---

**Version:** 3.0 - GLENZ Stack
**Date:** Février 2024
