@isTest
public class AutoCommunityExperienceControllerTest {
    static testMethod void test_autoCommunityExperience() {

        ProfileDomainName__c objProfileDomain = new ProfileDomainName__c ();
        objProfileDomain.Name = 'CommunityDomain';
        objProfileDomain.DomainName__c = '/alumni';
        insert objProfileDomain;
        Account objAccount  = new Account() ;
        objAccount.Name = 'Test Account';
        insert objAccount; 

        Contact objContact = new Contact ();
        objContact.LastName = 'Test Contact';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        Id objProfileId = [Select Id From profile where Name='Partner Community User'].id;
        User objUser = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =true,ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert objUser;

        system.runAs(objUser) {
            AutoCommunityExperienceController objController = new AutoCommunityExperienceController();
            test.startTest();

            objController.getBrandParameter();
            Test.setCurrentPageReference(Page.AutoCommunityExperience);
            Apexpages.currentpage().getparameters().put('brand', 'Fletcher');
            Test.setCurrentPageReference(objController.setRedirectTopage());

            Contact objUpdatedContact = [Select Id, 
                                                 acfComm__Community_Experience_selected__c 
                                         From Contact 
                                         Where Id =: objContact.Id];
            
            System.assertEquals(objUpdatedContact.acfComm__Community_Experience_selected__c, 'fletcher');
            System.assertEquals(System.currentPageReference().getUrl().contains('/home/home.jsp'), true);

            test.stopTest();
        }// RunAs    
    }//test_autoCommunityExperience 
}