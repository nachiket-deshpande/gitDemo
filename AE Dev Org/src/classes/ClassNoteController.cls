/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Siddharth Pandit
    Created Date: April 4,2015
    Description: Controller class used to display calss note information.
-----------------------------------------------------------------------*/

public with sharing class ClassNoteController {
    public Community_Web_Content__c communityWebContent{ get; set; }// object for Community_Web_Content__c to display the content on the page
    public list<Sobject> lstClassNotes{ get; set; }
    public list<Sobject> lstCustomSettingFields{ get; set; }
   // public boolean displayPopup{ get; set;}
    public static final String CLASS_NOTE_OBJECT = 'Classnotes__c';
    public static final String ORDER_FIELD = 'Order__c';
    public static final String API_FIELD_NAME = 'Field_Name__c';
    public static final String QUERY_LIMIT = '500';
    public static final String STATC_WHERE = 'CreatedDate>LAST_N_YEARS:2';


    //Constructor
    public ClassNoteController(){
        init();
        lstClassNotes = new list<Sobject>();
        list<Sobject> lstFieldsCustomSetting = getFieldsFromCustomSetting();
        //String queryClassNotes = UtilityGeneral.construcuDynamicQueryforFields(lstFieldsCustomSetting,CLASS_NOTE_OBJECT,API_FIELD_NAME, 'Approved__c=TRUE');
        String queryClassNotes = UtilityGeneral.construcuDynamicQueryforFields(lstFieldsCustomSetting,CLASS_NOTE_OBJECT,API_FIELD_NAME, STATC_WHERE, QUERY_LIMIT);
        system.debug('\n\n\n queryClassNotes: '+queryClassNotes+'\n\n\n');
        lstClassNotes = UtilityGeneral.getObjectRecords(queryClassNotes);
        lstCustomSettingFields = UtilityGeneral.getOrderwiseFields(lstFieldsCustomSetting,ORDER_FIELD);
    }//End Constructor
    
    //method to initialize the variables
    public void init(){
        lstCustomSettingFields = new list<Sobject>();
        
        communityWebContent = new Community_Web_Content__c();
        system.debug('**ApexPages.CurrentPage().getUrl()' + ApexPages.CurrentPage().getUrl());
        communityWebContent = UtilityGeneral.getWebContent(ApexPages.CurrentPage().getUrl());
        system.debug('communityWebContent ==='+communityWebContent );
    }//end method

    public list<Sobject> getFieldsFromCustomSetting(){
        return Class_Notes_Fields_CustomSetting__c.getAll().values();
    }//End method

    //Method which redirects to Submit class Note Url
    public pageReference redirectToSubmitPage(){
        ProfileDomainName__c domainName = UtilityGeneral.getProfileDomainName();
        String page_Url = '/' + domainName.DomainName__c + '/ClassnoteSubmissionPage';
        return UtilityGeneral.redirect(page_Url, true);
    }//End method
}//End Class