<pageType label="Bug_Add" id="Bug_Add.frm" height="480" width="680" category="">
  <textBox x="20" component="textBox" y="20" arrPos="1" id="Feature_Add_textBox_1" emptyText="" width="200" tabOrder="" height="20" label="Name" allowBlank="true" validation="none"/>
  <textarea x="240" component="textarea" y="20" arrPos="2" id="Descrip" tebOrder="" emptyText="" width="420" tabOrder="" height="140" label="Description"/>
  <datebox x="20" allowBlank="true" component="datebox" y="100" tabOrder="" height="20" label="Reported Date" id="ReportedDate" width="200" arrPos="3"/>
  <hRule x="20" component="hRule" width="640" arrPos="4" height="20" label=" " id="Feature_Add_hRule_6" y="180"/>
  <checkBox x="20" component="checkBox" y="240" tabOrder="" height="20" label="Resolved" id="Complete" width="120" arrPos="5"/>
  <datebox x="140" allowBlank="true" component="datebox" y="220" tabOrder="" height="20" label="Resolved Date" id="ResolvedDate" width="160" arrPos="6"/>
  <checkBox x="20" component="checkBox" y="280" tabOrder="" height="20" label="Tested" id="Tested" width="120" arrPos="7"/>
  <datebox x="140" allowBlank="true" component="datebox" y="260" tabOrder="" height="20" label="Tested Date" id="TestedDate" width="160" arrPos="8"/>
  <checkBox x="380" component="checkBox" y="220" tabOrder="" height="20" label="Development Server" id="Development" width="160" arrPos="9"/>
  <checkBox x="380" component="checkBox" y="240" tabOrder="" height="20" label="Beta Server" id="Beta" width="160" arrPos="10"/>
  <checkBox x="380" component="checkBox" y="260" tabOrder="" height="20" label="Demo Server" id="Demo" width="160" arrPos="11"/>
  <checkBox x="380" component="checkBox" y="280" tabOrder="" height="20" label="Live Server" id="Live" width="160" arrPos="12"/>
  <combobox x="20" component="combobox" width="200" tabOrder="" arrPos="13" height="20" label="Feature" id="Feature" y="60" mode="remote"/>
  <button x="440" component="button" width="100" arrPos="14" height="20" label="Cancel" id="CancelButton" y="440"/>
  <button x="560" component="button" width="100" arrPos="15" height="20" label="Save" id="SaveButton" y="440"/>
</pageType>