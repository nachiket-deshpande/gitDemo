public with sharing class CommunityExperienceHandlerClass {
    //urlparam false and Community_Experience_selected__c set to null
    public Pagereference getCommunityExperienceDetails(String pUrlParam, String pCommunityExperienceSelected){
        User userComm = [select id, ContactId from User where ContactID != null limit 1];
        Pagereference commPageReference;
        ProfileDomainName__c domain_Name = UtilityGeneral.getProfileDomainName();
        
        System.runAs(userComm) {
            //Setting Url Params
            Contact userContact = new Contact();
            userContact.id = userComm.ContactId;
            userContact.acfComm__Community_Experience_Options__c = 'Athletics,Columbia,University';
            userContact.acfComm__Community_Experience_selected__c = null;
            update userContact;
                
            Test.setCurrentPageReference(new PageReference('Page.CommunityExperiencePage'));
            System.currentPageReference().getParameters().put('isCommExperience', pUrlParam);
              
            CommunityExperienceController commExp = new CommunityExperienceController();
            
            commExp.COMMUNITY_HOME_URL =  domain_Name.DomainName__c + '/home/home.jsp';
            
            
                //commExp.urlParam='true';
            commExp.init();
            //commExp.communityExperienceSelected = pCommunityExperienceSelected;
            //commExp.updateCommunityExperience();
              
             /* if(pUrlParam == 'true'){
                system.assertequals('Columbia', commExp.currentUserContact.acfComm__Community_Experience_selected__c);
              }
              if(pUrlParam == 'false'){
                system.assertequals('Columbia', commExp.currentUserContact.acfComm__Community_Experience_selected__c);
              } */
              commPageReference = commExp.loadPagereference;
        }
        return commPageReference;
    }
}