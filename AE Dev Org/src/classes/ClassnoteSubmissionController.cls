/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Siddharth Pandit
    Created Date: June 11, 2015
    Description: Controller class used to submit a classnote
        			 
-----------------------------------------------------------------------*/
public class ClassnoteSubmissionController {
    public Classnotes__c classNoteObject{ get; set; }
    public String ObjectName { get; set; }
    public Contact objectContact { get; set; }
    public list<Class_Note_Submission_Fields__c> lstCustomSettingFields { get; set; }
    public string fileName { get; set;}  
    public Blob fileBody { get; set; }  
    
    public Attachment attachment {
    get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
  set;
  }
    
    //Constructor
    public ClassnoteSubmissionController(){
        init();
        
    }//End Constructor
    
    //Method to initialize the variables
    public void init(){
        lstCustomSettingFields = new list<Class_Note_Submission_Fields__c>();
        String contactId = UtilityGeneral.getContactIdFromUser(Userinfo.getUserId());
        //String contactQuery = UtilityGeneral.constructQueryForObject('Contact_Fields_Prepopulate', 'contact');
        //system.debug('***contactQuery' + contactQuery);
        //contactQuery = contactQuery + ' where id =:contactId';
       // system.debug('***contactQuery' + contactQuery);
        objectContact = getContactInformation(contactId);
        classNoteObject = new Classnotes__c();
        PrePopulateContactFields(objectContact);
        lstCustomSettingFields = UtilityGeneral.getOrderwiseFields(getFieldsFromCustomSetting(), 'Order__c');
    }//End Method
    
    //Method to Prepoulate Fields
    public void PrePopulateContactFields(Contact pObjContact){
        classNoteObject.Contact__c = pObjContact.Id;
    }//End Method
    
    //Method to retrive Custom settings data
    public list<Sobject> getFieldsFromCustomSetting(){
        return Class_Note_Submission_Fields__c.getAll().values();
    }//End method
    
    //Method to get Contact Information from Contact Id
    public Contact getContactInformation(String pContactId){
  		if(pContactId == null){
  			return null;
  		}
        return database.query('select name, email, Reunion_Year__c from Contact where id = :pContactId');
    }//End method
    
    //Method to submit a classnote
    public Pagereference SubmitClassNote(){
      try {
            if(classNoteObject != null)
            {
                insert classNoteObject;
                inserAttachmentForRecord(classNoteObject);
                getUrlForAttachment();
                classNoteObject = new Classnotes__c();
                PrePopulateContactFields(objectContact);
               
            }//End If
        }
      catch(Exception e) {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Insert failed.');
             ApexPages.addMessage(myMsg);
             return null;
      }
      Pagereference pr = new Pagereference('/Class_Note_Page');
      return pr;
    }//End Method
    
    //Method to save attachment for particular classnote Record
    public void inserAttachmentForRecord(Classnotes__c pClassNote){
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = pClassNote.id; // the record the file is attached to
        attachment.IsPrivate = true;
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            //return null;
        } finally {
            //attachment = new Attachment(); 
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    }//End method
    
    //Method to generate Attachment Url and update it into the Record
    public void getUrlForAttachment(){
    	ProfileDomainName__c domainName = UtilityGeneral.getProfileDomainName();
    	try{
	    	if(domainName != null){
	    		//classNoteObject.Photo_Upload__c = '<a href="'+System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + domainName.DomainName__c +'/servlet/servlet.FileDownload?file=' + attachment.Id+'" target="_blank"><img src="'+System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + domainName.DomainName__c +'/servlet/servlet.FileDownload?file=' + attachment.Id+'"></a>';
                classNoteObject.Photo_Upload__c = '<img src="'+System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + domainName.DomainName__c +'/servlet/servlet.FileDownload?file=' + attachment.Id+'">';
	            system.debug('classNoteObject.Photo_Upload__c = '+classNoteObject.Photo_Upload__c);
	            update classNoteObject;
	    	}
    	}
       catch(Exception e) {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
             ApexPages.addMessage(myMsg);
      }
    }//End Method
    
}//End Class