<pageType label="SearchModule_Add" id="SearchModule_Add.frm" height="480" width="680" category="">
  <checkBox tabOrder="2" height="20" y="80" width="120" id="addButton" component="checkBox" x="20" arrPos="1" label="Can Add"/>
  <textBox id="addButtonTitle" tabOrder="3" component="textBox" arrPos="2" label="Add Button Label" emptyText="" allowBlank="true" y="60" width="520" validation="none" height="20" x="140"/>
  <textarea id="addButtonHandler" height="60" tabOrder="4" tebOrder="" y="100" width="640" emptyText="" component="textarea" x="20" arrPos="3" label="Add Button Action"/>
  <checkBox tabOrder="5" height="20" y="200" width="120" id="editButton" component="checkBox" x="20" arrPos="4" label="Can Edit"/>
  <textBox id="editButtonTitle" tabOrder="6" component="textBox" arrPos="5" label="Edit Button Label" emptyText="" allowBlank="true" y="180" width="520" validation="none" height="20" x="140"/>
  <textarea id="editButtonHandler" height="60" tabOrder="7" tebOrder="" y="220" width="640" emptyText="" component="textarea" x="20" arrPos="6" label="Edit Button Action"/>
  <checkBox tabOrder="8" height="20" y="320" width="120" id="deleteButton" component="checkBox" x="20" arrPos="7" label="Can Delete"/>
  <textBox id="deleteButtonTitle" tabOrder="9" component="textBox" arrPos="8" label="Delete Button Label" emptyText="" allowBlank="true" y="300" width="520" validation="none" height="20" x="140"/>
  <textarea id="deleteButtonHandler" height="60" tabOrder="10" tebOrder="" y="340" width="640" emptyText="" component="textarea" x="20" arrPos="9" label="Delete Button Action"/>
  <button height="20" y="440" width="100" id="SaveButton" component="button" x="560" arrPos="10" label="Save"/>
  <button height="20" y="440" width="100" id="CancelButton" component="button" x="440" arrPos="11" label="Cancal"/>
  <combobox id="object" component="combobox" mode="local" y="0" width="340" tabOrder="1" height="20" x="20" arrPos="12" label="Object"/>
  <textBox emptyText="" allowBlank="true" id="groupField" component="textBox" arrPos="13" label="Group Object" validation="none" tabOrder="" y="0" width="180" height="20" x="380"/>
  <checkBox height="20" tabOrder="" y="20" width="120" id="groupedView" component="checkBox" x="580" arrPos="14" label="Group"/>
  <textBox allowBlank="true" label="searchURL" component="textBox" arrPos="15" tabOrder="" x="20" height="20" y="420" id="searchURL" width="200" validation="none" emptyText=""/>
</pageType>