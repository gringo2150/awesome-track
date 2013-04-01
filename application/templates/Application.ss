<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="ExportModule/css/ExportModule.css" />
<link rel="stylesheet" type="text/css" href="ExportModule/css/ReportModule.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/resources/css/xtheme-pluto.css" />
<link rel="stylesheet" type="text/css" href="application/css/layout.css" />
<link rel="stylesheet" type="text/css" href="application/css/icons.css" />
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/fileuploadfield/css/fileuploadfield.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/IconCombo.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/XCheckbox.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/ColorField.css"/>
<link rel="stylesheet" type="text/css" href="application/javascript/ext/ux/css/ux-all.css" />
<script type="text/javascript" src="application/javascript/ext/adapter/ext/ext-base-debug.js"></script>
<script type="text/javascript" src="application/javascript/ext/ext-all-debug.js"></script>
<script type="text/javascript" src="application/javascript/ext/ux/ux-all.js"> </script>
<script type="text/javascript" src="application/javascript/ext/debug.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/jsonp.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/IconCombo.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/XCheckbox.js"> </script>
<script type="text/javascript" src="application/javascript/ext/ux/ColorField.js"> </script>
<script type="text/javascript" src="application/javascript/jquery.js"></script>
<script type="text/javascript" src="application/javascript/MetaForm.js"></script>
<script type="text/javascript" src="application/javascript/FormParser.js"></script>
<% if adminPermissionCheck %>
<script type="text/javascript" src="application/javascript/FormBuilder/formBuilder.js"></script>
<% end_if %>
<script type="text/javascript" src="application/javascript/Utils/cellRenderers.js"></script>
<script type="text/javascript" src="application/javascript/Utils/dateCalculations.js"></script>
<script type="text/javascript" src="workflows.script"></script>
$moduleScripts
<script>
if (Ext.isIE) {
	Ext.enableGarbageCollector = false;
}

var loadingMask = new Ext.LoadMask(Ext.getBody(), {msg: "Preforming action please wait..."});

Ext.WindowMgr.zseed = 11000;
var iblWinMgr = new Ext.WindowGroup();
iblWinMgr.zseed = 10000;

var main = null;

var isAdmin = <% if adminPermissionCheck %>1<% else %>0<% end_if %>;

var main = Object();

function executeFunctionByName(functionName/*, args */) {
  var context = window;
  var args = Array.prototype.slice.call(arguments).splice(1);
  /*var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for(var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }*/
  return window[functionName].apply(this, args);
}

/*********************
System Variables

Modules, the list of modules installed in the system
Objects, the list of objects installed in the system.
*********************/

var InstalledModules = [$workflowModules];
var InstalledObjects = [$databaseObjects];

/*******************
System Vars END
*******************/

Ext.onReady(function(){
	
	Ext.Ajax.timeout = 120000;
	Ext.BLANK_IMAGE_URL = '{$BaseHref}application/javascript/ext/resources/images/default/s.gif';
	Ext.QuickTips.init(false);
		
	<% include Navigation %>
	<% include Menu %>
    
	<% include HomeControlWorkflow %>
	$includeModulesTemplates
	<% if adminPermissionCheck %>
		<% include AdministrationWorkflow %>
	<% end_if %>
	<% include ManageWorkflowModuleScreen %>
	<% include ManageWorkflowItemScreen %>
	
    main = new Ext.Viewport({
		layout: 'border',
		id: 'main',
		items: [{
			xtype: 'panel',
			region:'center',
			margins: '0 0 0 0',
			layout:'border',
			defaults: {
				collapsible: true,
				split: true
			},
			items: [mainNavPanel,
			{
				id: 'centerWorkflowHolder',
				collapsible: false,
				region:'center',
				margins: '5 5 5 0',
				layout: 'anchor',
				height: '100%',
				width: '100%',
				border: false,
				layoutConfig: {
					align: 'stretch',
					pack: 'start'
				},
				defaults: {
					anchor: '100% 100%',
					height: '100%',
					width: '100%',
					renderHidden: true
				},
				items: [
					homeControlWorkflow,
					addWorkflowCat, 
					addWorkflowItem,
					<% if adminPermissionCheck %>
						adminWorkflow,
					<% end_if %>
					$includeModules
				]
			}],
			tbar: {
				xtype: 'container',
				layout: 'anchor',
				defaults: { anchor : '100%' },
				items: [
					mainMenu
				]
			},
			bbar: new Ext.Toolbar({
				enableOverflow: true,
				id: 'windowManagerArea',
				items: [{
					icon: 'application/images/toolbars/desktop.png',
					handler: function() {
						iblWinMgr.hideAll();
					}	
				},'-']
    	    })
		}]
	});

});

/* Generated Functions */

$moduleAddEditTemplates

/* End Generrated Functions */

</script>
</head>
<body style="height: 100%; width: 100%;">
<% if adminPermissionCheck %>
<div id="formBuilderWindow" style="display: none; height: 100%; width: 100%;">
	<object width="100%" height="100%">
		<param name="movie" value="application/builder/IBLProcessBuilder.swf" />
		<param name="wmode" value="transparent" />
		<embed id="formBuilderFlash" wmode="transparent" src="application/builder/IBLProcessBuilder.swf" width="100%" height="100%"></embed>
	</object>
</div>
<% end_if %>
</body>
</html>
