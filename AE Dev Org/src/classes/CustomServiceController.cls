/********************************************************************
* Author: ACF Solutions
*		  Sophak Phou
* Date: Sept 2014 
* Description:  A controller used to build custom public REST 
*				Webservices for JavaScript calls
*/
@RestResource(urlMapping='/acf')
global class CustomServiceController {
	
	// Constructor for the CustomServiceController class
	public CustomServiceController() {

	}
	
	@HttpGet
	global static String doGet() {
		String name = RestContext.request.params.get('name');
		String method = RestContext.request.params.get('m');
		String id = RestContext.request.params.get('id');
		
		if(name!=null)
			return 'Hello '+name;
		
		if(method!=null && 'contact'==method.toLowerCase() && id!=null){
			List<Contact> cList = [ Select Id, FirstName, LastName, Email from Contact where Id = :id];
			if(cList.size() > 0)
				return JSON.serialize(cList[0]);
			else return 'No results found';
		} else return 'Invalid request.';
		
	}
	
	@HttpPost
	global static String createNewCase(String companyName, String caseType) {
		System.debug('COMPANY: '+companyName);
		System.debug('CASE TYPE: '+caseType);
		return 'Done';
	}
	
	@HttpDelete
	global static String deleteOldCases() {
		String companyName = RestContext.request.params.get('companyName');
		//Account company = [ Select ID, Name, Email__c, BillingState from Account where Name = :companyName];
		   
		//List<Case> cases = [SELECT Id, Subject, Status, OwnerId, Owner.Name from Case WHERE AccountId =: company.Id AND Status = 'Closed'];
		//delete cases;
		 
		return 'Closed Cases Deleted';
	}
	
	//Accepting Binary Data from RESTRequest Object
	//@HttpPut
	//global static String doPut(RestRequest req) {
	//    String companyName = req.params.get('companyName');
	//}
}