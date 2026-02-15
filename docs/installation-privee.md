# Guide d'Installation Privé 


Instructions détaillées d'installation 

---

## Vue d'ensemble de l'infrastructure

Cette installation utilise VMware Workstation avec 3 machines virtuelles :

```
                    Internet
                       |
                   [VMnet8 NAT]
                       |
                  +---------+
                  | pfSense |  (10GB, 2 CPU, 4GB RAM)
                  +---------+
                       |
                   [VMnet1 Host-Only]
                       |
        +--------------+---------------+
        |                              |
   +---------+                   +---------+
   | Ubuntu  |                   | Ubuntu  |
   | GLENZ   |                   | Client  |
   | 30GB    |                   | 10GB    |
   | 4GB RAM |                   | 4GB RAM |
   | 2 CPU   |                   | 2 CPU   |
   +---------+                   +---------+
   
   GLENZ=Grafana,Logstash,Elasticsearch,Nginx,Zeek
```

**Architecture réseau :**
- pfSense : 2 interfaces (VMnet8 WAN + VMnet1 LAN)
- pfSense fournit DHCP sur VMnet1
- Ubuntu GLENZ : héberge la stack de surveillance
- Ubuntu Client : machine de test (optionnelle)

---

## 1. Préparation de l'environnement VMware

### 1.1 Configuration des réseaux virtuels VMware

**VMnet8 (NAT) - Accès Internet :**
- Type : NAT
- Utilisé pour : WAN de pfSense

**VMnet1 (Host-Only) - Réseau interne :**
- Type : Host-Only
- Subnet : 192.168.58.0/24 (sera géré par pfSense)
- Utilisé pour : LAN du laboratoire

### 1.2 Création des machines virtuelles

**VM 1 : pfSense (Routeur/Firewall)**
```
Nom : pfSens
OS : FreeBSD 64-bit
Disque : 10 GB
RAM : 4 GB
CPU : 2 cores
Carte réseau 1 : VMnet8 (NAT) - WAN
Carte réseau 2 : VMnet1 (Host-Only) - LAN
```

**VM 2 : Ubuntu GLENZ (Serveur de surveillance)**
```
Nom : Ubuntu-GLENZ
OS : Ubuntu 64-bit
Disque : 30 GB
RAM : 4 GB
CPU : 2 cores
Carte réseau : VMnet1 (Host-Only)
```

**VM 3 : Ubuntu Client (Machine de test - optionnelle)**
```
Nom : Ubuntu-Client
OS : Ubuntu 64-bit
Disque : 10 GB
RAM : 4 GB
CPU : 2 cores
Carte réseau : VMnet1 (Host-Only)
```

---

## 2. Installation et configuration de pfSense

### 2.1 Installation de pfSense

```bash
# 1. Télécharger pfSense ISO
#https://www.pfsense.org/download/

# 2. Monter l'ISO dans la VM pfSense et démarrer

# 3. Suivre l'installation :
# - Accept
# - Install
# - Keymap : us (ou fr)
# - Partitioning : Auto (UFS)
# - Reboot
```

### 2.2 Configuration initiale de pfSense

```bash
# Au premier démarrage, configurer les interfaces :

# Should VLANs be set up now? → n

# Enter the WAN interface name → em0 (ou vmx0)
# Enter the LAN interface name → em1 (ou vmx1)

# Proceed? → y
```

### 2.3 Configuration du LAN pfSense

```bash
# Dans le menu pfSense, choisir option 2 (Set interface IP address)

# Select interface → 2 (LAN)
# Configure IPv4 address via DHCP? → n
# Enter the new LAN IPv4 address → 192.168.58.128
# Enter the new LAN IPv4 subnet bit count → 24
# Configure IPv4 address via DHCP6? → n
# Do you want to enable the DHCP server on LAN? → y
# Enter the start address of the IPv4 client address range → 192.168.58.100
# Enter the end address of the IPv4 client address range → 192.168.58.200
# Do you want to revert to HTTP as the webConfigurator protocol? → n
```

### 2.4 Accès à l'interface web pfSense

Depuis votre machine hôte (si VMnet1 est configuré) ou depuis une VM sur VMnet1 :
```
URL : https://192.168.58.128
User : admin
Pass : pfsense
```



---

## 3. Installation d'Ubuntu sur la VM GLENZ

### 3.1 Installation d'Ubuntu Server 22.04

```bash
# 1. Télécharger Ubuntu Server 22.04 

# 2. Monter l'ISO dans la VM Ubuntu-GLENZ et démarrer

# 3. Installation :
# - Langue : English (ou Français)
# - Keyboard : us (ou fr)
# - Network : DHCP (pfSense donnera une IP automatiquement)
# - Proxy : laisser vide
# - Mirror : par défaut
# - Storage : Use entire disk
# - Profile :
#   - Your name : labadmin
#   - Server name : glenz-stack
#   - Username : labadmin
#   - Password : [votre mot de passe]
# - Reboot
```

### 3.2 Vérification de la connectivité réseau

```bash

# Vérifier l'IP reçue de pfSense
ip addr show

# Devrait afficher une IP dans la plage 192.168.58.100-200

# Tester la connectivité Internet
ping -c 4 8.8.8.8
ping -c 4 google.com

```

### 3.3 Mise à jour du système

```bash
# Mise à jour complète
sudo apt update
sudo apt upgrade -y

# Installer les outils de base
sudo apt install -y curl wget git vim net-tools htop

# Redémarrer si nécessaire
sudo reboot
```

---

## 4. Installation de Docker et Portainer

### 4.1 Installation de Docker

```bash
# 1. Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# 2. Installer les dépendances
sudo apt install -y ca-certificates curl gnupg

# 3. Ajouter la clé GPG
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Ajouter le dépôt Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Installer Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Utiliser Docker sans sudo
sudo usermod -aG docker $USER
newgrp docker

# 7. Vérifier l'installation
docker run hello-world
```



### 4.3 Installation de Portainer

Portainer permet de gérer les containers Docker via une interface web.

```bash
# Créer un volume pour Portainer
docker volume create portainer_data

# Lancer Portainer
docker run -d \
  -p 8000:8000 \
  -p 9000:9000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Vérifier que Portainer tourne
docker ps | grep portainer
```

### 4.4 Accès à Portainer

```bash
# Depuis votre navigateur (machine hôte ou autre VM sur VMnet1)
http://localhost:9000

# Au premier accès :
# - Créer un compte admin
# - Username : admin
# - Password : [votre mot de passe sécurisé]
# - Choisir "Get Started" pour gérer l'environnement local
```

### 4.5 Test Docker

```bash
# Tester que Docker fonctionne
docker run hello-world

# Vérifier Docker Compose
docker compose version
```

---

## 5. Déploiement du projet GLENZ

### 5.1 Récupération des fichiers du projet

 **Clone Git**

```bash

```

```bash
# Vérifier la structure du projet
# .
# ├── configs/
# │   ├── grafana/
# │   ├── logstash/
# │   ├── nginx/
# │   └── zeek/
# ├── data/
# ├── docs/
# ├── scripts/
# ├── docker-compose.yml

```


### 5.5 Lancement de la stack GLENZ

```bash
# Démarrer tous les services
docker compose up -d

# Vérifier que les containers démarrent
docker compose ps

# Suivre les logs
docker compose logs -f
```

**Vous pouvez aussi utiliser Portainer :**
- Aller sur https://192.168.1.xxx:9443
- Naviguer vers "Stacks"
- Cliquer sur "Add stack"
- Uploader le fichier docker-compose.yml
- Ou copier/coller le contenu
- Cliquer sur "Deploy the stack"

---

## 6. Vérification et tests

### 6.1 Vérification des containers

```bash
# Vérifier que tous les containers tournent
docker compose ps

# Devrait afficher:
# NAME                              STATUS
# surveillance-elasticsearch        Up (healthy)
# surveillance-grafana              Up (healthy)
# surveillance-zeek                 Up
# surveillance-logstash             Up
# surveillance-dumpcap              Up
# surveillance-ettercap             Up

# Ou via Portainer : aller dans "Containers"
```


### 6.3 Tests automatiques

```bash
# Exécuter le script de tests
bash scripts/tests.sh

# Devrait afficher:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TOUS LES TESTS SONT PASSÉS !
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 7. Configuration Grafana

### 7.1 Accès initial

```bash
# Depuis votre navigateur (machine hôte Windows ou autre VM)
localhost:3000

# Identifiants par défaut:
# User: admin
# Pass: admin 
```


### 7.4 Dashboards pré-configurés

Les dashboards sont automatiquement chargés au démarrage de Grafana grâce au provisioning.

**Dashboards disponibles dans le dossier GLENZ :**

1. **Network Security Overview** (`network-security-overview.json`)
   - Vue d'ensemble du trafic réseau
   - Statistiques de connexions
   - Top IPs source/destination
   - Protocoles utilisés

2. **ARP MITM Detection** (`arp-mitm-detection.json`)
   - Détection d'attaques ARP spoofing
   - Alertes Ettercap
   - Conflits d'adresses MAC

3. **Web Traffic Analysis** (`web-traffic-analysis.json`)
   - Analyse du trafic HTTP/HTTPS
   - User-agents
   - Codes de statut HTTP
   - URIs les plus visitées

**Vérification des dashboards :**

```bash
# Les dashboards sont dans
ls -la configs/grafana/dashboards/

# Devrait afficher :
# arp-mitm-detection.json
# network-security-overview.json
# web-traffic-analysis.json
```

**Accès aux dashboards dans Grafana :**

1. Se connecter à Grafana : http://192.168.1.xxx:3000
2. Aller dans **Dashboards** (icône avec 4 carrés)
3. Ouvrir le dossier **GLENZ**
4. Les 3 dashboards sont disponibles

**Si les dashboards ne s'affichent pas :**

```bash
# Vérifier les logs Grafana
docker compose logs grafana | grep -i dashboard

# Vérifier le provisioning
docker compose exec grafana ls -la /etc/grafana/dashboards/

# Redémarrer Grafana
docker compose restart grafana

# Attendre 10-15 secondes et rafraîchir la page
```

---


```




