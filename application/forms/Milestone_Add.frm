<pageType label="Milestone_Add" id="Milestone_Add.frm" height="240" width="680" category="">
  <textBox x="20" component="textBox" y="20" arrPos="1" id="Name" emptyText="" width="200" tabOrder="" height="20" label="Milestone" allowBlank="true" validation="none"/>
  <textarea x="240" component="textarea" y="20" arrPos="2" id="Descrip" tebOrder="" emptyText="" width="420" tabOrder="" height="140" label="Description"/>
  <datebox x="20" allowBlank="true" component="datebox" y="100" tabOrder="" height="20" label="Due Date" id="Milestone_Add_datebox_3" width="200" arrPos="3"/>
  <checkBox x="20" component="checkBox" y="160" tabOrder="" height="20" label="Complete" id="Complete" width="100" arrPos="4"/>
  <datebox x="120" allowBlank="true" component="datebox" y="140" tabOrder="" height="20" label="Complete Date" id="CompleteDate" width="100" arrPos="5"/>
  <button x="440" component="button" width="100" arrPos="6" height="20" label="Cancel" id="CancelButton" y="200"/>
  <button x="560" component="button" width="100" arrPos="7" height="20" label="Save" id="SaveButton" y="200"/>
  <combobox x="20" component="combobox" width="200" tabOrder="" arrPos="8" height="20" label="Project" id="Project" y="60" mode="remote"/>
</pageType>