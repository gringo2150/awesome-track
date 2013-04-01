var HomeMenu = [
<% if isParticipant %>
{
	text: 'Help',
	icon: 'application/images/built_in_menus/help.png',
	tooltip: 'Need Help?, opens up the help documents panel, here you can find out how aspects of the system work.',
	handler: function() {
		window.open('application/images/UserHelp.pdf', '_blank');
	}
},{
	text: 'Give feedback',
	icon: 'application/images/built_in_menus/questions2.png',
	tooltip: 'Begin or continue to answer the questions set out for you. You can save your progress at any point and return to answering at a later time.',
	handler: function() {
		var selection = Ext.getCmp('ParticipantGrid').getSelectionModel().getSelected();
		var ID = selection.json.ParticipantID ? selection.json.ParticipantID : null;
		var ProjectID = selection.json.ProjectID ? selection.json.ProjectID : null;
		if(ID != null && ProjectID != null) {
			respondeeAnswerQuestion(ID, ProjectID);
		} else {
			Ext.Msg.alert("Choose Participant", "No participant selected. You must first select a participant from the table on the right");
		}
	}
},{
	text: 'Change Password',
	icon: 'application/images/built_in_menus/key.png',
	tooltip: 'Change the password you use to login to the system.',
	handler: function() {
		var ID = $CurrentMember.ID;
		changePassword(ID);
	}
}
<% end_if %>
<% if adminPermissionCheck %>
{
	text: 'Help',
	icon: 'application/images/built_in_menus/help.png',
	tooltip: 'Need Help?, opens up the help documents panel, here you can find out how aspects of the system work.',
	handler: function() {
		alert('Load help menu');
	}
}
<% end_if %>
];

/*
{
	text: 'View Calendar',
	icon: 'application/images/built_in_menus/calendar.png',
	tooltip: 'Your calendar, this contains all the company wide events and your follow up actions.',
	handler: function() {
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		HomeWorkflowCalandar.show();
		Ext.getCmp('main').doLayout();
	}
},
*/
<% if adminPermissionCheck %>
var AdministrationMenu = [{
	text: 'Manage Modules',
	icon: 'application/images/built_in_menus/module_edit.png',
	tooltip: 'Module Manager, this section allows for new modules to be added to the system, new modules can either be a workflow or a plugin.',
	handler: function() {
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		addWorkflowCat.show();
		moduleStore.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Manage Menus',
	icon: 'application/images/built_in_menus/menu_edit.png',
	tooltip: 'Menu Manager, this section allows for new menus to be added to the system, new menus appear under modules and can either be a workflow or a plugin.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		addWorkflowItem.show();
		itemStore.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Import Data',
	icon: 'application/images/built_in_menus/import_data.png',
	tooltip: 'Allows the import of data into the system from CSV files.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		ImportModule.show();
		Ext.getCmp('ImportModule_Center').setTitle('Import Data');
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Export Data',
	icon: 'application/images/built_in_menus/export_data.png',
	tooltip: 'Allows queries to be built and the data viewed and used in reports.',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		ExportModule.show();
		Ext.getCmp('ExportModule_North').setTitle('Export Data');
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'System Properties',
	icon: 'application/images/built_in_menus/system_props.png',
	tooltip: '',
	handler: function(){
		for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
			Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
		}
		SearchModule.show();
		Ext.getCmp('SearchModule_AddButton').setText('Add System Property');
		Ext.getCmp('SearchModule_EditButton').setText('Edit System Property');
		Ext.getCmp('SearchModule').setTitle('System Properties Search');
		SearchModule.object = 'SystemParameter';
		SearchModule_Store.proxy.setUrl('home/search/SystemParameter', true);
		SearchModule_Store.removeAll();
		SearchModule_Store.baseParams = {start: 0,limit: 20,meta: true,columnModel: true};
		SearchModule_Store.load();
		Ext.getCmp('main').doLayout();
	}
},{
	text: 'Form Builder',
	icon: 'application/images/built_in_menus/form_builder.png',
	tooltip: '',
	handler: function(){
		formBuilderWindow();
	}
}];
<% end_if %>

var HomePanel = new Ext.Toolbar({
	flex: 2, 
	layout: 'vbox',
	height: '100%',
	autoWidth: true,
	width: 'auto', 
	layoutConfig: { 
		align: 'stretch', 
		pack: 'start'
	}, 
	hidden: false, 
	defaults: { 
		margins: '5 5 0 5',
		 
		cls: 'leftButton' 
	},
	items: HomeMenu	
});

$modulePanels

<% if adminPermissionCheck %> 
var AdministrationPanel = new Ext.Toolbar({
	flex: 2, 
	layout: 'vbox',
	height: '100%',
	autoWidth: true,
	width: 'auto', 
	layoutConfig: { 
		align: 'stretch', 
		pack: 'start'
	}, 
	hidden: true, 
	defaults: { 
		margins: '5 5 0 5',
		 
		cls: 'leftButton' 
	},
	items: AdministrationMenu
});
<% end_if %>

var subNavigationHolder = new Ext.Panel({
	flex: 2,
	border: false,
	id: 'subNavigationHolder',
	items: [
		HomePanel
		$moduleNaviagtionPanels 
		<% if adminPermissionCheck %>
			,AdministrationPanel
		<% end_if %>
	]
});
	
var mainNavPanel = {
	xtype: 'panel',
	id: 'mainNavPanel',
	title: 'Navigation',
	region:'west',
	collapsible: false,
	margins: '5 0 5 5',
	width: 200,
	minSize: 100,
	maxSize: 225,
	layout:'vbox',
	layoutConfig: {
		align : 'stretch',
		pack  : 'start'
	},
	items: [
		subNavigationHolder,
		{ 
			border: false, 
			layoutConfig: {
				align: 'stretch',
				pack: 'end',
				width: '100%'				
			},
			items: [
				<% if adminPermissionCheck %>
				new Ext.Button({
					cls: 'x-toolbar',
					width: '100%',
					text: 'Home',
					icon: 'application/images/built_in_menus/home.png',
					handler: function() {
						for (var i=0; i<subNavigationHolder.items.items.length; i++) {
							subNavigationHolder.items.items[i].hide();
						}
						HomePanel.show();
						for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
							Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
						}
						homeControlWorkflow.show();
						Ext.getCmp('main').doLayout();
					}
				})
				$moduleNavigation
				, new Ext.Button({
					cls: 'x-toolbar',
					width: '100%',
					text: 'Administration',
					icon: 'application/images/built_in_menus/administration.png',
					handler: function() {
						for (var i=0; i<subNavigationHolder.items.items.length; i++) {
							subNavigationHolder.items.items[i].hide();
						}
						AdministrationPanel.show();
						for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
							Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
						}
						adminWorkflow.show();
						Ext.getCmp('main').doLayout();
					}
				})
				<% end_if %>
			]
		}
	]	
};
