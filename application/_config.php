<?php

global $project;
$project = 'application';

Director::set_dev_servers(array(
	'localhost',
	'127.0.0.1'
));

global $databaseConfig;
if(Director::isDev()) {
	//Development Database settings
	$databaseConfig = array(
		"type" => "MySQLDatabase",
		"server" => "localhost", 
		"username" => "root", 
		"password" => "", 
		"database" => "BugTracker"
	);
} else {
	//Production Database settings
	$databaseConfig = array(
		"type" => "MySQLDatabase",
		"server" => "localhost:666", 
		"username" => "root", 
		"password" => "", 
		"database" => "BugTracker",
	);
}

Security::setDefaultAdmin("admin","password");

//Director::set_environment_type("dev");

//SSViewer::set_theme('IBL');

//SS_Log::add_writer(new SS_LogEmailWriter('email@example.com'), SS_Log::ERR); 

//Email::setAdminEmail('email.example.com');

GD::set_default_quality(100);

//Director::forceSSL();

//Register Objects with the application
$objects = Application::scanPathForObjects(Director::baseFolder().'/application/code/Database/Application');
Application::registerObject($objects);

Director::addRules(10, array(
	'workflows.script' => 'Resources_Controller'
));

?>
