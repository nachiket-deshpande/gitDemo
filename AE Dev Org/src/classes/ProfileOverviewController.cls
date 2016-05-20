public class ProfileOverviewController {
	
	public list<acfComm__ProfileOverviewSubTabs__c> ProfileSubTabList { get; set; }
	//Constructor
	public ProfileOverviewController(){
		init();
		ProfileSubTabList = getSubTabNames();
	}
	
	public void init(){
		ProfileSubTabList = new list<acfComm__ProfileOverviewSubTabs__c>();
	}
	
	public list<acfComm__ProfileOverviewSubTabs__c> getSubTabNames(){
		list<acfComm__ProfileOverviewSubTabs__c> SubTabList = new list<acfComm__ProfileOverviewSubTabs__c>();
		SubTabList = [SELECT acfComm__TabName__c FROM acfComm__ProfileOverviewSubTabs__c];
		if(SubTabList.isEmpty()){
			return NULL;
		}
		return SubTabList;
	}
}