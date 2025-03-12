# DeployBundel

`DeployBundel` est un bundle Symfony permettant d'installer automatiquement un script de déploiement (`deploy.sh`) dans la racine de votre projet.

## Prérequis

- PHP 8.0 ou supérieur
- Symfony 7.2 ou supérieur

## Installation
1. **Ajouter ces ligne dans comoser.json**
   
  "repositories": [
        {
            "type": "vcs",
            "url": "git@github.com:connect-ease/deployBundel.git"
        }
    ],

  "require": {
        "connect-ease/deploy-bundel": "dev-master"
    },


2. **Télécharger le bundle**

   Exécutez la commande suivante pour télécharger le télécharger dans votre projet Symfony :
    
   composer require connect-ease/deploy-bundel

3. **Installer le bundle**

   Exécutez la commande suivante pour installer le télécharger dans votre projet Symfony :
    
   php -r "require 'vendor/autoload.php'; \DeployBundel\Installer::install();"
