<pageType label="moduleAdd" id="moduleAdd.frm" height="300" width="600" category="">
  <textBox tabOrder="" width="160" validation="none" id="name" allowBlank="true" label="Module Name" height="20" component="textBox" arrPos="1" x="20" y="20" emptyText=""/>
  <textBox tabOrder="" width="160" validation="none" id="priority" allowBlank="true" label="Menu Priority" height="20" component="textBox" arrPos="2" x="200" y="20" emptyText=""/>
  <addFileBox tabOrder="" height="20" width="200" arrPos="3" id="image" x="380" component="addFileBox" y="20" label="Module Icon"/>
  <textarea tabOrder="" width="560" validation="none" id="action" allowBlank="true" tebOrder="" label="Module Action" height="120" component="textarea" arrPos="4" x="20" y="60" emptyText=""/>
  <textBox tabOrder="" width="100" validation="none" id="xPos" allowBlank="true" label="xPos" height="20" component="textBox" arrPos="5" x="220" y="200" emptyText=""/>
  <textBox tabOrder="" width="100" validation="none" id="yPos" allowBlank="true" label="yPos" height="20" component="textBox" arrPos="6" x="340" y="200" emptyText=""/>
  <checkBox tabOrder="" height="20" width="120" arrPos="7" id="showOnHome" x="460" component="checkBox" y="220" label="Show On Home"/>
  <button id="saveButton" height="20" width="100" arrPos="8" x="480" component="button" y="260" label="Save"/>
  <button id="cancelButton" height="20" width="100" arrPos="9" x="360" component="button" y="260" label="Cancel"/>
  <combobox tabOrder="" height="20" width="180" mode="local" id="module" x="20" component="combobox" y="200" label="Module" arrPos="10"/>
</pageType>