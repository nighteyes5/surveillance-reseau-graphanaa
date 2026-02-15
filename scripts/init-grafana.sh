#!/bin/sh

echo "========================================="
echo "Initialisation de Grafana"
echo "========================================="

echo "Attente du démarrage de Grafana..."
RETRY=0
MAX_RETRY=60

until curl -s http://grafana:3000/api/health > /dev/null 2>&1; do
    RETRY=$((RETRY+1))
    if [ $RETRY -gt $MAX_RETRY ]; then
        echo "ERREUR: Grafana n'a pas démarré après ${MAX_RETRY} tentatives"
        exit 1
    fi
    echo "  Tentative $RETRY/$MAX_RETRY..."
    sleep 2
done

echo "Grafana est prêt!"
echo "========================================="

# Attendre un peu plus pour s'assurer que l'API est complètement prête
sleep 5

echo "Configuration de la datasource Elasticsearch..."
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Elasticsearch-Zeek",
    "type": "elasticsearch",
    "url": "http://elasticsearch:9200",
    "access": "proxy",
    "database": "zeek-*",
    "jsonData": {
      "timeField": "@timestamp",
      "esVersion": "8.0.0",
      "interval": "Daily",
      "timeInterval": "10s"
    }
  }' \
  http://admin:admin@grafana:3000/api/datasources 2>&1

echo ""
echo "========================================="
echo "Configuration Grafana terminée!"
echo "========================================="
echo ""
echo "Accès Grafana:"
echo "  URL: http://localhost:3000"
echo "  User: admin"
echo "  Pass: admin"
echo ""
echo "Datasource Elasticsearch configurée:"
echo "  Name: Elasticsearch-Zeek"
echo "  URL: http://elasticsearch:9200"
echo "  Index: zeek-*"
echo ""
echo "========================================="
