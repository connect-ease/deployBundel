<?php 

namespace DeployBundel;

class Installer
{
    public static function install()
    {
        $projectRoot = dirname(__DIR__, 4);
        $targetFile = $projectRoot . '/deploy.sh';
        $sourceFile = __DIR__ . '/Resources/deploy.sh';

        if (!file_exists($targetFile)) {
            copy($sourceFile, $targetFile);
            chmod($targetFile, 0755);
            echo "✅ Le fichier deploy.sh a été installé avec succès !\n";
        } else {
            echo "⚠️ Le fichier deploy.sh existe déjà.\n";
        }
    }
}
