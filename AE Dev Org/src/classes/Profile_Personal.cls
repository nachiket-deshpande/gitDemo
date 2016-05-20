public with sharing class Profile_Personal {

	public String subTabHTML { get; set; }
    public sObject objName { get; set; }
    public List<String> objFieldList { get; set; }
    private String sObjectName;
    public list<Sobject> lstDeleteRecords{get; set;}

    public String currentUserContactId;
    public String realtedRecordIdToDelete { get; set; }
    public String relatedRecordIdToEdit { get; set; }
    public map<String, list<sObject>> sectionIdToObjMap { get; set; }
   // public map<String, Sobject> mapRecordIdWithData { get; set;}
    public map<String, Sobject> mapRecordNumWithData { get; set;}
    public Sobject objEditRecord { get; set; }
    public boolean isEditMode { get; set;}
    public String recordMode { get; set; }
    public list<Sobject> customSettingFields { get; set ; }
    public list<acfComm__Profile_Personal_SubSection__c> lstSubsectionCustomSetting{ get; set; }
    
    public map<String, list<Sobject>> mapSectionWithSubHeaderFields{ get; set; }
    public map<String, map<String, list<Sobject>>> mapSubsectionDetails{ get; set; }
    public set<String> setTotalFields{ get; set; }
    public String HtmlForEditMode { get; set; }
    public map<String, list<Sobject>> sectionIdToFieldsMap { get; set; }
    public list<acfComm__Profile_Personal__c> TwoColumnsubSectionCustomSettings { get; set; }
    public list<WrapperFields> lstWrapperFields{ get; set; }

    //Constructor
    public Profile_Personal(ApexPages.StandardController stdController) 
    {
    	//User u = stdController.getRecord();
    	init();
    }//End Constructor

    public void init(){
    	customSettingFields = new list<Sobject>();
    	lstDeleteRecords = new list<Sobject>();
    	//lstCustomSettingForCompact = new list<acfComm__Profile_Personal__c>();
    	if(isEditMode == null){
    		isEditMode = false;
    	}
    	if(recordMode == null){
    		recordMode = 'Read';
    	}
    	system.debug('IsEditMode***' + isEditMode);
        //mapRecordIdWithData = new map<String, Sobject>();
        mapRecordNumWithData = new map<String, Sobject>();
        currentUserContactId = getContactIdFromUser();
        sectionIdToObjMap = new map<String, list<sObject>>();
        sectionIdToFieldsMap = new map<String, list<sObject>>();
        TwoColumnsubSectionCustomSettings = new list<acfComm__Profile_Personal__c>();
        lstWrapperFields = new list<WrapperFields>();
        list<acfComm__Profile_Personal__c> subSectionCustomSettings = getSubSectionCustomSetting();
      
        for(acfComm__Profile_Personal__c subSectionCustomSetting : subSectionCustomSettings){
            if(String.ValueOf(subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c')).toLowerCase()=='2 column')
            {
                
                String queryStringForCustomSettingFields = constructDynamicQueryForFieldsCustomSetting(subSectionCustomSetting.acfComm__Custom_Setting__c);
                System.debug('\n\n\nQuery String is: ' + queryStringForCustomSettingFields);
                    
                list<Sobject> customSettingSectionFields;
                list<String> fieldAPINames;
                list<sObject> sectionObj;
                integer rownum = 1;
                customSettingSectionFields = Database.query(queryStringForCustomSettingFields);
                if(customSettingSectionFields != null && !customSettingSectionFields.isEmpty()){
                    fieldAPINames = createListOfFieldAPINames(customSettingSectionFields, 'acfComm__Field_API_Name__c');
                    if(fieldAPINames != null && !fieldAPINames.isEmpty()){
                        String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting.acfComm__Object__c, fieldAPINames, subSectionCustomSetting.Field_API_For_Contact_Id__c);
                        sectionObj = Database.query(queryStringForFields);
                        sectionIdToFieldsMap.put(subSectionCustomSetting.Id, customSettingSectionFields);
                     }
                 }
                    
                 for(Sobject objfield : customSettingSectionFields){
                     lstWrapperFields.add(new WrapperFields(String.valueof(objfield.get('acfComm__Field_Name__c')),String.valueof(objfield.get('acfComm__Field_API_Name__c')),String.valueof(objfield.get('acfComm__Privacy_Field_API__c'))));
                 }
                 TwoColumnsubSectionCustomSettings.add(subSectionCustomSetting);
                 sectionIdToObjMap.put(String.valueof(subSectionCustomSetting.get('acfComm__Title__c')), sectionObj);
                 subTabHTML = CreateHTMLForPage(subSectionCustomSetting, sectionIdToObjMap, sectionIdToFieldsMap);
                 sObjectName = subSectionCustomSetting.acfComm__Object__c;
                 objName = Profile_Personal.createNewSobj(sObjectName);
                 for(String objRecord : sectionIdToObjMap.keySet()){
                     objName = sectionIdToObjMap.get(objRecord).get(0);
                 }  
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

	//Fetch Custom Setting to get field custom Setting
	public String constructDynamicQueryForSubSectionCustomSetting(String customSettingName)
    {
    	String querySubsection = 'select Id, acfComm__Custom_Setting__c, acfComm__Custom_Setting_Type__c, acfComm__Object__c,'
                + 'acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Title__c, Field_API_For_Contact_Id__c'
                + ' from ' + customSettingName + ' order by acfComm__Order__c';
                System.debug('*****querySubsection' + querySubsection);
       return querySubsection;
    }
	
    public String constructDynamicQueryForFieldsCustomSetting(String customSettingName)
    {
        String dynamicQuery = '';
        if(customSettingName != null){
            String fieldsToSearch = 'acfComm__Column_Span__c, acfComm__Defaut_Read_Only_Field_For_Record__c, acfComm__Field_API_Name__c, acfComm__Field_Name__c, acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Read_Only__c';
            dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + customSettingName + ' order by acfComm__Order__c';
        }
        return dynamicQuery;
    }

    public String constructDynamicQueryForFields(String objName, list<String> fields, String ConIdAPIName)
    {
        String dynamicQuery = '';
        String fieldsToSearch = convertListIntoFieldsToSearchString(fields);
        //dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\' limit 1';
        dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId  + '\'';
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

    public String CreateHTMLForPage(Sobject subSection ,map<String, list<sObject>> sectionIdToObjMap, map<String, list<sObject>> sectionIdToFieldsMap)
    {
        String html = '';   
		sObject obj = sectionIdToObjMap.get(String.ValueOf(subSection.get('acfComm__Title__c'))).get(0);
		list<Sobject> customSettingFields = sectionIdToFieldsMap.get(String.ValueOf(subSection.get('Id')));
		html = html + '<div class="profile_section"><div class="profile_header">'+subSection.get('acfComm__Title__c')+'</div>';
		if(obj != null || customSettingFields != null){
			html = html + create2ColumnHTML(obj, customSettingFields,sectionIdToObjMap);
		}
        return html;
    }

    public String create2ColumnHTML(sObject obj, list<sObject> customSettingFields, map<String, list<Sobject>> sectionIdToObjMap)
	{
		String html = '<div class="profile_data"><table>';
		for(String objRecord : sectionIdToObjMap.keySet()){
			list<Sobject> lstobjRecords = sectionIdToObjMap.get(objRecord);
			Integer rowNum = 1;
			for(Sobject objRec : lstobjRecords){
				for(sObject field : customSettingFields)
				{ 
					integer colspan = 0;
					if(field.get('acfComm__Column_Span__c')!= null){
						colspan = integer.valueof(field.get('acfComm__Column_Span__c'));
					}
					
					if(math.MOD(rowNum, 2)!=0){	
					html = html + '<tr><td colspan="'+ colspan +'">'+ objRec.get(String.valueOf(field.get('acfComm__Field_API_Name__c')))+'</td>';
				}
					else{
						if(obj.get(String.valueOf(field.get('acfComm__Field_API_Name__c'))) != null){
							html = html + '<td colspan="'+ colspan +'">'+ objRec.get(String.valueOf(field.get('acfComm__Field_API_Name__c')))+'</td></tr>';
						}
					}
					rowNum++;
				 }	
			 }
		}
		html = html + '</table></div></div>';
		return html;
	}
    
    public Pagereference EditSobjectRecord(){
    	recordMode ='Edit';
        isEditMode = true;
        return null;
    }
    
    public PageReference saveSobjectRecord(){
    	try {
	        if(objName != null){
	        	update objName;
	        	recordMode = 'Read';
	        	isEditMode = false;
	        	subTabHTML = CreateHTMLForPage(TwoColumnsubSectionCustomSettings.get(0), sectionIdToObjMap, sectionIdToFieldsMap);
	        }
    	}
      catch(Exception e) {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
             ApexPages.addMessage(myMsg);
      }
         return null;
    }
    
    public PageReference cancel(){
        recordMode = 'Read';
        isEditMode = false;
        subTabHTML = CreateHTMLForPage(TwoColumnsubSectionCustomSettings.get(0), sectionIdToObjMap, sectionIdToFieldsMap);
        return null;
    }
    public class WrapperFields{
    	public String fieldLabel{ get; set; }
    	public String fieldAPIName{ get; set; }
    	public String PrivacyFieldAPI{ get; set; }
    	
    	public WrapperFields(String pFieldLabel, String pFieldAPIName,String pPrivacyFieldAPI){
    		this.fieldLabel = pFieldLabel;
    		this.fieldAPIName = pFieldAPIName;
    		this.PrivacyFieldAPI = pPrivacyFieldAPI;
    	}
    	
    }
}