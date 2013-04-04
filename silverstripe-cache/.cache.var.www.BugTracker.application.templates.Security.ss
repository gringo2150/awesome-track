<?php
$val .= <<<SSVIEWER
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >
<head>
<link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />

SSVIEWER;
$val .=  SSViewer::get_base_tag($val); ;
 $val .= <<<SSVIEWER

<link rel="stylesheet" type="text/css" href="application/javascript/ext/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="application/css/layout.css" />

SSVIEWER;
 Requirements::themedCSS("security"); ;
 $val .= <<<SSVIEWER
 
<script type="text/javascript" src="application/javascript/ext/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="application/javascript/ext/ext-all.js"></script>
<script type="text/javascript" src="application/javascript/jquery.js"></script>
<script>
Ext.onReady(function(){
	var mainWidth = jQuery(window).width();
	var mainHeight = jQuery(window).height();
	mainWidth = (mainWidth -450) / 2;
	mainHeight = (mainHeight -500) / 2;
	var main = new Ext.Viewport({
		renderTo: Ext.getBody(),
		layout: 'absolute',
		items: [{
			xtype: 'panel',
			title: 'Login',
			contentEl: 'Container',
			width: 450,
			pageY: 100,
			pageX: mainWidth,
			collapsible: false,
			frame: true,
			iconCls: 'login-icon'
		}]
	});
	jQuery('#Container').show();
});
</script>
</head>
<body>
	<div id="Container" style="display: none;">
		
SSVIEWER;
$val .=  $item->XML_val("Content",null,true) ;
 $val .= <<<SSVIEWER

		
SSVIEWER;
$val .=  $item->XML_val("Form",null,true) ;
 $val .= <<<SSVIEWER

	</div>
</body>
</html>

SSVIEWER;
