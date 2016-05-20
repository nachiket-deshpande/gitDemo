/*-----------------------------------------------------------------------
    ACF Solutions
    Description: Controller class used to pull data from custom settings
                 and display sections on the profile page.
                 
                 **This class convert "Web Content" object field value to
                 picklist values based on field custom setting record.
                 Modified date : 28/07/2015**
-----------------------------------------------------------------------*/

public class Profile_Personal_V1_Clone {

    public String subTabHTML { get; set; }

    public String currentUserContactId;
    public Contact currentContact {get; set;}

    public map<String, list<sObject>> sectionIdToObjMap{get; set;}
    public map<String, list<sObject>> sectionIdToFieldsMap{get; set;}
    public map<String, list<sObject>> sectionIdToBranchObj{get; set;}
    public list<sObject> subSectionCustomSettings{ get; set; }
    public map<String, sObject> subSectionCustomSettingMap{get; set;}
    public map<String, sObject> sectionObjIdToSectionObj{get; set;}
    public map<String, Community_Web_Content__c> mapWebContent{get; set;}
    
    public boolean isEditMode { get; set;}

    public list<sObject> lstSubsectionCustomSetting{get; set;}

    public map<String, sObject> sectionIdToRelatedListObjectMap{get; set;}

    public Boolean showEditBtn {get; set;}
    
    public map<String, list<SelectOption>> mapCustomFieldWithSelectList{ get; set;}
    public list<fieldWrapperClass> lstWrapper{ get; set;}
    
    public String strSelectOptionValue{ get; set;}
    public list<string> lstRelatedFullRecordId{get; set;}
    public String realtedListEditObjId{get; set;}
    public map<String, boolean> mapEditableFields{get; set;}
    public boolean isInit{get; set;}
    
    
    //parameters for Edit/Create/Delete functionality
    public boolean isCreate{get; set;}
    public String relatedFullId{get; set;}
    public String relatedFullCancelId{get; set;}
    
    public list<wrapperSectionIdToObj> lstwrapperSectionIdToObj{get; set;}
    
    /*public void QueryPage()
    {
        retriveWebContent();
        subSectionCustomSettings = getProfilePersonal();
        init(subSectionCustomSettings);
        
    }*/

    public void QueryPage1()
    {
        subSectionCustomSettings = getProfilePersonal1();
        system.debug('***subSectionCustomSettings' + subSectionCustomSettings);
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
        String userIdParam = '';
        if(apexpages.currentpage().getparameters().get('sfdc.userId')!=null)
        {
            userIdParam = apexpages.currentpage().getparameters().get('sfdc.userId');
        }
        else
        {
           userIdParam = apexpages.currentpage().getparameters().get('id'); 
        }
        String userIdSystem = UserInfo.getUserId().substring(0, 15);
        system.debug('\n\n\n userIdParam: '+userIdParam+'\n\n\n');
        system.debug('\n\n\n userIdSystem: '+userIdSystem+'\n\n\n');
        if(userIdParam.equalsIgnoreCase(userIdSystem))
        {
            showBtns = true;
        }
        return showBtns;
    }

    public void init(list<sObject> csSubSection)
    {
      relatedFullId ='';
        currentUserContactId = getContactIdFromUser();
        sectionIdToObjMap = new map<String, list<sObject>>();
        sectionIdToFieldsMap = new map<String, list<sObject>>();
        sectionIdToRelatedListObjectMap = new map<String, sObject>();
        subSectionCustomSettingMap = new map<String, sObject>();
        sectionObjIdToSectionObj = new map<String, sObject>();
        lstwrapperSectionIdToObj = new list<wrapperSectionIdToObj>();
        
        //subSectionCustomSettings = getSubSectionCustomSetting();

        showEditBtn = determineShowEditBtn();
        system.debug('***Custom Settings' + csSubSection);
        set<String> fieldAPINamesForCon = new set<String>();
        for(sObject subSectionCustomSetting : csSubSection)
        {
            fieldAPINamesForCon.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Privacy_Field_API__c'));

            subSectionCustomSettingMap.put(subSectionCustomSetting.Id, subSectionCustomSetting);
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).equalsIgnoreCase('subsection'))
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
                    system.debug('\n\n\n fieldAPINames: '+fieldAPINames+'\n\n\n');

                    if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting, fieldAPINames);
                        system.debug('\n\nqueryStringForFields: '+queryStringForFields+'\n\n');
                        // **** QUERY INSIDE OF FOR LOOP ****
                        sectionObj = Database.query(queryStringForFields);
                    }
                    sectionIdToFieldsMap.put(subSectionCustomSetting.Id, lstSubsectionCustomSetting);
                }
                sectionIdToObjMap.put(subSectionCustomSetting.Id, sectionObj);
                list<wrapperEditableRecords> lstWrapperEditableRecords = new list<wrapperEditableRecords>();
                for(Sobject objSection : sectionObj){
                    lstWrapperEditableRecords.add(new wrapperEditableRecords(objSection, false));
                }
                lstwrapperSectionIdToObj.add(new wrapperSectionIdToObj(subSectionCustomSetting.Id, lstWrapperEditableRecords));
                system.debug('****lstwrapperSectionIdToObj' + lstwrapperSectionIdToObj);
                for(sObject objSubsection : lstSubsectionCustomSetting)
                {
                    String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(string.ValueOf(objSubsection.get('Custom_Setting__c')));
                
                    //list<sObject> customSettingSectionFields;
                    fieldAPINames = new set<String>();
                    //list<sObject> sectionObj;
                    // **** QUERY INSIDE OF FOR LOOP ****
                    customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                    system.debug('***customSettingSectionFields' + customSettingSectionFields);
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
                    if(String.ValueOf(objSubsection.get('Custom_Setting_Type__c')).equalsIgnoreCase('related list compact') || 
                    String.ValueOf(objSubsection.get('Custom_Setting_Type__c')).equalsIgnoreCase('related list full'))
                    {
                        sObject newObjForRelatedList = Schema.getGlobalDescribe().get(String.valueOf(subSectionCustomSetting.get('Object__c'))).newSObject();
                        sectionIdToRelatedListObjectMap.put(objSubsection.Id, newObjForRelatedList);
                    }

                    subSectionCustomSettingMap.put(objSubsection.Id, objSubsection);
                }
            }
            else
            {
                System.debug('****Inside Else');
                String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(String.ValueOf(subSectionCustomSetting.get('Custom_Setting__c')));
                System.debug('\n\n\nQuery String is: ' + queryStringForCustomSettingFields);
                
                list<sObject> customSettingSectionFields;
                set<String> fieldAPINames = new set<String>();
                list<sObject> sectionObj;
                // **** QUERY INSIDE OF FOR LOOP ****
                customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                
                //getPicklistFieldValues(customSettingSectionFields);
                
                if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty())
                {
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Related_List_Privacy_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Related_List_Read_Only_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(subSectionCustomSetting, 'Privacy_Field_API__c'));
                    fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Field_API_Name__c'));
                    //fieldAPINames.addAll(createListOfFieldAPINames(customSettingSectionFields, 'Picklist__c'));

                    if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting, fieldAPINames);
                        system.debug('\n\nqueryStringForFields: '+queryStringForFields+'\n\n');
                        // **** QUERY INSIDE OF FOR LOOP ****
                        sectionObj = Database.query(queryStringForFields);
                        sectionIdToFieldsMap.put(subSectionCustomSetting.Id, customSettingSectionFields);
                    }
                }
                sectionIdToObjMap.put(subSectionCustomSetting.Id, sectionObj);
                system.debug('***sectionObj' + sectionObj);
                
                 
                for(sObject sobj : sectionObj)
                {
                    sectionObjIdToSectionObj.put(sobj.Id, sobj);
                }
                 system.debug('***sectionObjIdToSectionObj****' + sectionObjIdToSectionObj);
                if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).equalsIgnoreCase('related list compact') || 
                String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).equalsIgnoreCase('related list full'))
                {
                    sObject newObjForRelatedList = Schema.getGlobalDescribe().get(String.valueOf(subSectionCustomSetting.get('Object__c'))).newSObject();
                    sectionIdToRelatedListObjectMap.put(subSectionCustomSetting.Id, newObjForRelatedList);
                }
            }
        } // end for
        
        if(mapEditableFields == null){
            //system.debug('***mapEditableFields*Inside***' + mapEditableFields);
            mapEditableFields = new map<String, boolean>();
        }
                for(list<sObject> sobj : sectionIdToObjMap.values())
                {
                    for(Sobject objFieldValue : sobj){
                        if(!mapEditableFields.containsKey(objFieldValue.Id)){
                            mapEditableFields.put(objFieldValue.Id, false);
                            //mapEditableFields.put(String.valueOf(objFieldValue.Id).subString(0, 15), false);
                        }
                        
                    }
                }
                system.debug('***mapEditableFields' + mapEditableFields);
            //}
         
         
        /* for(list<sObject> sobj : sectionIdToObjMap.values()){
             for(Sobject objFieldValue : sobj){
                if(!mapEditableFields.containsKey(objFieldValue.Id)){
                    mapEditableFields.put(objFieldValue.Id, false);
                    //mapEditableFields.put(String.valueOf(objFieldValue.Id).subString(0, 15), false);
                }
            }
        }*/
               /* else if(!String.isBlank(relatedFullCancelId)){
                    mapEditableFields.put(relatedFullCancelId, false);
                }*/
            system.debug('***mapEditableFields****' + mapEditableFields);

        String ConQuery = 'Select Id ';
        if(fieldAPINamesForCon.size()>0)
        {
            String fieldsToSearch = convertListIntoFieldsToSearchString(fieldAPINamesForCon);
            ConQuery = ConQuery+', '+fieldsToSearch;
        }
        ConQuery = ConQuery + ' from Contact where Id=\''+currentUserContactId+'\'';
        currentContact = Database.query(ConQuery);

        if(isEditMode == null){
            isEditMode = false;
        }
        //subTabHTML = CreateHTMLForPage(subSectionCustomSettings, sectionIdToObjMap, sectionIdToFieldsMap);
        system.debug('\n\n\n **sectionIdToObjMap**: '+sectionIdToObjMap+'\n\n\n');
    }

    public Profile_Personal_V1_Clone(ApexPages.StandardController stdController) 
    {
        if(isEditMode == null){
            isEditMode = false;
        }
    }

    //Fetch Custom Setting to get field custom Setting
    public String constructDynamicQueryForSubSectionCustomSetting(String customSettingName)
    {
        String querySubsection = 'select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, Order__c, Privacy_Field_API__c, Title__c, Help_Text__c, Field_API_For_Contact_Id__c, Related_List_Privacy_API__c, Related_List_Read_Only_API__c, related_list_static_where__c,Sort__c'
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

        //User currentUser = [Select ContactId from User u where Id=:userIdParam limit 1];
        //User currentUser = [Select ContactId from User u where Id=:UserInfo.getUserId() limit 1];
        return UtilityGeneral.getContactIdFromUser(userIdParam);
    }

    /*public list<Profile_Personal__c> getProfilePersonal()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,Help_Text__c,
                related_list_static_where__c,Sort__c, Read_Only__c
                from Profile_Personal__c order by Order__c];
    }*/
    
    public list<Profile_Page_1__c> getProfilePersonal1()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, Allow_Editing__c,
                Create__c,Edit__c,Delete__c,
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c, 
                related_list_static_where__c,Sort__c, Help_Text__c, Read_Only__c
                from Profile_Page_1__c order by Order__c];
    }

    public list<Profile_Page_2__c> getProfilePersonal2()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,
                related_list_static_where__c,Sort__c, Help_Text__c, Read_Only__c
                from Profile_Page_2__c order by Order__c];
    }

    public list<Profile_Page_3__c> getProfilePersonal3()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,
                related_list_static_where__c, Sort__c,Help_Text__c, Read_Only__c
                from Profile_Page_3__c order by Order__c];
    }

    public list<Profile_Page_4__c> getProfilePersonal4()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,
                related_list_static_where__c,Sort__c, Help_Text__c, Read_Only__c
                from Profile_Page_4__c order by Order__c];
    }

    public list<Profile_Page_5__c> getProfilePersonal5()
    {
        return [select Id, Custom_Setting__c, Custom_Setting_Type__c, Object__c, 
                Order__c, Privacy_Field_API__c, Title__c, Field_API_For_Contact_Id__c,
                Related_List_Privacy_API__c, Related_List_Read_Only_API__c,
                related_list_static_where__c, Sort__c,Help_Text__c, Read_Only__c
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
        String whereClause = String.valueOf(pSubSectionCustomSetting.get('related_list_static_where__c'));
        String sortByParam = String.valueOf(pSubSectionCustomSetting.get('Sort__c'));
        
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
        if(!String.isblank(sortByParam)){
               dynamicQuery = dynamicQuery +  ' order by ' + sortByParam;
        }
        
        System.debug('dynamicQuery : ' + dynamicQuery + '\n\n');
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
        //init(subSectionCustomSettings);
    }
    
    public PageReference saveSobjectRecord()
    {
        system.debug('\n\n SAVE \n\n');
        system.debug('****objmap' + sectionIdToObjMap);
        list<sObject> objs = new list<sObject>();
        map<String, sObject> objsToUpdateMap = new map<String, sObject>();
        for(sObject subSectionCustomSetting : subSectionCustomSettings)
        {
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).equalsIgnoreCase('2 column'))
            {
                objs = sectionIdToObjMap.get(subSectionCustomSetting.Id);
                sObject obj = objs[0];
                String objectCS = String.valueOf(subSectionCustomSetting.get('Object__c'));
                sObject objToUpdate = Schema.getGlobalDescribe().get(objectCS).newSObject();
                objToUpdate.Id = obj.Id;
                if(objsToUpdateMap.get(obj.Id)!=null)
                {
                    objToUpdate = objsToUpdateMap.get(obj.Id);
                }
                    for(sObject fieldsCS : sectionIdToFieldsMap.get(subSectionCustomSetting.Id))
                    {
                        if(fieldsCS.get('Read_Only__c')==false)
                        {
                            objToUpdate.put(String.valueOf(fieldsCS.get('Field_API_Name__c')), obj.get(String.valueOf(fieldsCS.get('Field_API_Name__c')))); 
                        }
                        if(fieldsCS.get('Privacy_Field_API__c')!=null)
                        {
                            objToUpdate.put(String.valueOf(fieldsCS.get('Privacy_Field_API__c')), obj.get(String.valueOf(fieldsCS.get('Privacy_Field_API__c'))));                     
                        }
                    }
                    if(subSectionCustomSetting.get('Privacy_Field_API__c')!=null)
                    {
                        objToUpdate.put(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')), obj.get(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')))); 
                    }
                objsToUpdateMap.put(obj.Id, objToUpdate);
            }
            if(String.ValueOf(subSectionCustomSetting.get('Custom_Setting_Type__c')).equalsIgnoreCase('subsection'))
            {
                objs = sectionIdToObjMap.get(subSectionCustomSetting.Id);
                system.debug('\n\n\n *objs**: '+objs+'\n\n\n');
                if(objs!=null && objs.size()>0)
                {
                    sObject obj = objs[0];
                    if(objsToUpdateMap.get(obj.Id)!=null)
                    {
                        sObject objToUpdate = objsToUpdateMap.get(obj.Id);
                        system.debug('\n\n\n Privacy Field API: '+subSectionCustomSetting.get('Privacy_Field_API__c')+'\n\n\n');
                        if(subSectionCustomSetting.get('Privacy_Field_API__c')!=null)
                        {
                            objToUpdate.put(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')), obj.get(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')))); 
                        }
                        //objsToUpdateMap.put(obj.Id, objToUpdate);
                    }
                    else
                    {
                        if(subSectionCustomSetting.get('Privacy_Field_API__c')!=null)
                        {
                            obj.put(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')), obj.get(String.valueOf(subSectionCustomSetting.get('Privacy_Field_API__c')))); 
                        }
                        objsToUpdateMap.put(obj.Id, obj);
                    }
                }

                for(sObject subSectionObj : lstSubsectionCustomSetting)
                {
                    objs = sectionIdToObjMap.get(subSectionObj.Id);
                    sObject obj = objs[0];
                    String objectCS = String.valueOf(subSectionObj.get('Object__c'));
                    sObject objToUpdate = Schema.getGlobalDescribe().get(objectCS).newSObject();
                    objToUpdate.Id = obj.Id;
                    system.debug('\n\n\n obj: '+obj+'\n\n\n');
                    system.debug('\n\n\n objsToUpdateMap: '+objsToUpdateMap+'\n\n\n');
                    if(objsToUpdateMap.get(obj.Id)!=null)
                    {
                        objToUpdate = objsToUpdateMap.get(obj.Id);
                    }
                        for(sObject fieldsCS : sectionIdToFieldsMap.get(subSectionObj.Id))
                        {
                            if(fieldsCS.get('Read_Only__c')==false)
                            {
                                objToUpdate.put(String.valueOf(fieldsCS.get('Field_API_Name__c')), obj.get(String.valueOf(fieldsCS.get('Field_API_Name__c')))); 
                            }
                            if(fieldsCS.get('Privacy_Field_API__c')!=null)
                            {
                                objToUpdate.put(String.valueOf(fieldsCS.get('Privacy_Field_API__c')), obj.get(String.valueOf(fieldsCS.get('Privacy_Field_API__c'))));                     
                            }
                        }
                }
            }
        }


        system.debug('***objsToUpdateMap' + objsToUpdateMap);
        update objsToUpdateMap.Values();

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
    public void saveSobjectRecordToList()
    {
        system.debug('\n\n TEST \n\n');
        sObject objToInsert = sectionIdToRelatedListObjectMap.get(pageSectionId);
        sObject csObj = subSectionCustomSettingMap.get(pageSectionId);
        system.debug('\n\n'+objToInsert+'\n\n');
        system.debug('\n\n'+csObj+'\n\n');
        objToInsert.put(String.valueOf(csObj.get('Field_API_For_Contact_Id__c')), currentUserContactId);
        insert objToInsert;
        system.debug('***subSectionCustomSettings' + subSectionCustomSettings);
        init(subSectionCustomSettings);
        mapEditableFields.put(objToInsert.id, false);
        //mapEditableFields.put(String.valueOf(objToInsert.id).subString(0, 15), false);
        system.debug('***objToInsert' + objToInsert);
        system.debug('***mapEditableFields' + mapEditableFields);
        //return null;
    }

    public String realtedListObjId{get; set;}
    //Method to delete Related list Record
    public PageReference deleteRelatedList()
    {
        sObject objToDelete = sectionObjIdToSectionObj.get(realtedListObjId);
        delete objToDelete;
        system.debug('***objToDelete' + objToDelete);
        init(subSectionCustomSettings);
        system.debug('***AfterdeleteRelatedList' + sectionObjIdToSectionObj);
        system.debug('***mapEditableFields' + mapEditableFields);
        //mapEditableFields.remove(realtedListObjId);
        return null;
    }
    
    //Method to cancel edit row view
    public PageReference cancelRelatedFullRecord()
    {
        init(subSectionCustomSettings);
        return null;
    }
    
    
    public PageReference editRelatedList()
    {
      system.debug('realtedListEditObjId***' + realtedListEditObjId);
        if(!String.isBlank(realtedListEditObjId)){
          
            mapEditableFields.put(realtedListEditObjId,true);
            //mapEditableFields.put(String.valueOf(realtedListEditObjId).subString(0, 15), true);
        }
        system.debug('***mapEditableFields' + mapEditableFields);
        init(subSectionCustomSettings);
        system.debug('***mapEditableFields' + mapEditableFields);
        
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
    
    //Method which returns all the web content records
    public void retriveWebContent () {
        mapWebContent = new map<String, Community_Web_Content__c>();
        list<Community_Web_Content__c> lstWebContent =  [SELECT  name, Content__c, Page_Content__c
                                                           FROM    Community_Web_Content__c];
        for(Community_Web_Content__c objWebContent :lstWebContent){
              mapWebContent.put(String.valueof(objWebContent.Name), objWebContent);
        }
        system.debug('***mapWebContent'+mapWebContent);
    }

    public Pagereference createRelatedListFullRecord(){
        isCreate = true;
        return null;
    }
    
    public Pagereference testMethodNew () {
        System.debug ('Sid:::: #731 I am in');
        return null;
    }
    //Method to update related list full record
    public Pagereference UpdateRelatedFullRecord (){
      System.debug ('Sid:::::#732 I am called');
        system.debug('***sectionIdToObjMap' + sectionIdToObjMap);
        system.debug('***relatedFullId' + relatedFullId);
        String idSobjectRecord;
        Sobject objUpdatRelatedListRecord;
        for(list<Sobject> lstRelatedFull : sectionIdToObjMap.values()){
            for(Sobject objRelatedFull : lstRelatedFull){
                idSobjectRecord = String.valueOf(objRelatedFull.get('id'));
                system.debug('***objRelatedFull' + objRelatedFull);
                if(idSobjectRecord.equalsIgnoreCase(relatedFullId)){
                    system.debug('***Inside' + idSobjectRecord);
                    objUpdatRelatedListRecord =  objRelatedFull;
            }
         }
     }
        if(objUpdatRelatedListRecord != null){
            update objUpdatRelatedListRecord;
            
            system.debug('***objUpdatRelatedListRecord' + objUpdatRelatedListRecord);
            system.debug('***mapEditableFields' + mapEditableFields);
            mapEditableFields.put(relatedFullId,false);
           // mapEditableFields.put(String.valueOf(relatedFullId).subString(0, 15), false);
            system.debug('***mapEditableFields' + mapEditableFields);
        }
        return null;
    }
    
    //Method to convert web content record to picklist values
    public void getPicklistFieldValues(list<Sobject> pLstCustomSettingFields){
        system.debug('****pLstCustomSettingFields' + pLstCustomSettingFields);
        String picklistValuesString ='';
        list<String> lstSelectOptionValues;
        
        //mapCustomFieldWithSelectList = new map<String , list<SelectOption>>();
        lstWrapper = new list<fieldWrapperClass>();
        for(Sobject objCustomSettingField : pLstCustomSettingFields){
            list<SelectOption> lstSelectOption = new list<SelectOption>();
            //lstSelectOption.add(new selectOption('--None--', '--None--'));
            if(String.ValueOf(objCustomSettingField.get('Picklist__c'))!=null && 
                String.ValueOf(objCustomSettingField.get('Picklist__c')).startsWith('Community_Web_Content__c.')){
                picklistValuesString = CommunityContentHelper.getContent(String.ValueOf(objCustomSettingField.get('acfComm__Picklist__c')));
                if(!String.IsBlank(picklistValuesString)){
                    lstSelectOptionValues = picklistValuesString.split(';');
                }
                for(String objSelectOptionValue : lstSelectOptionValues){
                    lstSelectOption.add(new selectOption(objSelectOptionValue, objSelectOptionValue));
                }
            }
            lstWrapper.add(new fieldWrapperClass(String.valueOf(objCustomSettingField.get('Field_API_Name__c')),lstSelectOption,''));
        }
    }
    
    public class wrapperSectionIdToObj{
        public String customSettingId{ get; set;}
        public list<wrapperEditableRecords> lstRecords { get; set;}
        
        public wrapperSectionIdToObj(String pCustomSettingId, list<wrapperEditableRecords> pLstRecords){
            customSettingId = pCustomSettingId;
            lstRecords = pLstRecords;
        }
    }
    
    public class wrapperEditableRecords{
        public Sobject objRecord{ get; set;}
        public boolean isEditable { get; set;}
        
        //Constructor
        public wrapperEditableRecords(Sobject pObjRecord, boolean pIsEditable){
            this.objRecord = pObjRecord;
            this.isEditable = pIsEditable;
        }
    }
    
    
    public class fieldWrapperClass{
        public String FieldApiName{ get; set;}
        public list<selectOption> lstSelectOption{ get; set;}
        public String SelectedValue{ get; set;}
        public fieldWrapperClass(String pFieldApiName, list<SelectOption> plstselectOption, String pSelectedValue){
            this.FieldApiName = pFieldApiName;
            this.lstSelectOption = plstselectOption;
            this.SelectedValue = pSelectedValue;
        }
    }
}//End Class