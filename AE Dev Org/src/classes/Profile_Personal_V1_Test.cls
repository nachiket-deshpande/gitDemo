@isTest
private class Profile_Personal_V1_Test {
    
    @isTest static void test_method_one() {

        Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage1();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        Sobject objRecord;
        boolean isEditable = true;
        Profile_Personal_V1.wrapperEditableRecords objwrapper = new Profile_Personal_V1.wrapperEditableRecords(objRecord,isEditable);
        
        PageReference pageRef = Page.Profile_Page1;
        controller.isEditMode = null;
        //controller.QueryPage1();
        
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);
        
        controller.QueryPage1();
        controller.saveSobjectRecord();
        controller.EditSobjectRecord();
        controller.deleteRelatedList();
        controller.cancel();
       
    }
    
    @isTest static void test_method_ProfilePage2() {
       Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage2();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        Sobject objRecord;
        boolean isEditable = true;
        Profile_Personal_V1.wrapperEditableRecords objwrapper = new Profile_Personal_V1.wrapperEditableRecords(objRecord,isEditable);
        
        PageReference pageRef = Page.Profile_Page2;
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);
    
        controller.QueryPage2();
        controller.saveSobjectRecord();
        controller.EditSobjectRecord();
        controller.deleteRelatedList();
        controller.cancel();
        
        
        controller.createRelatedListFullRecord();
        controller.saveSobjectRecordToList();
        controller.editRelatedList();
        controller.UpdateRelatedFullRecord();
        controller.cancelRelatedFullRecord();
        controller.redirectOnBlankPage();
        controller.setMobileMode();
        controller.setDesktopMode();
        controller.QueryPage3();
        controller.QueryPage4();
        controller.QueryPage5();
        controller.getPicklistFieldValues(null);
    }
    
    
    @isTest static void test_method_ProfilePage3() {
       Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage3();
        Student_Enrollment__c st = new Student_Enrollment__c(name='st1', Contact__c = c.id, LastEnrollmentTerm__c='2020');
        insert st;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        Sobject objRecord;
        boolean isEditable = true;
        Profile_Personal_V1.wrapperEditableRecords objwrapper = new Profile_Personal_V1.wrapperEditableRecords(objRecord,isEditable);
        
        PageReference pageRef = Page.Profile_Page3;
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);

        controller.QueryPage3();
        system.debug('\n\n\n sectionIdToObjMap4:After '+ controller.sectionIdToObjMap +'\n\n\n');
        controller.isEditMode = false;
        controller.createRelatedListFullRecord();
        controller.saveSobjectRecord();
        controller.EditSobjectRecord();
        controller.deleteRelatedList();
        controller.cancel();
        controller.isEditMode = true;
        controller.saveSobjectRecordToList();
        controller.editRelatedList();
        controller.UpdateRelatedFullRecord();
        controller.cancelRelatedFullRecord();
        controller.redirectOnBlankPage();
        controller.setMobileMode();
        controller.setDesktopMode();
    }
    /*
    @isTest static void test_method_ProfilePage4() {
       Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage4();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        Sobject objRecord;
        boolean isEditable = true;
        Profile_Personal_V1.wrapperEditableRecords objwrapper = new Profile_Personal_V1.wrapperEditableRecords(objRecord,isEditable);
        
        PageReference pageRef = Page.Profile_Page4;
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);

        controller.QueryPage4();
        controller.saveSobjectRecord();
        controller.EditSobjectRecord();
        controller.deleteRelatedList();
        controller.cancel();
    }
    
    @isTest static void test_method_ProfilePage5() {
       Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where name='Customer Community User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage5();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        Sobject objRecord;
        boolean isEditable = true;
        Profile_Personal_V1.wrapperEditableRecords objwrapper = new Profile_Personal_V1.wrapperEditableRecords(objRecord,isEditable);
        
        PageReference pageRef = Page.Profile_Page5;
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);

        controller.QueryPage5();
        
    }*/
}