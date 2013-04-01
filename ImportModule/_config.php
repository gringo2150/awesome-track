<?php

Director::addRules(50, array(
	ImportModule_Controller::$URLSegment . '/$Action/$ID' => 'ImportModule_Controller'
));

//Register this module with the application.
Application::registerModule(array('ImportModule'));
//Register this modules scripts with the application.
Application::addModuleScripts(array('ImportModule/javascript/filetree/js/Ext.ux.FileUploader.js'));
Application::addModuleScripts(array('ImportModule/javascript/filetree/js/Ext.ux.form.BrowseButton.js'));

?>
