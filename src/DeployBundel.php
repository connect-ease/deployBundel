<?php
namespace DeployBundel;

use DeployBundel\DependencyInjection\DeployBundelExtension;
use Symfony\Component\HttpKernel\Bundle\Bundle;
use Symfony\Component\DependencyInjection\Extension\ExtensionInterface;

class DeployBundel extends Bundle
{
    public function getContainerExtension(): ?ExtensionInterface
    {
        return new DeployBundelExtension();
    }
}