function featureEdit(ID, store) {
	if(store == null || store == undefined){
		var search = Ext.getCmp('SearchModule')
		store = search.store;
	}
	parseForm('Feature_Add.frm','Edit Feature', function(obj){
		
		/*** Start Combo Store Config ***/
		
		obj.Milestone.store = new Ext.data.JsonStore({ 
			url: 'home/getChildObjects/Milestone',
			root: 'rows',
			fields: ['ID', 'Name'],
			baseParams: {
			}
		});
		obj.Milestone.displayField = 'Name';
		obj.Milestone.valueField = 'ID';
		
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
			//Disable check boxed for data submit...
			obj.Completed.setDisabled(true);
			obj.Tested.setDisabled(true);
			obj.Development.setDisabled(true);
			obj.Beta.setDisabled(true);
			obj.Demo.setDisabled(true);
			obj.Live.setDisabled(true);
			
			obj.form.submit({
				url: 'home/updateSingleObject/Feature',
				waitMsg: 'Saving Feature...',
				submitEmptyText: false,
				params: {
					ID: ID,
					Completed: obj.Completed.getValue() ? '1' : '0',
					Tested: obj.Tested.getValue() ? '1' : '0',
					Development: obj.Development.getValue() ? '1' : '0',
					Beta: obj.Beta.getValue() ? '1' : '0',
					Demo: obj.Demo.getValue() ? '1' : '0',
					Live: obj.Live.getValue() ? '1' : '0'
				},
				success: function(fp, o){
					Ext.Msg.show({
						title:'Updated Feature',
						msg: 'Feature has been updated',
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
		
		/*** Loader Start ***/
		
		obj.form.trackResetOnLoad = true;
		obj.form.load({
			url:'home/selectSingleObject/Feature/'+ID,
			waitMsg:'Loading record please wait...',
			fileUpload: true,
			success: function(form, action){
				var data = Ext.decode(action.response.responseText);
			}
		});
		
		/*** Loader End ***/
	});
}