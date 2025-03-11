#!/bin/bash
#
# Script de déploiement automatisé d'une application Symfony sur un serveur distant
#

set -e  # Arrêt en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE=".deploy_config"
SSH_TIMEOUT=300  # Timeout de 5 minutes pour SSH
REMOTE_USER="www-data" # Utilisateur du serveur web

# Fonction pour afficher les étapes
function step() {
    echo -e "${GREEN}==>${NC} ${BLUE}$1${NC}"
}

# Fonction pour afficher les erreurs et annuler le déploiement
function error() {
    echo -e "${RED}ERREUR:${NC} $1"
    exit 1
}

# Chargement de la configuration
if [ -f "$CONFIG_FILE" ]; then
    step "Chargement de la configuration sauvegardée"
    source "$CONFIG_FILE"
fi

# Mode simulation
if [[ $1 == "--dry-run" ]]; then
    echo "Mode simulation activé. Voici les actions qui seraient effectuées :"
    cat "$CONFIG_FILE"
    exit 0
fi

# Demander les informations nécessaires
read -p "Nom du projet (PROJECT_NAME) ${PROJECT_NAME:+[$PROJECT_NAME]}: " PROJECT_NAME_INPUT
PROJECT_NAME=${PROJECT_NAME_INPUT:-$PROJECT_NAME}

read -p "Adresse du serveur (SERVER_HOST) ${SERVER_HOST:+[$SERVER_HOST]}: " SERVER_HOST_INPUT
SERVER_HOST=${SERVER_HOST_INPUT:-$SERVER_HOST}

read -p "Utilisateur SSH (SERVER_USER) ${SERVER_USER:+[$SERVER_USER]}: " SERVER_USER_INPUT
SERVER_USER=${SERVER_USER_INPUT:-$SERVER_USER}

read -p "Chemin d'installation sur le serveur (REMOTE_PATH) ${REMOTE_PATH:+[$REMOTE_PATH]}: " REMOTE_PATH_INPUT
REMOTE_PATH=${REMOTE_PATH_INPUT:-$REMOTE_PATH}

read -p "Dépôt Git (laisser vide si non applicable) ${GIT_REPO:+[$GIT_REPO]}: " GIT_REPO_INPUT
GIT_REPO=${GIT_REPO_INPUT:-$GIT_REPO}

# Vérifier que toutes les informations sont fournies
if [ -z "$PROJECT_NAME" ] || [ -z "$SERVER_HOST" ] || [ -z "$SERVER_USER" ] || [ -z "$REMOTE_PATH" ]; then
    error "Toutes les informations requises doivent être fournies."
fi

# Sauvegarde de la configuration
cat > "$CONFIG_FILE" << EOL
PROJECT_NAME="$PROJECT_NAME"
SERVER_HOST="$SERVER_HOST"
SERVER_USER="$SERVER_USER"
REMOTE_PATH="$REMOTE_PATH"
GIT_REPO="$GIT_REPO"
EOL
chmod 600 "$CONFIG_FILE"

step "Connexion au serveur et préparation de l'environnement"

ssh -o ConnectTimeout=$SSH_TIMEOUT "$SERVER_USER@$SERVER_HOST" << EOF
    set -e
    echo -e "${YELLOW}Mise à jour des paquets...${NC}"
    sudo apt-get update && sudo apt-get install -y php-cli unzip git

    # Installer PHP et Nginx si nécessaire
    read -p "Installer Nginx et PHP-FPM (y/n) ? " INSTALL_NGINX
    if [ "\$INSTALL_NGINX" = "y" ]; then
        sudo apt-get install -y nginx php-fpm
        sudo systemctl enable nginx
        sudo systemctl restart nginx
    fi

    # Création du dossier projet
    echo -e "${YELLOW}Préparation du dossier projet...${NC}"
    mkdir -p "$REMOTE_PATH"
    cd "$REMOTE_PATH"

    # Clonage ou mise à jour du dépôt
    if [ -n "$GIT_REPO" ]; then
        if [ ! -d ".git" ]; then
            git clone "$GIT_REPO" .
        else
            git pull origin main
        fi
    fi

    # Installer les dépendances
    echo -e "${YELLOW}Installation des dépendances Symfony...${NC}"
    composer install --no-dev --optimize-autoloader

    # Gestion des permissions Symfony
    echo -e "${YELLOW}Configuration des permissions...${NC}"
    sudo chmod -R 775 var/cache var/log var/sessions
    sudo chown -R "$REMOTE_USER":"$REMOTE_USER" var

    # Chargement de l'environnement
    if [ -f ".env" ]; then
        echo -e "${YELLOW}Mise à jour de l'environnement...${NC}"
        php bin/console cache:clear --env=prod
        php bin/console cache:warmup
    fi

    # Exécution des migrations
    echo -e "${YELLOW}Mise à jour de la base de données...${NC}"
    php bin/console doctrine:migrations:migrate --no-interaction

    # Installation des assets
    echo -e "${YELLOW}Installation des assets...${NC}"
    php bin/console assets:install

    echo -e "${GREEN}Déploiement terminé avec succès !${NC}"
EOF
