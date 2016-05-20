@istest
public class CommunityAccessRequestControllerTest {
    @isTest static void test_method_one(){
    	Account a = new Account(name='testAcc');
        insert a;
      
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='standarduser@test.com',
                          ContactId=c.Id);
        insert u;
        
        System.runAs(u){
            Test.setCurrentPageReference(Page.CommunityAccessRequest);
	        list<Community_Web_Content__c> lstWbContents = TestDataFactoryClass.getWebContentRecords();
	        CommunityAccessRequestController objCommAccess = new CommunityAccessRequestController();
	        objCommAccess.retriveCustomSetting(null);
	        TestDataFactoryClass.insertCustomSearchRegistration();
	        objCommAccess = new CommunityAccessRequestController();
	        objCommAccess.saveContact();
	        objCommAccess.objCommunityAccessRequest.FirstName__c = 'Test';
	        objCommAccess.saveContact();
	        objCommAccess.objCommunityAccessRequest.Last_Name__c = 'TestObject';
	        objCommAccess.saveContact();
	        objCommAccess.objCommunityAccessRequest.Current_Email__c = 'Test@test.com';
	        objCommAccess.saveContact();
	        objCommAccess.objCommunityAccessRequest.Current_Email__c = '123456';
	        objCommAccess.saveContact();
	        TestDataFactoryClass.addDomainName('alumni');
	        objCommAccess.backPage();
	        objCommAccess.sendEmail();
	        objCommAccess.objCommunityAccessRequest.Current_Email__c = null;
	        objCommAccess.sendEmail();
	        objCommAccess.clearFields();
	        system.assertEquals(objCommAccess.IsInfoWindow, false);
        }
    	
    }
}