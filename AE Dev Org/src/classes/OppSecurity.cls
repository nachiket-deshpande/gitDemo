//********************************************************************
// Author: Sophak Phou, ACF Solutions
// Date: October 2014
// Description: OppSecurity class containing the defined methods for 
//              
//
public class OppSecurity {
	
	private list<String> slist;
	
	// Constructor for the OppSecurity class
	public OppSecurity() {
		slist = new list<String>();
	}
	
	public List<Opportunity> getOpportunityList () {
		return [select Id, Name from Opportunity];
	}
	
	public List<String> getOpportunityStrList () {
		//List<Opportunity> ol = [select Id, Name from Opportunity];
		for(Opportunity o:[select Id, Name from Opportunity]){
			slist.add(o.Name);
		}
		
		return slist;
	}
}