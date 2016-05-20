public class CommunityHeaderController 
{
	public String userName {get; set;}
	public String userCommunity {get; set;}
 
	public CommunityHeaderController() 
	{
		if (UserInfo.getName()!=null)
		{
			userName = UserInfo.getName();	
		}
		else userName = '';	
		
		getUserCommunityType();
	}
	
	public String getUserCommunityType()
	{
		User u = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
		Contact c = [select Id, acfComm__Community_Type__c from Contact where Id=:u.ContactId];
		
		userCommunity = c.acfComm__Community_Type__c;	
		
		System.debug('\n\n\nIn Community Header Controller, User Community Type is: ' + userCommunity + '\n\n\n');
		
		return userCommunity;	
	}
	
	
}