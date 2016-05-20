/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Siddharth Pandit
    Created Date: June 16, 2015
    Description: This Class is used to create the test data
-----------------------------------------------------------------------*/
@istest
public class TestDataFactoryClass {
    //Method to insert Domain name for community
    public static void addDomainName(String domainName){
        ProfileDomainName__c objDomain = new ProfileDomainName__c();
        objDomain.DomainName__c = domainName;
        objDomain.name='CommunityDomain';
        try{
            insert objDomain;
        }
        catch(DmlException d){
        }
    }//End Method
    
    public static void addCustomSetting()
    {
        Mobile_Card__c settingMobileCard = new Mobile_Card__c();
        settingMobileCard.Name = 'Academic';
        settingMobileCard.Link__c = 'https://www.google.co.in/';
        settingMobileCard.Title__c = 'Whatever';
        settingMobileCard.Label__c = 'View';
        insert settingMobileCard;
    }
    
        //Method to create profile custom Setting Data
    public static void AddClassNoteSettingData(){
        list<Class_Notes_Fields_CustomSetting__c> classnote = new list<Class_Notes_Fields_CustomSetting__c>();
        for(integer count = 1; count<= 200; count++)
            classnote.add(new Class_Notes_Fields_CustomSetting__c(Field_Name__c='Category__c' + count, Label__c = 'Category' + count, Order__c = String.ValueOf(count)));
        insert classnote;   
    }//End Method
    
    //Method to create LoginFlowCustomSetting Data
    public static list<Sobject> AddLoginFlowCustomSettingData(){
        list<LoginFlowCustomSetting__c> loginFlow = new list<LoginFlowCustomSetting__c>();
        for(integer count = 1; count<=200 ; count++)
            loginFlow.add(new LoginFlowCustomSetting__c(Name = 'Page ' + count, PageName__c= 'Page_' + count, PageNumber__c = count));
        insert loginFlow;
        
        return (list<Sobject>)LoginFlowCustomSetting__c.getAll().Values();
    }//End Method    
    
    public static void addClassNoteSubmissionData(){
        list<Class_Note_Submission_Fields__c> lstClassNoteSubmission = new list<Class_Note_Submission_Fields__c>();
        lstClassNoteSubmission.add(new Class_Note_Submission_Fields__c(name='Category', Field_Name__c='Category__c',Label__c='Category',Order__c='1'));
        lstClassNoteSubmission.add(new Class_Note_Submission_Fields__c(name='Class Note', Field_Name__c='ClassNote__c',Label__c='Class Note',Order__c='2'));
        lstClassNoteSubmission.add(new Class_Note_Submission_Fields__c(name='Include in Allegheny magazine', Field_Name__c='Include_in_Allegheny_magazine__c',Label__c='Include in Allegheny magazine',Order__c='3'));
        lstClassNoteSubmission.add(new Class_Note_Submission_Fields__c(name='Post online', Field_Name__c='Post_online__c',Label__c='Post online',Order__c='4'));
        insert lstClassNoteSubmission;
    }//End method
    
    public static list<Community_Web_Content__c> getWebContentRecords(){
        list<Community_Web_Content__c> lstWebContent = new list<Community_Web_Content__c>();
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage',Page_Content__c ='Community Web Content1'));
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage2',Page_Content__c ='Community Web Content2'));
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage3',Page_Content__c ='Community Web Content3'));
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage4',Page_Content__c ='Community Web Content4'));
        lstWebContent.add(new Community_Web_Content__c(name='TestWebContentPage5',Page_Content__c ='Community Web Content5'));
        insert lstWebContent;
        return lstWebContent;
        
    }
    
    
    //method is called from MobileLinkPageControllerTest to create the custom setting data .
    public static void AddMobileLinkSettingData(){
        //insert HP_Mobile_Links__c custom setting data
        list<HP_Mobile_Links__c> lstMobContent = new list<HP_Mobile_Links__c>();
        lstMobContent.add(new HP_Mobile_Links__c(Name= 'ColumbiaUniversityResource',
                            Custom_Setting__c='HP_Custom_Link__c',Title__c='ColumbiaUniversityResource'));
        insert lstMobContent ;
        
        // insert HP_Custom_Link__c custom setting data .
        list<HP_Custom_Link__c > lstMobLinkContent = new list<HP_Custom_Link__c >();
        lstMobLinkContent.add(new HP_Custom_Link__c (name = 'Admissions',Link_Text__c='Admissions',Link_URL__c='/Admissions'));
        insert lstMobLinkContent ;        
    }
    
    public static void Add_Custom_Setting_ProfilePage(){
        Profile_Page_1__c twoCol1 = new Profile_Page_1__c(Name='2 Column Layout Test', Order__c='1', 
                                                          Custom_Setting__c='Profile_Subsection__c',
                                                          Title__c='2 Column Layout Test',
                                                          Object__c='Contact', Custom_Setting_Type__c='2 column',
                                                          Field_API_For_Contact_Id__c='id');
        insert twoCol1;
        
        Profile_Page_2__c relatedListCompact = new Profile_Page_2__c(Name='related list compact Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            //Title__c='2 Column Layout Test', Object__c='Student_Enrollment__c', Custom_Setting_Type__c='related list compact', Field_API_For_Contact_Id__c='id', related_list_static_where__c ='LastEnrollmentTerm__c =\'2020\'');
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id');
        insert relatedListCompact;
        
        Profile_Page_3__c twoCol3 = new Profile_Page_3__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id');
         insert twoCol3;
         
        Profile_Page_4__c twoCol4 = new Profile_Page_4__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id');
         insert twoCol4;
         
         Profile_Page_5__c twoCol5 = new Profile_Page_5__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Subsection__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='2 column', Field_API_For_Contact_Id__c='id');
         insert twoCol5;
    }
    
     public static void Add_Custom_Setting_ProfilePage1(){
         Profile_Page_1__c twoCol1 = new Profile_Page_1__c(Name='2 Column Layout Test', Order__c='1', 
                                                          Custom_Setting__c='Profile_Subsection__c',
                                                          Title__c='2 Column Layout Test',
                                                          Object__c='Contact', Custom_Setting_Type__c='2 column',
                                                          Field_API_For_Contact_Id__c='id');
         insert twoCol1;
         
         Profile_Page_1__c subSection = new Profile_Page_1__c(Name='Subsection Test', Order__c='2', Custom_Setting__c='Profile_Personal_SubSection__c',
            Title__c='Subsection Test1', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id', Privacy_Field_API__c='Company_Address_Privacy__c');
         insert subSection;
         
         Profile_Page_1__c subSection1 = new Profile_Page_1__c(Name='Subsection Test', Order__c='2', Custom_Setting__c='Profile_Personal_SubSection__c',
            Title__c='Subsection Test', Object__c='Contact', Custom_Setting_Type__c='subsection', Field_API_For_Contact_Id__c='id', Privacy_Field_API__c='Company_Address_Privacy__c');
         insert subSection1;
         
         Profile_Personal_SubSection__c profileSubsection2 = new Profile_Personal_SubSection__c(name='Local/Company Address', Custom_Setting_Type__c='2 column',Field_API_For_Contact_Id__c='id',Object__c='Contact',Privacy_Field_API__c='Company_Address_Privacy__c', Order__c='1', Custom_Setting__c ='Profile_Personal_Additional_Fields__c');
         insert profileSubsection2;
         
         Profile_Personal_SubSection__c profileSubsection3 = new Profile_Personal_SubSection__c(name='Local/Company Address', Custom_Setting_Type__c='related list full',Field_API_For_Contact_Id__c='id',Object__c='Contact',Privacy_Field_API__c='Company_Address_Privacy__c', Order__c='1', Custom_Setting__c ='Profile_Personal_Additional_Fields__c');
         
         
         
         list<Profile_Personal_Additional_Fields__c> ps = new list<Profile_Personal_Additional_Fields__c>();
         ps.add(new Profile_Personal_Additional_Fields__c(name='first Name', Column_Span__c='1', Field_API_Name__c='firstName', Order__c='1', Field_Name__c='First Name'));
         ps.add(new Profile_Personal_Additional_Fields__c(name='Last Name', Column_Span__c='1', Field_API_Name__c='lastName', Order__c='2', Field_Name__c='Last Name', Privacy_Field_API__c='Company_Address_Privacy__c'));
         ps.add(new Profile_Personal_Additional_Fields__c(name='Address Privacy', Column_Span__c='1', Field_API_Name__c='Company_Address_Privacy__c', Order__c='3', Field_Name__c='Company Address'));
         
         insert ps;
         
         Profile_Subsection__c ps2 = new Profile_Subsection__c(name='first Name', Column_Span__c='1', Field_API_Name__c='firstName', Order__c='1', Field_Name__c='First Name', Privacy_Field_API__c='Company_Address_Privacy__c');
         insert ps2;
         
         Profile_Page_2__c relatedListCompact = new Profile_Page_2__c(Name='related list compact Test', Order__c='1', Custom_Setting__c='acfComm__Profile_Personal_Profile_Degree_Fields__c',
            //Title__c='2 Column Layout Test', Object__c='Student_Enrollment__c', Custom_Setting_Type__c='related list compact', Field_API_For_Contact_Id__c='id', related_list_static_where__c ='LastEnrollmentTerm__c =\'2020\'');
            Title__c='2 Column Layout Test', Object__c='Student_Enrollment__c', Custom_Setting_Type__c='related list compact', Field_API_For_Contact_Id__c='id', related_list_static_where__c ='LastEnrollmentTerm__c = 2020');
         insert relatedListCompact;
         
         
         Profile_Personal_Profile_Degree_Fields__c relatedListCompactFields = new Profile_Personal_Profile_Degree_Fields__c(Name='related list compact Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Last Enrollment Term',Privacy_Field_API__c='LastEnrollmentTerm__c' );
         insert relatedListCompactFields;
         
         Profile_Personal_Employee_Info_Fields__c relatedListFullFields = new Profile_Personal_Employee_Info_Fields__c(Name='related list full Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Student Enrollment Term');
         insert relatedListFullFields;
         

         
         
     }
     
     public static void Add_Custom_Setting_ProfilePage2(){
         Profile_Page_2__c relatedListCompact = new Profile_Page_2__c(Name='related list compact Test', Order__c='1', Custom_Setting__c='acfComm__Profile_Personal_Profile_Degree_Fields__c',
            //Title__c='2 Column Layout Test', Object__c='Student_Enrollment__c', Custom_Setting_Type__c='related list compact', Field_API_For_Contact_Id__c='id', related_list_static_where__c ='LastEnrollmentTerm__c =\'2020\'');
            Title__c='2 Column Layout Test', Object__c='Student_Enrollment__c', Custom_Setting_Type__c='related list compact', Field_API_For_Contact_Id__c='id', related_list_static_where__c ='LastEnrollmentTerm__c = 2020');
         insert relatedListCompact;
         
         
         Profile_Personal_Profile_Degree_Fields__c relatedListCompactFields = new Profile_Personal_Profile_Degree_Fields__c(Name='related list compact Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Last Enrollment Term',Privacy_Field_API__c='LastEnrollmentTerm__c' );
         insert relatedListCompactFields;
         
         Profile_Personal_Employee_Info_Fields__c relatedListFullFields = new Profile_Personal_Employee_Info_Fields__c(Name='related list full Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Student Enrollment Term');
         insert relatedListFullFields;
         

         
     }
     
     public static void Add_Custom_Setting_ProfilePage3(){
         Profile_Page_3__c twoCol3 = new Profile_Page_3__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Personal_Employee_Info_Fields__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='related list full', Field_API_For_Contact_Id__c='id');
         insert twoCol3;
         
         
         Profile_Personal_Employee_Info_Fields__c relatedListFullFields = new Profile_Personal_Employee_Info_Fields__c(Name='related list full Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Student Enrollment Term');
         insert relatedListFullFields;
         
         Community_Web_Content__c cv = new Community_Web_Content__c(name='picklist', Content__c='AB;CD;EF;GH;IJ;KL;MN;OP;QR;ST;UV;WX;YZ', Page_Content__c='AB;CD;EF;GH;IJ;KL;MN;OP;QR;ST;UV;WX;YZ', Title__c='picklist');
        
         insert cv;
     }
     
     public static void Add_Custom_Setting_ProfilePage4(){
         
         Profile_Page_4__c twoCol4 = new Profile_Page_4__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Personal_Employee_Info_Fields__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='related list full', Field_API_For_Contact_Id__c='id');
         insert twoCol4;
         
         Profile_Personal_Employee_Info_Fields__c relatedListFullFields = new Profile_Personal_Employee_Info_Fields__c(Name='related list full Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Student Enrollment Term');
         insert relatedListFullFields;
     }
     
     public static void Add_Custom_Setting_ProfilePage5(){
         
         Profile_Page_5__c twoCol5 = new Profile_Page_5__c(Name='2 Column Layout Test', Order__c='1', Custom_Setting__c='Profile_Personal_Employee_Info_Fields__c',
            Title__c='2 Column Layout Test', Object__c='Contact', Custom_Setting_Type__c='2 column', Field_API_For_Contact_Id__c='id');
         insert twoCol5;
         
         Profile_Personal_Employee_Info_Fields__c relatedListFullFields = new Profile_Personal_Employee_Info_Fields__c(Name='related list full Test', Order__c='1',
                                                                            Field_API_Name__c='LastEnrollmentTerm__c',Field_Name__c='Student Enrollment Term');
         insert relatedListFullFields;
        
     }
     
     public static void insertCustomSearchRegistration(){
	     Custom_Search_Registration__c objCustomSearchReg = new Custom_Search_Registration__c(name='testCustomSearch' ,PageName__c ='communityaccessrequest', Record_Name__c= 'TestWebContentPage');
	     insert objCustomSearchReg;
     }
    
}//End class