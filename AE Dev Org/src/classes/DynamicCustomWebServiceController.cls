/********************************************************************
* Author: ACF Solutions
*		  Valerie Sibirsky, Sophak Phou
* Date: Nov 2014 
* Description:  A controller used to build custom public REST JSON
*				Webservices for JavaScript calls
*/
public class DynamicCustomWebServiceController {
	
	private final String NAMESPACE = 'acfComm__';
	
	// Custom setting record parameters
	private String csName;
	private String csRecordName;
	private String csViewName;
	
	// Pagination Parameters
	private Integer pageNumber;
	private Boolean pageNumberProvided;
	private Integer pagePositionOn;
	private Integer pageSize;
	private Integer pageOffset; 
	
	// Simple Search Parameters
	private Boolean soslMode;
	private String  soslQString;
	
	private Map<String, List<String>> objectNameToSearchFieldsMap;
	private Map<String, String> labelApiNameMap;
	private Map<String, String> apiNameLabelMap;
	private Set<String> labelList;
	
	// Constructor for the DynamicCustomWebServiceController class
	public DynamicCustomWebServiceController() {
		
		csName = 'acfComm__DynamicQueryFields__c';
		csRecordName = 'Profile';
		csViewName = 'acfComm__ListView__c';
		pageNumber = 1;
		pageNumberProvided = false;
		pagePositionOn = 0;
		pageSize = 20;
		pageOffset = 0; 
		
		objectNameToSearchFieldsMap = new Map<String, List<String>>();
		
		LoadPageParameters();
		CreateObjectSearchfieldMap();
		
		//queriesGenerated = GenerateParentQueries();
		GenerateQueries();
	}
	
	private void LoadPageParameters() {
		
		if(ApexPages.currentPage().getParameters().get('name') != null && ApexPages.currentPage().getParameters().get('name') != '')
            csRecordName = ApexPages.currentPage().getParameters().get('name');
            
        if(ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') {
        	String viewname = NAMESPACE + ApexPages.currentPage().getParameters().get('view') + 'View__c';
        	
        	Map<String, Schema.SObjectField> customSettingFields = Schema.getGlobalDescribe().get(csName).getDescribe().fields.getMap(); 

        	//check if ViewName is part of the Custom Setting
    		if(customSettingFields.containsKey(viewname)) 
				csViewName = viewname;            
        }
                      	
        if(ApexPages.currentPage().getParameters().get('pagesize') != null && ApexPages.currentPage().getParameters().get('pagesize') != ''){
        	if (Integer.valueOf(ApexPages.currentPage().getParameters().get('pagesize')) > 0)
            	pageSize = Integer.valueOf(ApexPages.currentPage().getParameters().get('pagesize'));
        }
        
        if(ApexPages.currentPage().getParameters().get('pagenumber') != null && ApexPages.currentPage().getParameters().get('pagenumber') != ''){
        	if (Integer.valueOf(ApexPages.currentPage().getParameters().get('pagenumber')) > 0) {
           		pageNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get('pagenumber'));
           		pageNumberProvided = true;
           	}
        }
                
    	pageOffset = pageSize * (pageNumber-1);   
		
		if(ApexPages.currentPage().getParameters().get('q') != null && ApexPages.currentPage().getParameters().get('q') != ''){
			soslQString = ApexPages.currentPage().getParameters().get('q');		
            soslMode = true;
		}
	}
	
	private void CreateObjectSearchfieldMap(){
		Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
		for (String parameterName : pageParameters.keySet()) {
			if (parameterName.startsWith('rel')) {
				List<String> tmpStrs = parameterName.replace('rel.', '').split('\\.'); 
	
				if (tmpStrs.size()==2){			
					String valueStr = tmpStrs[1] + '=' + pageParameters.get(parameterName);
					if (objectNameToSearchFieldsMap.containsKey(tmpStrs[0]))
						objectNameToSearchFieldsMap.get(tmpStrs[0]).add(valueStr);
					else objectNameToSearchFieldsMap.put(tmpStrs[0], new List <String> { valueStr });					
				}
			}
		}
		
		System.debug('\n\n\nobjectNameToSearchFieldsMap is: ' + objectNameToSearchFieldsMap + '\n\n\n');
	}
	
	private List<String> GenerateQueries(){
		
		System.debug('\n\n\nIn GenerateQueries\n\n\n');

		String queryStr = 'Select acfComm__sourceObjectName__c, acfComm__SourceObjectFields__c, ' + csViewName + ' from ' + csName + ' where Name=\'' + csRecordName + '\''; 
		sObject resultsObj = Database.query(queryStr);	// Results returned
			
		BuildFieldMaps(String.valueOf(resultsObj.get('acfComm__SourceObjectFields__c')));
		//fieldsToDisplay = String.valueOf(resultsObj.get(viewName));
		
		return constructDynamicQueries(resultsObj);			
	}

	private void BuildFieldMaps(String fieldMapping) {
		System.debug('\n\n\nIn Build Maps\n\n\n');
		
		labelApiNameMap = new Map<String, String>();
		apiNameLabelMap = new Map<String, String>();
		//labelList = new List<String>();
		
   	   	fieldMapping = fieldMapping.replaceAll(' ', '');	
		
		List<String> mappingPairs = fieldMapping.split(',');
		
		//fieldsString = '';
		
		//populate Label to API Name Map and API Name to Label Map
		if (mappingPairs.size()>0) {
			for (String pair : mappingPairs) {
				List<String> splitPair = pair.split('=');
				
				if (splitPair.size()==2) {
					String label = splitPair[0];
					String apiName = splitPair[1];
					
					labelApiNameMap.put(label, apiName);
					apiNameLabelMap.put(apiName, label);
					
					//if (fieldsString.length()>0) fieldsString += ', ' + apiName; 
					//else fieldsString = apiName;
							
					//labelList.add(label); // SP: Can we just get this from the key of the Map?
				} 
			}
			labelList = labelApiNameMap.keySet();
		}
		
		System.debug('\n\n\nlabelApiNameMap is: ' + labelApiNameMap + '\n\n\n');
		System.debug('\n\n\napiNameLabelMap is: ' + apiNameLabelMap + '\n\n\n');
		//System.debug('\n\n\nfieldsString is: ' + fieldsString + '\n\n\n');
		
		System.debug('\n\n\ntest\n\n\n');
				
		System.debug('\n\n\nlabelList is: ' + labelList + '\n\n\n');
		
		System.debug('\n\n\nLeaving buildParentMaps\n\n\n');
	}
	
	private List<String> constructDynamicQueries(sObject dq){
		
		System.debug('\n\n\nIn constructDynamicQueries\n\n\n');	
		
		List<String> dynamicQueries = new List<String>{''};
		List<String> childQueriesIdSetsDeepestLevel = new List<String>();
		List<String> childQueriesIdSetsMiddleLevel = new List<String>();
		Map<String, Integer> objectLevelMap = new Map<String, Integer>();
		Integer deepestLevel = 0;
		String deepestLevelForeignKey = '';	
		String parentObjectName = String.valueOf(dq.get('acfComm__sourceObjectName__c')); // SP: passed in by reference no need to use global
		
		//Construct children queries
		//Determine relationship level and build generation 1, 2, 3, etc. queries
		String childDynamicQuery = '';
		
		if (objectNameToSearchFieldsMap.size()>0)
		{
			//poopulate objectLevelMap
			for (String objectLabel : objectNameToSearchFieldsMap.keySet())
			{
				findObjectLevel(objectLabel, csRecordName, objectLevelMap); 
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
						/*deepestLevelForeignKey = getForeignKeyApiName(getForeignKey(csName, objectLabel));
						
						childDynamicQuery = generateChildQuery(objectLabel, objectNameToSearchFieldsMap.get(objectLabel), objectLevelMap.get(objectLabel));	
						
						idSetsDeepestLevel.add(runChildQuery(objectLabel, objectNameToSearchFieldsMap.get(objectLabel), objectLevelMap.get(objectLabel)));	
																	
						dynamicQueries.add('Level ' + objectLevelMap.get(objectLabel) + ' query ' + counter + ': ' + childDynamicQuery);
						
						childQueriesIdSetsDeepestLevel.add('childQueryLevel' + objectLevelMap.get(objectLabel) + 'Number' + counter + 'IdSet');	
					
						counter++;*/
					}
				}
			} 
			/*
			System.debug('\n\n\nidSetsDeepestLevel is: ' + idSetsDeepestLevel + '\n\n\n');
			
			
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
								if (childDynamicQuery.contains('where'))
									childDynamicQuery += ' AND Id in: ' + childQueriesIdSetsDeepestLevel[i];
								else childDynamicQuery += ' where Id in: ' + childQueriesIdSetsDeepestLevel[i];
							}
						}
																				
						idSetsMiddleLevel.add(runChildQuery(objectLabel, objectNameToSearchFieldsMap.get(objectLabel), objectLevelMap.get(objectLabel)));	
																				
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
				idSetsMiddleLevel.add(runChildQuery(objLabel, new List<String>(), 1));		
														
				//add Id sets from children queries
				if (childQueriesIdSetsDeepestLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsDeepestLevel.size(); i++)
					{
						if (childDynamicQuery.contains('where'))
							childDynamicQuery += ' AND Id in: ' + childQueriesIdSetsDeepestLevel[i];
						else childDynamicQuery += ' where Id in: ' + childQueriesIdSetsDeepestLevel[i];
					}
				}
																				
				dynamicQueries.add('Level 1 query 1: ' + childDynamicQuery);	
					
				childQueriesIdSetsMiddleLevel.add('childQueryLevel1Number1IdSet');				
			}
			*/
		}


		//Construct parentQuery		
		String parentDynamicQuery = '';
		String actualParentQuery = '';
		
		//parentObjectName = String.valueOf(queriedFields.get('acfComm__sourceObjectName__c'));
		/*
		if (useSosl)
		{
			parentDynamicQuery = 'FIND \'' + soslString + '\' IN NAME FIELDS RETURNING ' + parentObjectName + '(' + fieldsToDisplay + ')';
			actualParentQuery = parentDynamicQuery;
		}
		else
		{
			System.debug('\n\n\nlabelList is: ' + labelList + '\n\n\n');
			
			for (String label : labelList)
			{
				if (ApexPages.currentPage().getParameters().get(label) != null && ApexPages.currentPage().getParameters().get(label) != '')
				{
					if (filterString.length()>0) filterString =+ ' AND ' + labelApiNameMap.get(label) + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
					else filterString = labelApiNameMap.get(label) + '=' + '\'' + ApexPages.currentPage().getParameters().get(label) + '\''; 
				}		
			}	
			
			System.debug('\n\n\nFilter String is: ' + filterString + '\n\n\n');
			
			parentDynamicQuery = 'Select ' + fieldsToDisplay + ' from ' + parentObjectName;
								
			if (filterString.length()>0) parentDynamicQuery += ' where ' + filterString;
			
			actualParentQuery = parentDynamicQuery;
			
			//add Id sets from children queries
			if (deepestLevel==1)
			{
				if (childQueriesIdSetsDeepestLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsDeepestLevel.size(); i++)
					{
						if (parentDynamicQuery.contains('where'))
							parentDynamicQuery += ' AND Id in: ' + childQueriesIdSetsDeepestLevel[i];
						else parentDynamicQuery += ' where Id in: ' + childQueriesIdSetsDeepestLevel[i];
					}
				}
				
				//set actualParentQuery
				for (Integer i=0; i<idSetsDeepestLevel.size(); i++)
				{
					if (actualParentQuery.contains('where'))
					{
						if (idSetsDeepestLevel[i].size()>0) actualParentQuery += ' AND Id in ' + idSetsDeepestLevel[i];
						else actualParentQuery += ' AND Id = null';
					}
					else 
					{
						if (idSetsDeepestLevel[i].size()>0) actualParentQuery += ' where Id in ' + idSetsDeepestLevel[i];
						else actualParentQuery += ' where Id = null';
					}
				}
				
				
			}
			else if (deepestLevel==2)
			{
				if (childQueriesIdSetsMiddleLevel.size()>0) 
				{
					for (Integer i=0; i<childQueriesIdSetsMiddleLevel.size(); i++)
					{
						if (parentDynamicQuery.contains('where'))
							parentDynamicQuery += ' AND Id in: ' + childQueriesIdSetsMiddleLevel[i];
						else parentDynamicQuery += ' where Id in: ' + childQueriesIdSetsMiddleLevel[i];
					}
				}
				
				//set actualParentQuery
				for (Integer i=0; i<idSetsMiddleLevel.size(); i++)
				{
					if (actualParentQuery.contains('where'))
					{
						if (idSetsMiddleLevel[i].size()>0) actualParentQuery += ' AND Id in ' + idSetsMiddleLevel[i];
						else actualParentQuery += ' AND Id = null';
					}
					else 
					{
						if (idSetsMiddleLevel[i].size()>0) actualParentQuery += ' where Id in ' + idSetsMiddleLevel[i];
						else actualParentQuery += ' where Id = null';
					}
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
			{
				parentDynamicQuery += ' ' + sortStr;
				actualParentQuery += ' ' + sortStr;
			}
			
			//add OFFSET and LIMIT if page number was specified
			if (pageNumberProvided)
			{
				parentDynamicQuery += ' LIMIT ' + pageSize + ' OFFSET ' + String.valueOf(offset);	
				actualParentQuery += ' LIMIT ' + pageSize + ' OFFSET ' + String.valueOf(offset);			
			}	
		}
		
		
		System.debug('\n\n\nActual Parent Query is: ' + actualParentQuery + '\n\n\n');
		
		if (useSosl) 
	    {
	       	List<List<SObject>> searchList = search.query(actualParentQuery);
			queriedSourceRecords = ((List<SObject>)searchList[0]); 
	    }
	    else queriedSourceRecords = Database.query(actualParentQuery);
		
		dynamicQueries.add('Parent query: ' + parentDynamicQuery);
		*/					
		return dynamicQueries;
	}
	
	private void findObjectLevel(String objectLabel, String parentLabel, Map<String, Integer> objectLevelMap)
    {
    	Integer level = 0;
    	Integer deepestLevel = 0;
    	
    	//find Foreign Key Value on 'objectLabel' Custom Setting record
    	String foreignKey; //Sp = getForeignKey(csName, objectLabel);
		String parentObjectName = '';
		
		System.debug('\n\n\nForeign Key for ' + objectLabel + ' is ' + foreignKey + '\n\n\n');
		
		//find object API name for Foreign Key found above
		String objectName; //SP: = getForeignKeyApiName(foreignKey);
		
		if (objectName == parentObjectName) level = 1;
		else 
		{
			String queryStr = 'Select acfComm__ForeignKey__c from ' + csName + ' where acfComm__SourceObjectName__c=\'' + objectName + '\'';
			sObject objectFields = Database.query(queryStr);	

			String objLabel = String.valueOf(objectFields.get('acfComm__ForeignKey__c')); 
			//SP objectName = getForeignKeyApiName(objLabel);
			
			if (objectName == parentObjectName) level = 2;
		}
    	
    	if (deepestLevel < level) deepestLevel = level;
    	
   		objectLevelMap.put(objectLabel, level);
   		
    }
	
}