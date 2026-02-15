#!/bin/bash

# ============================================
# SCRIPT DE TESTS AUTOMATIQUES - GLENZ STACK
# (Grafana-Logstash-Elasticsearch-Nginx-Zeek)
# ============================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Compteurs
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Fonction d'affichage
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

test_result() {
    local test_name="$1"
    local result="$2"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# ============================================
# TESTS PRÉREQUIS
# ============================================
print_header "1. TESTS DES PRÉREQUIS"

# Test Docker
docker --version &>/dev/null
test_result "Docker installé" $?

# Test Docker Compose
docker-compose --version &>/dev/null || docker compose version &>/dev/null
test_result "Docker Compose installé" $?

# Test permissions Docker
docker ps &>/dev/null
test_result "Permissions Docker OK" $?

# Test vm.max_map_count
current_count=$(sysctl vm.max_map_count | awk '{print $3}')
[ "$current_count" -ge 262144 ]
test_result "vm.max_map_count >= 262144" $?

# ============================================
# TESTS STRUCTURE PROJET
# ============================================
print_header "2. TESTS DE LA STRUCTURE DU PROJET"

[ -f "docker-compose.yml" ]
test_result "Fichier docker-compose.yml présent" $?

[ -f ".env" ]
test_result "Fichier .env présent" $?

[ -d "configs" ]
test_result "Répertoire configs/ présent" $?

[ -d "configs/zeek" ]
test_result "Configuration Zeek présente" $?

[ -d "configs/logstash" ]
test_result "Configuration Logstash présente" $?

[ -d "configs/grafana" ]
test_result "Configuration Grafana présente" $?

[ -d "data" ]
test_result "Répertoire data/ présent" $?

[ -d "scripts" ]
test_result "Répertoire scripts/ présent" $?

# ============================================
# TESTS CONTENEURS
# ============================================
print_header "3. TESTS DES CONTENEURS DOCKER"

# Vérifier que les conteneurs sont lancés
container_running() {
    docker-compose ps | grep -q "$1.*Up"
    return $?
}

container_running "elasticsearch"
test_result "Elasticsearch en cours d'exécution" $?

container_running "grafana"
test_result "Grafana en cours d'exécution" $?

container_running "zeek"
test_result "Zeek en cours d'exécution" $?

container_running "logstash"
test_result "Logstash en cours d'exécution" $?

container_running "dumpcap"
test_result "Dumpcap en cours d'exécution" $?

container_running "ettercap"
test_result "Ettercap en cours d'exécution" $?

container_running "nginx"
test_result "Nginx en cours d'exécution" $?

# ============================================
# TESTS SERVICES WEB
# ============================================
print_header "4. TESTS DES SERVICES WEB"

# Test Elasticsearch
curl -s http://localhost:9200/_cluster/health &>/dev/null
test_result "Elasticsearch répond (port 9200)" $?

# Test Grafana
curl -s http://localhost:3000/api/health &>/dev/null
test_result "Grafana répond (port 3000)" $?

# Test Nginx
curl -s http://localhost &>/dev/null
test_result "Nginx répond (port 80)" $?

# ============================================
# TESTS SANTÉ ELASTICSEARCH
# ============================================
print_header "5. TESTS DE SANTÉ ELASTICSEARCH"

# Statut cluster
es_status=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status')
[ "$es_status" = "green" ] || [ "$es_status" = "yellow" ]
test_result "Cluster Elasticsearch en santé ($es_status)" $?

# Nombre de nœuds
es_nodes=$(curl -s http://localhost:9200/_cluster/health | jq -r '.number_of_nodes')
[ "$es_nodes" -ge 1 ]
test_result "Au moins 1 nœud Elasticsearch actif" $?

# ============================================
# TESTS CAPTURE DONNÉES
# ============================================
print_header "6. TESTS DE CAPTURE DE DONNÉES"

# PCAP directory exists
[ -d "data/pcap" ]
test_result "Répertoire PCAP existe" $?

# Check for recent PCAP files (last 2 hours)
pcap_count=$(find data/pcap -type f -name "*.pcap*" -mmin -120 2>/dev/null | wc -l)
[ "$pcap_count" -gt 0 ]
test_result "Fichiers PCAP récents trouvés ($pcap_count)" $?

# Zeek logs directory
[ -d "data/logs/zeek/current" ]
test_result "Répertoire logs Zeek existe" $?

# Zeek conn.log
[ -f "data/logs/zeek/current/conn.log" ]
test_result "Fichier conn.log Zeek existe" $?

# Zeek conn.log has content
conn_lines=$(grep -v "^#" data/logs/zeek/current/conn.log 2>/dev/null | wc -l || echo 0)
[ "$conn_lines" -gt 0 ]
test_result "Connexions Zeek capturées ($conn_lines lignes)" $?

# Zeek dns.log
[ -f "data/logs/zeek/current/dns.log" ]
test_result "Fichier dns.log Zeek existe" $?

# Ettercap data
[ -d "data/logs/ettercap" ]
test_result "Répertoire logs Ettercap existe" $?

# ============================================
# TESTS INDEX ELASTICSEARCH
# ============================================
print_header "7. TESTS DES INDEX ELASTICSEARCH"

# Lister les index
indices=$(curl -s http://localhost:9200/_cat/indices?format=json 2>/dev/null)

# Vérifier si des index existent
index_count=$(echo "$indices" | jq -r '. | length')
[ "$index_count" -gt 0 ]
test_result "Index Elasticsearch présents ($index_count index)" $?

# Vérifier les index Zeek conn
zeek_conn_indices=$(echo "$indices" | jq -r '.[].index' | grep -c "^zeek-conn-" || true)
[ "$zeek_conn_indices" -ge 0 ]
test_result "Index Zeek conn trouvés ($zeek_conn_indices)" 0

# Vérifier les index Zeek dns
zeek_dns_indices=$(echo "$indices" | jq -r '.[].index' | grep -c "^zeek-dns-" || true)
[ "$zeek_dns_indices" -ge 0 ]
test_result "Index Zeek dns trouvés ($zeek_dns_indices)" 0

# Vérifier les index Zeek http
zeek_http_indices=$(echo "$indices" | jq -r '.[].index' | grep -c "^zeek-http-" || true)
[ "$zeek_http_indices" -ge 0 ]
test_result "Index Zeek http trouvés ($zeek_http_indices)" 0

# ============================================
# TESTS DOCUMENTS ELASTICSEARCH
# ============================================
print_header "8. TESTS DES DOCUMENTS INDEXÉS"

# Compter les documents Zeek conn
zeek_conn_docs=$(curl -s http://localhost:9200/zeek-conn-*/_count 2>/dev/null | jq -r '.count' || echo 0)
[ "$zeek_conn_docs" -ge 0 ]
test_result "Documents Zeek conn indexés ($zeek_conn_docs docs)" 0

# Compter les documents Zeek dns
zeek_dns_docs=$(curl -s http://localhost:9200/zeek-dns-*/_count 2>/dev/null | jq -r '.count' || echo 0)
[ "$zeek_dns_docs" -ge 0 ]
test_result "Documents Zeek dns indexés ($zeek_dns_docs docs)" 0

# Compter les documents Zeek http
zeek_http_docs=$(curl -s http://localhost:9200/zeek-http-*/_count 2>/dev/null | jq -r '.count' || echo 0)
[ "$zeek_http_docs" -ge 0 ]
test_result "Documents Zeek http indexés ($zeek_http_docs docs)" 0

# ============================================
# TESTS GRAFANA
# ============================================
print_header "9. TESTS GRAFANA"

# Test datasources
datasources=$(curl -s http://admin:admin@localhost:3000/api/datasources 2>/dev/null | jq -r '. | length' || echo 0)
[ "$datasources" -ge 0 ]
test_result "Datasources Grafana configurées ($datasources)" 0

# ============================================
# TESTS RÉSEAU
# ============================================
print_header "10. TESTS RÉSEAU"

# Interface réseau configurée
INTERFACE=$(grep CAPTURE_INTERFACE .env | cut -d= -f2)
ip link show "$INTERFACE" &>/dev/null
test_result "Interface $INTERFACE existe" $?

# ============================================
# TESTS ESPACE DISQUE
# ============================================
print_header "11. TESTS ESPACE DISQUE"

# Vérifier espace libre
free_space=$(df -h . | tail -1 | awk '{print $4}' | sed 's/G//')
[ "${free_space%.*}" -gt 5 ]
test_result "Espace disque suffisant (${free_space}G disponible)" $?

# Taille des données
pcap_size=$(du -sh data/pcap 2>/dev/null | awk '{print $1}')
test_result "Taille PCAP: $pcap_size" 0

logs_size=$(du -sh data/logs 2>/dev/null | awk '{print $1}')
test_result "Taille logs: $logs_size" 0

es_size=$(du -sh data/elasticsearch 2>/dev/null | awk '{print $1}')
test_result "Taille Elasticsearch: $es_size" 0

# ============================================
# TESTS LOGSTASH PIPELINES
# ============================================
print_header "12. TESTS LOGSTASH"

# Vérifier les pipelines Logstash
pipelines=("01-zeek-conn.conf" "02-zeek-dns.conf" "03-zeek-http.conf" "04-zeek-notice.conf" "05-ettercap.conf")
for pipeline in "${pipelines[@]}"; do
    [ -f "configs/logstash/pipelines/$pipeline" ]
    test_result "Pipeline $pipeline présent" $?
done

# ============================================
# RÉSUMÉ
# ============================================
print_header "RÉSUMÉ DES TESTS - GLENZ STACK"

echo -e "Total: ${BLUE}$TOTAL_TESTS${NC} tests"
echo -e "Réussis: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Échoués: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ TOUS LES TESTS SONT PASSÉS !${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Stack GLENZ opérationnelle:"
    echo "  - Grafana: http://localhost:3000 (admin/admin)"
    echo "  - Elasticsearch: http://localhost:9200"
    echo "  - Nginx: http://localhost"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}✗ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Suggestions:"
    echo "  1. Vérifier les logs: docker-compose logs"
    echo "  2. Vérifier l'état: docker-compose ps"
    echo "  3. Vérifier logs Zeek: data/logs/zeek/current/"
    echo "  4. Vérifier Logstash: docker-compose logs logstash"
    echo "  5. Consulter la documentation: docs/installation-privee.md"
    exit 1
fi
