#!/bin/bash

################################################################################
# Script d'Installation Automatique - Plateforme Surveillance Réseau
# Version: 2.1
# Description: Déploiement zero-touch avec configuration automatique
################################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Fonction pour afficher une barre de progression
show_progress() {
    local duration=$1
    local message=$2
    echo -ne "${BLUE}[INFO]${NC} $message"
    for ((i=0; i<duration; i++)); do
        sleep 1
        echo -n "."
    done
    echo ""
}

################################################################################
# 1. Vérifications préalables
################################################################################

log_info "═══════════════════════════════════════════════════════════════"
log_info "  Plateforme de Surveillance Réseau - Installation v2.1"
log_info "═══════════════════════════════════════════════════════════════"
echo ""

log_info "Vérification des prérequis..."

# Vérifier que le script est exécuté en tant qu'utilisateur normal
if [ "$EUID" -eq 0 ]; then
    log_error "Ne pas exécuter ce script en tant que root!"
    log_info "Exécutez: bash install.sh"
    exit 1
fi

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker n'est pas installé!"
    log_info "Installez Docker: https://docs.docker.com/engine/install/"
    exit 1
fi
log_success "Docker installé"

# Vérifier Docker Compose
if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose n'est pas installé!"
    exit 1
fi
log_success "Docker Compose installé"

# Vérifier que Docker tourne
if ! docker info &> /dev/null; then
    log_error "Le daemon Docker ne tourne pas!"
    log_info "Démarrez Docker: sudo systemctl start docker"
    exit 1
fi
log_success "Docker daemon actif"

# Vérifier jq (pour l'API Kibana)
if ! command -v jq &> /dev/null; then
    log_warning "jq n'est pas installé (optionnel pour debug)"
    log_info "Installation: sudo apt-get install -y jq"
fi

echo ""

################################################################################
# 2. Détection de l'interface réseau
################################################################################

log_info "Détection de l'interface réseau..."

# Trouver l'interface principale (celle avec route par défaut)
DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$DEFAULT_INTERFACE" ]; then
    log_warning "Impossible de détecter l'interface automatiquement"
    log_info "Interfaces disponibles:"
    ip link show | grep -E "^[0-9]+:" | awk '{print "  - " $2}' | sed 's/:$//'
    echo ""
    read -p "Entrez le nom de l'interface à surveiller: " INTERFACE
else
    log_info "Interface détectée: $DEFAULT_INTERFACE"
    read -p "Utiliser cette interface? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        log_info "Interfaces disponibles:"
        ip link show | grep -E "^[0-9]+:" | awk '{print "  - " $2}' | sed 's/:$//'
        echo ""
        read -p "Entrez le nom de l'interface: " INTERFACE
    else
        INTERFACE=$DEFAULT_INTERFACE
    fi
fi

log_success "Interface sélectionnée: $INTERFACE"
echo ""

################################################################################
# 3. Création de la structure de dossiers
################################################################################

log_info "Création de la structure de dossiers..."

# Créer tous les dossiers nécessaires
mkdir -p data/elasticsearch
mkdir -p data/logs/suricata
mkdir -p data/logs/arpwatch
mkdir -p data/pcap
mkdir -p configs/suricata/rules
mkdir -p configs/filebeat
mkdir -p configs/nginx/html
mkdir -p scripts

log_success "Dossiers créés"

################################################################################
# 4. Configuration des permissions
################################################################################

log_info "Configuration des permissions..."

# Elasticsearch a besoin de permissions 777
chmod -R 777 data/elasticsearch

# Les autres dossiers en 755
chmod -R 755 data/logs
chmod -R 755 data/pcap
chmod -R 755 configs

log_success "Permissions configurées"

################################################################################
# 5. Mise à jour de docker-compose.yml avec l'interface
################################################################################

log_info "Configuration de l'interface dans docker-compose.yml..."

if [ -f "docker-compose.yml" ]; then
    # Backup du fichier original
    cp docker-compose.yml docker-compose.yml.backup

    # Remplacer l'interface (chercher ens33 et remplacer)
    sed -i "s/CAPTURE_INTERFACE=.*/CAPTURE_INTERFACE=$INTERFACE/" docker-compose.yml
    sed -i "s/ARPWATCH_INTERFACE=.*/ARPWATCH_INTERFACE=$INTERFACE/" docker-compose.yml

    log_success "Interface configurée: $INTERFACE"
else
    log_error "docker-compose.yml introuvable!"
    exit 1
fi

echo ""

################################################################################
# 6. Configuration système (vm.max_map_count pour Elasticsearch)
################################################################################

log_info "Configuration système pour Elasticsearch..."

CURRENT_MAX_MAP_COUNT=$(sysctl -n vm.max_map_count 2>/dev/null || echo "0")

if [ "$CURRENT_MAX_MAP_COUNT" -lt 262144 ]; then
    log_warning "vm.max_map_count trop bas ($CURRENT_MAX_MAP_COUNT)"
    log_info "Configuration de vm.max_map_count=262144..."

    sudo sysctl -w vm.max_map_count=262144

    # Rendre permanent
    if ! grep -q "vm.max_map_count" /etc/sysctl.conf; then
        echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf > /dev/null
    fi

    log_success "vm.max_map_count configuré"
else
    log_success "vm.max_map_count déjà configuré ($CURRENT_MAX_MAP_COUNT)"
fi

echo ""

################################################################################
# 7. Démarrage de la stack
################################################################################

log_info "Démarrage de la plateforme (cela peut prendre 2-5 minutes)..."

# Pull des images
log_info "Téléchargement des images Docker..."
docker compose pull

# Démarrer tous les services
log_info "Démarrage des containers..."
docker compose up -d

log_success "Containers démarrés"
echo ""

################################################################################
# 8. Attente du démarrage complet
################################################################################

log_info "Attente du démarrage des services..."

# Attendre Elasticsearch
log_info "Attente d'Elasticsearch (max 120 secondes)..."
for i in {1..40}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        log_success "Elasticsearch prêt"
        break
    fi
    sleep 3
    echo -n "."
done
echo ""

# Attendre Kibana
log_info "Attente de Kibana (max 120 secondes)..."
for i in {1..40}; do
    if curl -s http://localhost:5601/api/status > /dev/null 2>&1; then
        log_success "Kibana prêt"
        break
    fi
    sleep 3
    echo -n "."
done
echo ""

# Attendre 30 secondes supplémentaires pour stabilisation
show_progress 30 "Stabilisation des services"

################################################################################
# 9. Configuration automatique de Kibana
################################################################################

log_info "Configuration automatique de Kibana..."

# Créer Data View Suricata
log_info "Création du Data View Suricata..."
curl -X POST "http://localhost:5601/api/data_views/data_view" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "data_view": {
      "title": "suricata-*",
      "name": "Suricata Events",
      "timeFieldName": "timestamp"
    }
  }' > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_success "Data View 'Suricata Events' créé"
else
    log_warning "Erreur création Data View Suricata (peut-être déjà existant)"
fi

# Créer Data View ARPWatch
log_info "Création du Data View ARPWatch..."
curl -X POST "http://localhost:5601/api/data_views/data_view" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "data_view": {
      "title": "arpwatch-*",
      "name": "ARPWatch Events",
      "timeFieldName": "@timestamp"
    }
  }' > /dev/null 2>&1

if [ $? -eq 0 ]; then
    log_success "Data View 'ARPWatch Events' créé"
else
    log_warning "Erreur création Data View ARPWatch (peut-être déjà existant)"
fi

echo ""

################################################################################
# 10. Vérifications finales
################################################################################

log_info "Vérifications finales..."

# Vérifier que tous les containers tournent
CONTAINERS_RUNNING=$(docker compose ps --format json 2>/dev/null | grep -c "running" || docker compose ps | grep -c "Up")
CONTAINERS_EXPECTED=7

if [ "$CONTAINERS_RUNNING" -ge "$CONTAINERS_EXPECTED" ]; then
    log_success "$CONTAINERS_RUNNING/$CONTAINERS_EXPECTED containers actifs"
else
    log_warning "Seulement $CONTAINERS_RUNNING/$CONTAINERS_EXPECTED containers actifs"
    log_info "Vérifiez les logs: docker compose logs"
fi

# Vérifier que Suricata capture
sleep 5
if [ -f "data/logs/suricata/eve.json" ]; then
    EVE_LINES=$(wc -l < data/logs/suricata/eve.json)
    if [ "$EVE_LINES" -gt 0 ]; then
        log_success "Suricata capture du trafic ($EVE_LINES événements)"
    else
        log_warning "Suricata ne capture pas encore (attendez 30 secondes)"
    fi
else
    log_warning "Fichier eve.json non créé (attendez 30 secondes)"
fi

# Vérifier ARPWatch
if [ -f "data/logs/arpwatch/arp.dat" ]; then
    ARP_SIZE=$(stat -f%z data/logs/arpwatch/arp.dat 2>/dev/null || stat -c%s data/logs/arpwatch/arp.dat 2>/dev/null)
    if [ "$ARP_SIZE" -gt 0 ]; then
        log_success "ARPWatch capture ARP ($ARP_SIZE bytes)"
    else
        log_warning "ARPWatch ne capture pas encore (générez du trafic avec ping)"
    fi
fi

echo ""

################################################################################
# 11. Affichage des informations finales
################################################################################

log_success "═══════════════════════════════════════════════════════════════"
log_success "  Installation terminée avec succès! 🎉"
log_success "═══════════════════════════════════════════════════════════════"
echo ""

echo -e "${GREEN}Accès aux interfaces:${NC}"
echo "  • Page d'accueil:  http://localhost"
echo "  • Kibana:          http://localhost:5601"
echo "  • Elasticsearch:   http://localhost:9200"
echo ""

echo -e "${GREEN}Data Views créés dans Kibana:${NC}"
echo "  • Suricata Events  (suricata-*)"
echo "  • ARPWatch Events  (arpwatch-*)"
echo ""

echo -e "${GREEN}Interface surveillée:${NC}"
echo "  • $INTERFACE"
echo ""

echo -e "${GREEN}Commandes utiles:${NC}"
echo "  • Voir les logs:        docker compose logs -f"
echo "  • Redémarrer:           docker compose restart"
echo "  • Arrêter:              docker compose down"
echo "  • État des services:    docker compose ps"
echo "  • Tests:                bash scripts/tests.sh"
echo ""

echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "  1. Ouvrir Kibana: http://localhost:5601"
echo "  2. Aller dans Discover"
echo "  3. Sélectionner 'Suricata Events' ou 'ARPWatch Events'"
echo "  4. Générer du trafic: ping google.com, naviguer sur le web, etc."
echo "  5. Observer les événements en temps réel!"
echo ""

echo -e "${BLUE}Documentation:${NC}"
echo "  • README.md"
echo "  • TROUBLESHOOTING.md"
echo "  • docs/fix-arpwatch-v2.1.md"
echo ""

log_info "Backup de la configuration originale: docker-compose.yml.backup"
echo ""

# Proposer de lancer les tests
read -p "Voulez-vous lancer les tests automatisés maintenant? [Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ -f "scripts/tests.sh" ]; then
        echo ""
        log_info "Lancement des tests..."
        bash scripts/tests.sh
    else
        log_warning "Script de tests introuvable"
    fi
fi

echo ""
log_success "Installation terminée! Bonne surveillance! 🛡️"
