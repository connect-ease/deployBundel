<?php
namespace DeployBundel;

use Symfony\Component\HttpKernel\Bundle\Bundle;

class DeployBundel extends Bundle
{
    public function boot()
    {
        $projectRoot = dirname(__DIR__, 2);

        $file = $projectRoot . '/deploy.sh';
        
        if (!file_exists($file)) {
            
            \DeployBundel\Installer::install();
        }
    }
}