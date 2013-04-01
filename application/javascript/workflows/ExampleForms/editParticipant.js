function editParticipant(ID, store, ProjectID, ProjectName) {
	if(ProjectID != null && ProjectID != undefined && ProjectName != null && ProjectName != undefined) {
	} else {
		var Search = Ext.getCmp('ParticipantSearchModule');
		var selection = Search.getSelectionModel().getSelected();
		ProjectID = selection.json.ProjectID ? selection.json.ProjectID : 0;
		ProjectName = selection.json.ProjectName ? selection.json.ProjectName : "";
	}
	parseForm('Participant_Project_Edit.frm', 'Edit Participant', function(obj) {
		/*** Start Form Item Config ***/
		obj.SavedPassword.setReadOnly(true);
		/*** End Form Item Config ***/
		
		/*** START Combo Config ***/
		obj.Project.store = new Ext.data.JsonStore({
			autoLoad: true,
			url: 'home/comboObjects/Project',
			root: 'rows',
			fields: ['ID', 'Name']
		});
		obj.Project.displayField = 'Name';
		obj.Project.valueField = 'ID';
		obj.Project.setDisabled(true);
		/*** END Combo Config ***/
		
		/*** Start Table Config ***/
		obj.RespondeeTable.store = new Ext.data.JsonStore({
			autoLoad: false,
			idProperty: 'ID',
			root: 'rows',
			totalProperty: 'results',
			fields: [
				"ID",
				"ProjectName",
				"FirstName", 
				"Surname", 
				"Email",
				"RespondeeRelation",
				"FeedbackGiven",
				"ParticipantFeedbackGiven"
			],
			baseParams: {
				ParticipantID: ID,
				ProjectID: ProjectID
			},
			proxy: new Ext.data.HttpProxy({
				url: 'home/getProjectRespondeesForParticipant'
			})
		});
		obj.RespondeeTable.colModel = new Ext.grid.ColumnModel({
			defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
				{header: 'First Name', dataIndex: 'FirstName', canSearch: true, incSearch: true, hidden: false},
				{header: 'Surname', dataIndex: 'Surname', canSearch: true, incSearch: true, hidden: false},
				{header: 'Relationship', dataIndex: 'RespondeeRelation', canSearch: true, incSearch: true, hidden: false},
				{header: 'Feedback', dataIndex: 'ParticipantFeedbackGiven', renderer: renderProgress2, width: 80}
			]
		});
		obj.RespondeeTable.reconfigure(obj.RespondeeTable.store, obj.RespondeeTable.colModel);
		obj.RespondeeTable.on('rowdblclick', function(grid, index, event) {
			var selection = grid.getSelectionModel().getSelected();
			var rID = selection.json.ID ? selection.json.ID : null;
			if(rID != null) {
				var PN = obj.FirstName.getValue() + " " + obj.Surname.getValue();
				//console.log(obj.Project.getValue());
				//console.log(ProjectID);
				editParticipantRespondee(rID, grid.store, ID, PN, ProjectID);
			}
		});
		
		/*obj.ProjectsTable.store = new Ext.data.JsonStore({
			autoLoad: false,
			idProperty: 'ID',
			root: 'rows',
			totalProperty: 'results',
			fields: [
				"ID",
				"Name", 
				"StartDate", 
				"EndDate"
			],
			baseParams: {
				ParticipantID: ID
			},
			proxy: new Ext.data.HttpProxy({
				url: 'home/listParticipantProjects/'+ID
			})
		});
		obj.ProjectsTable.colModel = new Ext.grid.ColumnModel({
			defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
				{header: 'Project', dataIndex: 'Name', canSearch: true, incSearch: true, hidden: false, width:20},
				{header: 'Start', dataIndex: 'StartDate', renderer: Ext.util.Format.dateRenderer('d/m/Y'), canSearch: true, incSearch: true, hidden: false, width:25},
				{header: 'End', dataIndex: 'EndDate', renderer: Ext.util.Format.dateRenderer('d/m/Y'), canSearch: true, incSearch: true, hidden: false, width:40}
			]
		});
		obj.ProjectsTable.reconfigure(obj.ProjectsTable.store, obj.ProjectsTable.colModel);
		obj.ProjectsTable.on('rowdblclick', function(grid, index, event) {
			var selection = grid.getSelectionModel().getSelected();
			var ProjectID = selection.json.ID ? selection.json.ID : null;
			if(ProjectID != null) {
				editProject(ProjectID, grid.store);
			}
		});*/
		/*** End Table Config ***/
		
		/*** Button Config Start ***/
		// Change Password Button
		obj.ChangePasswordButton.handler = function() {
			changePassword(ID);
		};
		
		obj.AddButton.handler = function() {
			addRespondee(obj.RespondeeTable.store, ProjectID, ID);
		};
		
		obj.RemoveButton.handler = function() {
			var selection = obj.RespondeeTable.getSelectionModel().getSelections();
			if (selection[0] != null && selection[0] != undefined) {
				Ext.Msg.show({
					title:'Remove Feedback Giver?',
					msg: 'Really remove the selected feedback giver from this participant?<br /><br />This action cannot be undone.',
					buttons: Ext.Msg.YESNO,
					icon: Ext.MessageBox.QUESTION,
					fn: function(btn) {
						if (btn == "yes") {
							Ext.Ajax.request({
								url: 'home/deleteProjectPartRes/',
								waitMsg: 'Removing feedback giver, please wait...',
								success: function(results){
									obj.RespondeeTable.store.load();
								},
								params: {
									ProjectID: ProjectID,
									ParticipantID: ID,
									RespondeeID: selection[0].json.ID
								}
							});
						}
					}
				});
			}		
		};
		
		obj.ImportButton.handler = function() {
			importRespondees(ID, obj.RespondeeTable.store, ProjectID);
		};
		
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.window.close();
		};
		//Save Button
		obj.SaveButton.handler = function() {
			obj.form.submit({
				url: 'home/mergeAndUpdate',
				waitMsg: 'Updating Participant...',
				submitEmptyText: false,
				params: {
					ID: ID
				},
				success: function(fp, o){
					Ext.Msg.alert('Success', 'Participant has been updated.');
					fp.reset();
					if (store != undefined && store != null) {
						store.load({params:store.lastOptions.params});
					} else {
						var Search = Ext.getCmp('ParticipantSearchModule');
						Search.store.load({params:Search.store.lastOptions.params});
					}
					obj.window.close();
				}
			});		
		};
		/*** End Button Config ***/
		obj.form.trackResetOnLoad = true;
		obj.form.load({
			url:'home/selectSingleObject/Participant/'+ID,
			waitMsg:'Loading record please wait...',
			fileUpload: true,
			success: function(form, action){
				obj.Project.setRawValue(ProjectID);
				obj.Project.setValue(ProjectName);
				obj.RespondeeTable.store.load();
				//obj.ProjectsTable.store.load();
			}
		});
	});
}

function editParticipantProject(ID, ProjectID, ProjectName, store) {
	parseForm('Participant_Project_Edit.frm', 'Edit Participant', function(obj) {
		/*** Start Form Item Config ***/
		obj.SavedPassword.setReadOnly(true);
		/*** End Form Item Config ***/
		
		/*** Start Table Config ***/
		obj.RespondeeTable.store = new Ext.data.JsonStore({
			autoLoad: false,
			idProperty: 'ID',
			root: 'rows',
			totalProperty: 'results',
			fields: [
				"ID",
				"FirstName", 
				"Surname", 
				"Email",
				"RespondeeRelation",
				"FeedbackGiven"
			],
			baseParams: {
				ParticipantID: ID
			},
			proxy: new Ext.data.HttpProxy({
				url: 'home/getRespondeesForParticipant'
			})
		});
		obj.RespondeeTable.colModel = new Ext.grid.ColumnModel({
			defaults: {
				sortable: true
			},
			columns: [
				new Ext.grid.RowNumberer({width: 20}),
				{id: 'ID', header: 'ID', width: 20, dataIndex: 'ID', canSearch: true, incSearch: false, hidden: true},
				{header: 'First Name', dataIndex: 'FirstName', canSearch: true, incSearch: true, hidden: false},
				{header: 'Surname', dataIndex: 'Surname', canSearch: true, incSearch: true, hidden: false},
				{header: 'Email', dataIndex: 'Email', canSearch: true, incSearch: true, hidden: false},
				{header: 'Relationship', dataIndex: 'RespondeeRelation', canSearch: true, incSearch: true, hidden: false},
				{header: 'Feedback Received', dataIndex: 'FeedbackGiven', renderer: renderProgress2, width: 100}
			]
		});
		obj.RespondeeTable.reconfigure(obj.RespondeeTable.store, obj.RespondeeTable.colModel);
		obj.RespondeeTable.on('rowdblclick', function(grid, index, event) {
			var selection = grid.getSelectionModel().getSelected();
			var rID = selection.json.ID ? selection.json.ID : null;
			if(rID != null) {
				var PN = obj.FirstName.getValue() + " " + obj.Surname.getValue();
				editParticipantRespondee(rID, grid.store, ID, PN, ProjectID);
			}
		});
		/*** End Table Config ***/
		
		/*** Button Config Start ***/
		// Change Password Button
		obj.ChangePasswordButton.handler = function() {
			changePassword(ID);
		};
		
		obj.AddButton.handler = function() {
			addRespondee(obj.RespondeeTable.store, obj.Project.getValue(), ID);
		};
		
		obj.RemoveButton.handler = function() {
			var selection = obj.RespondeeTable.getSelectionModel().getSelections();
			if (selection[0] != null && selection[0] != undefined) {
				Ext.Msg.show({
					title:'Remove Feedback Giver?',
					msg: 'Really remove the selected feedback giver from this participant?<br /><br />This action cannot be undone.',
					buttons: Ext.Msg.YESNO,
					icon: Ext.MessageBox.QUESTION,
					fn: function(btn) {
						if (btn == "yes") {
							Ext.Ajax.request({
								url: 'home/deleteSingleHasManyObject',
								waitMsg: 'Removing feedback giver, please wait...',
								success: function(results){
									obj.RespondeeTable.store.load();
								},
								params: {
									ParentObject: "Participant",
									ParentID: ID,
									HasMany: "Respondees",
									HasManyObjectID: selection[0].json.ID
								}
							});
						}
					}
				});
			}		
		};
		
		obj.ImportButton.handler = function() {
			importRespondees(ID, obj.RespondeeTable.store);
		};
		
		//Cancel Button
		obj.CancelButton.handler = function() {
			obj.window.close();
		};
		//Save Button
		obj.SaveButton.handler = function() {
			obj.form.submit({
				url: 'home/mergeAndUpdate',
				waitMsg: 'Updating Participant...',
				submitEmptyText: false,
				params: {
					ID: ID
				},
				success: function(fp, o){
					Ext.Msg.alert('Success', 'Participant has been updated.');
					fp.reset();
					if (store != undefined && store != null) {
						store.load({params:store.lastOptions.params});
					} else {
						var Search = Ext.getCmp('ParticipantSearchModule');
						Search.store.load({params:Search.store.lastOptions.params});
					}
					obj.window.close();
				}
			});		
		};
		/*** End Button Config ***/
		obj.form.trackResetOnLoad = true;
		obj.form.load({
			url:'home/selectSingleObject/Participant/'+ID,
			waitMsg:'Loading record please wait...',
			fileUpload: true,
			success: function(form, action){
				obj.RespondeeTable.store.load();
				obj.ProjectsTable.store.load();
			}
		});
	});
}
