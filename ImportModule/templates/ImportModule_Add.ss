//This could just be anotherr javascript file...
function ImportModule_Add(pWindow, pForm) {
	var window = new Ext.Window({
		title: 'Import Module Options',
		layout: 'fit',
		height: 233,
		width: 600,
		border: false,
		/*items: [{
			xtype: 'form',
			id: 'MapModule_Add',
			labelWidth: 100,
        	frame:true,
			fileUpload: true,
			height: '100%',
			width: '100%',
			margins: '5 5 5 5',
			defaults: {
				anchor: '-18',
				allowBlank: false,
				msgTarget: 'side'
			},
			defaultType: 'textfield',
			items: [{
				fieldLabel: 'Center Latitude',
				emptyText: 'Enter a latitude for the map to center on when it first loads.',
				name: 'CenterLat',
				allowBlank:false
			},{
				fieldLabel: 'Center Longitude',
				emptyText: 'Enter a longitude for the map to center on when it first loads.',
				name: 'CenterLon',
				allowBlank:false
			},{
				fieldLabel: 'Zoom Level',
				emptyText: 'Enter a default Zoom Level for this map.',
				name: 'ZoomLevel',
				allowBlank:false
			}]
		}],*/
		buttons: [{
			text: 'Cancel',
			handler: function() {
				window.close();
			}
		},{
			text: 'Save',
			handler: function() {
				//var params = Ext.getCmp('ImportModule_Add').getForm().getValues();
				pForm.submit({
					url: 'home/saveSingleObject/ImportModule',
					waitMsg: 'Creating new Import Module...',
					params: {
						module: 'ImportModule'
					},
					submitEmptyText: false,
					success: function(fp, o){
						msg('Success', 'New Import Module has been added.');
						fp.reset();
						Ext.getCmp('browseModuleGrid').store.load();
						window.close();
						pWindow.close();
					}
				});
			}
		}]
	});
	window.show();
}
