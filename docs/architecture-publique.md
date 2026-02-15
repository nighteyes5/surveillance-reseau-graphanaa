# Architecture du Système de Surveillance Réseau

Projet GLENZ (Grafana-Logstash-Elasticsearch-Nginx-Zeek)  
École Supérieure Polytechnique - UCAD  
Département Génie Informatique

## Vue d'ensemble

Ce projet met en place un système de surveillance réseau pour le laboratoire. L'idée principale est de capturer tout le trafic réseau, l'analyser avec Zeek, puis stocker et visualiser les résultats dans Elasticsearch et Grafana.

On a choisi Zeek plutôt qu'un IDS classique parce qu'il analyse le comportement du réseau au lieu de chercher des signatures d'attaques connues. Ça permet de détecter des choses inhabituelles même si on ne sait pas exactement ce qu'on cherche.

### Ce que fait le système

Le système capture le trafic réseau complet (fichiers PCAP) et génère des logs détaillés sur les connexions, les requêtes DNS, le trafic HTTP, etc. Zeek s'occupe de l'analyse en temps réel, Logstash transforme les logs pour les rendre exploitables, Elasticsearch les stocke, et Grafana permet de tout visualiser.

On a aussi ajouté Ettercap pour détecter les attaques de type man-in-the-middle (ARP spoofing, DNS poisoning).

## Composants utilisés

- **Zeek 6.0** : analyse le trafic réseau et génère des logs détaillés (connexions, DNS, HTTP, SSL, etc.)
- **Dumpcap** : capture les paquets complets en PCAP avec rotation automatique (ring buffer de 10 fichiers × 1GB)
- **Ettercap** : détecte les attaques ARP/DNS spoofing en mode passif
- **Logstash 8.11.0** : transforme les logs Zeek (format TSV) en JSON et les envoie vers Elasticsearch
- **Elasticsearch 8.11.0** : stocke tous les événements avec indexation par date
- **Grafana 10.3.0** : dashboards pour visualiser et analyser les données

## Architecture générale

Le schéma ci-dessous montre comment les données circulent dans le système :

```
Réseau (interface ens33)
    |
    +---> Zeek ---------> logs TSV ------+
    |                                     |
    +---> Dumpcap ------> PCAP files     |
    |                                     |
    +---> Ettercap -----> logs JSON -----+
                                          |
                                          v
                                      Logstash (5 pipelines)
                                          |
                                          v
                                    Elasticsearch (indices par date)
                                          |
                                          v
                                       Grafana (dashboards)
```

## Comment ça marche

### Capture du trafic

Trois outils tournent en parallèle sur l'interface réseau (ens33 dans notre cas) :

**Zeek** écoute le trafic et génère des logs au format TSV. Il crée plusieurs fichiers selon le type de trafic :
- conn.log : toutes les connexions (IP source/dest, ports, protocole, volume de données)
- dns.log : requêtes DNS avec les réponses
- http.log : requêtes HTTP avec méthode, URI, user-agent, code de statut
- ssl.log : infos sur les certificats SSL/TLS
- notice.log : alertes quand Zeek détecte quelque chose d'anormal

Les logs sont dans `/data/logs/zeek/current/` et tournent toutes les heures.

**Dumpcap** capture les paquets complets en PCAP. On utilise un ring buffer : 10 fichiers de 1GB max, quand le 10ème est plein, on écrase le premier. Ça donne environ 10GB de PCAP en permanence, soit ~7 jours de rétention selon le trafic. Les fichiers sont dans `/data/pcap/YYYY-MM-DD/`.

**Ettercap** tourne en mode passif pour détecter les attaques ARP/DNS spoofing. Il génère des logs JSON dans `/data/logs/ettercap/ettercap.log`.

### Traitement des logs

Logstash lit les logs générés par Zeek et Ettercap et les transforme. On a configuré 5 pipelines différents :

1. **zeek-conn** : parse conn.log, convertit les types (ports en int, durée en float), renomme les champs (id.orig_h devient src_ip)
2. **zeek-dns** : parse dns.log, extrait les requêtes et réponses DNS
3. **zeek-http** : parse http.log, extrait méthode, URI, user-agent, status code
4. **zeek-alerts** : parse notice.log pour les alertes Zeek
5. **ettercap** : parse les logs Ettercap (déjà en JSON donc plus simple)

Chaque pipeline envoie les données vers Elasticsearch dans un index différent avec la date du jour (ex: zeek-conn-2024.02.15).

### Stockage

Elasticsearch stocke tout dans des index séparés par type et par date :
- zeek-conn-* : connexions réseau
- zeek-dns-* : requêtes DNS
- zeek-http-* : trafic HTTP
- zeek-alerts-* : alertes Zeek
- ettercap-* : détections MITM

La config est simple : mode single-node, 2GB de RAM, pas de sécurité activée (c'est un labo).

### Visualisation

Grafana se connecte à Elasticsearch et permet de créer des dashboards. On a configuré plusieurs dashboards de base :
- Vue d'ensemble du trafic réseau
- Analyse des requêtes DNS
- Analyse du trafic HTTP
- Alertes de sécurité
- Détections MITM

## Configuration des composants

### Zeek

Le fichier `/configs/zeek/local.zeek` charge les protocoles à analyser et définit les réseaux locaux :

```zeek
@load base/protocols/conn
@load base/protocols/dns
@load base/protocols/http
@load policy/protocols/http/detect-sqli
@load policy/protocols/http/detect-webapps

redef Site::local_nets = {
    192.168.0.0/16,
    10.0.0.0/8,
    172.16.0.0/12
};
```

### Logstash

Config dans `/configs/logstash/logstash.yml` :

```yaml
pipeline.workers: 2
pipeline.batch.size: 125
queue.type: memory
```

Les 5 pipelines sont dans `/configs/logstash/pipelines/`. Chacun lit un fichier de log spécifique, le parse, et l'envoie vers Elasticsearch.

### Elasticsearch

Config minimale pour un labo :

```yaml
discovery.type: single-node
ES_JAVA_OPTS: -Xms2g -Xmx2g
xpack.security.enabled: false
```

### Grafana

La datasource Elasticsearch est provisionnée automatiquement au démarrage :

```yaml
apiVersion: 1
datasources:
  - name: Elasticsearch-Zeek
    type: elasticsearch
    url: http://elasticsearch:9200
    database: "zeek-*"
```

## Organisation du stockage

Tout est stocké dans le dossier `data/` :

```
data/
├── elasticsearch/      # Index Elasticsearch
├── grafana/           # Config et dashboards Grafana
├── logs/
│   ├── zeek/current/  # Logs Zeek (conn.log, dns.log, http.log, notice.log)
│   └── ettercap/      # Logs Ettercap
└── pcap/              # Fichiers PCAP (organisés par date)
    └── 2024-02-15/
        ├── capture_00001.pcap
        ├── capture_00002.pcap
        └── ...
```

Estimation de l'espace disque nécessaire (dépend du trafic) :

- Logs Zeek : ~500MB/jour, on garde 30 jours = 15GB
- Elasticsearch : ~1GB/jour, on garde 30 jours = 30GB  
- PCAP : 10GB max (ring buffer)
- Grafana : ~10MB

Total : environ 55GB pour un mois de données + 10GB de PCAP.

## Utilisation

### Accès aux interfaces

Grafana : http://localhost:3000 (admin/admin)  
Elasticsearch : http://localhost:9200

### Quelques requêtes utiles

Vérifier qu'Elasticsearch tourne :
```bash
curl http://localhost:9200/_cluster/health?pretty
```

Lister les index Zeek :
```bash
curl http://localhost:9200/_cat/indices/zeek-*
```

Chercher une requête DNS spécifique :
```bash
curl -X GET "http://localhost:9200/zeek-dns-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"query": {"match": {"dns_query": "google.com"}}}'
```

### Exemples de dashboards Grafana

Pour voir les top IPs par volume de données :
- Index: zeek-conn-*
- Metric: sum(orig_bytes)
- Group by: src_ip.keyword

Pour détecter des requêtes DNS suspectes (fichiers .exe, .dll) :
- Index: zeek-dns-*
- Query: dns_query:*.exe OR dns_query:*.dll

### Analyse des PCAP

Les fichiers PCAP sont dans `data/pcap/` organisés par date. On peut les ouvrir avec Wireshark :

```bash
wireshark data/pcap/2024-02-15/capture_00001.pcap
```

Ou utiliser tshark pour des stats rapides :

```bash
tshark -r capture.pcap -q -z io,stat,60
```

---

Département Génie Informatique - UCAD ESP  
Projet de surveillance réseau - 2024
