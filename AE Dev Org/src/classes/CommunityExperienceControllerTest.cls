@isTest(SeeAllData=true)
public class CommunityExperienceControllerTest {
	//Get Contact Id for the current User
	
	public static testmethod void checkCommunityExperienceForInsert(){
	 	CommunityExperienceControllerTest.testCommunityExperience('true');
	}
	
	public static testmethod void checkCommunityExperienceForUpdate(){
	 	CommunityExperienceControllerTest.testCommunityExperience('false');
	}
	
	public static void testCommunityExperience(String pUrlParam){
		 User userComm = [select id, ContactId from User where ContactID != null limit 1];
      	 System.runAs(userComm) {
          //Setting Url Params
      	  Contact userContact = new Contact();
      	  userContact.id = userComm.ContactId;
      	  userContact.Community_Experience_Options__c = 'Athletics;Columbia,University';
      	  userContact.Community_Experience_selected__c = 'Columbia';
      	  update userContact;
      		
      	  Test.setCurrentPageReference(new PageReference('Page.CommunityExperiencePage'));
		  System.currentPageReference().getParameters().put('isCommExperience', pUrlParam);
		  CommunityExperienceController commExp = new CommunityExperienceController();
		  commExp.communityExperienceSelected = 'Columbia';
		  commExp.COMMUNITY_HOME_URL = '/community/home/home.jsp';
			//commExp.urlParam='true';
		  commExp.init();
		  commExp.updateCommunityExperience();
		  commExp.populateMobile();
		  if(pUrlParam == 'true'){
		  	system.assertequals('Columbia',commExp.currentUserContact.Community_Experience_selected__c);
		  }
		  if(pUrlParam == 'false'){
		  	system.assertequals('Columbia', commExp.currentUserContact.Community_Experience_selected__c);
		  }
			
		}
	}
}