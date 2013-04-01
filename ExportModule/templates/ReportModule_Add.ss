//This could just be anotherr javascript file...
function ReportModule_Add(pWindow, pForm) {
	var window = new Ext.Window({
		title: 'Report Module Options',
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
				//var params = Ext.getCmp('ReportModule_Add').getForm().getValues();
				pForm.submit({
					url: 'home/saveSingleObject/ReportModule',
					waitMsg: 'Creating new Report Module...',
					params: {
						module: 'ReportModule'
					},
					submitEmptyText: false,
					success: function(fp, o){
						fp.reset();
						Ext.getCmp('browseModuleGrid').store.load();
						pWindow.close();
						window.close();
						msg('Success', 'New Report Module has been added.');
					}
				});
			}
		}]
	});
	window.show();
}
