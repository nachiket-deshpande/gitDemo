public class DynamicRelationshipQueriesController3
{
	public List<String> queriesGenerated {get; set;}	
	private Map<String, List<String>> objectNameToSearchFieldsMap {get; set;}
	private Map<String, Integer> objectLevelMap {get; set;}
    public Integer deepestLevel {get; set;}
	
	private sObject queriedFields {get; set;}	           //Parent fields to be queried
	private List<sObject> queriedSourceRecords {get;set;}
	private List<helperClass> queriedSourceWrapperRecords {get;set;}
	private String queryString {get; set;}
	private String jsonStr {get; set;}
	private Map<String, String> labelApiNameMap {get; set;}
	private Map<String, String> apiNameLabelMap {get; set;}
    private boolean useSosl {get; set;}
    private String soslString {get; set;}
	
	public String parentObjectName {get; set;}
	public String childrenString {get; set;}
	public String grandchildrenString {get; set;}
	
	private String fieldsToDisplay {get; set;}
	private List<String> sourceObjectFields {get; set;}
	
	private String fieldsString {get; set;}
	private String filterString {get; set;}
	private String sortStr {get; set;}
	private List<String> labelList {get; set;}
		
	private final String CustomSettingName = 'acfComm__DynamicQueryFields__c';
	
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

	private String filterId {get; set;}
	
	private class helperClass 
	{
		private sObject sObj {get; set;}
		private Integer pageNumber = 0;
		private Integer positionOnPage = 0;
		
		public helperClass(sObject so, Integer pn, Integer pos)
		{
			sObj = so;
			pageNumber = pn;
			positionOnPage = pos;
		}
	}
	
	public DynamicRelationshipQueriesController3()
	{
		//Initialize variables
		
		//default custom setting record
		CustomSettingRecordName = 'Profile';
		nameSpace = 'acfComm__';
		
		//default View
		viewName = 'acfComm__ListView__c';
		
		pageNumber = 1;
		pageNumberProvided = false;
		positionOnPage = 0;
		pageSize = 20;
		offset = 0;
	
		queriesGenerated = new List<String>();
		objectNameToSearchFieldsMap = new Map<String, List<String>>();
		objectLevelMap = new Map<String, Integer>();
		
		labelApiNameMap = new Map<String, String>();
		apiNameLabelMap = new Map<String, String>();
		labelList = new List<String>();
		filterString = '';
		childrenString = '';
		grandchildrenString = '';
		useSosl = false;
		deepestLevel = 0;
		
		Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
		for (String parameterName : pageParameters.keySet())
		{
			if (parameterName.startsWith('rel'))
			{
				List<String> tmpStrs = parameterName.replace('rel.', '').split('\\.'); 
	
				if (tmpStrs.size()==2)
				{			
					String valueStr = tmpStrs[1] + '=' + pageParameters.get(parameterName);
					
					if (objectNameToSearchFieldsMap.containsKey(tmpStrs[0]))
						objectNameToSearchFieldsMap.get(tmpStrs[0]).add(valueStr);
					else objectNameToSearchFieldsMap.put(tmpStrs[0], new List <String> { valueStr });					
				}
			}
		}
		
		System.debug('\n\n\nobjectNameToSearchFieldsMap is: ' + objectNameToSearchFieldsMap + '\n\n\n');
		
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
		
				
		queriesGenerated = generateQueries();		
	}
	
    private void findObjectLevel(String objectLabel, String parentLabel)
    {
    	Integer level = 0;
    	
    	//find Foreign Key Value on 'objectLabel' Custom Setting record
    	String foreignKey = getForeignKey(CustomSettingName, objectLabel);
		
		System.debug('\n\n\nForeign Key for ' + objectLabel + ' is ' + foreignKey + '\n\n\n');
		
		//find object API name for Foreign Key found above
		String objectName = getForeignKeyApiName(foreignKey);
		
		if (objectName == parentObjectName) level = 1;
		else 
		{
			String queryStr = 'Select acfComm__ForeignKey__c from ' + CustomSettingName + ' where acfComm__SourceObjectName__c=\'' + objectName + '\'';
			sObject objectFields = Database.query(queryStr);	

			String objLabel = String.valueOf(objectFields.get('acfComm__ForeignKey__c')); 
			objectName = getForeignKeyApiName(objLabel);
			
			if (objectName == parentObjectName) level = 2;
		}
    	
    	if (deepestLevel < level) deepestLevel = level;
    	
   		objectLevelMap.put(objectLabel, level);
   		
    }
    
	private void getParentFields(String customSettingName, String CustomSettingRecordName)
	{
		System.debug('\n\n\nIn getFields\n\n\n');
		
		String queryStr = 'Select acfComm__sourceObjectName__c, acfComm__SourceObjectFields__c, acfComm__FilterId__c, ' + viewName + ' from ' + customSettingName + ' where Name=\'' + CustomSettingRecordName + '\''; 
		queriedFields = Database.query(queryStr);	
			
		buildParentMaps(String.valueOf(queriedFields.get('acfComm__SourceObjectFields__c')));
		
		System.debug('\n\n\n111111111111111111111111111\n\n\n');
		
		fieldsToDisplay = String.valueOf(queriedFields.get(viewName));

		filterId = String.valueOf(queriedFields.get('acfComm__FilterId__c'));

		System.debug('\n\n\n filterId: '+filterId+'\n\n\n');		
		
		System.debug('\n\n\n22222222222222222222222222222222\n\n\n');		
	}
	
	private void buildParentMaps(String fieldMapping)
	{
		System.debug('\n\n\nIn Build Maps\n\n\n');
		
		labelApiNameMap = new Map<String, String>();
		apiNameLabelMap = new Map<String, String>();
		
   	   	fieldMapping = fieldMapping.replaceAll(' ', '');	
		
		List<String> mappingPairs = fieldMapping.split(',');
		
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
					String apiName = splitPair[1];
					
					labelApiNameMap.put(label, apiName);
					apiNameLabelMap.put(apiName, label);
					
					if (fieldsString.length()>0) fieldsString += ', ' + apiName;
					else fieldsString = apiName;
							
					labelList.add(label);
				} 
			}
		}
		
		System.debug('\n\n\nlabelApiNameMap is: ' + labelApiNameMap + '\n\n\n');
		System.debug('\n\n\napiNameLabelMap is: ' + apiNameLabelMap + '\n\n\n');
		System.debug('\n\n\nfieldsString is: ' + fieldsString + '\n\n\n');
		
		System.debug('\n\n\ntest\n\n\n');
				
		System.debug('\n\n\nlabelList is: ' + labelList + '\n\n\n');
		
		System.debug('\n\n\nLeaving buildParentMaps\n\n\n');
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
			String replacementStr = labelApiNameMap.get(label);  
			
			System.debug('\n\n\nsearchStr is: ' + searchStr + '\n\n\n');
			System.debug('\n\n\nreplacementStr is: ' + replacementStr + '\n\n\n');
		
			if (str.contains(searchStr))
			{
				System.debug('\n\n\nsearch str found\n\n\n');
				
				if (labelApiNameMap.get(label)!=null && labelApiNameMap.get(label)!='')
					str = str.replace(searchStr, replacementStr);
				else str = '';
			}			
		}
		
		return str;
	}
	
	private String getObjectApiName(String customSettingName, String recordName)
	{	
		String objectName = '';
		sObject objectFields;
		
		String queryStr = 'Select acfComm__sourceObjectName__c from ' + customSettingName + ' where Name=\'' + recordName + '\''; 
		objectFields = Database.query(queryStr);	
			
		return String.valueOf(objectFields.get('acfComm__sourceObjectName__c'));
	}
	
	private String getForeignKey(String customSettingName, String recordName)
	{	
		String queryStr = 'Select acfComm__ForeignKey__c from ' + customSettingName + ' where Name=\'' + recordName + '\''; 
		sObject customSettingFields = Database.query(queryStr);	
		
		String foreignKey = String.valueOf(customSettingFields.get('acfComm__ForeignKey__c'));
		
		return foreignKey;
	}
	
	private String getForeignKeyApiName(String recordName)
	{
		String queryStr = 'Select acfComm__ObjectName__c from acfComm__ForeignKeys__c where Name=\'' + recordName + '\''; 
		sObject customSettingFields = Database.query(queryStr);	
		
		String objectName = String.valueOf(customSettingFields.get('acfComm__ObjectName__c'));
		
		return objectName;
	}
	
	private String getFieldApiName(String customSettingName, String recordName, String fieldLabel)
	{	
		String objectName = '';
		String fieldName = '';
		sObject customSettingFields;
		
		String queryStr = 'Select acfComm__sourceObjectName__c, acfComm__SourceObjectFields__c from ' + customSettingName + ' where Name=\'' + recordName + '\''; 
		customSettingFields = Database.query(queryStr);	
		
		String fieldMapping = String.valueOf(customSettingFields.get('acfComm__SourceObjectFields__c'));
		
		fieldMapping = fieldMapping.replaceAll(' ', '');		
		List<String> mappingPairs = fieldMapping.split(',');
		
		if (mappingPairs.size()>0)
		{
			for (String pair : mappingPairs)
			{
				if (pair.startsWith(fieldLabel))
				{
					List<String> splitPair = pair.split('=');
				
					if (splitPair.size()==2)
					{
						fieldName = splitPair[1];
					}
				}
			}
		}
		
		return fieldName;
	}
	
	private String generateChildQuery(String objectLabel, List<String> fieldLabelValuePairs, Integer childLevel)
	{
		String childQ = '';
		String filterString = '';
		String objectName = '';
		
		objectName = getObjectApiName(CustomSettingName, objectLabel);
		
		if (fieldLabelValuePairs.size()>0)
		{
			childQ = 'Select ' + getForeignKey(CustomSettingName, objectLabel) +  ' from ' + objectName + ' where ';
			
			for (Integer i=0; i < fieldLabelValuePairs.size(); i++)
			{
				List<String> fieldParts = fieldLabelValuePairs[i].split('=');
			
				if (fieldParts.size()==2)
				{
					String fieldLabel = fieldParts[0];
					String fieldValue = fieldParts[1];
					
					if (i==0) filterString = getFieldApiName(CustomSettingName, objectLabel, fieldLabel) + '=' + '\'' + fieldValue + '\'';
					else filterString = ' AND ' + getFieldApiName(CustomSettingName, objectLabel, fieldLabel) + '=' + '\'' + fieldValue + '\'';
					
					childQ += filterString;
				}
			}
		}
		else childQ = 'Select ' + getForeignKey(CustomSettingName, objectLabel) +  ' from ' + objectName;
		
		if (childLevel == 1) if (childrenString=='') childrenString = objectName; else childrenString += ', ' + objectName;
   		if (childLevel == 2) if (grandchildrenString=='') grandchildrenString = objectName; else grandchildrenString += ', ' + objectName;
		
		
		System.debug('\n\n\nchild query is: ' + childQ + '\n\n\n');
		
		return childQ;
	}
	
	private List<String> constructDynamicQueries(sObject dq)
	{
		System.debug('\n\n\nIn constructDynamicQueries\n\n\n');	
		
		List<String> dynamicQueries = new List<String>{''};
		List<String> childQueriesIdSetsDeepestLevel = new List<String>();
		List<String> childQueriesIdSetsMiddleLevel = new List<String>();		
		
		String deepestLevelForeignKey = '';	
				
		parentObjectName = String.valueOf(queriedFields.get('acfComm__sourceObjectName__c'));
		
		//Construct children queries
		//Determine relationship level and build generation 1, 2, 3, etc. queries
		String childDynamicQuery = '';
		
		if (objectNameToSearchFieldsMap.size()>0)
		{
			//poopulate objectLevelMap
			for (String objectLabel : objectNameToSearchFieldsMap.keySet())
			{
				findObjectLevel(objectLabel, CustomSettingRecordName); 
			}
				
			System.debug('\n\n\nobjectLevelMap is: ' + objectLevelMap + '\n\n\n');	
				
			//build queries, starting with deepest level		
			Integer counter = 1;		
			for (String objectLabel : objectLevelMap.keySet())
			{
				if (objectLevelMap.get(objectLabel)>0)
				{
					if (objectLevelMap.get(objectLabel)==deepestLevel)
					{
						deepestLevelForeignKey = getForeignKeyApiName(getForeignKey(CustomSettingName, objectLabel));
						
						childDynamicQuery = generateChildQuery(objectLabel, objectNameToSearchFieldsMap.get(objectLabel), objectLevelMap.get(objectLabel));	
																	
						dynamicQueries.add('Level ' + objectLevelMap.get(objectLabel) + ' query ' + counter + ': ' + childDynamicQuery);	
					
						childQueriesIdSetsDeepestLevel.add('childQueryLevel' + objectLevelMap.get(objectLabel) + 'Number' + counter + 'IdSet');	
					
						counter++;
					}
				}
			} 
			
			
			//build queries next level up 
			counter = 1;		
			for (String objectLabel : objectLevelMap.keySet())
			{
				if (objectLevelMap.get(objectLabel)>0)
				{
					if (objectLevelMap.get(objectLabel)==deepestLevel-1)
					{
						childDynamicQuery = generateChildQuery(objectLabel, objectNameToSearchFieldsMap.get(objectLabel), objectLevelMap.get(objectLabel));	
														
						//add Id sets from children queries
						if (childQueriesIdSetsDeepestLevel.size()>0) 
						{
							for (Integer i=0; i<childQueriesIdSetsDeepestLevel.size(); i++)
							{
								childDynamicQuery += concatFilterSetIds(childDynamicQuery, childQueriesIdSetsDeepestLevel[i]);
							}
						}
																				
						dynamicQueries.add('Level ' + objectLevelMap.get(objectLabel) + ' query ' + counter + ': ' + childDynamicQuery);	
					
						childQueriesIdSetsMiddleLevel.add('childQueryLevel' + objectLevelMap.get(objectLabel) + 'Number' + counter + 'IdSet');	
					
						counter++;
					}
				}
			} 
			
			if (deepestLevel==2 && childQueriesIdSetsMiddleLevel.size()==0)
			{
				System.debug('\n\n\nMiddle level params not specified\n\n\n');
				
				//generate middle level query based on Foreign Key in deepest level
				String queryStr = 'Select Name from ' + CustomSettingName + ' where acfComm__SourceObjectName__c=\'' + deepestLevelForeignKey + '\'';
				sObject objectFields = Database.query(queryStr);	

				String objLabel = String.valueOf(objectFields.get('Name'));
				
				System.debug('\n\n\nobjectLabel is: ' + objLabel);
				
				childDynamicQuery = generateChildQuery(objLabel, new List<String>(), 1);	
														
				//add Id sets from children queries
				if (childQueriesIdSetsDeepestLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsDeepestLevel.size(); i++)
					{
						childDynamicQuery += concatFilterSetIds(childDynamicQuery, childQueriesIdSetsDeepestLevel[i]);
					}
				}
																				
				dynamicQueries.add('Level 1 query 1: ' + childDynamicQuery);	
					
				childQueriesIdSetsMiddleLevel.add('childQueryLevel1Number1IdSet');				
			}
			
		}


		//Construct parentQuery		
		String parentDynamicQuery = '';
		
		//parentObjectName = String.valueOf(queriedFields.get('acfComm__sourceObjectName__c'));
		
		if (useSosl)
		{
			parentDynamicQuery = 'FIND \'' + soslString + '\' IN NAME FIELDS RETURNING ' + parentObjectName + '(' + fieldsToDisplay + ')';
		}
		else
		{
			for (String label : labelList)
			{
				if (ApexPages.currentPage().getParameters().get(label) != null && ApexPages.currentPage().getParameters().get(label) != '')
				{
					if (filterString.length()>0) filterString =+ ' AND ' + labelApiNameMap.get(label) + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
					else filterString = labelApiNameMap.get(label) + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
				}		
			}	
			
			parentDynamicQuery = 'Select ' + fieldsToDisplay + ' from ' + parentObjectName;
					
			if (filterString.length()>0) parentDynamicQuery += ' where ' + filterString;
			
			//add Id sets from children queries
			if (deepestLevel==1)
			{
				if (childQueriesIdSetsDeepestLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsDeepestLevel.size(); i++)
					{
						parentDynamicQuery = concatFilterSetIds(parentDynamicQuery, childQueriesIdSetsDeepestLevel[i]);
						/*if (parentDynamicQuery.contains('where'))
							parentDynamicQuery += ' AND Id in: ' + childQueriesIdSetsDeepestLevel[i];
						else parentDynamicQuery += ' where Id in: ' + childQueriesIdSetsDeepestLevel[i];*/
						system.debug('\n\n\n Parent query: ' + parentDynamicQuery+'\n\n\n');
					}
				}
			}
			else if (deepestLevel==2)
			{
				if (childQueriesIdSetsMiddleLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsMiddleLevel.size(); i++)
					{
						parentDynamicQuery = concatFilterSetIds(parentDynamicQuery, childQueriesIdSetsMiddleLevel[i]);
						/*if (parentDynamicQuery.contains('where'))
							parentDynamicQuery += ' AND Id in: ' + childQueriesIdSetsMiddleLevel[i];
						else parentDynamicQuery += ' where Id in: ' + childQueriesIdSetsMiddleLevel[i];*/
						system.debug('\n\n\n Parent query: ' + parentDynamicQuery+'\n\n\n');
					}
				}
			}

			system.debug('\n\n\n Parent query: ' + parentDynamicQuery+'\n\n\n');
			
			//add Order By if sort string was specified
			if(ApexPages.currentPage().getParameters().get('sort') != null && ApexPages.currentPage().getParameters().get('sort') != '')
	       	{
	       		System.debug('\n\n\nFound sort parameter\n\n\n');
	       		
	            String tmpStr = replaceLabelsWithApiNames(ApexPages.currentPage().getParameters().get('sort'));  
	            
	            if (tmpStr!='') sortStr = 'ORDER BY ' + tmpStr; 
	       	}
       	
			if (sortStr!=null && sortStr!='')
				parentDynamicQuery += ' ' + sortStr;
			
			//add OFFSET and LIMIT if page number was specified
			if (pageNumberProvided)
				parentDynamicQuery += ' LIMIT ' + pageSize + ' OFFSET ' + String.valueOf(offset);			
				
		}
		
		dynamicQueries.add('Parent query: ' + parentDynamicQuery);
								
		return dynamicQueries;
	}

	private String concatFilterSetIds(String pChildDynamicQuery, String pChildQueriesIdSetsDeepestLevel)
	{
		system.debug('\n\n\n'+filterId+'\n\n\n');
		system.debug('\n\n\n'+pChildDynamicQuery+'\n\n\n');
		system.debug('\n\n\n'+pChildQueriesIdSetsDeepestLevel+'\n\n\n');
		if(filterId!=null)
		{
			if (pChildDynamicQuery.contains('where'))
			{
				pChildDynamicQuery += ' AND '+filterId+' in: ' + pChildQueriesIdSetsDeepestLevel;
				system.debug('\n\n\n'+pChildDynamicQuery+'\n\n\n');
			}
			else 
			{
				pChildDynamicQuery += ' where '+filterId+' in: ' + pChildQueriesIdSetsDeepestLevel;
				system.debug('\n\n\n'+pChildDynamicQuery+'\n\n\n');
			}
		}
		else
		{
			if (pChildDynamicQuery.contains('where'))
				pChildDynamicQuery += ' AND Id in: ' + pChildQueriesIdSetsDeepestLevel;
			else pChildDynamicQuery += ' where Id in: ' + pChildQueriesIdSetsDeepestLevel;
		}
		system.debug('\n\n\n'+pChildDynamicQuery+'\n\n\n');
		return pChildDynamicQuery;
	}
	
	private String constructDynamicQuery(sObject dq)
	{
		String dynamicQuery = '';
		parentObjectName = String.valueOf(queriedFields.get('acfComm__sourceObjectName__c'));
		
		System.debug('\n\n\nIn constructDynamicQuery\n\n\n');		

		
		if (useSosl)
		{
			dynamicQuery = 'FIND \'' + soslString + '\' IN NAME FIELDS RETURNING ' + parentObjectName + '(' + fieldsToDisplay + ')';
			//FIND 'map' RETURNING Contact(FirstName, LastName)
		}
		
		else
		{
			for (String label : labelList)
			{
				if (ApexPages.currentPage().getParameters().get(label) != null && ApexPages.currentPage().getParameters().get(label) != '')
				{
					if (filterString.length()>0) filterString =+ ' AND ' + labelApiNameMap.get(label) + '=' + ApexPages.currentPage().getParameters().get(label); 
					else filterString = labelApiNameMap.get(label) + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
				}		
			}	
			
			dynamicQuery = 'Select ' + fieldsToDisplay + ' from ' + parentObjectName;
					
			if (filterString.length()>0) dynamicQuery += ' where ' + filterString;
			
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
		
		queriesGenerated.add(dynamicQuery);
								
		return dynamicQuery;
	}
	
	private List<String> generateQueries()
	{
		System.debug('\n\n\nIn generateQueries\n\n\n');
		
		getParentFields(CustomSettingName, CustomSettingRecordName);
		
		return constructDynamicQueries(queriedFields);			
	}
	
	private sObject findQueriedSourceRecords()
    {
    	System.debug('\n\n\nIn findqueriedSourceRecords\n\n\n');
    	
    	try
    	{
 	    	getParentFields(CustomSettingName, CustomSettingRecordName);
 	    	
 	       	queryString = constructDynamicQuery(queriedFields);
 	  	   		    		    	
	    	System.debug('\n\n\nQuery String is: ' + queryString);
	    		    	
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
			System.debug('Error in Retrieving Queried Records');
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
    		helperClass hcRecord = new helperClass(queriedSourceRecords[i], pNumber, position);
			System.debug('\n\n\nAfter helper class\n\n\n');
			
			queriedSourceWrapperRecords.add(hcRecord);
			
			
    	}
    	
    	System.debug('\n\n\nLeaving convertQueriedRecordsToWrapperClass()\n\n\n');
    }

}