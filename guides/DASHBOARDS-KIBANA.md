# 📊 Dashboards et Visualisations Kibana

## ✅ Ce qui est créé automatiquement

Au premier `docker compose up -d`, le système crée automatiquement:

### 1. **Data Views** (Index Patterns)
- ✅ **Suricata Events** (`suricata-*`)
  - Timestamp field: `timestamp`
  - Données: DNS, HTTP, TLS, Alerts, Flow, etc.

- ✅ **ARPWatch Events** (`arpwatch-*`)
  - Timestamp field: `@timestamp`
  - Données: new_station, mac_changed, IP/MAC mapping

### 2. **Visualisations Pré-configurées**

#### 📈 Total Événements (Metric)
- **Type**: Metric (compteur)
- **Source**: suricata-*
- **Affiche**: Nombre total d'événements capturés en temps réel
- **Usage**: Vue rapide de l'activité réseau

#### 🥧 Répartition par Type (Pie Chart)
- **Type**: Pie Chart (diagramme circulaire)
- **Source**: suricata-*
- **Affiche**: % de chaque type d'événement (DNS, HTTP, TLS, Alert, etc.)
- **Usage**: Comprendre la composition du trafic

#### 📉 Timeline Réseau (Line Chart)
- **Type**: Line Chart (graphique linéaire)
- **Source**: suricata-*
- **Affiche**: Évolution du nombre d'événements dans le temps
- **Usage**: Détecter les pics d'activité, patterns temporels

#### 🌐 Top 10 Sites Visités (Horizontal Bar)
- **Type**: Horizontal Bar Chart
- **Source**: suricata-*
- **Filtre**: `event_type: "dns"`
- **Champ**: `dns.rrname.keyword` (nom de domaine)
- **Affiche**: Les 10 sites web les plus consultés
- **Usage**: Identifier les sites populaires, détecter les domaines suspects

---

## 🔍 Comment voir les visualisations

### Méthode 1: Via Kibana UI

```
1. Ouvrir http://localhost:5601
2. Menu (☰) → Analytics → Visualize Library
3. Vous verrez 4 visualisations:
   - Total Événements
   - Répartition par Type
   - Timeline Réseau
   - Top 10 Sites Visités
```

### Méthode 2: Créer un Dashboard avec ces visualisations

```
1. Analytics → Dashboard → Create dashboard
2. Cliquer "Add from library"
3. Sélectionner les 3 visualisations créées
4. Arranger sur le canvas
5. Save dashboard → Nommer "Vue d'ensemble Réseau"
```

---

## 📊 Dashboards Recommandés à Créer

### Dashboard 1: **Vue d'ensemble Réseau** ⭐

**Objectif**: Monitoring général en temps réel

**Visualisations suggérées:**
- Total Événements (Metric)
- Répartition par Type (Pie)
- Timeline Réseau (Line)
- Top 10 IP Destinations (Horizontal Bar)
- Top 10 IP Sources (Horizontal Bar)

**Comment créer:**
```
1. Dashboard → Create
2. Add from library → Sélectionner "Total Événements"
3. Create new → Bar chart vertical
   - Data source: suricata-*
   - Metric: Count
   - Buckets: Terms → dest_ip.keyword
   - Size: 10
   - Save as "Top Destinations"
4. Répéter pour IP sources
5. Save dashboard
```

---

### Dashboard 2: **Alertes Sécurité** 🚨

**Objectif**: Focus sur les menaces détectées

**Visualisations suggérées:**
- Nombre d'Alertes (Metric avec filtre `event_type: "alert"`)
- Alertes par Sévérité (Pie)
- Timeline des Alertes (Area chart)
- Top Signatures Déclenchées (Table)
- IP Sources Suspectes (Tag Cloud)

**Filtres à appliquer:**
```kql
event_type: "alert"
```

**Comment créer une alerte metric:**
```
1. Create visualization → Metric
2. Data source: suricata-*
3. Add filter: event_type is "alert"
4. Title: "Alertes Sécurité"
5. Metric: Count
6. Save
```

---

### Dashboard 3: **Analyse DNS** 🌐

**Objectif**: Comprendre l'utilisation réseau

**Visualisations suggérées:**
- Total Requêtes DNS (Metric)
- Top 20 Domaines (Bar chart)
- Timeline DNS (Line)
- Requêtes par Type (A, AAAA, CNAME, etc.)
- Domaines Suspects (Table avec filtre)

**Filtre de base:**
```kql
event_type: "dns"
```

**Exemple: Top Domaines**
```
1. Create visualization → Vertical Bar
2. Data source: suricata-*
3. Filter: event_type is "dns"
4. Metric: Count
5. Buckets:
   - X-axis → Terms
   - Field: dns.rrname.keyword
   - Size: 20
   - Order: Metric (Count) descending
6. Save as "Top Domaines Consultés"
```

---

### Dashboard 4: **Surveillance ARP** 🔐

**Objectif**: Détecter les attaques réseau (spoofing, MITM)

**Visualisations suggérées:**
- Total Nouvelles Stations (Metric avec filtre `action: "new_station"`)
- Changements de MAC (Metric avec filtre `action: "mac_changed"`)
- Carte IP/MAC (Data Table)
- Timeline Événements ARP (Line)
- Alertes ARP Spoofing (Table filtrée sur mac_changed)

**Exemple: Détection ARP Spoofing**
```
1. Create visualization → Data Table
2. Data source: arpwatch-*
3. Filter: action is "mac_changed"
4. Columns:
   - @timestamp
   - ip_address
   - mac_address
   - hostname
   - action
5. Sort: @timestamp descending
6. Save as "Alertes ARP Spoofing"
```

---

## 🎨 Créer des Visualisations Personnalisées

### Types de Visualisations Disponibles

| Type | Usage | Exemple |
|------|-------|---------|
| **Metric** | Compteur/KPI | "Nombre total d'alertes" |
| **Pie Chart** | Répartition en % | "% par type d'événement" |
| **Vertical Bar** | Comparaison catégories | "Top 10 IPs" |
| **Horizontal Bar** | Classement | "Top domaines" |
| **Line** | Évolution temporelle | "Trafic dans le temps" |
| **Area** | Tendances cumulées | "Cumul alertes" |
| **Data Table** | Liste détaillée | "Liste des alertes" |
| **Tag Cloud** | Fréquence visuelle | "Mots-clés DNS" |
| **Heatmap** | Corrélations | "IP source × dest" |
| **Gauge** | Indicateur | "% usage bande passante" |

### Étapes Génériques

```
1. Analytics → Visualize Library → Create visualization
2. Choisir le type
3. Sélectionner Data Source (suricata-* ou arpwatch-*)
4. Configurer les métriques:
   - Count (nombre)
   - Sum (somme)
   - Average (moyenne)
   - Min/Max
   - Unique Count
5. Configurer les buckets (agrégations):
   - Terms (par valeur de champ)
   - Date Histogram (par temps)
   - Filters (filtres multiples)
   - Range (par plage)
6. Ajuster les paramètres visuels
7. Save
```

---

## 🔍 Requêtes KQL Utiles

### Filtres Suricata

```kql
# Événements DNS
event_type: "dns"

# Connexions HTTPS
event_type: "tls"

# Trafic HTTP en clair
event_type: "http"

# Alertes critiques (sévérité 1-2)
event_type: "alert" AND alert.severity: [1 TO 2]

# Trafic vers IPs externes (hors RFC1918)
NOT dest_ip: 192.168.* AND NOT dest_ip: 10.* AND NOT dest_ip: 172.16.*

# Requêtes DNS suspectes
dns.rrname: (*exe OR *download OR *malware OR *phish*)

# Connexions vers ports inhabituels
dest_port: >1024 AND dest_port: <5000

# Trafic d'un utilisateur spécifique
src_ip: "192.168.1.100"

# Événements avec alerte ET connexion établie
event_type: "alert" AND flow.state: "established"
```

### Filtres ARPWatch

```kql
# Nouvelles stations détectées
action: "new_station"

# Changements de MAC (ARP spoofing potentiel)
action: "mac_changed"

# Événements d'une IP spécifique
ip_address: "192.168.1.50"

# Devices VMware
mac_address: 00:50:56:* OR mac_address: 00:0c:29:*

# Événements récents (dernière heure)
@timestamp >= now-1h
```

---

## 📅 Rafraîchissement et Période

### Configurer le rafraîchissement auto

```
1. Ouvrir un Dashboard
2. Cliquer sur l'icône horloge (en haut à droite)
3. Refresh every: Sélectionner 30 seconds ou 1 minute
4. Start
```

### Ajuster la période de temps

```
Quick ranges:
- Last 15 minutes
- Last 1 hour
- Last 24 hours
- Last 7 days
- Today
- This week

Custom:
- Absolute: Dates précises
- Relative: now-24h to now
```

---

## 🎯 Best Practices

### 1. **Organisation**
- Créer des dossiers par catégorie (Sécurité, Réseau, ARP)
- Nommer clairement les visualisations
- Ajouter des descriptions

### 2. **Performance**
- Limiter les visualisations à 5-8 par dashboard
- Utiliser des filtres pour réduire le dataset
- Éviter les agrégations trop complexes

### 3. **Alerting** (optionnel)
- Configurer des seuils dans les visualisations
- Utiliser Kibana Alerting pour notifications
- Exemple: Alerte si > 100 alertes Suricata en 5min

### 4. **Partage**
- Exporter les dashboards en PDF
- Générer des liens de partage
- Planifier des rapports automatiques (Kibana feature)

---

## 🐛 Troubleshooting

### Problème: "No results found"

**Causes:**
1. Pas de données dans l'index
2. Période de temps incorrecte
3. Filtre trop restrictif

**Solutions:**
```bash
# 1. Vérifier qu'il y a des données
curl -s http://localhost:9200/suricata-*/_count | jq
curl -s http://localhost:9200/arpwatch-*/_count | jq

# 2. Dans Kibana, ajuster le Time Range (top right)
# Essayer: "Last 7 days" ou "Last 30 days"

# 3. Supprimer les filtres
# Cliquer sur "x" à côté de chaque filtre
```

### Problème: Visualisation cassée

**Solution:**
```
1. Edit la visualisation
2. Vérifier que le Data Source existe
3. Stack Management → Data Views
4. Si manquant, recréer:
   docker compose restart kibana-init
```

### Problème: Dashboard lent

**Solutions:**
```
1. Réduire le nombre de visualisations
2. Limiter la période de temps
3. Augmenter la RAM d'Elasticsearch dans .env
4. Ajouter des filtres pour réduire le dataset
```

---

## 📚 Ressources

- [Kibana Lens Documentation](https://www.elastic.co/guide/en/kibana/current/lens.html)
- [KQL Syntax](https://www.elastic.co/guide/en/kibana/current/kuery-query.html)
- [Best Practices](https://www.elastic.co/guide/en/kibana/current/dashboard-best-practices.html)

---

## 🎬 Workflow Recommandé

```
1. Démarrage:
   docker compose up -d

2. Attendre 2-3 minutes
   (initialisation + capture de données)

3. Ouvrir Kibana:
   http://localhost:5601

4. Aller dans Discover:
   - Sélectionner Data View "Suricata Events"
   - Observer les événements en temps réel

5. Créer votre premier dashboard:
   - Dashboard → Create
   - Ajouter les 3 visualisations pré-créées
   - Save as "Ma Surveillance Réseau"

6. Personnaliser selon vos besoins:
   - Ajouter des visualisations
   - Configurer des filtres
   - Ajuster les couleurs et styles

7. Partager:
   - Share → Copy link
   - Envoyer aux collègues
```

---

**Version:** 2.1
**Dernière mise à jour:** 2026-02-14
**Dashboards créés automatiquement:** 0 dashboards, 4 visualisations
**Data Views créés:** 2 (Suricata, ARPWatch)

---

## 🎯 Visualisations Créées Automatiquement

| # | Nom | Type | Source | Description |
|---|-----|------|--------|-------------|
| 1 | Total Événements | Metric | suricata-* | Compteur temps réel |
| 2 | Répartition par Type | Pie Chart | suricata-* | % par event_type |
| 3 | Timeline Réseau | Line Chart | suricata-* | Évolution temporelle |
| 4 | Top 10 Sites Visités | Horizontal Bar | suricata-* | Domaines DNS les plus consultés |
