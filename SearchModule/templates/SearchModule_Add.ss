//This could just be anotherr javascript file...
function SearchModule_Add(pWindow, pForm) {
		parseForm('SearchModule_Add.frm', 'New Search Module', function(obj) {
		/*** Start Combo Store Config ***/
		obj.object.store = new Ext.data.ArrayStore({
			fields: [
				'displayText'
			],
			data: InstalledObjects
		});
		obj.object.displayField = 'displayText';
		obj.object.valueField = 'displayText';
		/*** End Combo Store Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.window.close();
		};
		//Save Button
		obj.SaveButton.handler = function() {
			var params = obj.form.getValues();
			params['module'] = 'SearchModule';
			params['object'] = obj.object.getValue();
			pForm.submit({
				url: 'home/saveSingleObject/SearchModule',
				waitMsg: 'Creating new Search Module...',
				params: params,
				submitEmptyText: false,
				success: function(fp, o){
					Ext.Msg.alert('Success', 'New Search Module has been added.');
					fp.reset();
					Ext.getCmp('browseModuleGrid').store.load();
					obj.window.close();
					pWindow.close();
				}
			});		
		};
		/*** End Button Config ***/
		obj.window.show();
	});
}
