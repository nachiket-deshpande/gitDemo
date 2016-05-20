public with sharing class ProfilePersonalUtil {
	
	public map<String, Sobject> mapReadModeFields;
	public map<String, Sobject> mapEditModeFields;
	public list<WrapperEditMode> lstWrapperEditMode;
	public map<String, list<sObject>> sectionIdToObjMap ;
	public list<acfComm__Profile_Personal__c> lstCustomSettingForRelatedList;
	public acfComm__Profile_Personal__c subSectionCustomSettingValue;
	
	public map<String, list<sObject>> sectionIdToFieldsMap;
	
	public integer recordCount;
	public ProfilePersonalUtil(){
		init();
	}
	
	private void init(){
		mapReadModeFields = new map<String, Sobject>();
		mapEditModeFields = new map<String, Sobject>();
		lstWrapperEditMode = new list<WrapperEditMode>();
		lstCustomSettingForRelatedList = new list<acfComm__Profile_Personal__c>();
		sectionIdToObjMap = new map<String, list<sObject>>();
		sectionIdToFieldsMap = new map<String, list<sObject>>();
	}
	
	public void getAllCustomSettings(String strCustomSetting, String currentUserContactId){
    	system.debug('--getAllCustomSettings---');
        list<acfComm__Profile_Personal__c> subSectionCustomSettings = acfComm__Profile_Personal__c.getall().values();
        for(acfComm__Profile_Personal__c subSectionCustomSetting : subSectionCustomSettings){
        	system.debug('---subSectionCustomSetting.get(acfComm__Custom_Setting_Type__c)---'+subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c'));
        	system.debug('--strCustomSetting---'+strCustomSetting);
            if(String.ValueOf(subSectionCustomSetting.get('acfComm__Custom_Setting_Type__c')).toLowerCase()==strCustomSetting)
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
                            String queryStringForFields = constructDynamicQueryForFields(subSectionCustomSetting.acfComm__Object__c, fieldAPINames, subSectionCustomSetting.Field_API_For_Contact_Id__c, currentUserContactId);
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
                    subSectionCustomSettingValue = subSectionCustomSetting;
                    system.debug('---subSectionCustomSettingValue---'+subSectionCustomSettingValue);
                    //subTabHTML = CreateHTMLForPage(subSectionCustomSetting, sectionIdToObjMap, sectionIdToFieldsMap);
                    //sObjectName=subSectionCustomSetting.acfComm__Object__c;
                    //objName = Profile_Personal_RelatedList_Compact.createNewSobj(sObjectName);
                    
                   
            }//End If
        }//End For
    }
    
    private String constructDynamicQueryForFieldsCustomSetting(String customSettingName)
    {
        String dynamicQuery = '';
        if(customSettingName != null){
            String fieldsToSearch = 'acfComm__Column_Span__c, acfComm__Defaut_Read_Only_Field_For_Record__c, acfComm__Field_API_Name__c, acfComm__Field_Name__c, acfComm__Order__c, acfComm__Privacy_Field_API__c, acfComm__Read_Only__c,acfComm__Read_Mode__c,acfComm__Edit_Mode__c';
            dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + customSettingName + ' order by acfComm__Order__c';
        }
        return dynamicQuery;
    }
    
    private list<String> createListOfFieldAPINames(list<sObject> customSettingSectionFields, String fieldNameForAPIName)
    {   
        list<String> fieldAPINames = new list<String>();
        for(sObject customSettingSectionField : customSettingSectionFields)
        {
            fieldAPINames.add(String.valueOf(customSettingSectionField.get(fieldNameForAPIName)));
        }
        return fieldAPINames;
    }
    
    private String constructDynamicQueryForFields(String objName, list<String> queryFields, String ConIdAPIName, String currentUserContactId)
    {
        String dynamicQuery = '';
        String fieldsToSearch = convertListIntoFieldsToSearchString(queryFields);
        //dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\' limit 1';
        dynamicQuery = 'Select ' + fieldsToSearch + ' from ' + objName + ' where ' + ConIdAPIName + '=\'' + currentUserContactId + '\'';
        System.debug('\n\n\nQuery String is: ' + dynamicQuery + '\n\n');
        return dynamicQuery;
    }
    
    private String convertListIntoFieldsToSearchString(list<String> queryFields)
    {    
        String fieldsToSearch = '';
        for(String field : queryFields)
        {
            fieldsToSearch = fieldsToSearch + field + ', ';
        }
        fieldsToSearch = fieldsToSearch.removeEndIgnoreCase(', ');
        return fieldsToSearch;
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