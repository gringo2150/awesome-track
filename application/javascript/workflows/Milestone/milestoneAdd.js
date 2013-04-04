function milestoneAdd(store) {
	if(store == null || store == undefined){
		var search = Ext.getCmp('SearchModule')
		store = search.store;
	}
	parseForm('Milestone_Add.frm','Create Milestone', function(obj){
		
		/*** Start Combo Store Config ***/
		
		obj.Project.store = new Ext.data.JsonStore({
			url: 'home/getChildObjects/Project',
			root: 'rows',
			fields: ['ID', 'Name'],
			baseParams: {
			}
		});
		obj.Project.displayField = 'Name';
		obj.Project.valueField = 'ID';
		
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
				url: 'home/saveSingleObject/Milestone',
				waitMsg: 'Adding Milestone...',
				submitEmptyText: false,
				params: {},
				success: function(fp, o){
					Ext.Msg.show({
						title:'Created Milestone',
						msg: 'A new Milestone has been created',
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
