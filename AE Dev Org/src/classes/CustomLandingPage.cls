public class CustomLandingPage {
    
    public CustomLandingPage()
    {
         
    }
    
    public pageReference returnPage()
    {
        return new PageReference('/HP_CommunityOptIn');
        /*User u = [SELECT id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        Contact c = [select Id, acfComm__Community_Type__c from Contact where Id=:u.ContactId];
        
        System.debug('\n\n\nIn CustomLandingPage, User Community Type is: ' + c.acfComm__Community_Type__c + '\n\n\n');
         ProfileDomainName__c Domain_Name = UtilityGeneral.getProfileDomainName();
          String page_url = '';
        if(c.acfComm__Community_Type__c=='Med')
        {
           
            page_url = Domain_Name.DomainName__c + '/s/med/DirectorySearchMed';
            return UtilityGeneral.redirect(page_Url, true);
           
        }
        else if(c.acfComm__Community_Type__c=='Law')
        {
            page_url = Domain_Name.DomainName__c + '/s/law/DirectorySearchLaw';
            return UtilityGeneral.redirect(page_Url, true);
        }
                
        return null;*/
    }
    
}