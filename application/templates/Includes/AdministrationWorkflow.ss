var adminWorkflow = new Ext.Panel({
	hidden: true,
	id: 'adminWorkflow',
	border: false,
	layout: 'border',
	items: [{
		xtype: 'panel',
		region: 'center',
		title: 'Administration',
		frame: false,
		layout: 'absolute',
		defaults: {
			height: 60,
			width: '150'
		},
		items: [
			/*new Ext.Button({
				text: 'Manage Modules',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 20,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					addWorkflowCat.show();
					moduleStore.load();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Manage Menus',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					addWorkflowItem.show();
					itemStore.load();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Import Data',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 180,
				iconAlign: 'top',
				handler: function() {
					
				}
			}),
			new Ext.Button({
				text: 'Export Data',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 20,
				y: 260,
				iconAlign: 'top',
				handler: function() {
					
				}
			}),
			new Ext.Button({
				text: 'System Properties',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 190,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					for (var i=0; i<Ext.getCmp('centerWorkflowHolder').items.items.length; i++) {
						Ext.getCmp('centerWorkflowHolder').items.items[i].hide();
					}
					systemPropertiesPanel.show();
					main.doLayout();
				}
			}),
			new Ext.Button({
				text: 'Form Builder',
				icon: 'application/images/buttons_icons/configure.png',
				scale: 'large',
				x: 360,
				y: 100,
				iconAlign: 'top',
				handler: function() {
					formBuilderWindow();
				}
			})*/
		]
	}]
});
