@istest
public class ClassNoteControllerTest {
     @isTest static void test_method_one() {
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
        
        list<Class_Notes_Fields_CustomSetting__c> objClassNoteFields = new list<Class_Notes_Fields_CustomSetting__c>();
         
        
            objClassNoteFields.add(new Class_Notes_Fields_CustomSetting__c(name='Category', Label__c='Category',Field_Name__c='acfComm__Category__c',Order__c = '1'));
            objClassNoteFields.add(new Class_Notes_Fields_CustomSetting__c(name='Class Note', Label__c='Class Note',Field_Name__c='acfComm__ClassNote__c',Order__c ='2'));
            objClassNoteFields.add(new Class_Notes_Fields_CustomSetting__c(name='Photo Upload', Label__c='Photo Upload',Field_Name__c='Photo_Upload__c',Order__c ='3'));

        
        insert objClassNoteFields;
        
        list<Classnotes__c>  objClassNote = new list<Classnotes__c>();
        objClassNote.add(new Classnotes__c(Category__c='Budgeting', ClassNote__c='class', Contact__c=c.Id));
        objClassNote.add(new Classnotes__c(Category__c='planning', ClassNote__c='class', Contact__c=c.Id));
        
        insert objClassNote;
        
        
        // create profile domainName custom setting 
        TestDataFactoryClass.addDomainName('alumni');
        system.runAs(u){
            
            PageReference pageRef = Page.Class_Note_Page;
            Test.setCurrentPage(pageRef);
            
            ClassNoteController classNoteObj = new ClassNoteController();
            classNoteObj.redirectToSubmitPage();
            system.assertEquals(true, classNoteObj.lstCustomSettingFields.size() > 0);
        }
     }
}