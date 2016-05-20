public class PublicProfileController2 {
	public User u {get; set;}
	public Contact c {get; set;}
	public List<Schema.FieldSetMember> fieldSetMembers {get; set;}
	public String mode{get; set;}

	private String pageName;
	private String device;

	public PublicProfileController2(ApexPages.StandardController stdController) 
	{
		String userIdDesktop = ApexPages.currentPage().getParameters().get('sfdc.userId');
		String userIdMobile = ApexPages.currentPage().getParameters().get('id');

		if(userIdDesktop!=null)
		{
			u = queryUser(userIdDesktop);
			device = 'desktop';
		}
		else if(userIdMobile!=null)
		{
			u = queryUser(userIdMobile);	
			device = 'mobile';
		}

		String urlMode = ApexPages.currentPage().getParameters().get('mode');
		if(urlMode=='edit')
		{
			mode='edit';
		}
		else
		{
			mode='view';
		}
		
		list<Contact> cons = queryContact(u.ContactId);
		c = cons[0];
		fieldSetMembers = new list<Schema.FieldSetMember>();
	}

	public void setPageNameToAddlContact()
	{
		pageName = 'addlInfo';
		getFieldSets(pageName);
	}

	public User queryUser(String userId)
	{
		return [select Id, FullPhotoURL, AboutMe, SmallPhotoUrl, ContactId, LastLoginDate from User where Id=:userId];
	}

	public List<Schema.FieldSetMember> getFieldSets(String pageNamePassed)
	{
		// query field set mappings from custom settings
		list<acfComm__Fieldset_Maps__c> FieldSetMapppings = queryFieldSetMapppings(pageName, device, mode);
		if(FieldSetMapppings.size()>0)
		{
			fieldSetMembers = readFieldSet(FieldSetMapppings[0].acfComm__Fieldset_API_Name__c, FieldSetMapppings[0].acfComm__Fieldset_Object__c);
		}
		return fieldSetMembers;
	}

	public list<acfComm__Fieldset_Maps__c> queryFieldSetMapppings(String name, String device, String mode)
	{
		system.debug('\n\n'+name+'\n\n');
		return [select Id, acfComm__Fieldset_API_Name__c, acfComm__Fieldset_Object__c
			from acfComm__Fieldset_Maps__c where
			acfComm__Page_Name__c=:name and acfComm__Device__c=:device and acfComm__Mode__c=:mode];
	}

	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
	{
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

	    //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

	    //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
	    //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
	    return fieldSetObj.getFields(); 
	}

	//public List<Schema.FieldSetMember> getFieldsetMembers(acfComm__Fieldset_Maps__c customSetting)
	//{
		//return SObjectType.customSetting.acfComm__Fieldset_Object__c.FieldSets.customSetting.acfComm__Fieldset_API_Name__c.getFields();
		//return SObjectType.Contact.FieldSets.[customSetting.acfComm__Fieldset_API_Name__c].getFields();
	//}
	
	// Query all contact fields
	public list<Contact> queryContact(String conId)
    {
    	// Initialize setup variables
		String objectName = 'Contact'; // modify as needed
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		 
		// Grab the fields from the describe method and append them to the queryString one by one.
		for(String s : objectFields.keySet()) {
		query += ' ' + s + ', ';
		}
		 
		// Manually add related object's fields that are needed.
		query += 'Account.Name'; // modify as needed
		 
		// Strip off the last comma if it exists.
		if (query.subString(query.Length()-1,query.Length()) == ','){
		query = query.subString(0,query.Length()-1);
		}
		 
		// Add FROM statement
		query += ' FROM ' + objectName;
		 
		// Add on a WHERE/ORDER/LIMIT statement as needed
		query += ' WHERE Id = \''+conId+'\' limit 1'; // modify as needed
		
			list<Contact> contacts = database.query(query);
			return contacts;
    }





	
	
	/*public PublicProfileController2(ApexPages.StandardController stdController) 
	{
		//UserId = ApexPages.currentPage().getParameters().get('sfdc.userId');
		//User foundUser = [select Id, FullPhotoURL, AboutMe, SmallPhotoUrl, ContactId, LastLoginDate from User where Id=:userId];
		
		this.u = (User)stdController.getRecord();
		User uQuery = [select Id, ContactId from User where Id=:u.Id];
		
		list<Contact> cons = queryContact(uQuery.ContactId);
		c = cons[0];
	}*/
}