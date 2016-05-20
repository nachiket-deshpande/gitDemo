@isTest
private class Generic_Profile_Personal_V1_Test {
    
    @isTest static void test_method_one() {

        Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where UserLicenseId IN (Select id From UserLicense u where u.name='Customer Community Login') limit 1];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;

        Profile_Subsection__c ps = new Profile_Subsection__c(name='first Name', Column_Span__c='1', Field_API_Name__c='firstName', 
            Order__c='1', Field_Name__c='First Name');
        insert ps;
        Profile_Page_1__c twoCol = new Profile_Page_1__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='2 column', Field_API_For_Contact_Id__c='id');
        insert twoCol;
        
        //Custom object
        list<Community_Web_Content__c> lstWebContent = new list<Community_Web_Content__c>();
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage',Page_Content__c ='Profile_Personal_V1'));
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage2',Page_Content__c ='Profile_Personal_V1_Test'));
        insert lstWebContent;

        Profile_Page_2__c twoCol2 = new Profile_Page_2__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='2 column', Field_API_For_Contact_Id__c='id');
        insert twoCol2;
        Profile_Page_1__c subSection = new Profile_Page_1__c(Name='Subsection Test', Order__c='2', Custom_Setting__c='Profile_Page_2__c',
            Title__c='Subsection Test', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id');
        insert subSection;

        
        ApexPages.StandardController sc = new ApexPages.StandardController(u);
        Profile_Personal_V1 controller = new Profile_Personal_V1(sc);
        
        PageReference pageRef = Page.Profile_Page1;
        pageRef.getParameters().put('sfdc.userId', String.valueOf(u.Id));

        pageRef.getParameters().put('Id', String.valueOf(u.Id));
        Test.setCurrentPage(pageRef);
        
        controller.isEditMode = null;
        controller.currentUserContactId = '';
        
        controller.QueryPage1();
        controller.QueryPage2();
        controller.QueryPage3();
        controller.QueryPage4();
        controller.QueryPage5();

        controller.EditSobjectRecord();
        controller.currentContact = c;
        controller.saveSobjectRecord();
        controller.currentContact = null;
        controller.saveSobjectRecord();
        controller.cancel();  
        
        controller.setDesktopMode();
        controller.setMobileMode();
        controller.redirectOnBlankPage();
        controller.createRelatedListFullRecord();
        Profile_Personal_V1.wrapperEditableRecords objWrapper = new Profile_Personal_V1.wrapperEditableRecords(null, true);
        Profile_Personal_V1.fieldWrapperClass objFieldWrapper = new Profile_Personal_V1.fieldWrapperClass(null, null, null);
        
        controller.deleteRelatedList();
        controller.saveSobjectRecordToList();
        controller.cancelRelatedFullRecord();
        controller.editRelatedList();
        controller.UpdateRelatedFullRecord();
        controller.subTabHTML='';
        controller.sectionIdToBranchObj = null;
        controller.mapWebContent = null;
        controller.lstSectionCustomSetting= null;
        controller.mapCustomFieldWithSelectList= null;
        controller.lstWrapper= null;
        controller.isInit= null;
        controller.relatedFullCancelId= null;
        controller.strSelectOptionValue = null;
        controller.lstRelatedFullRecordId = null;
              
    }
}


/*@isTest
private class Profile_Personal_V1_Test {
    
    @isTest static void test_method_one() {

        Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where UserLicenseId IN (Select id From UserLicense u where u.name='Customer Community Login') limit 1];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com', ContactId=c.Id);
        insert u;
        
        TestDataFactoryClass.Add_Custom_Setting_ProfilePage();
        
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
    /*
    @isTest static void test_method_ProfilePage2() {
       Account a = new Account(name='testAcc');
        insert a;
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        Profile p = [select id from profile where UserLicenseId IN (Select id From UserLicense u where u.name='Customer Community Login') limit 1];
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
        Profile p = [select id from profile where UserLicenseId IN (Select id From UserLicense u where u.name='Customer Community Login') limit 1];
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
    }*/
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
        
    }
}*/