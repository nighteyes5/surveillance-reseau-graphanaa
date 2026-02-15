# 📦 Distribution et Déploiement

## ✅ Ce que l'utilisateur lambda DOIT avoir (à distribuer)

### Structure minimale requise:

```
surveillance-reseau/
├── docker-compose.yml          # ⚠️ OBLIGATOIRE - Configuration des services
├── .env.example                # ⚠️ OBLIGATOIRE - Template configuration
│
├── configs/                    # ⚠️ OBLIGATOIRE - Configurations
│   ├── filebeat/
│   │   └── filebeat.yml
│   ├── suricata/
│   │   ├── suricata.yaml
│   │   └── rules/
│   │       └── *.rules
│   └── nginx/
│       ├── nginx.conf
│       └── html/
│           └── index.html
│
├── scripts/                    # ⚠️ OBLIGATOIRE - Scripts de démarrage
│   ├── start-suricata.sh
│   ├── start-arpwatch.sh
│   ├── capture.sh
│   ├── rotate-pcap.sh
│   ├── init-kibana.sh
│   └── tests.sh
│
├── docs/                       # 📚 RECOMMANDÉ - Documentation
│   ├── architecture-publique.md
│   ├── installation-privee.md
│   ├── evaluation-conformite.md
│   ├── fix-arpwatch-v2.1.md
│   └── enseigne-laboratoire.md
│
├── README.md                   # 📖 OBLIGATOIRE - Guide principal
├── QUICKSTART-ZERO-CONFIG.md   # 🚀 OBLIGATOIRE - Guide rapide
├── DEPLOY.md                   # 📋 RECOMMANDÉ - Guide déploiement
├── CHANGELOG.md                # 📝 RECOMMANDÉ - Historique
├── TROUBLESHOOTING.md          # 🔧 RECOMMANDÉ - Dépannage
├── install.sh                  # ⚙️ OPTIONNEL - Installation guidée
└── .gitignore                  # OPTIONNEL
```

---

## ❌ Ce qui N'a PAS besoin d'être distribué (créé automatiquement)

### Ces dossiers sont créés automatiquement par Docker:

```
surveillance-reseau/
├── data/                       # ✅ Auto-créé par Docker volumes
│   ├── elasticsearch/          # ✅ Créé automatiquement
│   ├── logs/                   # ✅ Créé automatiquement
│   │   ├── suricata/
│   │   └── arpwatch/
│   └── pcap/                   # ✅ Créé automatiquement
│
└── docker-compose.yml.backup   # Créé par install.sh
```

**Important**: Le dossier `data/` ne doit PAS être inclus dans la distribution!

---

## 📦 Comment créer le package de distribution

### Méthode 1: Archive ZIP/TAR (Recommandé)

```bash
# Aller dans le dossier parent
cd /path/to/

# Créer une archive sans le dossier data/
tar -czf surveillance-reseau-v2.1.tar.gz \
  --exclude='data' \
  --exclude='*.backup' \
  --exclude='.git' \
  surveillance-reseau/

# Ou en ZIP
zip -r surveillance-reseau-v2.1.zip \
  surveillance-reseau/ \
  -x "surveillance-reseau/data/*" \
  -x "surveillance-reseau/*.backup" \
  -x "surveillance-reseau/.git/*"
```

### Méthode 2: Git Repository

```bash
# Créer un .gitignore pour exclure data/
cat > .gitignore << 'EOF'
# Données générées
data/
*.backup

# Logs
*.log

# Variables d'environnement
.env
EOF

# Push vers Git
git add .
git commit -m "v2.1 - Déploiement zero-configuration"
git push
```

---

## 📋 Checklist avant distribution

### ✅ Fichiers obligatoires présents:

- [ ] `docker-compose.yml`
- [ ] `.env.example`
- [ ] `configs/filebeat/filebeat.yml`
- [ ] `configs/suricata/suricata.yaml`
- [ ] `configs/suricata/rules/` (avec règles)
- [ ] `configs/nginx/nginx.conf`
- [ ] `configs/nginx/html/index.html`
- [ ] `scripts/start-suricata.sh`
- [ ] `scripts/start-arpwatch.sh`
- [ ] `scripts/capture.sh`
- [ ] `scripts/init-kibana.sh`
- [ ] `README.md`
- [ ] `QUICKSTART-ZERO-CONFIG.md`

### ✅ Scripts exécutables:

```bash
# Rendre tous les scripts exécutables avant distribution
chmod +x scripts/*.sh
chmod +x install.sh
```

### ✅ Vérifier les fins de ligne Unix:

```bash
# Convertir tous les scripts en format Unix (LF)
find scripts/ -name "*.sh" -exec dos2unix {} \;
dos2unix install.sh
```

### ✅ Tester la distribution:

```bash
# Extraire l'archive dans un nouveau dossier
mkdir /tmp/test-distribution
cd /tmp/test-distribution
tar -xzf surveillance-reseau-v2.1.tar.gz

# Tester le déploiement
cd surveillance-reseau
docker compose up -d

# Vérifier que tout fonctionne
sleep 120
docker compose ps
curl http://localhost:5601
```

---

## 🚀 Instructions pour l'utilisateur lambda

### Ce que l'utilisateur doit faire:

```bash
# 1. Extraire l'archive
tar -xzf surveillance-reseau-v2.1.tar.gz
cd surveillance-reseau

# 2. Configuration système (UNE SEULE FOIS)
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# 3. (Optionnel) Configurer l'interface réseau
cp .env.example .env
nano .env  # Changer CAPTURE_INTERFACE si besoin

# 4. Démarrer TOUT
docker compose up -d

# 5. Attendre 2-3 minutes
sleep 180

# 6. Accéder à Kibana
firefox http://localhost:5601
```

**C'est tout! 🎉**

---

## 📊 Taille de la distribution

### Estimation:

| Composant | Taille approximative |
|-----------|---------------------|
| Scripts | ~50 KB |
| Configs | ~100 KB |
| Règles Suricata | ~5 MB |
| Documentation | ~500 KB |
| **Total archive** | **~6 MB** |

### Images Docker (téléchargées automatiquement):

| Image | Taille |
|-------|--------|
| Elasticsearch 8.11 | ~800 MB |
| Kibana 8.11 | ~700 MB |
| Suricata 7.0 | ~200 MB |
| Filebeat 8.11 | ~150 MB |
| Ubuntu 22.04 | ~80 MB |
| Nginx Alpine | ~40 MB |
| Netshoot | ~100 MB |
| Curl | ~5 MB |
| **Total images** | **~2 GB** |

**Note**: Les images Docker sont téléchargées automatiquement au premier `docker compose up -d`

---

## 📝 README dans l'archive

### Créer un fichier README-DISTRIBUTION.txt à la racine:

```txt
═══════════════════════════════════════════════════════════
  PLATEFORME DE SURVEILLANCE RÉSEAU v2.1
  Installation Zero-Configuration
═══════════════════════════════════════════════════════════

DÉMARRAGE RAPIDE:

1. Configuration système (une seule fois):
   sudo sysctl -w vm.max_map_count=262144

2. Démarrer la plateforme:
   docker compose up -d

3. Attendre 2-3 minutes, puis ouvrir:
   http://localhost:5601 (Kibana)

C'EST TOUT! Tout est automatique.

DOCUMENTATION COMPLÈTE:
- Démarrage rapide: QUICKSTART-ZERO-CONFIG.md
- Guide complet: DEPLOY.md
- Dépannage: TROUBLESHOOTING.md

PRÉREQUIS:
- Ubuntu/Debian avec Docker installé
- 4 GB RAM minimum
- 50 GB disque

SUPPORT:
Voir TROUBLESHOOTING.md
═══════════════════════════════════════════════════════════
```

---

## 🔐 Sécurité de la distribution

### ⚠️ NE PAS inclure dans la distribution:

- ❌ Dossier `data/` (contient des données sensibles)
- ❌ Fichier `.env` (contient des configs locales)
- ❌ Fichiers `*.backup`
- ❌ Dossier `.git/` (si distribution archive)
- ❌ Logs ou captures PCAP

### ✅ Vérifications avant distribution:

```bash
# Vérifier qu'il n'y a pas de données sensibles
grep -r "password\|secret\|token" configs/ scripts/

# Vérifier qu'il n'y a pas de chemins absolus spécifiques
grep -r "/home/\|/Users/" configs/ scripts/

# Vérifier les permissions
find . -type f -perm /111  # Doit montrer seulement les .sh
```

---

## 🎯 Résumé

### Pour distribuer la plateforme:

1. ✅ **Inclure**:
   - docker-compose.yml
   - configs/ (complet)
   - scripts/ (complet)
   - docs/ (complet)
   - README.md, QUICKSTART-ZERO-CONFIG.md, DEPLOY.md
   - .env.example
   - install.sh (optionnel)

2. ❌ **Exclure**:
   - data/
   - .env
   - *.backup
   - .git/

3. ✅ **Créer archive**:
   - `surveillance-reseau-v2.1.tar.gz` (~6 MB)

4. ✅ **Documentation utilisateur**:
   - README-DISTRIBUTION.txt
   - QUICKSTART-ZERO-CONFIG.md

### L'utilisateur lambda fait:

```bash
tar -xzf surveillance-reseau-v2.1.tar.gz
cd surveillance-reseau
sudo sysctl -w vm.max_map_count=262144
docker compose up -d
```

**Fini! 🚀**
