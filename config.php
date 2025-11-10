<?php
// ===========================================================
// Configuració bàsica per a Moodle GVA Base (Docker)
// ===========================================================

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MOODLE_DB_HOST') ?: 'db';
$CFG->dbname    = getenv('MOODLE_DB_NAME') ?: 'moodle';
$CFG->dbuser    = getenv('MOODLE_DB_USER') ?: 'moodleuser';
$CFG->dbpass    = getenv('MOODLE_DB_PASSWORD') ?: 'moodlepass';
$CFG->prefix    = 'mdl_';

$CFG->wwwroot   = 'http://localhost:' . (getenv('MOODLE_PORT') ?: '8080');
$CFG->dataroot  = '/var/www/moodledata';
$CFG->directorypermissions = 0777;
$CFG->admin = 'admin';

// Evitem el mode instal·lació
$CFG->skiplangupgrade = true;
// --- Configuració addicional GVA ---
$CFG->lang = 'ca_valencia';
$CFG->langlist = 'ca_valencia,es,en';
$CFG->skiplangupgrade = false;  // permet actualitzar paquets d'idioma
$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

