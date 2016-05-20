/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 16, 2015
    Description: Custom search Registration controller Test class
-----------------------------------------------------------------------*/
@isTest
private class CustomSearchRegistrationControllerTest {

    //Creates account object.
    private static Account createAccount(String accountName) {

        Account objAccount  = new Account() ;
        objAccount.Name = accountName;
        return objAccount; 
    }

    //Creates contact object.
    public static Contact createContact(String contactFirstName, String contactLastName, Id accountId, String bannerId) {

        Contact objContact = new Contact ();
        objContact.FirstName = contactFirstName;
        objContact.LastName = contactLastName;
        objContact.email = 'test@test.com';
        //objContact.Student_ID__c = bannerId;
        //objContact.Class_Year__c = 2000;
        //objContact.Degree__c = 'MS';
        objContact.AccountId = accountId;
        return objContact;
    }

    //When the student Id is provided in the input.
    static testMethod void testUserUpdateStudentId() {
        Account objAccount = createAccount('Test Account');
        insert objAccount;

        Contact objContact = createContact('test','Test Contact', objAccount.Id, '1');
        insert objContact;

        Id objProfileId = [Select Id From profile where Name='Partner Community User'].id;
        
        User objUser = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =false,ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert objUser;
        test.startTest();
            CustomSearchRegistrationController objCustomSearchRegistrationController = new CustomSearchRegistrationController();
            objCustomSearchRegistrationController.firstName = 'test';
            objCustomSearchRegistrationController.lastName = 'Test Contact';
            objCustomSearchRegistrationController.email = 'test@test.com';
            objCustomSearchRegistrationController.studentId = '1';
            //objCustomSearchRegistrationController.updateUser();
            Boolean userIsActive = [Select isActive from User where id =: objUser.Id].isActive;
            system.assert(userIsActive, true);
        test.stopTest();
    }

    //When the Class year and Degree are provided in the input.
    /*static testMethod void testUserUpdateClassYearDegree() {
        Account objAccount = createAccount('Test Account');
        insert objAccount;

        Contact objContact = createContact('test','Test Contact', objAccount.Id, '1');
        insert objContact;

        Id objProfileId = [Select Id From profile where Name='Partner Community User'].id;
        
        User objUser = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =false,ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert objUser;
        test.startTest();
            CustomSearchRegistrationController objCustomSearchRegistrationController = new CustomSearchRegistrationController();
            objCustomSearchRegistrationController.firstName = 'test';
            objCustomSearchRegistrationController.lastName = 'Test Contact';
            objCustomSearchRegistrationController.email = 'test@test.com';
            objCustomSearchRegistrationController.classYear = '2000';
            objCustomSearchRegistrationController.degree = 'MS';
            objCustomSearchRegistrationController.updateUser();
            Boolean userIsActive = [Select isActive from User where id =: objUser.Id].isActive;
            system.assert(userIsActive, true);
        test.stopTest();
    }

    //When no match is found.
    static testMethod void testUserUpdateWhenNoMatchFound() {
        Account objAccount = createAccount('Test Account');
        insert objAccount;

        Contact objContact = createContact('test','Test Contact', objAccount.Id, '1');
        insert objContact;

        Id objProfileId = [Select Id From profile where Name='Partner Community User'].id;
        
        User objUser = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =false,ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert objUser;
        test.startTest();
            CustomSearchRegistrationController objCustomSearchRegistrationController = new CustomSearchRegistrationController();
            objCustomSearchRegistrationController.firstName = 'test1';
            objCustomSearchRegistrationController.lastName = 'Test Contact';
            objCustomSearchRegistrationController.email = 'test@test.com';
            objCustomSearchRegistrationController.classYear = '2000';
            objCustomSearchRegistrationController.degree = 'MS';
            objCustomSearchRegistrationController.updateUser();
            Boolean userIsActive = [Select isActive from User where id =: objUser.Id].isActive;
            //system.assert(userIsActive, true);
    
            Boolean messageFound = false;
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            system.debug('pageMessages===>>> '+pageMessages);
            for(ApexPages.Message message : pageMessages) {
                system.debug('message.getDetail()====>>> '+message.getDetail());
                system.debug('message.getSummary()====>>> '+message.getSummary());
                if(message.getDetail() == 'Error: No Match Found') {
                    messageFound = true;        
                }
            }
            System.assert(messageFound);
            //system.assert(userIsActive, false);
        test.stopTest();
    }*/
    
    //When more than 1 match found.
    static testMethod void testUserUpdateWhenMoreThanOneMatchFound() {
        Account objAccount = createAccount('Test Account');
        insert objAccount;

        Contact objContact = createContact('test','Test Contact', objAccount.Id, '1');
        insert objContact;
        system.debug('This is debug number 0....');
        Contact objContact_1 = createContact('test','Test Contact', objAccount.Id, '2');
        insert objContact_1;
        system.debug('This is debug number 1....');
        Id objProfileId = [Select Id From profile where Name='Partner Community User'].id;

        User objUser = new User(alias = 'test123', email='test123@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =false,ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert objUser;
        system.debug('This is debug number 2....');
        User objUser_1 = new User(alias = 'test345', email='test123_1@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing_1', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = objProfileId, country='United States',
                                IsActive =true,ContactId = objContact_1.Id,
                                timezonesidkey='America/Los_Angeles', username='tester_1@noemail.com');
        insert objUser_1;

        test.startTest();
            CustomSearchRegistrationController objCustomSearchRegistrationController = new CustomSearchRegistrationController();
            objCustomSearchRegistrationController.firstName = 'test';
            objCustomSearchRegistrationController.lastName = 'Test Contact';
            //objCustomSearchRegistrationController.updateUser();
            objCustomSearchRegistrationController.getSearchSelectionCriteria();
            //objCustomSearchRegistrationController.getDegreeList();
            //Boolean userIsActive = [Select isActive from User where id =: objUser.Id].isActive;
            //system.assert(userIsActive, true);
    
            Boolean messageFound = false;
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            system.debug('pageMessages===>>> '+pageMessages);
            for(ApexPages.Message message : pageMessages) {
                system.debug('message.getDetail()====>>> '+message.getDetail());
                system.debug('message.getSummary()====>>> '+message.getSummary());
                if(message.getDetail() == 'Error: No Exact Match or Too Many Records Found') {
                    messageFound = true;        
                }
            }
            System.assert(messageFound);
            //system.assert(userIsActive, false);
        test.stopTest();
    }
}