# ⚡ Déploiement Zero-Configuration

## 🎯 Installation en 30 secondes

### Prérequis
- Ubuntu/Debian avec Docker installé
- 4 GB RAM minimum
- Droits sudo

### Configuration système (UNE SEULE FOIS)

```bash
# Configurer vm.max_map_count pour Elasticsearch
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Déploiement AUTOMATIQUE

```bash
# 1. Aller dans le dossier du projet
cd /path/to/surveillance-reseau

# 2. (Optionnel) Changer l'interface réseau
# Copier .env.example vers .env et modifier si besoin
cp .env.example .env
nano .env  # Changer CAPTURE_INTERFACE si nécessaire

# 3. Tout démarrer AUTOMATIQUEMENT
docker compose up -d
```

## ✅ C'est tout!

**Attendez 2-3 minutes** que tout démarre, puis:

- 🌐 **Page d'accueil**: http://localhost
- 📊 **Kibana**: http://localhost:5601 (Data Views déjà créés!)
- 🔍 **Elasticsearch**: http://localhost:9200

## 🚀 Ce qui est automatique

✅ Création de tous les dossiers
✅ **Permissions automatiques** (Elasticsearch, Filebeat, logs)
✅ Démarrage de 10 services (7 principaux + 3 init)
✅ Configuration d'Elasticsearch
✅ Configuration de Kibana
✅ Création des Data Views:
  - Suricata Events (suricata-*)
  - ARPWatch Events (arpwatch-*)
✅ Création automatique de 4 visualisations Kibana
✅ Début de la capture réseau
✅ Début de l'analyse IDS
✅ Début de la surveillance ARP

**Note**: Après `git clone`, tout fonctionne directement sans intervention manuelle!

## 📊 Utiliser Kibana

1. Ouvrir http://localhost:5601
2. Menu → **Discover**
3. Sélectionner "Suricata Events" ou "ARPWatch Events"
4. **C'est prêt!** Les données arrivent en temps réel

## 🔧 Commandes utiles

```bash
# Voir l'état
docker compose ps

# Voir les logs
docker compose logs -f

# Redémarrer
docker compose restart

# Arrêter
docker compose down
```

## 📖 Documentation complète

- **Déploiement détaillé**: `DEPLOY.md`
- **Guide utilisateur**: `README.md`
- **Dépannage**: `TROUBLESHOOTING.md`

---

**Plus simple que ça, impossible! 🎉**
