public with sharing class Profile_Personal_Subsection {
    public sObject objName { get; set; }

    private String sObjectName;
    public list<Sobject> lstDeleteRecords{get; set;}

    public String currentUserContactId;
    public String realtedRecordIdToDelete { get; set; }
    public String relatedRecordIdToEdit { get; set; }
    public map<String, list<sObject>> sectionIdToObjMap { get; set; }
    

    public boolean isEditMode { get; set;}
    public String recordMode { get; set; }
    public list<Sobject> customSettingFields { get; set ; }
    public list<acfComm__Profile_Personal_SubSection__c> lstSubsectionCustomSetting{ get; set; }
    
    public map<Sobject, list<Sobject>> mapSectionWithSubHeaderFields{ get; set; }
    public map<String, map<String, list<Sobject>>> mapSubsectionDetails{ get; set; }
    public set<String> setTotalFields{ get; set; }
    
    public list<acfComm__Profile_Personal__c> subSectionCustomSettings{ get; set; }
    public String queryStringForFields{ get; set;}
    
    public map<String, Sobject> mapCustomSettingNameWithObject{ get; set; }
    public map<String, Sobject> mapSubsectionWithFields { get; set; } 
    public boolean isSubsectionChecked{ get; set; }

    //Constructor
    public Profile_Personal_Subsection(ApexPages.StandardController stdController) 
    {
    	init();
    }//End Constructor

    public void init(){
    	//Variable Initialization
    	customSettingFields = new list<Sobject>();
    	lstDeleteRecords = new list<Sobject>();
    	mapSectionWithSubHeaderFields = new map<Sobject, list<Sobject>>();
    	lstSubsectionCustomSetting = new list<acfComm__Profile_Personal_SubSection__c>();
    	mapSubsectionDetails = new  map<String, map<String, list<Sobject>>>();
    	setTotalFields = new set<String>();
    	mapCustomSettingNameWithObject = new map<String, Sobject>();
    	acfComm__Profile_Personal_SubSection__c customSetting_Subsection = new acfComm__Profile_Personal_SubSection__c();
    	
    	list<sObject> sectionObj;
    	
    	if(isEditMode == null){
    		isEditMode = false;
    	}
    	if(recordMode == null){
    		recordMode = 'Read';
    	}
    	   
       currentUserContactId = getContactIdFromUser();
       sectionIdToObjMap = new map<String, list<sObject>>();
       map<String, list<sObject>> sectionIdToFieldsMap = new map<String, list<sObject>>();
       subSectionCustomSettings = getSubSectionCustomSetting();
       /*
       //Iterate Through custom setting
       for(acfComm__Profile_Personal__c subSectionCustomSetting : subSectionCustomSettings){
       		mapCustomSettingNameWithObject.put(String.ValueOf(subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c')).equalIgnorecase(),subSectionCustomSetting);
       }
       //get Custom setting for Subsection
       if(mapCustomSettingNameWithObject !=null && mapCustomSettingNameWithObject.containsKey('subsection')){
       		customSetting_Subsection = mapCustomSettingNameWithObject.get('subsection');
       }
       
       String queryStringForSubsectionCustomSetting = constructDynamicQueryForSubSectionCustomSetting(customSetting_Subsection.acfComm__Custom_Setting__c);
       lstSubsectionCustomSetting = Database.query(queryStringForSubsectionCustomSetting);
       
       for(Sobject objCustomSetting : lstSubsectionCustomSetting){
       		if(!mapSectionWithSubHeaderFields.containsKey(objSubsection)){
               mapSectionWithSubHeaderFields.put(objSubsection, new list<Sobject>());	
            }//End If
       }//End For
       */
       
        for(acfComm__Profile_Personal__c subSectionCustomSetting : subSectionCustomSettings){
            system.debug('subSectionCustomSetting.get()).toLowerCase()'+subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c'));
            if(String.ValueOf(subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c')).toLowerCase()=='subsection')
            {
            	String queryStringForSubsectionCustomSetting = constructDynamicQueryForSubSectionCustomSetting(subSectionCustomSetting.acfComm__Custom_Setting__c);
                lstSubsectionCustomSetting = Database.query(queryStringForSubsectionCustomSetting);
                for(acfComm__Profile_Personal_SubSection__c objSubsection : lstSubsectionCustomSetting){
                	
                    if(!mapSectionWithSubHeaderFields.containsKey(objSubsection)){
                    	mapSectionWithSubHeaderFields.put(objSubsection, new list<Sobject>());	
                    }//End If
                    
                    String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(objSubsection.acfComm__Custom_Setting__c);
                	list<sObject> customSettingSectionFields;
                	list<String> fieldAPINames;
                	customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                	
                	if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty()){
                        fieldAPINames = createListOfFieldAPINames(customSettingSectionFields, 'acfComm__Field_API_Name__c','acfComm__Privacy_Field_API__c');
                        if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        	setTotalFields.addAll(fieldAPINames);
                        }//End If
                        mapSectionWithSubHeaderFields.put(objSubsection, customSettingSectionFields);
                    }//End If
                }//End For
                
                 system.debug('***setTotalFields' + setTotalFields);
        		if(lstSubsectionCustomSetting != null){
        			queryStringForFields = constructDynamicQueryForFields(lstSubsectionCustomSetting.get(0).acfComm__Object__c, setTotalFields, lstSubsectionCustomSetting.get(0).Field_API_For_Contact_Id__c);
        		}//End If
        		
        		
        		sectionObj = getFieldDetails();
        		system.debug('**sectionObj' + sectionObj);
        		
        		
        		if(!sectionIdToObjMap.containsKey(String.valueof(subSectionCustomSetting.get('acfComm__Title__c')))){
        			sectionIdToObjMap.put(String.valueof(subSectionCustomSetting.get('acfComm__Title__c')), new list<Sobject>());
        		}//End If
        		if(sectionObj != null){
        			sectionIdToObjMap.put(String.valueof(subSectionCustomSetting.get('acfComm__Title__c')), sectionObj);
        			//objName = Profile_Personal_Subsection.createNewSobj(sObjectName);
        			objName = sectionObj.get(0);
        		}
        		system.debug('***mapSectionWithSubHeaderFields' + mapSectionWithSubHeaderFields);
            }//End If
        }//End For
    }
    
    public list<Sobject> getFieldDetails(){
    	list<Sobject> sectionDetails = Database.query(queryStringForFields);
    	return sectionDetails;
    }    
    
    // Instantiate an sObject with the type passed in as an argument at run time.
    public static sObject createNewSobj (String objName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        if (targetType == null) { return null; }
        
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

	//Fetch Custom Setting to get field custom Setting
	public String constructDynamicQueryForSubSectionCustomSetting(String customSettingName)
    {
    	String querySubsection = 'select Id, acfComm__Custom_Setting__c, acfComm__Custom_Setting_Type__c, acfComm__Object__c,'
                + 'acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Title__c, Field_API_For_Contact_Id__c,acfComm__Privacy_Subsection__c'
                + ' from ' + customSettingName + ' order by acfComm__Order__c';
       return querySubsection;
    }
	
    public String constructDynamicQueryForFieldsCustomSetting(String customSettingName)
    {
        String dynamicQuery = '';
        if(customSettingName != null){
            String fieldsToSearch = 'acfComm__Column_Span__c, acfComm__Defaut_Read_Only_Field_For_Record__c, acfComm__Field_API_Name__c, acfComm__Field_Name__c, acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Read_Only__c';
            dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + customSettingName + ' order by acfComm__Order__c';
        }//End If
        return dynamicQuery;
    }

    public String constructDynamicQueryForFields(String objName, Set<String> fields, String ConIdAPIName)
    {
    	system.debug('***fields' + fields);
        String dynamicQuery = '';
        String fieldsToSearch = convertListIntoFieldsToSearchString(fields);
        //dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\' limit 1';
        dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId  + '\'';
        System.debug('\n\n\nQuery String is: ' + dynamicQuery + '\n\n');
        return dynamicQuery;
    }

    public String convertListIntoFieldsToSearchString(Set<String> fields)
    {    
        String fieldsToSearch = '';
        for(String field : fields)
        {
            fieldsToSearch = fieldsToSearch + field + ', ';
        }
        fieldsToSearch = fieldsToSearch.removeEndIgnoreCase(', ');
        return fieldsToSearch;
    }

    public list<String> createListOfFieldAPINames(list<sObject> customSettingSectionFields, String fieldNameForAPIName,String fieldNameForPrivacyField)
    {   //objFieldList = new List<String> ();
        list<String> fieldAPINames = new list<String>();
        for(sObject customSettingSectionField : customSettingSectionFields)
        {
            fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
            fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForPrivacyField)));
            //objFieldList.add (String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
            //objFieldList.add (String.valueOf(customSettingSectionField.get(fieldNameForPrivacyField)));
        }
        return fieldAPINames;
    }

    public void EditSobjectRecord(){
    	//list<Sobject> sectionData = getFieldDetails();
    	
    	
    	//system.debug('****sectionData' + sectionData);
    	//if(sectionData != null){
    		//objName = sectionData.get(0);
    	//}
    	
    	recordMode ='Edit';
        isEditMode = true;
        system.debug('****objName' + objName);
       
        //return null;
    }
    
    public PageReference saveSobjectRecord(){
    	system.debug('****saveSobjectRecord');
    	//list<Sobject> sectionDetailsToUpdate = new list<Sobject>();
    	if(objName != null){
        	update objName;
        	recordMode = 'Read';
        	isEditMode = false;
        }
    	//for(Sobject objSec : mapSectionWithSubHeaderFields.keySet()){
    	//	sectionDetailsToUpdate.add(objSec);
    	//}
    	//system.debug('***sectionDetailsToUpdate' + sectionDetailsToUpdate);
       // 
        //if(sectionDetailsToUpdate != null){
    	//	update sectionDetailsToUpdate;
    	//}
         return null;
    }
    
    public PageReference cancel(){
        recordMode = 'Read';
        isEditMode = false;
        return null;
    }
}