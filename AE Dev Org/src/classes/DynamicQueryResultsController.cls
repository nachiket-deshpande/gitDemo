public without sharing class DynamicQueryResultsController 
{
	private sObject queriedFields {get; set;}	           //Fields to be queried
	public List<sObject> queriedSourceRecords {get;set;}
	private List<helperClass> queriedSourceWrapperRecords {get;set;}
	public String queryString {get; set;}
	public String jsonStr {get; set;}
	private Map<String, list<String>> labelApiNameMap {get; set;}
	private Map<String, String> apiNameLabelMap {get; set;}
//	public sObject resultObject {get; set;}
    private boolean useSosl {get; set;}
    private String soslString {get; set;}
	
	public String sourceObjectName {get; set;}
//	public String resultObjectName {get; set;}
	
	private String fieldsToDisplay {get; set;}
	public List<String> sourceObjectFields {get; set;}
	private String staticWhere { get; set; }
	
	private String fieldsString {get; set;}
	private String filterString {get; set;}
	private String sortStr {get; set;}
	private List<String> labelList {get; set;}
		
	private final String CustomSettingName = 'acfcomm__DynamicQueryFields__c';
	
	//default custom setting record
	private String CustomSettingRecordName {get; set;}
	private String nameSpace {get; set;}
	
	//default View
	private String viewName {get; set;}
	
	private Integer pageNumber {get; set;}
	private Boolean pageNumberProvided {get; set;}
	private Integer positionOnPage {get; set;}
	private Integer pageSize {get; set;}
	private Integer offset {get; set;}
	
	private class helperClass 
	{
		private sObject sObj {get; set;}
		
		private list<String> fields = new list<String>();
		private map<String, String> socialIconURLMap = new map<String, String>();

		private Integer pageNumber = 0;
		private Integer positionOnPage = 0;
		
		public helperClass(sObject so, list<String> fieldValues,
			map<String, String> socialIconURLMapValues,
			Integer pn, Integer pos)
		{
			sObj = so;
			pageNumber = pn;
			positionOnPage = pos;
			fields = fieldValues;
			socialIconURLMap = socialIconURLMapValues;
		}
	}
	
	public DynamicQueryResultsController()
	{
		//Initialize variables
		
		//default custom setting record
		CustomSettingRecordName = 'Donations';
		nameSpace = '';
		
		//default View
		viewName = 'ListView__c';
		
		pageNumber = 1;
		pageNumberProvided = false;
		positionOnPage = 0;
		pageSize = 20;
		offset = 0; 
	
	
		labelApiNameMap = new Map<String, list<String>>();
		apiNameLabelMap = new Map<String, String>();
		labelList = new List<String>();
		filterString = '';
		useSosl = false;
		
			
		if(ApexPages.currentPage().getParameters().get('name') != null && ApexPages.currentPage().getParameters().get('name') != '')
            CustomSettingRecordName = ApexPages.currentPage().getParameters().get('name');
            
        if(ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '')
        {
   			String tmpStr = nameSpace + ApexPages.currentPage().getParameters().get('view') + 'View__c';
        	
        	Map<String, Schema.SObjectField> customSettingFields = Schema.getGlobalDescribe().get(CustomSettingName).getDescribe().fields.getMap(); 

        	//check if ViewName is part of the Custom Setting
    		if(customSettingFields.containsKey(tmpStr)) 
				viewName = tmpStr;               
        }
                      	
        if(ApexPages.currentPage().getParameters().get('pagesize') != null && ApexPages.currentPage().getParameters().get('pagesize') != '')
        {
        	if (Integer.valueOf(ApexPages.currentPage().getParameters().get('pagesize')) > 0)
            	pageSize = Integer.valueOf(ApexPages.currentPage().getParameters().get('pagesize'));
        }
        
        if(ApexPages.currentPage().getParameters().get('pagenumber') != null && ApexPages.currentPage().getParameters().get('pagenumber') != '')
        {
        	if (Integer.valueOf(ApexPages.currentPage().getParameters().get('pagenumber')) > 0)   
           	{
           		pageNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('pagenumber'));
           		pageNumberProvided = true;
           	}
        }
                
    	offset = pageSize * (pageNumber-1);   
		
		if(ApexPages.currentPage().getParameters().get('q') != null && ApexPages.currentPage().getParameters().get('q') != '')
		{
			soslString = ApexPages.currentPage().getParameters().get('q');		
            useSosl = true;
		}
		
		System.debug('\n\n\n33333333333333333333333333333\n\n\n');
		
		queriedSourceRecords = new List<sObject>(); 
		queriedSourceWrapperRecords = new List<helperClass>(); 
//		resultObjectFields = new List<String>();
		
		//instantiate new Custom Setting record
		Schema.SObjectType targetType1 = Schema.getGlobalDescribe().get(CustomSettingName);
   		Sobject queriedFields = targetType1.newSObject();
   				
   		System.debug('\n\n\n3aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n\n');
   				
		queriedFields = findQueriedSourceRecords();
		
		
		System.debug('queriedFields****' + queriedFields);
		
		convertQueriedRecordsToWrapperClass();
		
		System.debug('queriedSourceWrapperRecords***' + queriedSourceWrapperRecords);
		
		//if(queriedSourceWrapperRecords.size()>0) System.debug('\n\n\n'+queriedSourceWrapperRecords[0].sobj+'\n\n\n');

		//jsonStr = JSON.serialize(queriedSourceRecords);
		jsonStr = JSON.serialize(queriedSourceWrapperRecords); 
		
		System.debug('\n\n\n'+jsonStr+'\n\n\n');

		jSonStr = replaceApiNamesWithLabels(jsonStr);
		
		system.debug('\n\n\n sourceObjectName: '+sourceObjectName+'\n\n\n');
		system.debug('\n\n\n CustomSettingRecordName: '+CustomSettingRecordName+'\n\n\n');

		jSonStr = jSonStr.replace(sourceObjectName, CustomSettingRecordName);
				
		System.debug('\n\n\nAfter findqueriedSourceRecords\n\n\n');
		
		System.debug('\n\n\nqueriedFields are: ' + queriedFields);
				
		//instantiate new Result Object record
/*		resultObjectName = String.valueOf(queriedFields.get('ResultObjectName__c'));
		System.debug('\n\n\nresultObjectName is: ' + resultObjectName + '\n\n\n');
	
		Schema.SObjectType targetType2 = Schema.getGlobalDescribe().get(resultObjectName); 
        resultObject = targetType2.newSObject();


   		System.debug('\n\n\nresultObject is: ' + resultObject + '\n\n\n');
*/   	
   		String sourceObjectFieldsString = String.valueOf(queriedFields.get('SourceObjectFields__c'));
   		//String resultFieldsString = String.valueOf(queriedFields.get('ResultObjectFields__c'));
   	   		
   	   	sourceObjectFieldsString = sourceObjectFieldsString.replaceAll(' ', '');	
   	    sourceObjectFields = sourceObjectFieldsString.split(',');
   		
/* 		resultFieldsString = resultFieldsString.replaceAll(' ', '');
   		resultObjectFields = resultFieldsString.split(',');
   		
   		Integer sourceFieldCount = sourceObjectFields.size();
   		Integer resultFieldCount = resultObjectFields.size();
   		
   		Integer i=0;
   		while (i<sourceFieldCount && i<resultFieldCount)
   		{
   			System.debug('\n\n\nsourceFieldName['+i+'] is: ' + sourceObjectFields[i] + '\n\n\n');
   			System.debug('\n\n\nresultFieldName['+i+'] is: ' + resultObjectFields[i] + '\n\n\n');
   			
   			if (sourceObjectFields[i]!='')
   			{
   				System.debug('\n\n\nIn outer if statement\n\n\n');
   				
   				if (String.valueOf(queriedSourceRecord).contains(sourceObjectFields[i]))
   				{
   					System.debug('\n\n\nIn inner if statement\n\n\n');
   					
   					String resultFieldValue = String.valueOf(queriedSourceRecord.get(sourceObjectFields[i]));   			
   				
	   				if (resultObjectFields[i]!='') 
	   				{	   					
	   					System.debug('\n\n\nresultObject.put(resultObjectFields[i], resultFieldValue) is: ' + resultObjectFields[i] + ', ' + resultFieldValue + '\n\n\n');
	   					resultObject.put(resultObjectFields[i], resultFieldValue);
	   				}
   				}
   			}
   				
   			i++;
   		}
   		
   		System.debug('\n\n\nresultObject is: ' + resultObject + '\n\n\n');
   	   	*/
	}
	
    
	private void getFields(String customSettingName, String CustomSettingRecordName)
	{
		System.debug('\n\n\nIn getFields\n\n\n');
		
		String queryStr = 'Select SourceObjectName__c, SourceObjectFields__c, Static_Where__c, Privacy_Fields__c, Social_Icon_Map__c, ' + viewName + ' from ' + customSettingName + ' where Name=\'' + CustomSettingRecordName + '\''; 
	
		System.debug('\n\n\nqueryStr is: ' + queryStr);
		
		queriedFields = Database.query(queryStr);	
		
		System.debug('\n\n\nquriedFields are: ' + queriedFields);
		
		// Privacy setup
		// Query object for privacy fields
		// create map of fieldAPIName to privacyFieldValue
		// if privacyFieldValue == true dont include in query string

		buildMaps(String.valueOf(queriedFields.get('SourceObjectFields__c')));
		
		//fieldsToDisplay = String.valueOf(queriedFields.get(viewName));
		fieldsToDisplay = getFieldsToDisplay();

		staticWhere = String.valueOf(queriedFields.get('Static_Where__c'));
	}

	private String getFieldsToDisplay()
	{
		System.debug('\n\n\nIn getFieldsToDisplay\n\n\n');
		String fieldsTD = '';
		fieldsTD = String.valueOf(queriedFields.get(viewName));
		Map<String, String> socialIconMap = createCustomSettingMap(String.valueOf(queriedFields.get('Social_Icon_Map__c')));
		system.debug('\n\n socialIconMap: '+socialIconMap+'\n\n');
		for(String socialIconField : socialIconMap.keySet())
		{
			fieldsTD = fieldsTD + ', ' + socialIconField;
		}

		Map<String, String> privacyMap = createCustomSettingMap(String.valueOf(queriedFields.get('Privacy_Fields__c')));
		for(String privacyField : privacyMap.values())
		{
			fieldsTD = fieldsTD + ', ' + privacyField;
		}
		// hard code some fields based on object
		if(String.valueOf(queriedFields.get('SourceObjectName__c')).toLowerCase()=='user')
		{
			fieldsTD = fieldsTD + ', FullPhotoUrl';
		}
		return fieldsTD;
	}

	private Map<String, String> createCustomSettingMap(String s)
	{
		System.debug('\n\n\nIn createCustomSettingMap\n\n\n');
		Map<String, String> csMap = new Map<String, String>();
		system.debug('\n\n'+s+'\n\n');
		if(s!=null && s.length()>0)
		{
			List<String> mappingPairs = s.split(',');

			if (mappingPairs.size()>0)
			{
				for (String pair : mappingPairs)
				{
					List<String> splitPair = pair.split('=', 2);
					String fieldAPI = splitPair[0];
					String privacyFieldAPI = splitPair[1];

					csMap.put(fieldAPI, privacyFieldAPI);
				}
			}
		}
		return csMap;
	}
	
	private void buildMaps(String fieldMapping)
	{
		System.debug('\n\n\nIn Build Maps\n\n\n');
		
		labelApiNameMap = new Map<String, list<String>>();
		apiNameLabelMap = new Map<String, String>();
		
   	   	fieldMapping = fieldMapping.replaceAll(' ', '');	
		
		List<String> mappingPairs = fieldMapping.split(';');
		
		fieldsString = '';
		
		//populate Label to API Name Map and API Name to Label Map
		if (mappingPairs.size()>0)
		{
			for (String pair : mappingPairs)
			{
				List<String> splitPair = pair.split('=');
				
				if (splitPair.size()==2)
				{
					String label = splitPair[0];
					String apiNames = splitPair[1];

					list<String> apiNameList =  new list<String>();
					if(apiNames.contains(','))
					{
						list<String> splitAPIName = apiNames.split(',');
						for(String apiName : splitAPIName)
						{
							apiNameList.add(apiName);	
							apiNameLabelMap.put(apiName, label);
							fieldsString += ', ' + apiName;
						}
					}
					else
					{
						apiNameList.add(apiNames);	
						apiNameLabelMap.put(apiNames, label);
						fieldsString += ', ' + apiNames;
					}
					labelApiNameMap.put(label, apiNameList);
					
							
					labelList.add(label);
				} 
			}
		}
		
		System.debug('\n\n\nlabelApiNameMap is: ' + labelApiNameMap + '\n\n\n');
		System.debug('\n\n\napiNameLabelMap is: ' + apiNameLabelMap + '\n\n\n');
		System.debug('\n\n\nfieldsString is: ' + fieldsString + '\n\n\n');
		System.debug('\n\n\nlabelList is: ' + labelList + '\n\n\n');
	}
	
	private String replaceApiNamesWithLabels(String jStr)
	{
		System.debug('\n\n\nIn replaceApiNamesWithLabels\n\n\n');
		System.debug('\n\n\njStr before is: ' + jStr + '\n\n\n');
		
		for (String apiName : apiNameLabelMap.keySet())
		{
			String searchStr = '\"' + apiName + '\"';  
			String replacementStr = '\"' + apiNameLabelMap.get(apiName) + '\"';  
	
			System.debug('\n\n\nsearchStr is: ' + searchStr + '\n\n\n');
			System.debug('\n\n\nreplacementStr is: ' + replacementStr + '\n\n\n');
			
			if (jStr.contains(searchStr))
				jStr = jStr.replace(searchStr, replacementStr);
		}
		
		System.debug('\n\n\njStr after is: ' + jStr + '\n\n\n');
		
		return jStr;
	}
	
	private String replaceLabelsWithApiNames(String str)
	{
		String initialStr = str;
		
		System.debug('\n\n\nIn replaceLabelsWithApiNames\n\n\n');
		System.debug('\n\n\nstr is: ' + str + '\n\n\n');
		
		for (String label : labelApiNameMap.keySet())
		{
			String searchStr = label;  
			list<String> replacementStrs = labelApiNameMap.get(label);  
			
			System.debug('\n\n\nsearchStr is: ' + searchStr + '\n\n\n');
			System.debug('\n\n\nreplacementStr is: ' + replacementStrs + '\n\n\n');
		
			if (str.contains(searchStr))
			{
				System.debug('\n\n\nsearch str found\n\n\n');
				for(String replacementStr : replacementStrs)
				{
					if (labelApiNameMap.get(label)!=null)
						str = str.replace(searchStr, replacementStr);
					else str = '';
				}
			}			
		}
		
		return str;
	}
	
	private String constructDynamicQuery(sObject dq)
	{
		System.debug('\n\n\nIn constructDynamicQuery\n\n\n');

		String dynamicQuery = '';
		sourceObjectName = String.valueOf(queriedFields.get('SourceObjectName__c'));
		
		if (useSosl)
		{
			dynamicQuery = 'FIND \'' + soslString + '\' IN NAME FIELDS RETURNING ' + sourceObjectName + '(' + fieldsToDisplay + ')';
			//FIND 'map' RETURNING Contact(FirstName, LastName)
		}
		
		else
		{
			for (String label : labelList)
			{
				if (ApexPages.currentPage().getParameters().get(label) != null && ApexPages.currentPage().getParameters().get(label) != '')
				{
					filterString = filterString + '(';
					// For each field in map
					system.debug('\n\n labelApiNameMap: '+labelApiNameMap+'\n\n');
					system.debug('\n\n'+labelApiNameMap.get(label)+'\n\n');
					for(String currentAPIName : labelApiNameMap.get(label))
					{
						//String currentAPIName = labelApiNameMap.get(label)[0];
						Schema.DisplayType fldType;
						System.debug('\n\n\n' + currentAPIName + '\n\n\n');
						if (currentAPIName.contains('.'))
						{
							List<String> pathPartList = currentAPIName.split('[.]', 2);
	        				fldType = getFieldType(String.valueOf(pathPartList[0].trim()), String.ValueOf(pathPartList[1]).trim());
						}
						else
						{
							fldType = getFieldType(sourceObjectName, currentAPIName);
						}

						/*if (filterString.length()>0) 
						{
							if(dontNeedQuotes(String.valueOf(fldType)))
							{
								filterString = filterString + currentAPIName + '=' + ApexPages.currentPage().getParameters().get(label); 
							}
							else
							{
								filterString = filterString + currentAPIName + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
							}
							
						}
						else 
						{*/
							if(dontNeedQuotes(String.valueOf(fldType)))
							{
								if(ApexPages.currentPage().getParameters().get(label).contains('*'))
								{
									filterString = filterString + currentAPIName + ' like ' + wildCardHandler(ApexPages.currentPage().getParameters().get(label)); 
								}
								else
								{
									filterString = filterString + currentAPIName + '=' + ApexPages.currentPage().getParameters().get(label); 
								}
							}
							else
							{
								if(ApexPages.currentPage().getParameters().get(label).contains('*'))
								{
									filterString = filterString + currentAPIName + ' like ' + '\'' + wildCardHandler(ApexPages.currentPage().getParameters().get(label)) + '\''; 	
								}
								else
								{
									filterString = filterString + currentAPIName + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
								}
							}
						//}
						filterString = filterString + ' OR ';					
					}
					
					filterString = filterString.removeEndIgnoreCase(' OR ');
					filterString = filterString + ') AND ';
					
					Map<String, String> privacyMap = createCustomSettingMap(String.valueOf(queriedFields.get('Privacy_Fields__c')));
					for(String currentAPIName : labelApiNameMap.get(label))
					{
						if(privacyMap.get(currentAPIName)!=null)
						{
							filterString = filterString + '(' + privacyMap.get(currentAPIName) + '=false) AND ';
						}
					}
				}						
			}	
			filterString = filterString.removeEndIgnoreCase(' AND ');
			
			dynamicQuery = 'Select ' + fieldsToDisplay + ' from ' + sourceObjectName;
					
			if (filterString.length()>0) dynamicQuery += ' where ' + filterString;
			
			if (staticWhere!=null && staticWhere!='')
			{
				if(dynamicQuery.contains('where'))
				{
					dynamicQuery += ' and ' + staticWhere;
				}
				else
				{
					dynamicQuery += ' where ' + staticWhere;
				}
			}

			//add Order By if sort string was specified
			if(ApexPages.currentPage().getParameters().get('sort') != null && ApexPages.currentPage().getParameters().get('sort') != '')
	       	{
	       		System.debug('\n\n\nFound sort parameter\n\n\n');
	       		
	            String tmpStr = replaceLabelsWithApiNames(ApexPages.currentPage().getParameters().get('sort'));  
	            
	            if (tmpStr!='') sortStr = 'ORDER BY ' + tmpStr; 
	       	}
       	
			if (sortStr!=null && sortStr!='')
				dynamicQuery += ' ' + sortStr;
			
			//add OFFSET and LIMIT if page number was specified
			if (pageNumberProvided)
				dynamicQuery += ' LIMIT ' + pageSize + ' OFFSET ' + String.valueOf(offset);
				
				
		}
		
		System.debug('\n\n\nFrom constructDynamicQuery, dynamicQuery is: ' + dynamicQuery + '\n\n\n');
								
		return dynamicQuery;
	}
	
	private String wildCardHandler(String s)
    {
        String newStr = s.replace('*', '%');
        return newStr;
    }

	private Schema.DisplayType getFieldType(String obj, String field)
	{
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		system.debug(obj);
        Schema.SObjectType leadSchema = schemaMap.get(obj);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        system.debug('\n\n'+field+'\n\n');
       	Schema.SObjectField currentField = fieldMap.get(field);
		system.debug('\n\n'+currentField+'\n\n');
		Schema.DisplayType fldType = currentField.getDescribe().getType();
		system.debug('\n\n'+fldType+'\n\n');
		return fldType;
	}

	private Boolean dontNeedQuotes(String fldTypeStr)
	{
		Boolean dontNeedQuotes = false;
		if(fldTypeStr.toLowerCase()=='double' || fldTypeStr.toLowerCase()=='integer' || fldTypeStr.toLowerCase()=='Boolean')
		{
			dontNeedQuotes = true;
		}
		return dontNeedQuotes;
	}

	private sObject findQueriedSourceRecords()
    {
    	System.debug('\n\n\nIn findqueriedSourceRecords\n\n\n');
    	
    	
 	    	getFields(CustomSettingName, CustomSettingRecordName);
 	    	
 	       	queryString = constructDynamicQuery(queriedFields);
	    		    		    	
	    	System.debug('\n\n\nQuery String is: ' + queryString);
	    try
    	{		    	
	       	if (useSosl) 
	       	{
	       		List<List<SObject>> searchList = search.query(queryString);
				queriedSourceRecords = ((List<SObject>)searchList[0]); 
	       	}
	       	else queriedSourceRecords = Database.query(queryString);
	       	
	       	System.debug('\n\n\nqueriedSourceRecords is: ' + queriedSourceRecords);
	       	
    	}
    	catch(Exception pEx)
    	{
			System.debug('\n\n\n Error in Retrieving Queried Records \n\n\n');
		} 
		
		return queriedFields;
    }
    
    private void convertQueriedRecordsToWrapperClass()
    {
    	System.debug('\n\n\nIn convertQueriedRecordsToWrapperClass()\n\n\n');
    	
    	for (Integer i = 0; i<queriedSourceRecords.size(); i++)
    	{
    		System.debug('\n\n\nIn For loop');
    		
    		Integer pNumber = 0;
    		Integer position = 0;
    		
    		System.debug('\n\n\nBefore: pNumber is: ' + pNumber + ',  position is: ' + position + '\n\n\n');
    		
    		if (pageNumber == 1)
       			pNumber = Integer.valueOf(Decimal.valueOf((i/pageSize)).round(System.RoundingMode.DOWN)) + 1;
       		else pNumber = pageNumber;
    		
    		if (pageNumber == 1)
    			position = i - (pageSize * (pNumber - 1)) + 1;
    		else position = i+1;
    		
    		System.debug('\n\n\nAfter: pNumber is: ' + pNumber + ',  position is: ' + position + '\n\n\n');
    		
    		System.debug('\n\n\nBefore helper class\n\n\n');

    		setPrivacyFieldsOnObj(queriedSourceRecords[i]);
    		list<String> fieldValues = getfieldValues(viewName, queriedSourceRecords[i]);
    		
    		map<String, String> socialIconURLMap = new map<String, String>();
    		socialIconURLMap = createSocialIconURLMap(queriedSourceRecords[i]);

    		helperClass hcRecord = new helperClass(queriedSourceRecords[i], fieldValues, 
    			socialIconURLMap,
    			pNumber, position);
			System.debug('\n\n\nAfter helper class\n\n\n');
			
			queriedSourceWrapperRecords.add(hcRecord);
			
			
    	}
    	
    	System.debug('\n\n\nLeaving convertQueriedRecordsToWrapperClass()\n\n\n');
    }

    private map<String, String> createSocialIconURLMap(sObject queriedSourceRecord)
    {
    	Map<String, String> socialIconURLMap = new Map<String, String>();
    	Map<String, String> socialIconMap = createCustomSettingMap(String.valueOf(queriedFields.get('Social_Icon_Map__c')));
    	for(String iconMapKey : socialIconMap.keySet())
    	{
    		socialIconURLMap.put(socialIconMap.get(iconMapKey), getFieldValueHelper(iconMapKey, queriedSourceRecord));
    	}
    	return socialIconURLMap;
    }

   /* private String getRowValue(String apiFieldName, sObject queriedSourceRecord)
    {
    	String rowValue = '';
    	SObject currentSObject;
		String fieldPath;
		if(queriedFields.get(apiFieldName)!=null)
		{
	    	if (String.ValueOf(queriedFields.get(apiFieldName)).contains('.'))
			{
				List<String> pathPartList = String.ValueOf(queriedFields.get(apiFieldName)).split ('[.]', 2);

				currentSObject = (SObject) queriedSourceRecord.getSobject(pathPartList[0]);
				fieldPath = pathPartList[1];
				if(String.ValueOf(currentSObject.get(fieldPath))!=null)
				{
					rowValue = String.ValueOf(currentSObject.get(fieldPath));
				}
			}
			else
			{
				if(String.ValueOf(queriedSourceRecord.get(String.valueOf(queriedFields.get(apiFieldName))))!=null)
				{
					rowValue = String.ValueOf(queriedSourceRecord.get(String.valueOf(queriedFields.get(apiFieldName))));
				}
			}
		}
		else
		{
			rowValue = '';	
		}
		return rowValue;
    }*/

    private void setPrivacyFieldsOnObj(sObject queriedSourceRecord)
    {
    	Map<String, String> privacyMap = createCustomSettingMap(String.valueOf(queriedFields.get('Privacy_Fields__c')));
    	for(String fieldAPIName : privacyMap.keySet())
    	{
    		if(getFieldValueHelper(privacyMap.get(fieldAPIName), queriedSourceRecord)=='true')
    		{
    			if(fieldAPIName.contains('.'))
    			{
    				List<String> pathPartList = fieldAPIName.split('[.]', 2);
    				SObject currentSObject = (SObject) queriedSourceRecord.getSobject(pathPartList[0].trim());
					String fieldPath = pathPartList[1];
					currentSObject.put(fieldPath, null);
    			}
    			else
    			{
    				queriedSourceRecord.put(fieldAPIName, null);
    			}
    		}
    	}
    }

    private list<String> getfieldValues(String apiFieldName, sObject queriedSourceRecord)
    {
    	list<String> fieldValues = new list<String>();
    	if(queriedFields.get(apiFieldName)!=null)
    	{
    		List<String> fieldsInCustomSetting = String.ValueOf(queriedFields.get(apiFieldName)).split ('[,]');
    		for(String field : fieldsInCustomSetting)
    		{
				fieldValues.add(getFieldValueHelper(field, queriedSourceRecord));
    		}
    	}
    	return fieldValues;
    }

    private String getFieldValueHelper(String field, sObject queriedSourceRecord)
    {
    	String fieldValue = '';
    	SObject currentSObject;
		String fieldPath;
    	if (field.contains('.'))
		{
			List<String> pathPartList = field.split('[.]', 2);
			currentSObject = (SObject) queriedSourceRecord.getSobject(pathPartList[0].trim());
			fieldPath = pathPartList[1];
			if(String.ValueOf(currentSObject.get(fieldPath.trim()))!=null)
			{
				fieldValue = String.ValueOf(currentSObject.get(fieldPath.trim()));
			}				
		}
		else
		{
			if(String.ValueOf(queriedSourceRecord.get(field))!=null)
			{
				fieldValue = String.ValueOf(queriedSourceRecord.get(field));
			}
		}
		return fieldValue;
    }
}