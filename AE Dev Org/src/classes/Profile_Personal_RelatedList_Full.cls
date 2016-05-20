public with sharing class Profile_Personal_RelatedList_Full {
	public String subTabHTML { get; set; }
    public sObject objName { get; set; }
    public List<String> objFieldList { get; set; }
    private String sObjectName;
    public list<Sobject> lstDeleteRecords{get; set;}

    public String currentUserContactId;
    public String realtedRecordIdToDelete { get; set; }
    public String relatedRecordIdToEdit { get; set; }
    public map<String, list<sObject>> sectionIdToObjMap { get; set; }
    public map<String, Sobject> mapRecordIdWithData { get; set;}
    public map<String, Sobject> mapRecordNumWithData { get; set;}
    public Sobject objEditRecord { get; set; }
    public boolean isEditMode { get; set;}
    public String recordMode { get; set; }
    list<Sobject> customSettingFields { get; set ; }
    
    public map<String, Sobject> mapReadModeFields{ get; set;}
	public map<String, Sobject> mapEditModeFields{get; set;}
	public list<WrapperEditMode> lstWrapperEditMode{ get ; set; }
	//public list<Sobject> lstFieldLabels{ get ; set ;}
	public integer recordCount{get; set; }
	public list<acfComm__Profile_Personal__c> lstCustomSettingForRelatedList { get; set; }

    //Constructor
    public Profile_Personal_RelatedList_Full(ApexPages.StandardController stdController) 
    {
    	init();
    }//End Constructor

    public void init(){
    	customSettingFields = new list<Sobject>();
    	mapReadModeFields = new map<String, Sobject>();
		mapEditModeFields = new map<String, Sobject>();
		lstWrapperEditMode = new list<WrapperEditMode>();
		lstCustomSettingForRelatedList = new list<acfComm__Profile_Personal__c>();
		//lstFieldLabels = new list<Sobject>();
    	
    	lstDeleteRecords = new list<Sobject>();
    	if(isEditMode == null){
    		isEditMode = false;
    	}
    	if(recordMode == null){
    		recordMode = 'Read';
    	}
        mapRecordIdWithData = new map<String, Sobject>();
        mapRecordNumWithData = new map<String, Sobject>();
        currentUserContactId = getContactIdFromUser();
        sectionIdToObjMap = new map<String, list<sObject>>();
        map<String, list<sObject>> sectionIdToFieldsMap = new map<String, list<sObject>>();
        list<acfComm__Profile_Personal__c> subSectionCustomSettings = getSubSectionCustomSetting();
        for(acfComm__Profile_Personal__c subSectionCustomSetting : subSectionCustomSettings){
            system.debug('subSectionCustomSetting.get()).toLowerCase()'+subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c'));
            if(String.ValueOf(subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c')).toLowerCase()=='related list full')
            {
                String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(subSectionCustomSetting.acfComm__Custom_Setting__c);
                System.debug('\n\n\nQuery String is: ' + queryStringForCustomSettingFields);
                    
                list<sObject> customSettingSectionFields;
                list<String> fieldAPINames;
                list<sObject> sectionObj;
                integer rownum = 1;
                customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                system.debug('customSettingSectionFields====>> '+customSettingSectionFields);
                
                    if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty()){
                        fieldAPINames = createListOfFieldAPINames(customSettingSectionFields, 'acfComm__Field_API_Name__c');
                        if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                            String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting.acfComm__Object__c, fieldAPINames, subSectionCustomSetting.Field_API_For_Contact_Id__c);
                            system.debug('queryStringForFields===>>> '+queryStringForFields);
                            sectionObj = Database.query(queryStringForFields);
                            
                            for(Sobject objField : customSettingSectionFields){
								if(objField.get('acfComm__Read_Mode__c') == true){
									mapReadModeFields.put(String.valueof(objField.get('acfComm__Field_API_Name__c')), objField);
								}
								if(objField.get('acfComm__Edit_Mode__c') == true){
									mapEditModeFields.put(String.valueof(objField.get('acfComm__Field_API_Name__c')),objField);
									lstWrapperEditMode.add(new WrapperEditMode(String.valueof(objField.get('acfComm__Field_Name__c')), String.valueof(objField.get('acfComm__Field_API_Name__c'))));
									//lstFieldLabels.add(objField);
								}
							}
							recordCount = lstWrapperEditMode.size();
                           // sectionIdToFieldsMap.put(subSectionCustomSetting.Id, customSettingSectionFields);
                            sectionIdToFieldsMap.put(subSectionCustomSetting.Id, mapReadModeFields.values());
                        }
                    }
                    lstCustomSettingForRelatedList.add(subSectionCustomSetting);
                    sectionIdToObjMap.put(String.valueof(subSectionCustomSetting.get('acfComm__Title__c')), sectionObj);
                    subTabHTML = CreateHTMLForPage(subSectionCustomSetting, sectionIdToObjMap, sectionIdToFieldsMap);
                    sObjectName=subSectionCustomSetting.acfComm__Object__c;
                    objName = Profile_Personal_RelatedList_Compact.createNewSobj(sObjectName);
                    
                   
            }//End If
        }//End For
    }
    
    public static sObject createNewSobj (String objName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        if (targetType == null) { return null; }
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject();
    }
    public String getContactIdFromUser()
    {
        User currentUser = [Select ContactId from User u where Id=:UserInfo.getUserId() limit 1];
        return currentUser.ContactId;
    }

    public list<acfComm__Profile_Personal__c> getSubSectionCustomSetting()
    {
        return [select Id, acfComm__Custom_Setting__c, acfComm__Custom_Setting_Type__c, acfComm__Object__c, 
                acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Title__c, Field_API_For_Contact_Id__c
                from acfComm__Profile_Personal__c order by acfComm__Order__c];
    }

    public String constructDynamicQueryForFieldsCustomSetting(String customSettingName)
    {
        String dynamicQuery = '';
        if(customSettingName != null){
            String fieldsToSearch = 'acfComm__Column_Span__c, acfComm__Defaut_Read_Only_Field_For_Record__c, acfComm__Field_API_Name__c, acfComm__Field_Name__c, acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Read_Only__c,acfComm__Read_Mode__c,acfComm__Edit_Mode__c';
            dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + customSettingName + ' order by acfComm__Order__c';
        }
        return dynamicQuery;
    }

    public String constructDynamicQueryForFields(String objName, list<String> fields, String ConIdAPIName)
    {
        String dynamicQuery = '';
        String fieldsToSearch = convertListIntoFieldsToSearchString(fields);
        //dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\' limit 1';
        dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\'';
        System.debug('\n\n\nQuery String is: ' + dynamicQuery + '\n\n');
        return dynamicQuery;
    }

    public String convertListIntoFieldsToSearchString(list<String> fields)
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
    {   objFieldList = new List<String> ();
        list<String> fieldAPINames = new list<String>();
        for(sObject customSettingSectionField : customSettingSectionFields)
        {
            fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
            objFieldList.add (String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
        }
        return fieldAPINames;
    }

    public String CreateHTMLForPage(sObject subSection,  map<String, list<sObject>> sectionIdToObjMap, map<String, list<sObject>> sectionIdToFieldsMap)
    {
        String html = '';    
        list<sObject> obj = sectionIdToObjMap.get(String.ValueOf(subSection.get('acfComm__Title__c')));
        customSettingFields = sectionIdToFieldsMap.get(String.ValueOf(subSection.get('Id')));
        //html = html + '<div><b>'+subSection.get('acfComm__Title__c')+'</b><hr/></div>';
        //system.debug('\n\n\n'+subSection.get('acfComm__Custom_Setting_Type__c')+'\n\n\n');
        integer rownum = 1;
        
        for(Sobject objSobject : obj){
        	String key = String.valueof(rownum) + system.now();
        	key= key.replaceAll(' ', '');
        	mapRecordNumWithData.put(key, objSobject);
        	rownum++;
        }
        if(obj != null || customSettingFields != null){
            html = html + createRelatedListCompactHTML(subSection,customSettingFields, mapRecordNumWithData,recordMode);
        }
        return html;
    }

    public String createRelatedListCompactHTML(Sobject subSection ,list<sObject> customSettingFields, map<String, sObject> RelatedListData, String pMode)
    {
        Integer rowNum = 1;
        integer colspan = 0;
        String html = '<div class="classHeader">'+subSection.get('acfComm__Title__c')+'</div>';
        html = html + '<table class="profileRealtedListFull"><tr>';
         if(pMode == 'Edit'){
         	 html = html +'<td>Action</td>';
         }
        //Create Html for Heading column
        for(integer i = 0 ; i < customSettingFields.size() ; i++){
          colspan = integer.valueof(customSettingFields[i].get('acfComm__Column_Span__c'));
            html = html +'<td colspan="'+ colspan +'">'+ String.valueOf(customSettingFields[i].get('acfComm__Field_Name__c')) + '</td>';
        }//End For
        html = html +'</tr>';
        
        //Iterate through map of records to get all the field values
        for(String objRelatedData : RelatedListData.keyset()){
            html = html +'<tr>';
            if(pMode == 'Edit'){
                html = html+'<td colspan="'+ colspan +'">' + '<a class= "deleteLink" record-Id= '+ objRelatedData.replaceAll(' ','') +' style="color: blue; cursor: hand;cursor: pointer;">delete</a></td>';
            }
            for(integer j = 0 ; j < customSettingFields.size() ; j++){
                String fieldValue = String.valueOf(customSettingFields[j].get('acfComm__Field_API_Name__c'));
                if(RelatedListData.get(objRelatedData).get(fieldValue) == null){
                    html = html + '<td/>';
                }else{
                    html = html + '<td colspan="'+ colspan +'">'+ RelatedListData.get(objRelatedData).get(fieldValue) + '</td>';
                }//End Else
            }//End For
            html = html +'</tr>';
        }//End For
        html = html + '</table>';
        return html;
    }
    
    public void deleteSobjectRecord(){
        system.debug('Record Id to Delete ===>> '+realtedRecordIdToDelete);
        if(realtedRecordIdToDelete != null || realtedRecordIdToDelete != '') {
            Sobject delRecord = mapRecordNumWithData.get(realtedRecordIdToDelete);
            if(delRecord.get('id') != null){
            	 lstDeleteRecords.add(delRecord);
            }
 			mapRecordNumWithData.remove(realtedRecordIdToDelete);
 			//subTabHTML = createRelatedListCompactHTML(customSettingFields, mapRecordNumWithData,recordMode);
        	 if(lstCustomSettingForRelatedList != null){
        	     subTabHTML = createRelatedListCompactHTML(lstCustomSettingForRelatedList[0], customSettingFields, mapRecordNumWithData,recordMode);
        	 }
        }
    }
    
    public void EditSobjectRecord(){
    	recordMode ='Edit';
    	//subTabHTML = createRelatedListCompactHTML(customSettingFields, mapRecordNumWithData,recordMode);
        //init();
        isEditMode = true;
        if(lstCustomSettingForRelatedList != null){
        	subTabHTML = createRelatedListCompactHTML(lstCustomSettingForRelatedList[0], customSettingFields, mapRecordNumWithData,recordMode);
        }
        
    }
    
    public PageReference saveSobjectRecord(){
    	list<Sobject> lstInsert = new list<Sobject>();
    	list<Sobject> lstUpdate = new list<Sobject>();
        if (mapRecordNumWithData != null) {
        	for(String objInsertRecord : mapRecordNumWithData.keyset()){
        		if(mapRecordNumWithData.get(objInsertRecord).get('id') == null){
        			lstInsert.add(mapRecordNumWithData.get(objInsertRecord));
        		}
        		else{
        			lstUpdate.add(mapRecordNumWithData.get(objInsertRecord));
        		}
        	}
        	try {
	        	if(lstInsert.size() > 0){
	        		insert lstInsert;
	        	}
        	}
        	catch(Exception e) {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Insert failed.');
                 ApexPages.addMessage(myMsg);
          }
        	try {
	        	if(lstUpdate.size() > 0){
	        		update lstUpdate;
	        	}
        	}
          catch(Exception e) {
	             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
	             ApexPages.addMessage(myMsg);
	      }
	      try {
	        	if(lstDeleteRecords.size() > 0){
	        		delete lstDeleteRecords;
	        	}
	      }
	      catch(Exception e) {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Delete failed.');
                 ApexPages.addMessage(myMsg);
          }
             objName = null;
             recordMode = 'Read';
             isEditMode = false;
             init();
        }
        return null;
    }
    
    public PageReference cancel(){
        recordMode = 'Read';
        isEditMode = false;
        init();
        return null;
    }
    
    public Pagereference saveSobjectRecordToList(){
    	system.debug('****objName' + objName);
        if (objName!=null) {
            String key = String.valueof(mapRecordNumWithData.size() + 1) + system.now();
            key = key.replaceAll(' ','');
            mapRecordNumWithData.put(key, objName);
            objName = null;
            objName = Profile_Personal_RelatedList_Compact.createNewSobj (sObjectName);
            recordMode = 'Edit';
            isEditMode = true;
            //subTabHTML = createRelatedListCompactHTML(customSettingFields, mapRecordNumWithData, recordMode);
             if(lstCustomSettingForRelatedList != null){
        	     subTabHTML = createRelatedListCompactHTML(lstCustomSettingForRelatedList[0], customSettingFields, mapRecordNumWithData,recordMode);
        	}
        }
    	return null;
    }
    
    public class WrapperEditMode{
    	public String fieldLabel{ get; set; }
    	public String fieldApiName { get; set;}
    	
    	public WrapperEditMode(String pFieldLabel, String pFieldAPIName){
    		fieldLabel = pFieldLabel;
    		fieldApiName = pFieldAPIName;
    	}
    }
    
}