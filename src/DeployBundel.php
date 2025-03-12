<?php
namespace DeployBundel;

use Symfony\Component\HttpKernel\Bundle\Bundle;

class DeployBundel extends Bundle
{
    public function boot()
    {
        Installer::install();
    }
}