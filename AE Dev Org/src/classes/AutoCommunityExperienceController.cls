/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 10, 2015
    Description: AutoCommunityExperienceController is to update the logged in user's 
                 contact's Community_Experience_selected__c field with the brand parameter 
                 of values 'Tufts' or 'Fletcher'.
                 Redirect to home page once the update is completed on contact if the URL has parameter redirect = true. 
-----------------------------------------------------------------------*/
public class AutoCommunityExperienceController {

    public String communityHomePage = '';            //Holds the URL for the home page.

    public String brandParameter;                    //Holds the brand parameter value from the URL.

    //Constructor
    public AutoCommunityExperienceController() {

        ProfileDomainName__c Domain_Name = UtilityGeneral.getProfileDomainName();
        communityHomePage = Domain_Name.DomainName__c + '/home/home.jsp';
    }

    //This method fetches the brand parameter from URL.
    public String getBrandParameter() {

        return apexpages.currentpage().getparameters().get('brand');
    }

    //This method updates the contact record.
    public void updateContact() {

        brandParameter = getBrandParameter();
        Contact contact = getLoggedInContact();
        List<Contact> updateContactList = new List<Contact>();
        if(contact != null && brandParameter != null) {
            if(contact.acfComm__Community_Experience_selected__c != brandParameter) {
                contact.Community_Experience_selected__c = brandParameter.toLowerCase();
                updateContactList.add(contact);
            }
        } 
        try {
            if(updateContactList != null && updateContactList.size() > 0){
                Database.update(updateContactList);
            }
        }
       catch(Exception e)
      {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
             ApexPages.addMessage(myMsg);
      }
    }

    //This method fetches the current logged in users Id.
    public String getLoggedInUser() {

        return system.UserInfo.getUserId();
    }
    
    //This method fetches the contact of the logged in user. 
    public Contact getLoggedInContact() {

        String userId = getLoggedInUser();
        //system.debug('userId===>>> '+userId);
        /*User loggedInUserObj;
        if(!String.isBlank(userId)){
            loggedInUserObj = [Select ContactId From User where Id =: userId LIMIT 1];
        }
        //system.debug('loggedInUserObj====>>> '+loggedInUserObj);*/
        Contact loggedInUserContact;
        String contactId = UtilityGeneral.getContactIdFromUser(userinfo.getUserId());
        if(!String.isBlank(contactId)){
            loggedInUserContact = [Select Id, acfComm__Community_Experience_selected__c From Contact where Id =: contactId LIMIT 1];
        } 
        return loggedInUserContact;
    }  

    //method to redirect to home page by default or stay on same page if redirect parameter in URL is set to false.
    public Pagereference setRedirectTopage() {

        updateContact();
        Pagereference homePageReference;

        if(Apexpages.currentpage().getparameters().get('redirect') != 'false') {
            homePageReference = new Pagereference(communityHomePage);
        } 
        return homePageReference;
    }
}