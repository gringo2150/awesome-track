function jobAdd(store) {
	if(store == null || store == undefined){
		var search = Ext.getCmp('SearchModule')
		store = search.store;
	}
	parseForm('Job_Add.frm','Create Job', function(obj){
		
		/*** Start Combo Store Config ***/
		/*** End Combo Store Config ***/
		
		/*** Start Table Config ***/
		//Hide the table on add job
		obj.MeasureTable.hide();
		/*** End Table Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.form.reset();
			obj.window.close();
		};
		
		//Save Button
		obj.AddButton.handler = function() {
			obj.form.submit({
				url: 'home/saveSingleObject/Job',
				waitMsg: 'Adding job...',
				submitEmptyText: false,
				params: {},
				success: function(fp, o){
					Ext.Msg.show({
						title:'Created Job',
						msg: 'A new job has been created',
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
