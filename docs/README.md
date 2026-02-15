# Documentation du Projet - Surveillance Réseau

**Version** : 2.0
**Date** : 2026-02-14
**Projet** : IntroSSI - Management de la Sécurité des Systèmes d'Information
**Institution** : UCAD ESP

---

## 📚 Documents Disponibles

### 1. Architecture Publique
**Fichier** : [`architecture-publique.md`](architecture-publique.md)
**Taille** : ~25 KB
**Public** : Présentation publique, affichage web

**Contenu** :
- Description narrative du NSOC (Network Security Operations Center)
- Stack technologique (Suricata, ELK, ARPWatch, Tcpdump)
- Diagrammes de réseau et flux de données
- Détails techniques de chaque composant
- Organisation du stockage et estimations
- Métriques de performance
- Best practices sécurité
- Exemples d'utilisation et requêtes Kibana

**Utilisation** :
- Documentation pour présentation projet
- Référence architecture technique
- Guide utilisateur Kibana

---

### 2. Installation Privée
**Fichier** : [`installation-privee.md`](installation-privee.md)
**Taille** : ~50 KB
**Public** : Installation technique (confidentiel)

**Contenu** :
- Prérequis matériels et logiciels
- Installation Ubuntu 22.04 LTS step-by-step
- Installation Docker Engine et Docker Compose
- Configuration réseau (Netplan, IP statique)
- **Configuration Mikrotik détaillée (v2.0)** :
  - 3 méthodes port mirroring (Switch Chip, Sniffer, Bridge)
  - Configuration NetFlow v9
  - Configuration Syslog
  - Configuration VLAN
  - Exemples CLI et WinBox
  - Troubleshooting Mikrotik
- Déploiement du projet
- Tests de vérification (9 tests)
- Configuration avancée (dashboards, règles, rotation)
- Maintenance quotidienne
- Dépannage (8 problèmes communs)

**Utilisation** :
- Guide d'installation depuis Ubuntu générique
- Référence configuration Mikrotik RouterOS
- Procédures de maintenance

---

### 3. Évaluation de Conformité **(NOUVEAU v2.0)**
**Fichier** : [`evaluation-conformite.md`](evaluation-conformite.md)
**Taille** : ~85 KB (~15,000 mots)
**Public** : Analyse académique

**Contenu** :
- Résumé exécutif (note 86/100)
- Grille d'évaluation détaillée par composant
- Analyse par composant (conformes, substitutions, absences)
- Choix d'architecture justifiés :
  - Tableaux comparatifs (Suricata vs Snort, ELK vs SOF-ELK)
  - Justifications techniques
- Améliorations v1.0 → v2.0 (détaillées)
- Points forts du projet (6 catégories)
- Recommandations futures (Priorité 3)
- Conclusion et verdict final

**Utilisation** :
- Comprendre l'évaluation académique
- Justifier les choix techniques
- Préparer la défense du projet

---

### 4. Enseigne de Laboratoire - HTML **(NOUVEAU v2.0)**
**Fichier** : [`enseigne-laboratoire.html`](enseigne-laboratoire.html)
**Taille** : ~6 KB
**Public** : Affichage laboratoire (obligatoire)

**Contenu** :
- Avertissement "TOUS LES ACCÈS INTERNET SONT SURVEILLÉS"
- Texte conforme au document IntroSSI
- Liste exhaustive des données collectées
- Conséquences et interdictions strictes
- Mentions légales (UCAD ESP, loi sénégalaise)
- Design professionnel (dégradés, icônes, bordures)
- Format A4 (210 × 297 mm)
- Optimisé pour impression couleur

**Utilisation** :
```bash
# Ouvrir dans navigateur
firefox docs/enseigne-laboratoire.html

# Imprimer (Ctrl+P)
# - Format : A4
# - Orientation : Portrait
# - Couleur : Oui
# - Marges : Aucune ou Minimales
```

**Affichage** :
- Imprimer 1+ exemplaires A4 couleur
- Plastifier pour durabilité
- Afficher à l'entrée du laboratoire (hauteur des yeux)
- Multiplier : 1 à l'entrée + 1 près de chaque poste

---

### 5. Enseigne de Laboratoire - Markdown **(NOUVEAU v2.0)**
**Fichier** : [`enseigne-laboratoire.md`](enseigne-laboratoire.md)
**Taille** : ~7 KB
**Public** : Affichage laboratoire (éditable)

**Contenu** :
- Même contenu que la version HTML
- Format Markdown pour édition facile
- Instructions d'impression (3 méthodes) :
  - Conversion PDF avec pandoc
  - Conversion PDF avec wkhtmltopdf
  - Conversion PDF avec Chrome headless
- Recommandations d'affichage

**Utilisation** :
```bash
# Méthode 1 : pandoc (recommandé)
pandoc enseigne-laboratoire.md -o enseigne.pdf \
  --pdf-engine=xelatex -V geometry:margin=2cm

# Méthode 2 : wkhtmltopdf (depuis HTML)
wkhtmltopdf enseigne-laboratoire.html enseigne.pdf

# Méthode 3 : Chrome headless
chromium --headless --print-to-pdf=enseigne.pdf \
  enseigne-laboratoire.html
```

---

## 📊 Tableau Récapitulatif

| Document | Type | Taille | Public | Nouveau v2.0 |
|----------|------|--------|--------|--------------|
| architecture-publique.md | Architecture | 25 KB | Présentation | ❌ |
| installation-privee.md | Installation | 50 KB | Technique | ✅ (Mikrotik) |
| evaluation-conformite.md | Évaluation | 85 KB | Académique | ✅ |
| enseigne-laboratoire.html | Enseigne | 6 KB | Affichage | ✅ |
| enseigne-laboratoire.md | Enseigne | 7 KB | Éditable | ✅ |

**Total** : 5 documents, ~173 KB, ~30,000+ mots

---

## 🎯 Utilisation par Cas d'Usage

### Je veux installer le projet depuis zéro
→ Lire [`installation-privee.md`](installation-privee.md)
- Section par section (1-10)
- Focus section 5 (Configuration Mikrotik)

### Je veux comprendre l'architecture
→ Lire [`architecture-publique.md`](architecture-publique.md)
- Diagrammes de flux
- Description de chaque composant

### Je veux préparer ma défense de projet
→ Lire [`evaluation-conformite.md`](evaluation-conformite.md)
- Grille d'évaluation
- Justifications techniques
- Tableaux comparatifs

### Je veux imprimer l'enseigne
→ Ouvrir [`enseigne-laboratoire.html`](enseigne-laboratoire.html)
- Ctrl+P → A4 couleur → Imprimer
- Ou convertir [`enseigne-laboratoire.md`](enseigne-laboratoire.md) en PDF

### Je veux modifier l'enseigne
→ Éditer [`enseigne-laboratoire.md`](enseigne-laboratoire.md)
- Format Markdown standard
- Convertir en PDF après modification

---

## 📁 Structure Complète du Projet

```
surveillance-reseau/
│
├── docs/                              ← Vous êtes ici
│   ├── README.md                      ← Ce fichier
│   ├── architecture-publique.md
│   ├── installation-privee.md         (Mikrotik v2.0)
│   ├── evaluation-conformite.md       (NOUVEAU v2.0)
│   ├── enseigne-laboratoire.html      (NOUVEAU v2.0)
│   └── enseigne-laboratoire.md        (NOUVEAU v2.0)
│
├── QUICKSTART.txt                     ← Démarrage 30 secondes
├── RESUME-EXECUTIF-V2.0.txt           ← Résumé 3 minutes
├── GUIDE-RAPIDE-V2.0.md               ← Guide complet 10 minutes
├── AMELIORATIONS-V2.0.md              ← Détail améliorations
├── CHANGELOG.md                       ← Historique versions
├── FICHIERS-MODIFIES-V2.0.txt         ← Liste fichiers modifiés
├── README.md                          ← Documentation principale
├── TROUBLESHOOTING.md                 ← Guide dépannage
│
├── docker-compose.yml
├── .env
├── configs/
├── data/
└── scripts/
```

---

## 🚀 Ordre de Lecture Recommandé

### Pour démarrer rapidement (5 min)
1. [`../QUICKSTART.txt`](../QUICKSTART.txt) - Démarrage 30 secondes
2. [`../README.md`](../README.md) - Documentation principale

### Pour comprendre le projet (30 min)
1. [`../RESUME-EXECUTIF-V2.0.txt`](../RESUME-EXECUTIF-V2.0.txt) - Résumé
2. [`architecture-publique.md`](architecture-publique.md) - Architecture
3. [`evaluation-conformite.md`](evaluation-conformite.md) - Évaluation

### Pour installer (1-2h)
1. [`installation-privee.md`](installation-privee.md) - Guide complet
2. [`../GUIDE-RAPIDE-V2.0.md`](../GUIDE-RAPIDE-V2.0.md) - Commandes rapides

### Pour soumettre le projet (10 min)
1. [`../RESUME-EXECUTIF-V2.0.txt`](../RESUME-EXECUTIF-V2.0.txt) - Checklist
2. [`enseigne-laboratoire.html`](enseigne-laboratoire.html) - Imprimer
3. [`evaluation-conformite.md`](evaluation-conformite.md) - Justifications

---

## 📞 Références Rapides

### Configuration Mikrotik (3 méthodes)
→ [`installation-privee.md`](installation-privee.md#51-configurer-le-port-mirroring-span) (ligne 410+)

### Grille d'évaluation académique
→ [`evaluation-conformite.md`](evaluation-conformite.md#2-grille-dévaluation-détaillée) (section 2)

### Exemples de requêtes Kibana
→ [`architecture-publique.md`](architecture-publique.md#exemples-de-requêtes-kibana)

### Troubleshooting complet
→ [`installation-privee.md`](installation-privee.md#9-dépannage) (section 9)
→ [`../TROUBLESHOOTING.md`](../TROUBLESHOOTING.md)

### Texte enseigne conforme
→ [`enseigne-laboratoire.md`](enseigne-laboratoire.md)
→ [`enseigne-laboratoire.html`](enseigne-laboratoire.html)

---

## ✅ Checklist Documentation

**Avant soumission, vérifier que** :
- [ ] Tous les fichiers docs/ sont présents (5 fichiers)
- [ ] Enseigne HTML s'ouvre correctement dans navigateur
- [ ] Enseigne imprimée (1 exemplaire A4 couleur minimum)
- [ ] Documentation Mikrotik complète (150+ lignes)
- [ ] Évaluation conformité présente (15,000+ mots)
- [ ] Tous les liens Markdown fonctionnent

---

## 📊 Statistiques Documentation

**Nombre de fichiers** : 5 (dans docs/) + 7 (racine) = 12 documents
**Taille totale** : ~180 KB
**Nombre de mots** : ~30,000 mots
**Temps de lecture** : ~2-3 heures (tout lire)
**Temps installation** : ~1 heure (avec guide)

---

## 🎓 Version et Contact

**Version du projet** : 2.0
**Date de publication** : 2026-02-14
**Statut** : Stable - Prêt pour soumission

**Projet** : IntroSSI - Management de la Sécurité des Systèmes d'Information
**Institution** : École Supérieure Polytechnique (ESP)
**Université** : Université Cheikh Anta Diop de Dakar (UCAD)

**Contact** :
- Responsable projet : [Votre Nom]
- Email : [votre.email@ucad.edu.sn]

---

**Dernière mise à jour** : 2026-02-14
**Auteurs** : Équipe projet Surveillance Réseau

---

**[Retour au README principal](../README.md)**
