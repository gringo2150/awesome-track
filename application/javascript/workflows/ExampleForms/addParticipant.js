function addParticipant(store, projectID, projectName) {
	parseForm('Participant_Add.frm', 'New Participant', function(obj) {
		
		obj.loadMask.show();
		
		/*** Start Combo Store Config ***/
		obj.Project.store = new Ext.data.JsonStore({
			autoLoad: true,
			url: 'home/getChildObjects/Project',
			root: 'rows',
			fields: ['ID', 'Name']
		});
		obj.Project.displayField = 'Name';
		obj.Project.valueField = 'ID';
		
		obj.Project.store.on('load', function() {
			if(projectID != null || projectID != undefined) {
				obj.Project.setValue(projectID);
				obj.Project.setRawValue(projectName);
				obj.Project.setReadOnly(true);
			}
			obj.loadMask.hide();
		});
		/*** End Combo Store Config ***/
		
		/*** Button Config Start ***/
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.form.reset();
			obj.window.close();
		};
		//Save Button
		obj.SaveButton.handler = function() {
			if (obj.SetPassword.getValue() == "") {
				obj.SetPassword.setValue(obj.FirstName.getValue().toLowerCase());
			}
			var params = Object();
			if(projectID != null || projectID != undefined) {
				params['ProjectID'] = projectID;
			}
			params['Self'] = 1;
			params['SavedPassword'] = obj.SetPassword.getValue();
			obj.form.submit({
				url: 'home/addParticipant',
				waitMsg: 'Adding participant...',
				submitEmptyText: false,
				params: params,
				success: function(fp, o){
					var json = Ext.decode(o.response.responseText);
					if (json.msg != undefined && json.msg == "OtherProject") {
						var msg = "A participant / feedback-giver with that email address already exists on another project.<br/><br/>At present, a new participant / feedback-giver record must be created for each project they take part in, and each record must contain a unique email address.";
						Ext.Msg.show({
							title:'Warning',
							msg: msg,
							buttons: Ext.Msg.OK,
							icon: Ext.MessageBox.WARNING
						});
					} else if (json.msg != undefined && json.msg == "Exists") {
						var msg = "A participant with that email address has already been added to this project.";
						Ext.Msg.show({
							title:'Warning',
							msg: msg,
							buttons: Ext.Msg.OK,
							icon: Ext.MessageBox.WARNING
						});
					} else if (json.msg != undefined && json.msg == "Changed") {
						var msg = "Feedback-giver changed to participant";
						Ext.Msg.show({
							title:'Success',
							msg: msg,
							buttons: Ext.Msg.OK,
							icon: Ext.MessageBox.INFO
						});
						fp.reset();
						if(store != null || store != undefined) store.load();
						//Ext.getCmp('SearchModule').store.load();
						obj.window.close();
					} else if (json.msg != undefined && json.msg == "Success") {
						Ext.Msg.alert('Success', 'Participant has been added.');
						fp.reset();
						if(store != null || store != undefined) store.load();
						//Ext.getCmp('SearchModule').store.load();
						obj.window.close();
					} else {
						var mess = (json.msg != undefined) ? json.msg : "Unknown Error";
						Ext.Msg.show({
							title:'Error',
							msg: "Oops! It appears there was an error. Message returned from server:<br/><br/>"+json.msg,
							buttons: Ext.Msg.OK,
							icon: Ext.MessageBox.ERROR
						});
					}
				}
			});
		};
		/*** End Button Config ***/
	});
}
