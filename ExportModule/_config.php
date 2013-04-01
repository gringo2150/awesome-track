<?php

Director::addRules(50, array(
	ExportModule_Controller::$URLSegment . '/$Action/$ID' => 'ExportModule_Controller',
	ReportModule_Controller::$URLSegment . '/$Action/$ID' => 'ReportModule_Controller'
));

//Register this module with the application.
Application::registerModule(array('ExportModule'));
Application::registerModule(array('ReportModule'));
//Register this modules scripts with the application.
Application::addModuleScripts(array('ExportModule/javascript/LineEditor.js'));
Application::addModuleScripts(array('ExportModule/javascript/jsDraw2D.js'));
Application::addModuleScripts(array('ExportModule/javascript/AddReport.js'));
?>
