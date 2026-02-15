# 📦 Portabilité du Système - Déploiement Ailleurs

**Comment déployer ce système chez quelqu'un d'autre facilement**

---

## 🎯 Objectif

Permettre à **n'importe qui** de reproduire ton système de surveillance (avec ou sans pfSense) sur sa propre infrastructure.

---

## 📁 Ce qui est déjà PORTABLE

### ✅ Grâce au Docker Compose

Ton système **EST DÉJÀ portable** car:

```
surveillance-reseau/
├── docker-compose.yml        ← Configuration des services
├── configs/                  ← Toutes les configs
├── scripts/                  ← Scripts de démarrage
└── guides/                   ← Documentation complète
```

**Avantage:** Quelqu'un peut prendre ce dossier et le déployer n'importe où!

---

## 🚀 Déploiement Rapide sur un Nouveau Serveur

### Méthode 1: Archive + Upload

```bash
# Sur TON serveur actuel:
bash create-distribution.sh
# Génère: /tmp/surveillance-reseau-v2.1.tar.gz

# Envoyer à quelqu'un:
# → Email, Dropbox, Google Drive, USB, etc.

# Sur LE NOUVEAU serveur:
tar -xzf surveillance-reseau-v2.1.tar.gz
cd surveillance-reseau
sudo sysctl -w vm.max_map_count=262144
docker compose up -d

# C'EST TOUT! ✅
# (Les permissions sont configurées automatiquement)
```

### Méthode 2: Git Repository

```bash
# Toi: Push sur GitHub/GitLab (une fois)
cd surveillance-reseau
git init
git add .
git commit -m "Système de surveillance v2.1"
git remote add origin https://github.com/ton-compte/surveillance-reseau.git
git push -u origin main

# Quelqu'un d'autre:
git clone https://github.com/ton-compte/surveillance-reseau.git
cd surveillance-reseau
sudo sysctl -w vm.max_map_count=262144
docker compose up -d

# FAIT! ✅
# (Les permissions sont configurées automatiquement)
```

---

## ⚙️ Points d'Adaptation (Ce qu'il faut changer)

### 1. Interface Réseau

**Fichier:** `.env` ou `docker-compose.yml`

```bash
# À adapter selon le nouveau serveur
CAPTURE_INTERFACE=ens33  # Peut être eth0, ens192, etc.

# Comment trouver sur le nouveau serveur:
ip link show
# Chercher l'interface avec du trafic
```

### 2. Adresse IP (si fixe)

**Fichier:** `/etc/netplan/...`

```yaml
# À adapter selon le réseau
addresses:
  - 192.168.100.10/24  # Changer selon le LAN
```

### 3. pfSense (si utilisé)

**Paramètres à adapter:**
- IP LAN pfSense (192.168.100.1 → selon réseau)
- Plage DHCP (192.168.100.100-200 → selon réseau)
- Réseau VMnet ou Bridge

---

## 📋 Checklist Déploiement Chez Quelqu'un

### Avant de partir:

```
1. [ ] Créer l'archive:
       bash create-distribution.sh

2. [ ] Tester sur une VM vierge
       (pour vérifier que ça marche vraiment)

3. [ ] Créer un fichier README-NOUVEAU-SERVEUR.txt
       (instructions spécifiques)

4. [ ] Documenter les paramètres à changer:
       - Interface réseau
       - IPs si réseau différent
       - Taille RAM Elasticsearch (selon serveur)
```

### Sur le nouveau serveur:

```
1. [ ] Installer Ubuntu 22.04 LTS
2. [ ] Installer Docker + Docker Compose
3. [ ] Configurer vm.max_map_count
4. [ ] Extraire l'archive
5. [ ] Adapter .env (interface réseau)
6. [ ] docker compose up -d
7. [ ] Vérifier http://localhost:5601
```

---

## 🔄 Variantes de Déploiement

### Variante A: Serveur Physique

```
Même chose, juste:
- Pas de VM
- Interface réseau physique (eth0, ens33)
- Port mirroring sur switch physique (SPAN)
```

### Variante B: Cloud (AWS, Azure, etc.)

```
Problème: Pas de port mirroring dans le cloud

Solution:
1. Installer sur une VM cloud
2. Surveillance limitée au trafic de CETTE VM
3. Ou utiliser VPC Traffic Mirroring (AWS)
4. Ou agents sur chaque VM (Beats)

Ou mieux:
- Garder pour réseau local/entreprise
- Pas optimal pour cloud public
```

### Variante C: Proxmox/ESXi

```
Avantage: Meilleur contrôle réseau

Setup:
1. Créer un vSwitch avec port mirroring
2. VM Ubuntu surveillance connectée au port miroir
3. Toutes les autres VMs sur le vSwitch
4. Capture tout le trafic inter-VMs

Différence avec VMware Workstation:
- Plus professionnel
- Meilleur performance
- Mais même principe
```

---

## 🎓 Documentation pour Autrui

### Créer un "Package Complet"

```bash
# Structure recommandée pour distribuer:
surveillance-reseau-package/
├── surveillance-reseau-v2.1.tar.gz  # Le système
├── README-START-HERE.txt            # Instructions ultra-simples
├── REQUIREMENTS.txt                 # Prérequis
├── NETWORK-DIAGRAM.png              # Schéma réseau
└── VIDEO-DEMO.mp4                   # (optionnel) Vidéo démo
```

**Contenu README-START-HERE.txt:**

```txt
╔═══════════════════════════════════════════════════╗
║   SYSTÈME DE SURVEILLANCE RÉSEAU v2.1            ║
║   Installation en 5 minutes                       ║
╚═══════════════════════════════════════════════════╝

PRÉREQUIS:
- Ubuntu Server 22.04 LTS
- Docker installé
- 4 GB RAM minimum
- 50 GB disque

INSTALLATION:

1. Extraire l'archive:
   tar -xzf surveillance-reseau-v2.1.tar.gz
   cd surveillance-reseau

2. Configuration système (UNE FOIS):
   sudo sysctl -w vm.max_map_count=262144
   echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

3. Adapter l'interface réseau:
   nano .env
   # Changer CAPTURE_INTERFACE=ens33 par VOTRE interface
   # Trouver avec: ip link show

4. Démarrer:
   docker compose up -d

5. Attendre 2-3 minutes, puis:
   http://VOTRE-IP:5601 (Kibana)

DOCUMENTATION COMPLÈTE:
- guides/QUICKSTART-ZERO-CONFIG.md
- guides/DEPLOY.md
- guides/PFSENSE-INTEGRATION.md (optionnel)

SUPPORT:
- Voir guides/TROUBLESHOOTING.md
```

---

## 🌍 Adapter pour Différents Contextes

### Entreprise

```
Adaptations:
- Réseau: Probablement plusieurs VLANs
- pfSense: Recommandé (déjà utilisé souvent)
- HTTPS: Certificats SSL valides
- Auth: Ajouter authentification Kibana
- Backup: Automatiser backups configs + données
```

### École/Université

```
Adaptations:
- Réseau: VLAN étudiants séparé
- Enseignes: Obligatoires (conformité)
- Rétention: Court (RGPD/vie privée)
- Ressources: Serveur partagé possible
```

### Lab/Formation

```
Adaptations:
- Tout en VMs (reproductible)
- Snapshots fréquents
- Configs de démo pré-chargées
- Données de test synthétiques
```

### Production PME

```
Adaptations:
- pfSense: Indispensable
- Monitoring 24/7: Ajouter alerting
- Redondance: Elasticsearch cluster (3 nodes)
- Backup: Quotidien automatisé
```

---

## 🔐 Sécurisation pour Production

### Si déployé en VRAI (pas lab):

```bash
# 1. Changer les ports (ne pas exposer 9200, 5601)
# Via nginx reverse proxy

# 2. Activer auth Kibana:
# Dans docker-compose.yml Elasticsearch:
- xpack.security.enabled=true

# 3. HTTPS partout:
# Certificats Let's Encrypt

# 4. Firewall sur le serveur:
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable

# 5. Pas d'accès direct Elasticsearch:
# Seulement via Kibana
```

---

## 📊 Export/Import Kibana (Dashboards)

### Pour partager tes dashboards:

```bash
# Export (sur ton serveur):
# Via UI Kibana:
Stack Management → Saved Objects → Export
# Sélectionner tous les dashboards/visualizations
# Télécharger: export.ndjson

# Import (sur nouveau serveur):
Stack Management → Saved Objects → Import
# Upload: export.ndjson
```

---

## 🎯 Template de Déploiement

### Script automatique pour nouveau serveur:

**Fichier:** `auto-deploy.sh`

```bash
#!/bin/bash

echo "🚀 Installation Automatique Surveillance Réseau"

# 1. Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker non installé. Installation..."
    curl -fsSL https://get.docker.com | bash
fi

# 2. Config système
echo "⚙️ Configuration système..."
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# 3. Détecter interface réseau
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
echo "🌐 Interface détectée: $INTERFACE"

# 4. Créer .env
cat > .env << EOF
CAPTURE_INTERFACE=$INTERFACE
ARPWATCH_INTERFACE=$INTERFACE
ES_JAVA_OPTS=-Xms2g -Xmx2g
EOF

# 5. Démarrer
echo "🐳 Démarrage des containers..."
docker compose up -d

# 6. Attendre
echo "⏱️ Attente initialisation (2 minutes)..."
sleep 120

# 7. Vérifier
echo "✅ Vérification..."
docker compose ps

# 8. Afficher infos
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "╔════════════════════════════════════════╗"
echo "║   ✅ Installation Terminée!            ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🌐 Kibana: http://$IP:5601"
echo "📊 Elasticsearch: http://$IP:9200"
echo ""
echo "📖 Documentation: guides/README.md"
```

**Utilisation:**

```bash
# Sur le nouveau serveur:
chmod +x auto-deploy.sh
./auto-deploy.sh

# C'EST TOUT! ✅
```

---

## 🎊 Résumé Portabilité

### ✅ CE QUI REND TON SYSTÈME PORTABLE:

1. **Docker** → Même environnement partout
2. **docker-compose.yml** → Config déclarative
3. **Scripts init** → Automatisation complète
4. **Documentation** → Guides clairs
5. **create-distribution.sh** → Package prêt à l'emploi

### ✅ POUR DÉPLOYER AILLEURS:

1. Créer archive
2. Envoyer
3. Extraire
4. `docker compose up -d`

**4 étapes. C'est tout!** 🚀

---

**Ton système est DÉJÀ conçu pour être portable!**
