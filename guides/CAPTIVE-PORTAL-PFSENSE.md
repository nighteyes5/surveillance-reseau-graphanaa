# 🔐 Portail Captif pfSense avec Enseigne de Surveillance

**Guide complet pour créer un portail d'authentification professionnel**

---

## 🎯 Objectif

Créer un **portail captif** qui:
- ✅ Affiche l'**enseigne de surveillance** obligatoirement
- ✅ Force la **connexion avec login/mot de passe**
- ✅ Bloque l'accès Internet jusqu'à authentification
- ✅ Enregistre qui s'est connecté et quand
- ✅ Apparence professionnelle

---

## 📋 Prérequis

- pfSense installé et configuré (voir `PFSENSE-INTEGRATION.md`)
- Accès à l'interface Web pfSense (http://192.168.100.1)
- Enseigne HTML disponible (`docs/enseigne-laboratoire.html`)

---

## 🚀 Configuration du Captive Portal

### Étape 1: Activer le Captive Portal

1. **Connecte-toi à pfSense WebGUI:**
   ```
   URL: http://192.168.100.1
   Login: admin
   Password: pfsense (ou ton mot de passe)
   ```

2. **Aller dans Services → Captive Portal:**
   ```
   Services → Captive Portal
   → Add (en bas)
   ```

3. **Configuration de base:**
   ```
   Zone name: LaboratoireCyber
   Zone description: Laboratoire de Cybersécurité - Authentification Obligatoire

   ☑ Enable Captive Portal

   Interface: LAN

   Maximum concurrent connections: 100
   Idle timeout: 120 (minutes)
   Hard timeout: 0 (pas de limite)

   Authentication:
   ☑ Authenticate using the local user manager

   → Save
   ```

**Configuration réussie du Captive Portal:**

![Configuration du Captive Portal pfSense](../../images/captiveportal.png)

---

### Étape 2: Créer des Utilisateurs

1. **Aller dans System → User Manager:**
   ```
   System → User Manager → Users → Add
   ```

2. **Créer un utilisateur de test:**
   ```
   Username: etudiant1
   Password: MotDePasse123!
   Full name: Étudiant Test

   ☑ Group Membership: admins (ou créer un groupe "Etudiants")

   → Save
   ```

3. **Répéter pour créer plusieurs utilisateurs:**
   ```
   etudiant1, etudiant2, etudiant3, etc.

   Ou pour un enseignant:
   Username: prof1
   Password: Prof2024Secure!
   ```

---

### Étape 3: Personnaliser la Page de Connexion

#### Option A: Page Simple avec Enseigne

1. **Aller dans Services → Captive Portal → [LaboratoireCyber]:**
   ```
   Onglet: Captive Portal
   Section: Portal Page Contents
   ```

2. **HTML personnalisé avec enseigne:**

```html
<div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; background: #1a1a2e; color: #fff; padding: 30px; border: 4px solid #ff6b35; border-radius: 10px;">

    <!-- ENSEIGNE DE SURVEILLANCE -->
    <div style="border: 4px solid #ff6b35; padding: 30px; margin-bottom: 30px; background: rgba(255, 107, 53, 0.1); border-radius: 10px; text-align: center;">
        <h1 style="color: #ff6b35; font-size: 36px; margin: 0 0 15px 0;">
            ⚠️ AVERTISSEMENT ⚠️
        </h1>
        <h2 style="color: #ffd700; font-size: 24px; margin: 0;">
            LABORATOIRE DE CYBERSÉCURITÉ
        </h2>
    </div>

    <!-- AVERTISSEMENT PRINCIPAL -->
    <div style="background: rgba(255, 107, 53, 0.2); border-left: 4px solid #ff6b35; padding: 20px; margin: 20px 0; font-weight: bold; font-size: 18px;">
        🔒 SURVEILLANCE ACTIVE 🔒<br>
        <span style="font-size: 16px; font-weight: normal; margin-top: 10px; display: block;">
            Tous les accès Internet sont surveillés et enregistrés
        </span>
    </div>

    <!-- INFORMATIONS -->
    <div style="background: rgba(255, 255, 255, 0.05); border: 2px solid #ffd700; padding: 20px; margin: 20px 0; border-radius: 8px;">
        <h3 style="color: #ffd700; text-align: center; margin-top: 0;">📊 DONNÉES COLLECTÉES</h3>
        <ul style="font-size: 14px; line-height: 1.8;">
            <li>Adresses IP sources et destinations</li>
            <li>Requêtes DNS (sites web visités)</li>
            <li>Protocoles utilisés (HTTP, HTTPS, FTP, SSH)</li>
            <li>Horodatages précis de chaque connexion</li>
            <li>Métadonnées des paquets réseau</li>
            <li>Alertes de sécurité et tentatives d'intrusion</li>
        </ul>
    </div>

    <!-- FINALITÉ -->
    <div style="text-align: center; margin: 20px 0; font-size: 14px; color: #ccc;">
        <p>Les données sont utilisées à des fins de:</p>
        <p><strong style="color: #ffd700;">Pédagogie • Recherche • Sécurité • Conformité • Audit</strong></p>
    </div>

    <!-- CONSENTEMENT -->
    <div style="background: #ff6b35; color: #fff; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; font-weight: bold;">
        ⚠️ EN VOUS CONNECTANT, VOUS ACCEPTEZ LA SURVEILLANCE COMPLÈTE DE VOS ACTIVITÉS
    </div>

    <!-- INTERDICTIONS -->
    <div style="background: rgba(255, 0, 0, 0.2); border: 2px solid #ff0040; padding: 15px; margin: 20px 0; border-radius: 8px;">
        <h3 style="color: #ff6b35; text-align: center; margin-top: 0;">🚫 INTERDICTIONS STRICTES</h3>
        <ul style="font-size: 13px; line-height: 1.6;">
            <li>❌ Attaques informatiques (DoS, DDoS, scan de ports)</li>
            <li>❌ Tentatives d'intrusion ou escalade de privilèges</li>
            <li>❌ Distribution de malwares, virus, ransomwares</li>
            <li>❌ Contournement des mesures de sécurité</li>
            <li>❌ Usage de VPN/Proxy non autorisé</li>
            <li>❌ Téléchargement de contenu illégal</li>
        </ul>
    </div>

    <!-- FORMULAIRE DE CONNEXION -->
    <div style="background: rgba(255, 255, 255, 0.05); border: 2px solid #00ff41; padding: 30px; margin: 30px 0; border-radius: 10px;">
        <h2 style="color: #00ff41; text-align: center; margin-top: 0;">
            🔐 AUTHENTIFICATION REQUISE
        </h2>

        <form method="post" action="$PORTAL_ACTION$" style="max-width: 400px; margin: 0 auto;">
            <input name="redirurl" type="hidden" value="$PORTAL_REDIRURL$">

            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; color: #ffd700; font-weight: bold;">
                    👤 Nom d'utilisateur:
                </label>
                <input name="auth_user" type="text"
                       style="width: 100%; padding: 12px; font-size: 16px; border: 2px solid #00ff41; background: #0a0e27; color: #00ff41; border-radius: 5px;"
                       placeholder="Entrez votre login"
                       required>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; color: #ffd700; font-weight: bold;">
                    🔑 Mot de passe:
                </label>
                <input name="auth_pass" type="password"
                       style="width: 100%; padding: 12px; font-size: 16px; border: 2px solid #00ff41; background: #0a0e27; color: #00ff41; border-radius: 5px;"
                       placeholder="Entrez votre mot de passe"
                       required>
            </div>

            <div style="margin-bottom: 20px; text-align: center;">
                <label style="font-size: 14px; color: #ccc;">
                    <input type="checkbox" name="accept_terms" required style="margin-right: 10px;">
                    J'ai lu et j'accepte les conditions de surveillance
                </label>
            </div>

            <button type="submit" name="accept" value="Accept"
                    style="width: 100%; padding: 15px; font-size: 18px; font-weight: bold; background: #00ff41; color: #0a0e27; border: none; border-radius: 5px; cursor: pointer; text-transform: uppercase; letter-spacing: 2px;">
                ✅ SE CONNECTER
            </button>
        </form>
    </div>

    <!-- FOOTER -->
    <div style="text-align: center; border-top: 2px solid #444; padding-top: 20px; margin-top: 30px; font-size: 12px; color: #888;">
        <p><strong>PROJET IntroSSI - Management de la Sécurité des SI</strong></p>
        <p>École Supérieure Polytechnique (ESP) - Université Cheikh Anta Diop de Dakar (UCAD)</p>
        <p style="margin-top: 10px; color: #ff6b35;">
            Document officiel - Révision 2026-02-14
        </p>
    </div>
</div>
```

3. **Coller ce code dans:**
   ```
   Services → Captive Portal → [LaboratoireCyber]
   → Onglet: Captive Portal
   → Section: Portal Page Contents
   → Coller le HTML ci-dessus
   → Save
   ```

**Résultat - Enseigne de surveillance:**

![Enseigne de surveillance du laboratoire](../../images/enseigne.png)

**Page de connexion finale:**

![Page de connexion du portail captif](../../images/login%20pfsense.png)

---

#### Option B: Page HTML Externe (Avancée)

Si tu veux utiliser ton fichier `enseigne-laboratoire.html` complet:

1. **Uploader le fichier vers pfSense:**
   ```
   Diagnostics → Command Prompt
   → Upload File
   → Sélectionner: docs/enseigne-laboratoire.html
   → Destination: /usr/local/captiveportal/enseigne.html
   ```

2. **Référencer dans le portail:**
   ```
   Services → Captive Portal → [LaboratoireCyber]
   → Portal page contents:
   <iframe src="/enseigne.html" width="100%" height="800px" frameborder="0"></iframe>
   $PORTAL_MESSAGE$
   ```

---

### Étape 4: Personnaliser les Messages

1. **Messages de succès/erreur:**
   ```
   Services → Captive Portal → [LaboratoireCyber]

   Authentication error page contents:
   <h2 style="color: red;">❌ AUTHENTIFICATION ÉCHOUÉE</h2>
   <p>Login ou mot de passe incorrect. Veuillez réessayer.</p>
   <p><a href="$PORTAL_ACTION$">← Retour</a></p>

   Logout popup text:
   Vous avez été déconnecté du réseau.
   Vos activités ont été enregistrées conformément à la politique de surveillance.
   ```

---

### Étape 5: Configuration Avancée

#### A) Enregistrer les Connexions

1. **Activer les logs détaillés:**
   ```
   Services → Captive Portal → [LaboratoireCyber]

   ☑ Log successful authentications
   ☑ Log failed authentication attempts

   → Save
   ```

2. **Voir les logs:**
   ```
   Status → System Logs → Portal Auth
   ```

#### B) Page Après Connexion

```
Services → Captive Portal → [LaboratoireCyber]

After authentication Redirection URL:
http://192.168.100.10  (ta page d'accueil de surveillance)

Ou laisser vide pour aller vers la destination originale
```

#### C) MAC Address Filtering (Optionnel)

```
Services → Captive Portal → [LaboratoireCyber]
→ Onglet: Allowed MAC Addresses

Ajouter des MACs pour contourner l'authentification:
- Imprimantes
- Serveurs
- Équipements réseau
```

---

## 🧪 Test du Portail Captif

### 1. Se Connecter depuis un Client

```
1. Connecte un PC/smartphone au réseau LAN de pfSense
2. Ouvre un navigateur
3. Essaye d'accéder à n'importe quel site
4. → Redirection automatique vers le portail captif
5. Voir l'enseigne de surveillance (référence image ci-dessus)
6. Entrer login/mot de passe (ex: etudiant1 / MotDePasse123!)
7. Cocher "J'accepte les conditions"
8. Cliquer "SE CONNECTER"
9. → Accès Internet autorisé!
```

**Captures d'écran attendues lors du test:**
- L'enseigne d'avertissement doit s'afficher (voir image enseigne.png)
- Le formulaire de connexion doit être visible (voir image login pfsense.png)

### 2. Vérifier les Logs

```bash
# Dans pfSense:
Status → System Logs → Portal Auth

# Tu verras:
# - Qui s'est connecté
# - Quand
# - Depuis quelle IP/MAC
# - Combien de temps
```

### 3. Vérifier dans Suricata

```bash
# Les événements du client authentifié apparaissent dans Kibana
# avec son IP source enregistrée
```

---

## 📊 Monitoring des Utilisateurs

### Utilisateurs Connectés Actuellement

```
Services → Captive Portal → [LaboratoireCyber]
→ Onglet: Active Users

Affiche:
- Username
- IP Address
- MAC Address
- Session start time
- Last activity
```

### Déconnecter un Utilisateur

```
Services → Captive Portal → Active Users
→ Cliquer sur l'icône "poubelle" à côté de l'utilisateur
```

---

## 🎨 Personnalisation Avancée

### A) Logo Personnalisé

```html
<!-- Ajouter en haut du HTML -->
<div style="text-align: center; margin-bottom: 20px;">
    <img src="/logo-esp.png" alt="ESP Logo" style="max-width: 200px;">
</div>
```

Upload du logo:
```
Diagnostics → Command Prompt → Upload File
→ /usr/local/captiveportal/logo-esp.png
```

### B) CSS Personnalisé

```html
<style>
    body {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        font-family: Arial, sans-serif;
    }
    .portal-container {
        max-width: 900px;
        margin: 50px auto;
        padding: 0 20px;
    }
    /* ... */
</style>
```

---

## 🔐 Sécurité Avancée

### 1. HTTPS (Recommandé pour Production)

```
Services → Captive Portal → [LaboratoireCyber]

☑ Enable HTTPS login
HTTPS server name: pfsense.local

Upload Certificate:
System → Cert Manager → Certificates → Add
→ Créer un certificat auto-signé
```

### 2. Timeout Automatique

```
Idle timeout: 30 (minutes d'inactivité)
Hard timeout: 240 (4 heures maximum)

→ Force re-authentification régulière
```

### 3. Limitation de Bande Passante

```
Services → Captive Portal → [LaboratoireCyber]

Per-user bandwidth restriction:
Download: 10 Mbps
Upload: 5 Mbps
```

---

## 📱 Compatibilité Mobile

Le portail fonctionne sur:
- ✅ Android (Chrome, Firefox)
- ✅ iOS/iPhone (Safari)
- ✅ Windows (Edge, Chrome, Firefox)
- ✅ Linux (tous navigateurs)
- ✅ macOS (Safari, Chrome)

**Note iOS:** Désactiver "Private Relay" dans les paramètres iCloud pour que le portail fonctionne.

---

## 🎓 Cas d'Usage Typiques

### 1. Laboratoire Universitaire

```
Utilisateurs: Étudiants + Enseignants
Authentification: Local user manager
Timeout: 4 heures (durée d'un TP)
Logs: Obligatoires (conformité)
```

### 2. Entreprise/PME

```
Utilisateurs: Employés + Invités
Authentification: RADIUS/LDAP (Active Directory)
Timeout: Journée de travail
Bande passante: Limitée pour invités
```

### 3. Café/Espace Public

```
Utilisateurs: Clients
Authentification: Vouchers (tickets temporaires)
Timeout: 2 heures
Terms of Service: Obligatoire
```

---

## ❓ Troubleshooting

### Problème: Pas de redirection vers le portail

**Solution:**
```
1. Vérifier que le Captive Portal est activé
2. Vérifier que l'interface est bien LAN
3. Firewall → Rules → LAN → Vérifier qu'il n'y a pas de règle bloquante
4. Essayer en navigation privée
5. Vider le cache DNS: ipconfig /flushdns (Windows)
```

### Problème: "Invalid credentials"

**Solution:**
```
1. Vérifier l'utilisateur dans System → User Manager
2. S'assurer que le mot de passe est correct
3. Vérifier les logs: Status → System Logs → Portal Auth
```

### Problème: Connexion réussie mais pas d'Internet

**Solution:**
```
1. Vérifier Firewall → Rules → LAN
2. Ajouter une règle "Allow all" pour les utilisateurs authentifiés
3. Vérifier NAT: Firewall → NAT → Outbound
```

---

## 📚 Pour Aller Plus Loin

### Intégration RADIUS (Active Directory)

```
Services → Captive Portal → [LaboratoireCyber]

Authentication Method: RADIUS
RADIUS Server: 192.168.100.50
Port: 1812
Shared Secret: VotreSecretRADIUS

→ Authentification centralisée avec AD
```

### Vouchers (Tickets Temporaires)

```
Services → Captive Portal → [LaboratoireCyber]
→ Onglet: Vouchers

Créer des codes d'accès temporaires:
- Validité: 1 jour, 1 semaine, 1 mois
- Usage unique ou multiple
- Parfait pour visiteurs/invités
```

---

## ✅ Checklist Mise en Production

```
☐ Captive Portal activé et testé
☐ Utilisateurs créés
☐ Enseigne de surveillance affichée
☐ Logs activés et fonctionnels
☐ HTTPS configuré (production)
☐ Timeouts configurés
☐ Page de sortie personnalisée
☐ Règles firewall vérifiées
☐ Backup de la configuration pfSense
☐ Documentation utilisateur créée
```

---

## 📞 Support

**Questions?** Voir:
- Guide pfSense officiel: https://docs.netgate.com/pfsense/en/latest/captiveportal/
- `PFSENSE-INTEGRATION.md` pour la config réseau
- `TROUBLESHOOTING.md` pour les problèmes généraux

---

**Portail Captif Professionnel - Prêt à l'Emploi! 🚀**

*Version: 1.0 - Révision: 2026-02-14*
