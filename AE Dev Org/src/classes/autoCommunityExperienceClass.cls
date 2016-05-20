/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 09, 2015
    Description: AutoCommunityExperienceController is to update the logged in user's 
                 contact's Community_Experience_selected__c field with the brand parameter of values 'Tufts' or 'Fletcher'.
-----------------------------------------------------------------------*/
public class autoCommunityExperienceClass {
    public autoCommunityExperienceClass(){
    }
    
    @AuraEnabled
    public static void getCurrentPageUrl(string currentUrl) {
        string strBrandValue= '';
        system.debug('--getCurrentPageURL---'+currentUrl);
        updateContact(currentUrl);        
    }

    
    //This method fetches the brand parameter from URL.
    public static String getBrandParameter(string currentUrl) {
        string strBrandValue= '';
        if(currentUrl.containsIgnoreCase('brand=') && currentUrl.substringAfter('brand=') != Null){
            strBrandValue = currentUrl.substringAfter('brand=').trim();
        }
        return strBrandValue;
    }
    
    //This method updates the contact record.
    public static void updateContact(string currentUrl) {
        String brandParameter = getBrandParameter(currentUrl);
        system.debug('brandParameter===>>> '+brandParameter);
        list<Contact> listContact = getLoggedInContact();
        system.debug('listContact===>>> '+listContact);
        List<Contact> listUpdateContact = new List<Contact>();
        if(listContact != null && listContact.size()>0) {
            system.debug('This is inside first If....');
            for(Contact contact : listContact){
                if(contact.acfComm__Community_Experience_selected__c != brandParameter 
                    && (brandParameter== 'Tufts' || brandParameter =='Fletcher')){
                    contact.Community_Experience_selected__c = brandParameter;
                }
                listUpdateContact.add(contact);
            }
        } 
        system.debug('listUpdateContact====>>> '+listUpdateContact);
       try {
            if(listUpdateContact != null && listUpdateContact.size() > 0){
                Database.update(listUpdateContact);
            }
       }
       catch(Exception e)
      {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
              ApexPages.addMessage(myMsg);
      }
    }
    //This method fetches the current logged in users Id.
    public static String getLoggedInUser(){
        return system.UserInfo.getUserId();
    }
    
    //This method fetches the contact of the logged in user. 
    public static list<Contact> getLoggedInContact() {
        String userId = '005o0000001EE2nAAG';//getLoggedInUser();
        system.debug('userId===>>> '+userId);
        /*User loggedInUserObj;
        if(!String.isBlank(userId)){
            loggedInUserObj = [Select ContactId From User where Id =: userId LIMIT 1];
        }
        system.debug('loggedInUserObj====>>> '+loggedInUserObj);
        */
        String contactId = UtilityGeneral.getContactIdFromUser(userId);
        list<Contact> loggedInUserContact = new list<Contact>();
        if(!String.isBlank(contactId)){
            loggedInUserContact = [Select Id, acfComm__Community_Experience_selected__c From Contact where Id =: contactId LIMIT 1];
        } 
        return loggedInUserContact;
    }
}