# 🔍 Guide Elasticsearch - Comprendre les Logs dans Grafana Explore

## 📚 Table des matières
1. [Accéder à Explore](#accéder-à-explore)
2. [Types de logs disponibles](#types-de-logs-disponibles)
3. [Champs principaux](#champs-principaux)
4. [Requêtes utiles](#requêtes-utiles)
5. [Exemples pratiques](#exemples-pratiques)

---

## 🎯 Accéder à Explore

1. Dans Grafana, cliquez sur **Explore** (icône boussole) dans le menu de gauche
2. Sélectionnez une datasource :
   - **Elasticsearch-All** : Tous les logs (Zeek + Ettercap)
   - **Elasticsearch-HTTP** : Uniquement les connexions web
   - **Elasticsearch-ARP** : Uniquement les attaques ARP/MITM

---

## 📊 Types de logs disponibles

### 1. **Zeek Connection Logs** (zeek-conn-*)
Toutes les connexions réseau détectées.

**Index**: `zeek-conn-*`

**Champs importants**:
- `src_ip` : IP source (qui initie la connexion)
- `dst_ip` : IP destination (où va la connexion)
- `src_port` : Port source
- `dst_port` : Port destination
- `proto` : Protocole (tcp, udp, icmp)
- `service` : Service détecté (http, dns, ssh, etc.)
- `duration` : Durée de la connexion en secondes
- `orig_bytes` : Octets envoyés par la source
- `resp_bytes` : Octets reçus de la destination
- `conn_state` : État de la connexion (SF=normal, S0=rejeté, etc.)

### 2. **Zeek HTTP Logs** (zeek-http-*)
Toutes les requêtes HTTP détectées.

**Index**: `zeek-http-*`

**Champs importants**:
- `src_ip` : IP de l'utilisateur
- `dst_ip` : IP du serveur web
- `host` : Nom de domaine (ex: google.com)
- `uri` : Chemin de la page (ex: /search?q=test)
- `method` : Méthode HTTP (GET, POST, PUT, DELETE)
- `status_code` : Code de réponse (200=OK, 404=Not Found, 500=Error)
- `user_agent` : Navigateur/application utilisée
- `referrer` : Page précédente
- `request_body_len` : Taille des données envoyées
- `response_body_len` : Taille des données reçues
- `username` : Nom d'utilisateur (si auth HTTP)
- `password` : Mot de passe (si auth HTTP - ⚠️ ATTENTION)

### 3. **Zeek DNS Logs** (zeek-dns-*)
Toutes les requêtes DNS (résolution de noms de domaine).

**Index**: `zeek-dns-*`

**Champs importants**:
- `src_ip` : IP qui fait la requête DNS
- `query` : Nom de domaine recherché
- `qtype_name` : Type de requête (A, AAAA, MX, etc.)
- `answers` : Réponses DNS (IPs retournées)
- `rcode_name` : Code de réponse (NOERROR, NXDOMAIN)

### 4. **Zeek Notice Logs** (zeek-notice-*)
Alertes et événements de sécurité détectés par Zeek.

**Index**: `zeek-notice-*`

**Champs importants**:
- `note` : Type d'alerte (Scan::Port_Scan, SSH::Login, etc.)
- `msg` : Message d'alerte
- `src_ip` : IP source de l'incident
- `dst_ip` : IP destination de l'incident
- `actions` : Actions prises (Notice::ACTION_LOG)

### 5. **Ettercap MITM Logs** (ettercap-*)
Détection d'attaques ARP spoofing, DNS spoofing, MITM.

**Index**: `ettercap-*`

**Champs importants**:
- `event_type` : Type d'événement (mitm_detection)
- `attack_type` : Type d'attaque (ARP, DNS, MITM)
- `attacker_ip` : IP de l'attaquant
- `victim_ip` : IP de la victime
- `attacker_mac` : Adresse MAC de l'attaquant
- `victim_mac` : Adresse MAC de la victime
- `message` : Description de l'attaque

---

## 🔍 Requêtes utiles

### Syntaxe de base
```
champ:valeur              # Recherche exacte
champ:"valeur avec espace"  # Valeur avec espaces
champ:>=100               # Comparaison numérique
champ:[10 TO 100]         # Plage de valeurs
NOT champ:valeur          # Négation
champ:* AND autre:*       # ET logique
champ:* OR autre:*        # OU logique
```

### Exemples de requêtes Zeek HTTP

```bash
# Toutes les requêtes HTTP
*

# Requêtes vers un site spécifique
host:"google.com"

# Requêtes d'une IP spécifique
src_ip:"192.168.1.100"

# Erreurs HTTP (4xx, 5xx)
status_code:>=400

# Requêtes POST (soumission de formulaires)
method:"POST"

# Téléchargements volumineux (>10MB)
response_body_len:>=10485760

# Sites HTTPS suspects (sans certificat valide)
host:* AND NOT status_code:200

# Rechercher des mots de passe en clair
password:*

# Navigateurs utilisés
user_agent:*Chrome* OR user_agent:*Firefox*

# Top 10 des sites visités (requête agrégée)
# Utiliser le panneau de requête et grouper par "host.keyword"
```

### Exemples de requêtes Zeek Connections

```bash
# Toutes les connexions
*

# Connexions SSH
service:"ssh" OR dst_port:22

# Connexions vers un port spécifique
dst_port:443

# Connexions longues (>60 secondes)
duration:>=60

# Transferts volumineux (>100MB)
orig_bytes:>=104857600

# Connexions échouées
conn_state:"REJ" OR conn_state:"S0"

# Scan de ports (nombreuses connexions d'une IP)
src_ip:"192.168.1.50" AND conn_state:"S0"

# Connexions sortantes vers Internet (pas locales)
NOT dst_ip:192.168.* AND NOT dst_ip:10.* AND NOT dst_ip:172.16.*
```

### Exemples de requêtes DNS

```bash
# Toutes les requêtes DNS
*

# Requêtes vers un domaine
query:"facebook.com"

# Requêtes DNS échouées
rcode_name:"NXDOMAIN"

# Recherche de domaines suspects
query:*.tk OR query:*.ml OR query:*.ga

# Requêtes IPv6
qtype_name:"AAAA"
```

### Exemples de requêtes ARP/MITM

```bash
# Toutes les attaques détectées
*

# Attaques ARP uniquement
attack_type:"ARP"

# Attaques DNS uniquement
attack_type:"DNS"

# Attaques visant une victime spécifique
victim_ip:"192.168.1.10"

# Attaques provenant d'un attaquant
attacker_ip:"192.168.1.200"
```

---

## 💡 Exemples pratiques

### 1. Voir qui visite YouTube
```
host:*youtube.com* OR host:*googlevideo.com*
```

### 2. Détecter des tentatives de scan de ports
```
event_type:"connection" AND conn_state:"S0"
# Puis grouper par src_ip pour voir les IP suspectes
```

### 3. Voir les téléchargements importants
```
response_body_len:>=10485760
# Trier par response_body_len pour voir les plus gros
```

### 4. Détecter des connexions suspectes la nuit (00h-06h)
Dans Grafana Explore, utilisez le sélecteur de temps en haut à droite et filtrez par heure.

### 5. Voir les sites visités par une IP spécifique
```
src_ip:"192.168.1.50" AND event_type:"http"
# Grouper par host.keyword
```

### 6. Détecter des attaques ARP sur le réseau
```
event_type:"mitm_detection" AND attack_type:"ARP"
```

### 7. Voir les mots de passe en clair (HTTP non sécurisé)
```
password:* AND NOT password:"-"
# ⚠️ Attention : ceci expose les mots de passe !
```

### 8. Analyser le trafic vers un serveur spécifique
```
dst_ip:"93.184.216.34"
# Grouper par src_ip pour voir qui y accède
```

---

## 📈 Utiliser les agrégations dans Explore

1. Dans Explore, faites votre requête
2. En bas, cliquez sur **"Add"** → **"Aggregation"**
3. Choisissez :
   - **Terms** : Grouper par valeur (ex: grouper par IP)
   - **Date Histogram** : Grouper par temps
   - **Sum/Avg** : Calculer des totaux/moyennes

**Exemple** : Top 10 des sites visités
- Query: `event_type:"http"`
- Aggregation: Terms sur `host.keyword`
- Size: 10
- Order: Count descending

---

## 🎨 Codes de statut HTTP courants

- **2xx (Succès)**
  - `200` : OK (page chargée)
  - `204` : No Content (réussi mais vide)

- **3xx (Redirection)**
  - `301` : Moved Permanently
  - `302` : Found (redirection temporaire)
  - `304` : Not Modified (cache)

- **4xx (Erreur client)**
  - `400` : Bad Request
  - `401` : Unauthorized (auth requise)
  - `403` : Forbidden (accès interdit)
  - `404` : Not Found (page inexistante)

- **5xx (Erreur serveur)**
  - `500` : Internal Server Error
  - `502` : Bad Gateway
  - `503` : Service Unavailable

---

## 🔐 Bonnes pratiques de sécurité

1. **Ne jamais partager les logs contenant** :
   - Des mots de passe (`password` field)
   - Des tokens d'authentification
   - Des données personnelles

2. **Surveiller régulièrement** :
   - Les erreurs 401/403 (tentatives d'accès)
   - Les connexions échouées (conn_state S0)
   - Les attaques ARP/MITM
   - Les scans de ports

3. **Créer des alertes pour** :
   - Nouvelles attaques MITM
   - Téléchargements volumineux suspects
   - Connexions vers des IPs malveillantes connues

---

## 🆘 Aide rapide

**Champs avec `.keyword`** : Pour les agrégations, utilisez `.keyword` après le nom du champ
- `host.keyword` au lieu de `host`
- `src_ip.keyword` au lieu de `src_ip`

**Wildcards** :
- `*` : N'importe quel caractère (plusieurs)
- `?` : Un seul caractère

**Échapper les caractères spéciaux** :
- Pour rechercher littéralement `192.168.1.1`, utilisez `"192.168.1.1"`

---

## 📞 Support

Pour plus d'informations, consultez :
- Documentation Zeek : https://docs.zeek.org
- Documentation Elasticsearch : https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
- Guide Grafana Explore : https://grafana.com/docs/grafana/latest/explore/
