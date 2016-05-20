public class TwoColumnController {

    public String subTabHTML { get; set; }

    public String currentUserContactId;

    public map<String, list<acfComm__Profile_Personal__c>> sectionIdToObjMap{get; set;}
    //public map<String, list<sObject>> sectionIdToFieldsMap{get; set;}
    public map<String, list<acfComm__two_col_layout__c>> sectionIdToFieldsMap{get; set;}
    public map<String, list<sObject>> sectionIdToBranchObj{get; set;}
    public list<Sobject> subSectionCustomSettings{ get; set; }
    public list<acfComm__Profile_Personal__c> subSectionCustomSettingsTwoColumn{ get; set; }
    public map<String, sObject> subSectionCustomSettingMap{get; set;}
    public map<String, sObject> sectionObjIdToSectionObj{get; set;}
    
    public boolean isEditMode { get; set;}

    public list<sObject> lstSubsectionCustomSetting{get; set;}

    public map<String, sObject> sectionIdToRelatedListObjectMap{get; set;}

    public Boolean showEditBtn {get; set;}
    public acfComm__Profile_Personal__c abc {get; set; }
    /*public Sobject pageSection{ get {
	      return pageSection;
	     }
	     set {
	       pageSection = value;
	       abc = (acfComm__Profile_Personal__c)pageSection;
	       system.debug('***pageSection' + pageSection);
	       //populateSobject(pageSection);
	       //QueryPage();
	     }
    }*/
    public void populateSobject(){
    	
    }
    
    public void QueryPage()
    {
        subSectionCustomSettingsTwoColumn = getProfilePersonal();
        init(subSectionCustomSettingsTwoColumn);
        system.debug('****subSectionCustomSettingsTwoColumn' + subSectionCustomSettingsTwoColumn);
        /*for(Sobject objCustomSetting : subSectionCustomSettings){
        	if(String.valueOf(objCustomSetting.get('acfComm__Custom_Setting_Type__c')).equalsIgnoreCase('2 column')){
        		abc = (acfComm__Profile_Personal__c)objCustomSetting;
        	}
        }
        system.debug('**subSectionCustomSettings' + subSectionCustomSettings);
        // system.debug('**pageSection' + pageSection);
         //system.debug('**sectionIdToFieldsMap' + sectionIdToFieldsMap);
        */
    }

    public void QueryPage1()
    {
        subSectionCustomSettings = getProfilePersonal1();
        init(subSectionCustomSettings);
    }

    public void QueryPage2()
    {
        subSectionCustomSettings = getProfilePersonal2();
        init(subSectionCustomSettings);
    }

    public void QueryPage3()
    {
        subSectionCustomSettings = getProfilePersonal3();
        init(subSectionCustomSettings);
    }

    public void QueryPage4()
    {
        subSectionCustomSettings = getProfilePersonal4();
        init(subSectionCustomSettings);
    }

    public void QueryPage5()
    {
        subSectionCustomSettings = getProfilePersonal5();
        init(subSectionCustomSettings);
    }

    public Boolean determineShowEditBtn()
    {
        Boolean showBtns = false;
        String userIdParam = apexpages.currentpage().getparameters().get('sfdc.userId');
        String userIdSystem = UserInfo.getUserId().substring(0, 15);
        system.debug('\n\n\n userIdParam: '+userIdParam+'\n\n\n');
        system.debug('\n\n\n userIdSystem: '+userIdSystem+'\n\n\n');
        if(userIdParam==userIdSystem)
        {
            showBtns = true;
        }
        return showBtns;
    }

    public void init(list<sObject> csSubSection)
    {
        currentUserContactId = getContactIdFromUser();
        sectionIdToObjMap = new map<String, list<acfComm__Profile_Personal__c>>();
        sectionIdToFieldsMap = new map<String, list<acfComm__two_col_layout__c>>();
        sectionIdToRelatedListObjectMap = new map<String, sObject>();
        subSectionCustomSettingMap = new map<String, sObject>();
        sectionObjIdToSectionObj = new map<String, sObject>();
        //subSectionCustomSettings = getSubSectionCustomSetting();

        showEditBtn = determineShowEditBtn();
		system.debug('***Custom Settings' + csSubSection);
        for(sObject subSectionCustomSetting : csSubSection)
        {
            subSectionCustomSettingMap.put(subSectionCustomSetting.Id, subSectionCustomSetting);
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).toLowerCase()=='subsection')
            {
                set<String> setTotalFields = new set<String>();
                map<Sobject, list<Sobject>> mapSectionWithSubHeaderFields = new map<Sobject, list<Sobject>>();
                //String queryStringForFields = '';    

                String queryStringForSubsectionCustomSetting = constructDynamicQueryForSubSectionCustomSetting(String.valueOf(subSectionCustomSetting.get('Custom_Setting__c')));
                
                list<sObject> customSettingSectionFields;
                set<String> fieldAPINames = new set<String>();
                list<sObject> sectionObj;
                // **** QUERY INSIDE OF FOR LOOP ****
                lstSubsectionCustomSetting = Database.query(queryStringForSubsectionCustomSetting);
                if(lstSubsectionCustomSetting != null && !lstSubsectionCustomSetting.isEmpty())
                {
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Privacy_Field_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(lstSubsectionCustomSetting, 'Privacy_Field_API__c'));

                    if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting, fieldAPINames);
                        system.debug('\n\nqueryStringForFields: '+queryStringForFields+'\n\n');
                        // **** QUERY INSIDE OF FOR LOOP ****
                        sectionObj = Database.query(queryStringForFields);
                    }
                    sectionIdToFieldsMap.put(subSectionCustomSetting.Id, lstSubsectionCustomSetting);
                }
                sectionIdToObjMap.put(subSectionCustomSetting.Id, sectionObj);
                
                for(sObject objSubsection : lstSubsectionCustomSetting)
                {
                    String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(string.ValueOf(objSubsection.get('Custom_Setting__c')));
                
                    //list<sObject> customSettingSectionFields;
                    fieldAPINames = new set<String>();
                    //list<sObject> sectionObj;
                    // **** QUERY INSIDE OF FOR LOOP ****
                    customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                    if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty())
                    {
                        fieldAPINames.addAll(createListOfFieldAPINames(objSubsection, 'Privacy_Field_API__c'));
                        fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Field_API_Name__c'));
                        fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Privacy_Field_API__c'));

                        if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                            String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting, fieldAPINames);
                            // **** QUERY INSIDE OF FOR LOOP ****
                            sectionObj = Database.query(queryStringForFields);
                            sectionIdToFieldsMap.put(objSubsection.Id, customSettingSectionFields);
                        }
                    }
                    sectionIdToObjMap.put(objSubsection.Id, sectionObj);
                    for(sObject sobj : sectionObj)
                    {
                        sectionObjIdToSectionObj.put(sobj.Id, sobj);
                    }
                }
            }
            else
            {
                String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(String.ValueOf(subSectionCustomSetting.get('Custom_Setting__c')));
                System.debug('\n\n\nQuery String is: ' + queryStringForCustomSettingFields);
                
                list<sObject> customSettingSectionFields;
                set<String> fieldAPINames = new set<String>();
                list<sObject> sectionObj;
                // **** QUERY INSIDE OF FOR LOOP ****
                customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty())
                {
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Related_List_Privacy_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Related_List_Read_Only_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Privacy_Field_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Field_API_Name__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Privacy_Field_API__c'));

                    if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting, fieldAPINames);
                        system.debug('\n\nqueryStringForFields: '+queryStringForFields+'\n\n');
                        // **** QUERY INSIDE OF FOR LOOP ****
                        sectionObj = Database.query(queryStringForFields);
                        sectionIdToFieldsMap.put(subSectionCustomSetting.Id, customSettingSectionFields);
                    }
                }
                sectionIdToObjMap.put(subSectionCustomSetting.Id, sectionObj);
                for(sObject sobj : sectionObj)
                {
                    sectionObjIdToSectionObj.put(sobj.Id, sobj);
                }
            }

            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).toLowerCase()=='related list compact' || 
               String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).toLowerCase()=='related list full')
            {
                sObject newObjForRelatedList = Schema.getGlobalDescribe().get(String.valueOf(subSectionCustomSetting.get('Object__c'))).newSObject();
                sectionIdToRelatedListObjectMap.put(subSectionCustomSetting.Id, newObjForRelatedList);
            }
        } // end for


        if(isEditMode == null){
            isEditMode = false;
        }
        //subTabHTML = CreateHTMLForPage(subSectionCustomSettings, sectionIdToObjMap, sectionIdToFieldsMap);
    }

    public TwoColumnController() 
    {
    	
        if(isEditMode == null){
            isEditMode = false;
        }
//        system.debug('**pageSection' + pageSection);
        QueryPage();
    }

    //Fetch Custom Setting to get field custom Setting
    public String constructDynamicQueryForSubSectionCustomSetting(String customSettingName)
    {
        String querySubsection = 'select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c'
                + ' from ' + customSettingName + ' order by Order__c';
       return querySubsection;
    }

    public String getContactIdFromUser()
    {
        String userIdParam = '';
        if(apexpages.currentpage().getparameters().get('sfdc.userId')!=null)
        {
            userIdParam = apexpages.currentpage().getparameters().get('sfdc.userId');
        }
        else
        {
           userIdParam = apexpages.currentpage().getparameters().get('id'); 
        }

        User currentUser = [Select ContactId from User u where Id=:userIdParam limit 1];
        //User currentUser = [Select ContactId from User u where Id=:UserInfo.getUserId() limit 1];
        return currentUser.ContactId;
    }

    public list<Profile_Personal__c> getProfilePersonal()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,acfComm__Help_Text__c,
                acfComm__related_list_static_where__c
                from Profile_Personal__c order by Order__c];
    }
    
    public list<Profile_Page_1__c> getProfilePersonal1()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c
                from Profile_Page_1__c order by Order__c];
    }

    public list<Profile_Page_2__c> getProfilePersonal2()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c
                from Profile_Page_2__c order by Order__c];
    }

    public list<Profile_Page_3__c> getProfilePersonal3()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c
                from Profile_Page_3__c order by Order__c];
    }

    public list<Profile_Page_4__c> getProfilePersonal4()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c
                from Profile_Page_4__c order by Order__c];
    }

    public list<Profile_Page_5__c> getProfilePersonal5()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c
                from Profile_Page_5__c order by Order__c];
    }

    public String constructDynamicQueryForFieldsCustomSetting(String customSettingName)
    {
    	system.debug('***customSettingName' + customSettingName);
        String dynamicQuery = '';
        if(customSettingName != null){
            String fieldsToSearch = 'Column_Span__c, Field_API_Name__c, Field_Name__c, Order__c, Privacy_Field_API__c, Read_Only__c, Read_Mode__c, Edit_Mode__c';
            dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + customSettingName + ' order by Order__c';
        }
        return dynamicQuery;
    }

    public String constructDynamicQueryForFields(Sobject pSubSectionCustomSetting, set<String> fields)
    {
    	String objName = String.valueOf(pSubSectionCustomSetting.get('Object__c'));
    	String ConIdAPIName = String.ValueOf(pSubSectionCustomSetting.get('Field_API_For_Contact_Id__c'));
    	String privacyStr = String.valueOf(pSubSectionCustomSetting.get('Related_List_Privacy_API__c'));
    	String whereClause = String.valueOf(pSubSectionCustomSetting.get('acfComm__related_list_static_where__c'));
        //if(currentUserContactId==null){ currentUserContactId='003o000000B9m2D'; }
        String dynamicQuery = '';
        String fieldsToSearch = convertListIntoFieldsToSearchString(fields);
        if(!String.isblank(whereClause)){
        	dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\'' + ' and ' + whereClause;
        }
        else{
        	dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\'';
        }
        
        system.debug('\n\n\n isEditMode: '+isEditMode+'\n\n\n');
        system.debug('\n\n\n privacyStr: '+privacyStr+'\n\n\n');
        if(isEditMode==false && privacyStr!=null)
        {
            dynamicQuery = dynamicQuery + ' and ' + privacyStr + '=false';
        }
        System.debug('\n\n\nQuery String is: ' + dynamicQuery + '\n\n');
        return dynamicQuery;
    }

    public String convertListIntoFieldsToSearchString(set<String> fields)
    {   
        String fieldsToSearch = '';
        for(String field : fields)
        {
            fieldsToSearch = fieldsToSearch + field + ', ';
        }
        fieldsToSearch = fieldsToSearch.removeEndIgnoreCase(', ');
        return fieldsToSearch;
    }

    public list<String> createListOfFieldAPINames(list<sObject> customSettingSectionFields, String fieldNameForAPIName)
    {
        list<String> fieldAPINames = new list<String>();
        for(sObject customSettingSectionField : customSettingSectionFields)
        {
            if(String.valueOf(customSettingSectionField.get(fieldNameForAPIName))!=null)
            {
                fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
            }
        }
        return fieldAPINames;
    }

    public list<String> createListOfFieldAPINames(sObject customSettingSectionField, String fieldNameForAPIName)
    {
        list<String> fieldAPINames = new list<String>();
        
        if(String.valueOf(customSettingSectionField.get(fieldNameForAPIName))!=null)
        {
                fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
        }
        return fieldAPINames;
    }

    public void EditSobjectRecord()
    {
        isEditMode = true;
        init(subSectionCustomSettings);
    }
    
    public PageReference saveSobjectRecord()
    {
        system.debug('\n\n SAVE \n\n');
        list<sObject> objs = new list<sObject>();
        map<String, sObject> objsToUpdateMap = new map<String, sObject>();
        for(sObject subSectionCustomSetting : subSectionCustomSettings)
        {
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).toLowerCase()=='2 column')
            {
                objs = sectionIdToObjMap.get(subSectionCustomSetting.Id);
                sObject obj = objs[0];
                if(objsToUpdateMap.get(obj.Id)!=null)
                {
                    sObject objToUpdate = objsToUpdateMap.get(obj.Id);
                    for(sObject fieldsCS : sectionIdToFieldsMap.get(subSectionCustomSetting.Id))
                    {
                        objToUpdate.put(String.valueOf(fieldsCS.get('Field_API_Name__c')), obj.get(String.valueOf(fieldsCS.get('Field_API_Name__c')))); 
                        if(fieldsCS.get('Privacy_Field_API__c')!=null)
                        {
                            objToUpdate.put(String.valueOf(fieldsCS.get('Privacy_Field_API__c')), obj.get(String.valueOf(fieldsCS.get('Privacy_Field_API__c'))));                     
                        }
                    }
                    if(subSectionCustomSetting.get('Privacy_Field_API__c')!=null)
                    {
                        objToUpdate.put(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')), obj.get(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')))); 
                    }
                }
                else
                {
                    objsToUpdateMap.put(obj.Id, obj);
                }
            }
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).toLowerCase()=='subsection')
            {
                objs = sectionIdToObjMap.get(subSectionCustomSetting.Id);
                if(objs!=null && objs.size()>0)
                {
                    sObject obj = objs[0];
                    if(objsToUpdateMap.get(obj.Id)!=null)
                    {
                        sObject objToUpdate = objsToUpdateMap.get(obj.Id);
                        if(subSectionCustomSetting.get('Privacy_Field_API__c')!=null)
                        {
                            objToUpdate.put(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')), obj.get(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')))); 
                        }
                    }
                    else
                    {
                        objsToUpdateMap.put(obj.Id, obj);
                    }
                }

                for(sObject subSectionObj : lstSubsectionCustomSetting)
                {
                    objs = sectionIdToObjMap.get(subSectionObj.Id);
                    sObject obj = objs[0];
                    system.debug('\n\n\n obj: '+obj+'\n\n\n');
                    system.debug('\n\n\n objsToUpdateMap: '+objsToUpdateMap+'\n\n\n');
                    if(objsToUpdateMap.get(obj.Id)!=null)
                    {
                        sObject objToUpdate = objsToUpdateMap.get(obj.Id);
                        for(sObject fieldsCS : sectionIdToFieldsMap.get(subSectionObj.Id))
                        {
                            objToUpdate.put(String.valueOf(fieldsCS.get('Field_API_Name__c')), obj.get(String.valueOf(fieldsCS.get('Field_API_Name__c')))); 
                            if(fieldsCS.get('Privacy_Field_API__c')!=null)
                            {
                                objToUpdate.put(String.valueOf(fieldsCS.get('Privacy_Field_API__c')), obj.get(String.valueOf(fieldsCS.get('Privacy_Field_API__c'))));                     
                            }
                        }
                    }
                    else
                    {
                        objsToUpdateMap.put(obj.Id, obj);
                    }
                }
            }
        }
       try {
        update objsToUpdateMap.Values();
       }
       catch(Exception e) {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
                 ApexPages.addMessage(myMsg);
          }

        isEditMode = false;
        init(subSectionCustomSettings);
        return null;
    }
    
    public PageReference cancel()
    {
        system.debug('\n\n CANCEL \n\n');
        isEditMode = false;
        init(subSectionCustomSettings);
        return null;
    }

    public String pageSectionId{get; set;}
    public Pagereference saveSobjectRecordToList()
    {
    	try {
	        system.debug('\n\n TEST \n\n');
	        sObject objToInsert = sectionIdToRelatedListObjectMap.get(pageSectionId);
	        sObject csObj = subSectionCustomSettingMap.get(pageSectionId);
	        objToInsert.put(String.valueOf(csObj.get('Field_API_For_Contact_Id__c')), currentUserContactId);
	        insert objToInsert;
    	}
    	catch(Exception e) {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Insert failed.');
                 ApexPages.addMessage(myMsg);
          }
        return null;
    }

    public String realtedListObjId{get; set;}
    public PageReference deleteRelatedList()
    {
    	try {
        sObject objToDelete = sectionObjIdToSectionObj.get(realtedListObjId);
        delete objToDelete;
        init(subSectionCustomSettings);
    	}
    	catch(Exception e) {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Delete failed.');
                 ApexPages.addMessage(myMsg);
          }
        return null;
    }

    /*public Pagereference saveSobjectRecordToListFull()
    {
        system.debug('\n\n TEST \n\n');
        sObject objToInsert = sectionIdToRelatedListObjectMap.get(pageSectionId);
        insert objToInsert;
        return null;
    }*/

    /* public String CreateHTMLForPage(list<sObject> subSections,  map<String, sObject> sectionIdToObjMap, map<String, list<sObject>> sectionIdToFieldsMap)
    {
        String html = '';
        for(sObject subSection : subSections)
        {   
            sObject obj = sectionIdToObjMap.get(String.ValueOf(subSection.get('Id')));
            list<Sobject> customSettingFields = sectionIdToFieldsMap.get(String.ValueOf(subSection.get('Id')));
            html = html + '<div><b>'+subSection.get('Title__c')+'</b><hr/></div>';
            system.debug('\n\n\n'+subSection.get('Custom_Setting_Type__c')+'\n\n\n');
        
            if(obj != null || customSettingFields != null){
                html = html + create2ColumnHTML(obj, customSettingFields,string.valueOf(subSection.get('Custom_Setting_Type__c')).substring(0,1));
            }
        }
        return html;
    }
*/
/*  public String create2ColumnHTML(sObject obj, list<sObject> customSettingFields)
    {
        Integer rowNum = 1;
        String html = '<table>';
        for(sObject field : customSettingFields)
        {
            if(math.MOD(rowNum, 2)!=0)
            {
                html = html + '<tr><td>'+obj.get(String.valueOf(field.get('Field_API_Name__c')))+'</td>';
            }
            else
            {
                html = html + '<td>'+obj.get(String.valueOf(field.get('Field_API_Name__c')))+'</td></tr>';
            }
            rowNum++;
        }   
        html = html + '</table>';
        return html;
    }*/
    
   /* public String create2ColumnHTML(sObject obj, list<sObject> customSettingFields, string pColumns)
    {
        Integer columnSize = integer.valueOf(pColumns);
        String html = '<table>';
        if(columnSize > 1){
            Integer rowNum = 1;
            for(sObject field : customSettingFields){
                if(math.MOD(rowNum, columnSize)!=0 && obj.get(String.valueOf(field.get('Field_API_Name__c'))) != null){
                    
                    html = html + '<tr><td>'+obj.get(String.valueOf(field.get('Field_API_Name__c')))+'</td>';
                }
                else{
                    if(obj.get(String.valueOf(field.get('Field_API_Name__c'))) != null){
                        html = html + '<td>'+obj.get(String.valueOf(field.get('Field_API_Name__c')))+'</td></tr>';
                    }
                }
                rowNum++;
            }   
        }
        else{
            for(sObject field : customSettingFields){
                if(obj.get(String.valueOf(field.get('Field_API_Name__c'))) != null){
                    html = html + '<tr><td>'+obj.get(String.valueOf(field.get('Field_API_Name__c')))+'</td></tr>';
                }
            }
        }
        html = html + '</table>';
        return html;
    }*/
}