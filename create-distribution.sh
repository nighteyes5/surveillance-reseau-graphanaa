#!/bin/bash

################################################################################
# Script de Création de Distribution
# Génère une archive prête à distribuer de la plateforme
################################################################################

set -e

VERSION="2.1"
ARCHIVE_NAME="surveillance-reseau-v${VERSION}"
TEMP_DIR="/tmp/${ARCHIVE_NAME}"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Création de l'archive de distribution v${VERSION}${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

# Nettoyer le dossier temp si il existe
if [ -d "$TEMP_DIR" ]; then
    echo -e "${YELLOW}[INFO]${NC} Nettoyage du dossier temporaire..."
    rm -rf "$TEMP_DIR"
fi

# Créer le dossier temp
echo -e "${BLUE}[INFO]${NC} Création du dossier temporaire..."
mkdir -p "$TEMP_DIR"

# Copier les fichiers nécessaires
echo -e "${BLUE}[INFO]${NC} Copie des fichiers de configuration..."

# Fichiers racine obligatoires
cp docker-compose.yml "$TEMP_DIR/"
cp .env.example "$TEMP_DIR/"
cp README.md "$TEMP_DIR/"
cp QUICKSTART-ZERO-CONFIG.md "$TEMP_DIR/"
cp DEPLOY.md "$TEMP_DIR/"
cp CHANGELOG.md "$TEMP_DIR/"
cp TROUBLESHOOTING.md "$TEMP_DIR/"
cp DISTRIBUTION.md "$TEMP_DIR/"
cp .gitignore "$TEMP_DIR/" 2>/dev/null || true

# Script d'installation (optionnel)
cp install.sh "$TEMP_DIR/" 2>/dev/null || true

# Copier les dossiers
echo -e "${BLUE}[INFO]${NC} Copie des scripts..."
cp -r scripts/ "$TEMP_DIR/"

echo -e "${BLUE}[INFO]${NC} Copie des configurations..."
cp -r configs/ "$TEMP_DIR/"

echo -e "${BLUE}[INFO]${NC} Copie de la documentation..."
cp -r docs/ "$TEMP_DIR/" 2>/dev/null || true

# Créer un README de distribution
echo -e "${BLUE}[INFO]${NC} Génération du README de distribution..."
cat > "$TEMP_DIR/START-HERE.txt" << 'EOF'
═══════════════════════════════════════════════════════════════
  PLATEFORME DE SURVEILLANCE RÉSEAU v2.1
  Installation Zero-Configuration
═══════════════════════════════════════════════════════════════

🚀 DÉMARRAGE RAPIDE (3 commandes):

1. Configuration système (UNE SEULE FOIS):
   sudo sysctl -w vm.max_map_count=262144
   echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

2. (Optionnel) Configurer l'interface réseau:
   cp .env.example .env
   nano .env  # Changer CAPTURE_INTERFACE si besoin

3. Démarrer TOUT automatiquement:
   docker compose up -d

4. Attendre 2-3 minutes, puis ouvrir:
   • Kibana: http://localhost:5601
   • Page d'accueil: http://localhost

C'EST TOUT! ✅ Tout est automatique.

═══════════════════════════════════════════════════════════════

📖 DOCUMENTATION COMPLÈTE:

• QUICKSTART-ZERO-CONFIG.md - Guide de démarrage 30 secondes
• DEPLOY.md                  - Guide de déploiement complet
• README.md                  - Documentation principale
• TROUBLESHOOTING.md         - Guide de dépannage
• CHANGELOG.md               - Historique des versions

═══════════════════════════════════════════════════════════════

💻 PRÉREQUIS:

• Système: Ubuntu 22.04 / Debian 11+ (ou compatible)
• Docker: version 20.10+ avec Docker Compose
• RAM: 4 GB minimum (8 GB recommandé)
• Disque: 50 GB disponible
• Réseau: Interface avec accès au trafic à surveiller

═══════════════════════════════════════════════════════════════

🎯 CE QUI EST INCLUS:

✅ Elasticsearch 8.11 (stockage)
✅ Kibana 8.11 (visualisation)
✅ Suricata 7.0 (IDS avec 64k+ règles)
✅ ARPWatch (surveillance ARP)
✅ Tcpdump (capture PCAP)
✅ Filebeat (collecte logs)
✅ Configuration automatique Kibana (Data Views pré-créés)
✅ Scripts de rotation PCAP
✅ Documentation complète

═══════════════════════════════════════════════════════════════

🔧 COMMANDES UTILES:

# Voir l'état des services
docker compose ps

# Voir les logs en temps réel
docker compose logs -f

# Redémarrer un service
docker compose restart suricata

# Arrêter tout
docker compose down

# Vérifier la capture
wc -l data/logs/suricata/eve.json
cat data/logs/arpwatch/arpwatch.log

═══════════════════════════════════════════════════════════════

❓ SUPPORT:

Consultez TROUBLESHOOTING.md pour les problèmes courants.

═══════════════════════════════════════════════════════════════

Version: 2.1
Date: 2026-02-14
Licence: MIT

═══════════════════════════════════════════════════════════════
EOF

# Rendre les scripts exécutables
echo -e "${BLUE}[INFO]${NC} Configuration des permissions..."
chmod +x "$TEMP_DIR/scripts/"*.sh
chmod +x "$TEMP_DIR/install.sh" 2>/dev/null || true

# Convertir les fins de ligne en Unix (LF)
echo -e "${BLUE}[INFO]${NC} Conversion des fins de ligne Unix..."
if command -v dos2unix &> /dev/null; then
    find "$TEMP_DIR" -name "*.sh" -exec dos2unix {} \; 2>/dev/null || true
else
    find "$TEMP_DIR" -name "*.sh" -exec sed -i 's/\r$//' {} \; 2>/dev/null || true
fi

# Créer l'archive TAR.GZ
echo -e "${BLUE}[INFO]${NC} Création de l'archive tar.gz..."
cd /tmp
tar -czf "${ARCHIVE_NAME}.tar.gz" "$ARCHIVE_NAME/"

# Créer l'archive ZIP (optionnel)
if command -v zip &> /dev/null; then
    echo -e "${BLUE}[INFO]${NC} Création de l'archive zip..."
    zip -r -q "${ARCHIVE_NAME}.zip" "$ARCHIVE_NAME/"
fi

# Calculer les checksums
echo -e "${BLUE}[INFO]${NC} Génération des checksums..."
sha256sum "${ARCHIVE_NAME}.tar.gz" > "${ARCHIVE_NAME}.tar.gz.sha256"
if [ -f "${ARCHIVE_NAME}.zip" ]; then
    sha256sum "${ARCHIVE_NAME}.zip" > "${ARCHIVE_NAME}.zip.sha256"
fi

# Afficher les informations
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Archives de distribution créées avec succès!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Fichiers générés:${NC}"
echo "  • /tmp/${ARCHIVE_NAME}.tar.gz"
if [ -f "/tmp/${ARCHIVE_NAME}.zip" ]; then
    echo "  • /tmp/${ARCHIVE_NAME}.zip"
fi
echo ""

echo -e "${GREEN}Checksums:${NC}"
cat "/tmp/${ARCHIVE_NAME}.tar.gz.sha256"
if [ -f "/tmp/${ARCHIVE_NAME}.zip.sha256" ]; then
    cat "/tmp/${ARCHIVE_NAME}.zip.sha256"
fi
echo ""

# Taille des archives
TAR_SIZE=$(du -h "/tmp/${ARCHIVE_NAME}.tar.gz" | cut -f1)
echo -e "${GREEN}Taille:${NC}"
echo "  • tar.gz: $TAR_SIZE"
if [ -f "/tmp/${ARCHIVE_NAME}.zip" ]; then
    ZIP_SIZE=$(du -h "/tmp/${ARCHIVE_NAME}.zip" | cut -f1)
    echo "  • zip: $ZIP_SIZE"
fi
echo ""

echo -e "${YELLOW}Contenu de l'archive:${NC}"
tar -tzf "/tmp/${ARCHIVE_NAME}.tar.gz" | head -20
echo "  ... (voir l'archive pour la liste complète)"
echo ""

echo -e "${BLUE}Pour distribuer:${NC}"
echo "  1. Copier /tmp/${ARCHIVE_NAME}.tar.gz vers le serveur cible"
echo "  2. Extraire: tar -xzf ${ARCHIVE_NAME}.tar.gz"
echo "  3. cd ${ARCHIVE_NAME}"
echo "  4. Lire START-HERE.txt"
echo "  5. docker compose up -d"
echo ""

echo -e "${GREEN}✅ Distribution prête!${NC}"

# Nettoyer le dossier temp
rm -rf "$TEMP_DIR"
