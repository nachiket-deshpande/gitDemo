@istest
public with sharing class DirectorySearchIframeTest {
    public static testmethod void testHP_DirectorySearchIframeTest(){
        TestDataFactoryClass.AddDomainName();
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
        system.runAs(u){
            DirectorySearchIframe directoryIframe = new DirectorySearchIframe ();
            system.assertequals(directoryIframe.profileDomainCustomSetting.DomainName__c , UtilityGeneral.getProfileDomainName().domainName__c);
        }
    }//End testmethod
}//End class