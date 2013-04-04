function projectAdd(store) {
	if(store == null || store == undefined){
		var search = Ext.getCmp('SearchModule')
		store = search.store;
	}
	parseForm('Project_Add.frm','Create Project', function(obj){
		
		/*** Start Combo Store Config ***/
		/*** End Combo Store Config ***/
		
		/*** Start Table Config ***/
		/*** End Table Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.form.reset();
			obj.window.close();
		};
		
		//Save Button
		obj.SaveButton.handler = function() {
			obj.form.submit({
				url: 'home/saveSingleObject/Project',
				waitMsg: 'Adding Project...',
				submitEmptyText: false,
				params: {},
				success: function(fp, o){
					Ext.Msg.show({
						title:'Created Project',
						msg: 'A new Project has been created',
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.INFO
					});
					if(store != null || store != undefined) {
						store.load();
					}
					obj.form.reset();
					obj.window.close();
				}
			});
		}
		/*** Button Config End ***/
	});
}