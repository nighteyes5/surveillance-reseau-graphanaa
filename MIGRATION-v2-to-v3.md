# Guide de Migration - v2.0 (Suricata) → v3.0 (GLENZ)

**⚠️ ATTENTION:** Cette migration nécessite un redéploiement complet. Les données ne sont pas compatibles entre les versions.

---

## Vue d'Ensemble

La version 3.0 (GLENZ Stack) est une **réécriture complète** de l'architecture avec une approche différente:

| Aspect | v2.0 | v3.0 GLENZ |
|--------|------|------------|
| **Philosophie** | Signature-based IDS | Behavioral analysis |
| **IDS** | Suricata | Zeek |
| **Processing** | Filebeat (forwarding) | Logstash (transformation) |
| **Visualization** | Kibana | Grafana |
| **Data Format** | EVE JSON | TSV → JSON |

---

## Incompatibilités

### ❌ Données Non Compatibles

- Les index Elasticsearch `suricata-*` ne sont **pas compatibles** avec `zeek-*`
- Les dashboards Kibana ne peuvent **pas être importés** dans Grafana
- Les règles Suricata ne s'appliquent **pas** à Zeek

### ❌ Configuration Non Compatible

- `configs/suricata/` → `configs/zeek/`
- `configs/filebeat/` → `configs/logstash/`
- `configs/kibana/` → `configs/grafana/`

---

## Stratégies de Migration

### Option 1: Déploiement Parallèle (Recommandé)

**Avantages:**
- Pas d'interruption de service
- Possibilité de comparer les deux stacks
- Rollback facile si problème

**Étapes:**

1. **Cloner le projet v3.0 dans un nouveau répertoire**
   ```bash
   # Garder v2.0
   cd ~/surveillance-reseau-v2

   # Déployer v3.0
   cd ~
   git clone <REPO_URL> surveillance-reseau-v3
   cd surveillance-reseau-v3
   ```

2. **Configurer l'environnement**
   ```bash
   cp .env.example .env
   nano .env
   # Modifier CAPTURE_INTERFACE si différent
   ```

3. **Démarrer GLENZ**
   ```bash
   sudo sysctl -w vm.max_map_count=262144
   docker compose up -d
   ```

4. **Tester et comparer**
   ```bash
   # GLENZ
   curl http://localhost:3000  # Grafana
   curl http://localhost:9200/_cat/indices/zeek-*

   # v2.0 (si toujours actif)
   curl http://localhost:5601  # Kibana
   curl http://localhost:9200/_cat/indices/suricata-*
   ```

5. **Migration progressive**
   - Utiliser GLENZ pendant 1-2 semaines
   - Vérifier que toutes les alertes sont détectées
   - Si OK, arrêter v2.0

---

### Option 2: Migration Destructive (Plus Rapide)

**⚠️ ATTENTION:** Perte de toutes les données v2.0

**Étapes:**

1. **Backup des données importantes**
   ```bash
   # Backup PCAP
   tar -czf backup-pcap-$(date +%Y%m%d).tar.gz data/pcap/

   # Backup configuration
   tar -czf backup-config-v2-$(date +%Y%m%d).tar.gz configs/

   # Export dashboards Kibana (optionnel)
   curl http://localhost:5601/api/saved_objects/_export > kibana-dashboards.ndjson
   ```

2. **Arrêter v2.0**
   ```bash
   docker compose down -v
   ```

3. **Nettoyer les données**
   ```bash
   rm -rf data/elasticsearch
   rm -rf data/logs
   # Garder data/pcap si besoin
   ```

4. **Supprimer les anciennes configurations**
   ```bash
   rm -rf configs/kibana
   rm -rf configs/suricata
   rm -rf configs/filebeat
   ```

5. **Pull v3.0**
   ```bash
   git pull origin v3.0
   # OU
   # Télécharger et extraire l'archive v3.0
   ```

6. **Configurer et démarrer GLENZ**
   ```bash
   cp .env.example .env
   nano .env
   sudo sysctl -w vm.max_map_count=262144
   docker compose up -d
   ```

---

## Équivalences

### Dashboards Kibana → Grafana

| Kibana Dashboard | Grafana Équivalent |
|-----------------|-------------------|
| Suricata Events | Zeek Network Overview |
| Suricata Alerts | Security Alerts |
| Network Traffic | Zeek Connections |
| DNS Queries | DNS Analysis |
| HTTP Traffic | HTTP Traffic Analysis |
| ARPWatch | MITM Detection |

**Note:** Les dashboards Grafana doivent être recréés manuellement ou importés depuis les templates fournis.

### Index Elasticsearch

| v2.0 | v3.0 GLENZ |
|------|-----------|
| `suricata-*` | `zeek-conn-*`, `zeek-dns-*`, `zeek-http-*` |
| `arpwatch-*` | `ettercap-*` |

### Champs de Données

**Connexions Réseau:**

| v2.0 (Suricata) | v3.0 (Zeek) |
|-----------------|-------------|
| `src_ip` | `src_ip` ✓ |
| `dest_ip` | `dst_ip` |
| `src_port` | `src_port` ✓ |
| `dest_port` | `dst_port` |
| `proto` | `proto` ✓ |
| `event_type` | `event_type` ✓ |
| `alert.signature` | `alert_type` (notice.log) |

**DNS:**

| v2.0 (Suricata) | v3.0 (Zeek) |
|-----------------|-------------|
| `dns.query` | `dns_query` |
| `dns.answers` | `dns_answers` |
| `dns.rcode` | `rcode_name` |

**HTTP:**

| v2.0 (Suricata) | v3.0 (Zeek) |
|-----------------|-------------|
| `http.method` | `method` |
| `http.url` | `uri` |
| `http.user_agent` | `user_agent` |
| `http.status` | `status_code` |

---

## Migration des Requêtes

### Kibana KQL → Grafana Lucene

**Exemple 1: Alertes**

```
# v2.0 Kibana (KQL)
event_type:alert AND alert.severity:[1 TO 3]

# v3.0 Grafana (Lucene)
event_type:alert AND alert_type:*
```

**Exemple 2: DNS**

```
# v2.0 Kibana (KQL)
dns.query:"*.exe"

# v3.0 Grafana (Lucene)
dns_query:*.exe
```

**Exemple 3: HTTP**

```
# v2.0 Kibana (KQL)
http.status >= 400

# v3.0 Grafana (Lucene)
status_code:[400 TO 599]
```

---

## Checklist de Migration

### Avant Migration

- [ ] Backup des PCAP importants
- [ ] Export des dashboards Kibana
- [ ] Backup de la configuration v2.0
- [ ] Noter les règles Suricata personnalisées
- [ ] Documenter les workflows actuels

### Pendant Migration

- [ ] Arrêter v2.0 (si migration destructive)
- [ ] Nettoyer les données
- [ ] Supprimer anciennes configs
- [ ] Déployer v3.0 GLENZ
- [ ] Vérifier tous les services démarrent
- [ ] Exécuter `bash scripts/tests.sh`

### Après Migration

- [ ] Vérifier capture réseau (Zeek)
- [ ] Vérifier parsing Logstash
- [ ] Vérifier index Elasticsearch
- [ ] Configurer Grafana datasource
- [ ] Créer dashboards Grafana
- [ ] Tester alerting
- [ ] Former les utilisateurs (nouvelles interfaces)

---

## FAQ

### Q: Puis-je garder mes données Elasticsearch v2.0?

**R:** Non, les index `suricata-*` et `zeek-*` ont des schémas incompatibles. Vous pouvez les garder en lecture seule, mais ils ne seront pas mis à jour.

### Q: Puis-je importer mes dashboards Kibana dans Grafana?

**R:** Non, il faut recréer les dashboards. Grafana et Kibana ont des formats différents.

### Q: Zeek détecte-t-il les mêmes menaces que Suricata?

**R:** Non, Zeek utilise une approche comportementale vs signatures. Les détections sont **complémentaires**, pas identiques.

### Q: Puis-je utiliser Zeek ET Suricata ensemble?

**R:** Oui, mais cela nécessite deux projets séparés. Vous pouvez déployer les deux en parallèle sur des ports différents.

### Q: La migration est-elle réversible?

**R:** Oui, si vous avez gardé les backups de v2.0. Sinon, vous devrez redéployer v2.0 from scratch.

### Q: Combien de temps prend la migration?

**R:**
- Migration parallèle: 1-2 heures (déploiement v3.0)
- Migration destructive: 30-60 minutes (si tout va bien)
- Formation utilisateurs: 2-4 heures

---

## Support

Pour toute question sur la migration:
- Consulter la [documentation v3.0](docs/)
- Exécuter `bash scripts/tests.sh` pour diagnostiquer
- Vérifier les logs: `docker compose logs -f`

---

**Version:** 3.0 - GLENZ Stack
**Date:** Février 2024
