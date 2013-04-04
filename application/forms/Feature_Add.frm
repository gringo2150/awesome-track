<pageType label="Feature_Add" id="Feature_Add.frm" height="480" width="680" category="">
  <textBox x="20" component="textBox" y="20" arrPos="1" id="Feature_Add_textBox_1" emptyText="" width="200" tabOrder="" height="20" label="Name" allowBlank="true" validation="none"/>
  <textarea x="240" component="textarea" y="20" arrPos="2" id="Descrip" tebOrder="" emptyText="" width="420" tabOrder="" height="140" label="Description"/>
  <datebox x="20" allowBlank="true" component="datebox" y="140" tabOrder="" height="20" label="Start Date" id="StartDate" width="100" arrPos="3"/>
  <datebox x="120" allowBlank="true" component="datebox" y="140" tabOrder="" height="20" label="Due Date" id="DueDate" width="100" arrPos="4"/>
  <textBox x="20" component="textBox" y="100" arrPos="5" id="Cost" emptyText="" width="200" tabOrder="" height="20" label="Cost" allowBlank="true" validation="none"/>
  <hRule x="20" component="hRule" width="640" arrPos="6" height="20" label=" " id="Feature_Add_hRule_6" y="180"/>
  <checkBox x="20" component="checkBox" y="240" tabOrder="" height="20" label="Completed" id="Completed" width="120" arrPos="7"/>
  <datebox x="140" allowBlank="true" component="datebox" y="220" tabOrder="" height="20" label="Completed Date" id="CompleteDate" width="160" arrPos="8"/>
  <checkBox x="20" component="checkBox" y="280" tabOrder="" height="20" label="Tested" id="Tested" width="120" arrPos="9"/>
  <datebox x="140" allowBlank="true" component="datebox" y="260" tabOrder="" height="20" label="Tested Date" id="TestedDate" width="160" arrPos="10"/>
  <checkBox x="380" component="checkBox" y="220" tabOrder="" height="20" label="Development Server" id="Development" width="160" arrPos="11"/>
  <checkBox x="380" component="checkBox" y="240" tabOrder="" height="20" label="Beta Server" id="Beta" width="160" arrPos="12"/>
  <checkBox x="380" component="checkBox" y="260" tabOrder="" height="20" label="Demo Server" id="Demo" width="160" arrPos="13"/>
  <checkBox x="380" component="checkBox" y="280" tabOrder="" height="20" label="Live Server" id="Live" width="160" arrPos="14"/>
  <combobox x="20" component="combobox" width="200" tabOrder="" arrPos="15" height="20" label="Milestone" id="Milestone" y="60" mode="remote"/>
  <button x="440" component="button" width="100" arrPos="16" height="20" label="Cancel" id="CancelButton" y="440"/>
  <button x="560" component="button" width="100" arrPos="17" height="20" label="Save" id="SaveButton" y="440"/>
</pageType>