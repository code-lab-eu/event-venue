<?php

/**
 * This file is included very early. See autoload.files in composer.json and
 * https://getcomposer.org/doc/04-schema.md#files
 */

use Dotenv\Dotenv;

$set_env_vars = function(array $vars): void {
  foreach ($vars as $name => $value) {
    if (!isset($_SERVER[$name])) {
      $_ENV[$name] = $value;
      $_SERVER[$name] = $value;
    }
  }
};

// Set environment variables dynamically if we are running in Lando.
$lando_info = $_SERVER['LANDO_INFO'] ?? [];
if (!empty($lando_info)) {
  $info = json_decode(getenv('LANDO_INFO'), TRUE);
  $base_url = array_reduce($info['appserver']['urls'] ?? [], function ($carry, $url) {
      $url = strpos($url, 'http://') === 0 ? $url : NULL;
      return $carry ?: $url;
  }, NULL);
  $behat_base_url = !empty($info['appserver']['service']) ? 'http://' . $info['appserver']['service'] : NULL;
  $webroot = $info['appserver']['webroot'] ?? NULL;
  $vars = [
    'BASE_URL' => $base_url,
    'BEHAT_BASE_URL' => $behat_base_url,
    'SCREENSHOTS_PATH' => '../tmp/screenshots',
    'WEBROOT' => $webroot,
  ];
  $set_env_vars($vars);
}

// Load environment variables.
foreach (['.env', '.env.dist'] as $file) {
  $path = __DIR__ . DIRECTORY_SEPARATOR . $file;
  if (is_file($path) && is_readable($path)) {
    $dotenv = Dotenv::createImmutable(__DIR__, $file);
    $dotenv->load();
  }
}

// Set dynamic environment variables.
$set_env_vars([
  'PROJECTROOT' => __DIR__,
  'WEBROOT' => __DIR__ . DIRECTORY_SEPARATOR . 'web',
]);
