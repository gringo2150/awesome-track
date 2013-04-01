<?php
$val .= <<<SSVIEWER
//This could just be anotherr javascript file...
function SearchModule_Edit(ID, readOnly, values) {
		parseForm('SearchModule_Edit.frm', 'Edit Search Module', function(obj) {
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
		//Update Button
		obj.UpdateButton.handler = function() {
			var params = Object();
			params['object'] = obj.object.getValue();
			params['ID'] = ID;
			obj.form.submit({
				url: 'home/updateSingleObject/SearchModule',
				waitMsg: 'Updating Module Please Wait...',
				params: params,
				submitEmptyText: false,
				success: function(fp, o){
					obj.form.reset();
					Ext.getCmp('browseModuleGrid').store.load();
					obj.window.close();
					Ext.Msg.alert('Success', 'Search Module has been updated.');
				}
			});		
		};
		/*** End Button Config ***/
		obj.window.show();
		obj.form.setValues(values);
		obj.object.setValue(values.object);
	});
}

SSVIEWER;
