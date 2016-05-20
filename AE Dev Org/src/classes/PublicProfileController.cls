public class PublicProfileController {

	public String UserId {get; set;}
	public User u {get; set;}
	public Contact c {get; set;}

	public PublicProfileController() 
	{
		UserId = ApexPages.currentPage().getParameters().get('sfdc.userId');
		system.debug('\n\n'+UserId+'\n\n');

		u = [select Id, FullPhotoURL, AboutMe, SmallPhotoUrl, ContactId, LastLoginDate from User where Id=:userId];
		list<Contact> cons = queryContact(u.ContactId);
		c = cons[0];	
	}

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

}