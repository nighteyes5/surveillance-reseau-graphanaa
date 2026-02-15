# 📚 Guides de la Plateforme de Surveillance Réseau

Documentation pratique et guides d'utilisation.

---

## 🚀 Démarrage Rapide

### [QUICKSTART-ZERO-CONFIG.md](./QUICKSTART-ZERO-CONFIG.md)
**Installation en 30 secondes - Zero Configuration**
- Configuration système (une fois)
- Déploiement automatique
- Vérifications

**Pour qui:** Premiers pas, déploiement rapide

---

## 📖 Installation et Déploiement

### [DEPLOY.md](./DEPLOY.md)
**Guide de déploiement complet et détaillé**
- Installation step-by-step
- Configuration réseau
- Vérifications post-déploiement
- Maintenance
- Troubleshooting

**Pour qui:** Installation en production, déploiement serveur

### [DISTRIBUTION.md](./DISTRIBUTION.md)
**Création de packages de distribution**
- Ce qui doit être inclus/exclu
- Création d'archives
- Checklist avant distribution
- Instructions pour utilisateur final

**Pour qui:** Packaging, redistribution du projet

---

## 🔧 Utilisation

### [DASHBOARDS-KIBANA.md](./DASHBOARDS-KIBANA.md)
**Dashboards et visualisations Kibana**
- Data Views créés automatiquement
- Visualisations pré-configurées (4)
- Créer des dashboards personnalisés
- Requêtes KQL utiles
- Best practices

**Pour qui:** Analyse de données, création de dashboards

---

## 🐛 Dépannage

### [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
**Guide de dépannage et résolution de problèmes**
- Problèmes courants (Elasticsearch, Filebeat, ARPWatch)
- Solutions pas-à-pas
- Commandes de diagnostic
- Réinitialisation complète

**Pour qui:** Résolution de problèmes, debugging

---

## 📊 Organisation de la Documentation

```
surveillance-reseau/
├── README.md                    # Vue d'ensemble du projet
├── CHANGELOG.md                 # Historique des versions
│
├── guides/                      # 📚 GUIDES PRATIQUES
│   ├── README.md                # (ce fichier)
│   ├── QUICKSTART-ZERO-CONFIG.md
│   ├── DEPLOY.md
│   ├── DISTRIBUTION.md
│   ├── DASHBOARDS-KIBANA.md
│   └── TROUBLESHOOTING.md
│
└── docs/                        # 📖 DOCUMENTATION TECHNIQUE
    ├── architecture-publique.md
    ├── installation-privee.md
    ├── evaluation-conformite.md
    ├── fix-arpwatch-v2.1.md
    └── enseigne-laboratoire.md
```

---

## 🎯 Quel guide lire?

### Je veux déployer rapidement:
→ **QUICKSTART-ZERO-CONFIG.md**

### Je veux une installation complète:
→ **DEPLOY.md**

### Je veux créer des dashboards Kibana:
→ **DASHBOARDS-KIBANA.md**

### J'ai un problème:
→ **TROUBLESHOOTING.md**

### Je veux distribuer le projet:
→ **DISTRIBUTION.md**

### Je veux comprendre l'architecture:
→ **docs/architecture-publique.md**

---

**Version:** 2.1
**Dernière mise à jour:** 2026-02-14
