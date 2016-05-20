@isTest
private class JobSearchTest {
    
    @isTest static void test_method_one() 
    {

        HP_ProfileSubCommunityType__c  subCommType = new HP_ProfileSubCommunityType__c(name='testCommunity', Sub_Community_Type__c='contact', Field_API_Name__c='firstname');
        insert subCommType;
        
        Job_Search_Fields__c fielCustomSetting = new Job_Search_Fields__c(name='Job Title', Field_Label__c = 'Job Title',Field_Name__c='title',Field_Order__c='1',Section_Label__c='Test',Section_Order__c='1',Field_Type__c='checkbox');
        insert fielCustomSetting;
        Job_Search_Fields__c fielCustomSetting2 = new Job_Search_Fields__c(name='Job Title', Field_Label__c = 'Job Title',Field_Name__c='title',Field_Order__c='2',Section_Label__c='Test',Section_Order__c='2',Field_Type__c='picklist',Picklist_Values__c ='Community_Web_Content__c. ; city1 ; city2 ;');
        insert fielCustomSetting2;
        Job_Search_Fields__c fielCustomSetting3 = new Job_Search_Fields__c(name='Job Title', Field_Label__c = 'Job Title',Field_Name__c='title',Field_Order__c='3',Section_Label__c='Test',Section_Order__c='3');
        insert fielCustomSetting3;

        

        Job_Search_Pagination_Fields__c pageFields = new Job_Search_Pagination_Fields__c(name='pageFields', Per_Page_Pagesize__c = 1, Per_Page_Records__c= 1, sortingParameters__c ='First Name:contact.firstname,Last Name:contact.lastname');
        insert pageFields;

        ProfileDomainName__c pfDomain = new ProfileDomainName__c(name='CommunityDomain',DomainName__c='alumni');
        insert pfDomain;

        PageReference pageRef = Page.JobSearch;
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        JobSearch controller = new JobSearch();
        system.assertequals( controller.profileDomain ,'alumni'); 
        Test.StopTest();
    }
}