/********************************************************************
* Author: ACF Solutions
* Date: December 2013
* Description: LocationTypeaheadController class containing the defined methods for
* 			   type ahead search. 
*              
*/
public class LocationTypeaheadController {
	
	private String searchTerm;
	public String outputStr;
	
	// Constructor for the LocationTypeaheadController class
	public LocationTypeaheadController() {
		searchTerm = ApexPages.currentPage().getParameters().get('q');
	}
	
	public String doSearch(){
		if(searchTerm != null && searchTerm != '' && searchTerm.length() > 0){
			list<Contact> cList = database.query('select MailingCity, MailingState, MailingPostalCode from Contact where MailingCity LIKE \'%'+searchTerm+'%\' OR MailingState LIKE \'%'+searchTerm+'%\' OR MailingPostalCode LIKE \'%'+searchTerm+'%\' order by MailingCity limit 5');
			if(cList != null && cList.size() > 0)
				return JSON.serialize(cList);
		}
		return '{}';
	}
	
	public String getOutputStr() {
		return doSearch();
	}
}