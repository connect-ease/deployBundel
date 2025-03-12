<?php 

namespace DeployBundel;

class Installer
{
    public static function install()
    {
        $projectRoot = dirname(__DIR__, 4);
        $targetFile = $projectRoot . '/deploy.sh';
        $sourceFile = __DIR__ . '/Resources/deploy.sh';
        
        // Vérifiez si le chemin est correct, sinon essayez un autre chemin
        if (!file_exists($sourceFile)) {
            $sourceFile = dirname(__DIR__) . '/Resources/deploy.sh';
        }
        
        // Vérifiez si le fichier source existe
        if (!file_exists($sourceFile)) {
            echo "❌ Erreur : Le fichier source deploy.sh est introuvable à {$sourceFile}.\n";
            return;
        }
        
        if (!file_exists($targetFile)) {
            if (copy($sourceFile, $targetFile)) {
                chmod($targetFile, 0755);
                echo "✅ Le fichier deploy.sh a été installé avec succès à {$targetFile}!\n";
            } else {
                echo "❌ Erreur lors de la copie du fichier deploy.sh.\n";
            }
        } else {
            echo "⚠️ Le fichier deploy.sh existe déjà à {$targetFile}.\n";
        }
    }
}