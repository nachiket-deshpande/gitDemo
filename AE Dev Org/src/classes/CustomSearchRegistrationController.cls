/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Suhas Patil
    Created Date: June 11, 2015
    Description: Custom search Registration controller for fetching the contact records according to the input from 
                 CustomsearchRegistration page. 
-----------------------------------------------------------------------*/

public class CustomSearchRegistrationController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String studentId {get; set;}
    public String formerEmail {get; set;}
    public String degree {get; set;}
    public String selectedSearchOption {get; set;}
    public String selectedDegree {get; set;}
    public boolean IsTryAgain { get; set; }
    public boolean isPasswordReset { get; set; }
    public User validUser{get; set;}
    public boolean IsInfoWindow{get; set;}
    public String messageBody { get; set;}
    public static final String BACK_SLASH = '/';
    public static final integer ONE = 1;
    public static final String EMAIL_UPDATED ='Email Updated';
    public static final String WELCOME_EMAIL = 'Welcome Email';
    public static final String FORWARD_SLASH = '/';
    public static final String ADD_COMMUNITYACCESS = '/apex/CommunityAccessRequest';
    public static final String USER_FOUND = '<b>User Found</b><br/>Your user record has been found. you should receive a password reset <br/>email at the following email address: ';
    public static final String REGISTRATION_COMPLETE = '<b>Registration Complete</b><br/>Your registration is complete. you should receive a welcome email at <br/> the following email address : ';
    public static final String ERROR_FIRST_NAME = 'Please add First Name';
    public static final String ERROR_LAST_NAME = 'Please add Last Name';
    public static final String ERROR_EMAIL = 'Please add Current Email';
    public static final String ERROR_STUDENT_ID = 'Please add Student Id';
    public static final String ERROR_FORMER_EMAIL = 'Please add Email';
    
    
    
    public Community_Web_Content__c communityWebContent{get; set;}
    public String whereCondition;

     
    //Constructor 
    public CustomSearchRegistrationController() {
        IsInfoWindow = false;
        messageBody = '';
        //Static section
        communityWebContent = new Community_Web_Content__c();
        String pageName = UtilityGeneral.getPageNameFromUrl(ApexPages.CurrentPage().getUrl());
        if(!String.isBlank(pageName)){
           communityWebContent = this.retriveCustomSetting(pageName);
        }
        // communityWebContent = UtilityGeneral.getWebContentDemo(ApexPages.CurrentPage().getUrl());
    }

    //Method to get Title and Help Text from custom setting
    public  Community_Web_Content__c retriveCustomSetting(String pPageName) {
        list<Custom_Search_Registration__c> customSearchList = new list<Custom_Search_Registration__c>();
        if (pPageName == null) {
            return null;
        }else{
            customSearchList = [SELECT  PageName__c, Record_Name__c
                    FROM    Custom_Search_Registration__c
                    WHERE   PageName__c = : pPageName
                    LIMIT   1];
        }
        if(customSearchList.size()>0)
        {
            list<Community_Web_Content__c> cwcList = new list<Community_Web_Content__c>();
            cwcList = [SELECT  Content__c, Page_Content__c ,Title__c
                    FROM    Community_Web_Content__c
                    WHERE   Name = :customSearchList[0].Record_Name__c
                    LIMIT   1];
          if(cwcList.size() > 0) {
            return cwcList[0];
          } else
            return null;
        }
        else {
            return null;
        }
    }

    //Method for radio button on the page
    public List<SelectOption> getSearchSelectionCriteria() 
    {

        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('SearchBy','Search By')); 
        //options.add(new SelectOption('Current_Email','Current Email')); 
        options.add(new SelectOption('Student_Id','Student Id')); 
        options.add(new SelectOption('Former_Email','Email'));
        return options; 
    }

    //Method to check registration flow and perform the operations accordingly.
    public Pagereference checkRegistrationFlow() 
    {
        system.debug('Controller Method  >>>>   ');
        reCAPTCHA captcha = new reCAPTCHA();
        if(String.isBlank(firstName))
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ERROR_FIRST_NAME);
            ApexPages.addmessage(msg);
        }
        else if(String.isBlank(lastName))
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ERROR_LAST_NAME);
            ApexPages.addmessage(msg);
        }
        else if(String.isBlank(email))
        {
             ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ERROR_EMAIL);
            ApexPages.addmessage(msg);
        }
        else if(selectedSearchOption.equalsIgnoreCase('Student_Id') && String.isBlank(studentId)) 
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, ERROR_STUDENT_ID);
            ApexPages.addmessage(msg);
        }
        else if(selectedSearchOption.equalsIgnoreCase('Former_Email') && String.isBlank(formerEmail))
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,ERROR_FORMER_EMAIL);
            ApexPages.addmessage(msg);
        }
        else if(captcha.verify(ApexPages.currentPage().getParameters().get('g-recaptcha-response'))==false)
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Captcha required');
            ApexPages.addmessage(msg);
        }
        else {
            system.debug(' Default Else >>>  ');
            List<Contact> contactList = queryContact();                //Get the matching contact for contact details
            /*if(contactList.isEmpty()){
                list <User> lstUser = queryUserForContactInfo();
                system.debug('***lstUser' + lstUser);
                if(!lstUser.isEmpty()){
                   if(!String.isBlank(lstUser.get(0).contactId)){
                       contactList = getContactFromId(lstUser.get(0).contactId);
                   }
                }
            }*/
            system.debug('***contactList  AFTER captcha' + contactList);
            List<User> userList = new List<User>();
            List<Contact> ContactsEmailMatchList = new List<Contact> ();
            ContactsEmailMatchList = [SELECT Id, Email, FirstName, Lastname, Student_ID__c
                            FROM Contact
                            WHERE Id 
                            IN (SELECT contactId  
                                FROM user 
                                WHERE UserName = :email)
            ]; 
            system.debug('++ContactsEmailMatchList ' + ContactsEmailMatchList); 
            /*userList = [SELECT ID,Email,UserName
                          FROM user
                          WHERE contactId IN :ContactsList
            ];
            system.debug('++userListsssList'+userList); 
            */
            if(contactList != null && contactList.size() == ONE) {
                system.debug('***contactList  >>>>  ' + contactList);
                userList = queryUser(contactList);
                system.debug('***ContactList in userList >>>> ' + userList);
                if(userList != null && userList.size() == ONE) {
                    system.debug('userList====>>>> ' + userList);
                    for(User objUser : userList){
                        system.debug('***objUser  >>>>  ' + objUser);
                        
                        //Check current email Address with user email address.
                        if(objUser.Email == email) {
                            
                            //addMatchFoundInfoMessage();
                            validUser = objUser;
                            try {
                                if(validUser.IsActive == false) {
                                    validUser.IsActive = true;
                                    update validUser;
                                    system.debug('***update user'+validUser);
                                }
                            }
                            catch(Exception e) {
	                           ApexPages.Message myMsg = 
	                               new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Update failed.');
	                           ApexPages.addMessage(myMsg);
                            }
                            resetUserPassword();              //SP 
                            IsInfoWindow = true;
                            messageBody = USER_FOUND + objUser.Email;
                        } else {
                            String formerEmailAddress = '';
                            for(Contact objContact : contactList){
                                objUser.Email = email;
                                objUser.username = email;
                                formerEmailAddress = objContact.Former_Email__c; 
                            }
                            if(objUser.IsActive == false){
                                objUser.IsActive = true;
                            }
                            //try {
                                if(!ContactsEmailMatchList.isEmpty() && ContactsEmailMatchList != null) {
                                    system.debug('++Contactssss List is not empty > ' + ContactsEmailMatchList); 
                                    
                                    if ((ContactsEmailMatchList[0].Firstname == FirstName && ContactsEmailMatchList[0].Lastname == lastName && ContactsEmailMatchList[0].Student_ID__c == studentId) ||
                                        (ContactsEmailMatchList[0].Firstname == FirstName && ContactsEmailMatchList[0].Lastname == lastName && ContactsEmailMatchList[0].Email == formerEmail)) {
                                    /*
                                    if (ContactsEmailMatchList[0].Firstname == FirstName && ContactsEmailMatchList[0].Lastname == lastName  && 
                                        ((ContactsEmailMatchList[0].Student_ID__c == studentId) || (ContactsEmailMatchList[0].Email == formerEmail))
                                    ) {
                                    */
                                        try {
	                                        system.debug('++ContactsEmailMatchList[0].Firstname == FirstName'); 
	                                        update objUser; 
	                                        system.debug('>>>  AFTER USER UPDATE >>>  ' + objUser);
	                                        validUser = objUser;
	                                        resetUserPassword();          //SP
	                                        IsInfoWindow = true;
	                                        messageBody = USER_FOUND + objUser.Email;
                                        } catch (DmlException e) {
                                            system.debug('CATCH >> This email address already exists as a username >>>  '); 
                                        }
                                    } else {
                                        system.debug('ELSE >> This email address already exists as a username >>>  '); 
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This email address already exists as a username. Please enter a different email address.');
                                        ApexPages.addMessage(myMsg); 
                                    } 
                                } else {
                                    try {
                                        system.debug('Contacts List Empty'); 
                                        update objUser;
                                        system.debug('>>>  AFTER USER UPDATE >>>  ' + objUser);
                                        validUser = objUser;
                                        resetUserPassword();          //SP
                                        IsInfoWindow = true;
                                        messageBody = USER_FOUND + objUser.Email;
                                    } catch (DmlException e) {
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This email address already exists as a username. Please enter a different email address.');//
                                        ApexPages.addMessage(myMsg); //
                                        //break;//
                                    }
                                    
                                }
                            /*
                            } catch(DmlException e) { 
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This email address already exists as a username. Please enter a different email address.');//
                                system.debug('*****************'+myMsg);//
                                ApexPages.addMessage(myMsg);//
                                break;//

                            }
                            */
                        //sendEmail(formerEmailAddress, EMAIL_UPDATED);       //SP
                        }
                    }
                } else {
                     system.debug('++Create new user');
                    User objectuser = new User();
                    // String contactName='';
                    for(Contact objContact : contactList){
                        //objuser.Name = objContact.firstname + objContact.lastname;
                        system.debug('****objContact' + objContact);
                        objectuser.email = objContact.email;
                        objectuser.username = objContact.email;
                        objectuser.contactId = objContact.id;
                        objectuser.firstname = objContact.firstname;
                        objectuser.lastname = objContact.lastname;
                        objectuser.username = objContact.email;
                        if(!String.Isblank(objContact.firstname)){
                            objectuser.Alias = objContact.firstname.substring(0,1) + objContact.lastname.substring(0,4);
                        } else{
                            //objectuser.Alias = objContact.Former_First_Name__c.substring(0,5);  //If firstname is not present then take FormerFirstName from Contact.
                            objectuser.Alias = objContact.lastname.substring(0,5);
                        }
                    }
                    profile commProfile = [select id from profile where name =:'Tufts Community User' limit 1];
                    objectuser.profileid = commProfile.Id;
                    objectuser.emailencodingkey = 'UTF-8';
                    objectuser.languagelocalekey = 'en_US';
                    objectuser.localesidkey = 'en_US';
                    objectuser.timezonesidkey = 'America/Los_Angeles';
                    
                    system.debug('***objectuser.username' + objectuser.username);
                    try {
                       insert objectuser;
                    } catch(Exception e) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'System.DmlException: Insert failed.');
                        ApexPages.addMessage(myMsg); 
                    }
                    IsInfoWindow = true;
                    messageBody =  REGISTRATION_COMPLETE + objectuser.email;
                    //sendEmail(objectuser.email,WELCOME_EMAIL);       
                }
            } else {
                ProfileDomainName__c profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
                Pagereference pageRef = new Pagereference(FORWARD_SLASH + profileDomainCustomSetting.DomainName__c + ADD_COMMUNITYACCESS);
                return pageRef;
            }
        }
        return null;
    }//End Method

    //Method for adding no match found error. 
    public void addNoMatchFoundErrorMessage() {
        IsTryAgain = true;
        isPasswordReset = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: No Match Found'));
    }
    
    //Method for adding error for no email match with user record.
    public void addNoMatchEmailFoundErrorMessage(){
        IsTryAgain = true;
        isPasswordReset = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: No Matching Email Found With User Email'));
    }
    
    //Method for adding user found message. 
    public void addMatchFoundInfoMessage() {
        isPasswordReset = true;
        IsTryAgain = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Info: User found'));
    }
    

    //Method for adding too many records found error. 
    public void addTooManyRecordFoundErrorMessage() {
        IsTryAgain = true;
        isPasswordReset = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: No Exact Match or Too Many Records Found'));
    }

    //This Method Fetches the User record to update.
    public List<User> queryUser(List<Contact> contactList) {

       // List<Contact> contactList = queryContact();         //get the matching contact for contact details
       //system.debug('contactList===>> '+contactList);
        String fieldList = '';
        List<User> userList;
        
        //If Matching Contact found
       // if(contactList != null && contactList.size() > 0) {
            fieldList = SobjectType.User.fields.Id.Name + ', ';
            fieldList += SobjectType.User.fields.IsActive.Name + ', ';
            fieldList += SobjectType.User.fields.Email.Name;
            String queryUser = buildQuery(SobjectType.User.Name, fieldList);
            whereCondition = '';
            whereCondition = buildQueryWhere(contactList);
            
            if(!String.isBlank(whereCondition)) {
                queryUser += whereCondition;
            }
            userList = Database.query(queryUser);
            system.debug('userList====>>> '+userList);
       // } else {
            //system.debug('This is called when Contact list is null====>> '+contactList);
           // addNoMatchFoundErrorMessage();
       // }
        return userList;
    }

    //This method queries the contact records.
   public List<Contact> queryContact() {
        String contactFieldList = SobjectType.Contact.fields.Id.Name + ', ' 
                                  + SobjectType.Contact.fields.Former_Email__c.Name + ', '
                                  + SobjectType.Contact.fields.Email.Name + ', '
                                  + SobjectType.Contact.fields.AccountId.Name + ', '
                                  + SobjectType.Contact.fields.Firstname.Name + ', '
                                  + SobjectType.Contact.fields.Former_First_Name__c.Name + ', '
                                  + SobjectType.Contact.fields.Business_Email__c.Name + ', '
                                  + SobjectType.Contact.fields.Lastname.Name + ', '
                                  + SobjectType.Contact.fields.Deceased__c.Name;
                             
        String queryContact = buildQuery(SobjectType.Contact.Name, contactFieldList);//buildQuery(true);
        system.debug('queryContact in queryContact====>> '+queryContact);
        whereCondition = buildQueryWhere(null);
        system.debug('whereCondition after buildQueryWhere >>> '+ whereCondition);
        
        if(!String.isBlank(whereCondition) && whereCondition != ' where ') {
            queryContact += whereCondition;
        }
        system.debug('queryContact====>>'+queryContact);
        List<Contact> contactList = Database.query(queryContact);
        system.debug('contactList====>>> '+contactList);
        return contactList;
    }
    
    //Method to fetch usr details from the contact information
   public list<User> queryUserForContactInfo(){
       String contactFieldList =  + SobjectType.User.fields.ContactId.Name;
                                  /*+ 'Contact.' + SobjectType.Contact.fields.Former_Email__c.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Email.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.AccountId.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Firstname.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Former_First_Name__c.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Business_Email__c.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Lastname.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.Deceased__c.Name + ', '
                                  + 'Contact.' + SobjectType.Contact.fields.CommunityEligible__c.Name;*/
        String queryContact = buildQuery(SobjectType.User.Name, contactFieldList);
        String whereCondition = buildQueryWhereForUser();
        queryContact += whereCondition;
        system.debug('***queryContact' + queryContact);
        list<User> lstUser = database.query(queryContact);
        
        return lstUser;
   }
   
   public list<Contact> getContactFromId(String pContactId){
       String contactFieldList = SobjectType.Contact.fields.Id.Name + ', ' 
                                  + SobjectType.Contact.fields.Former_Email__c.Name + ', '
                                  + SobjectType.Contact.fields.Email.Name + ', '
                                  + SobjectType.Contact.fields.AccountId.Name + ', '
                                  + SobjectType.Contact.fields.Firstname.Name + ', '
                                  + SobjectType.Contact.fields.Former_First_Name__c.Name + ', '
                                  + SobjectType.Contact.fields.Business_Email__c.Name + ', '
                                  + SobjectType.Contact.fields.Lastname.Name + ', '
                                  + SobjectType.Contact.fields.Deceased__c.Name;

        String queryContact = buildQuery(SobjectType.Contact.Name, contactFieldList);//buildQuery(true);
        queryContact+=' where id =: pContactId' ;
        system.debug('***queryContact' + queryContact);
        return database.query(queryContact);
   }
 
   public String buildQueryWhereForUser(){
       String whereString = ' where ';  
       if(!String.isBlank(email)) {
                whereString += String.escapeSingleQuotes(SobjectType.User.fields.Username.Name);
                whereString += whereEquateValues(email, true);
                
                if(!String.isBlank(formerEmail)){
                    whereString += String.escapeSingleQuotes(SobjectType.User.fields.Username.Name);
                    whereString += whereEquateValues(formerEmail, true);
                    whereString = whereString.removeEnd(' OR ');
                }
                whereString = whereString.removeEnd(' OR ');
        }
        system.debug('***whereString' + whereString);
        return whereString;
    }

    //Method builds the query for User and Contact.
    public String buildQuery(String objectName, String fieldList) {
        String query = '';
        system.debug('***fieldList' + fieldList);
        query = 'SELECT ';
        query += fieldList;
        query += ' FROM ';
        query += objectName;

        return query;
    }

    // Method is to generate the where condition for Contact.
       // Method is to generate the where condition for Contact.
    public String buildQueryWhere(List<Contact> contactList) {

        String whereString = ' where ';
        if(contactList != null && contactList.size() > 0) { //This is for where clause of User query.
            whereString += String.escapeSingleQuotes(SobjectType.User.fields.ContactId.Name);
            whereString += ' IN :';
            whereString += 'contactList';
            
        }
        else {  
            //Where clause for contact query.              
             if(!String.isBlank(firstName) && !String.isBlank(lastName) && !String.isBlank(email)) {
                
                whereString +=  '(' + String.escapeSingleQuotes(SobjectType.Contact.fields.Deceased__c.Name );
                // whereString += whereEquateValues('true', true);
                whereString += '=' + false;
                whereString = whereString.removeEnd(' OR ');
                whereString += ') AND ';

                whereString += '(' + String.escapeSingleQuotes(SobjectType.Contact.fields.Community_Eligible__c.Name );
                //whereString += whereEquateValues('false', true);
                whereString += '=' + true;
                whereString = whereString.removeEnd(' OR ');
                whereString += ') AND ';
                
                
                whereString +=  '('+ String.escapeSingleQuotes(SobjectType.Contact.fields.FirstName.Name );
                whereString += whereEquateValues(firstName, true);
                
                whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Former_First_Name__c.Name);
                whereString += whereEquateValues(firstName, true);
                whereString = whereString.removeEnd(' OR ');
                whereString += ') AND ';
                
                whereString +=  '('+String.escapeSingleQuotes(SobjectType.Contact.fields.LastName.Name);
                whereString += whereEquateValues(lastName, true);
                
                whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Former_Last_Name__c.Name);
                whereString += whereEquateValues(lastName, true);
                whereString = whereString.removeEnd(' OR ');
                /*whereString += ') AND ';
                
                whereString +=   '('+String.escapeSingleQuotes(SobjectType.Contact.fields.Email.Name);
                whereString += whereEquateValues(email, true);
                
                whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Business_Email__c.Name);
                whereString += whereEquateValues(email, true);
                
                whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_1__c.Name);
                whereString += whereEquateValues(email, true);
                
                whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_2__c.Name);
                whereString += whereEquateValues(email, true);
                */
                whereString = whereString.removeEnd(' OR ');
                whereString += ') ';
                
                /*if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Current_Email'))
                {
                    whereString += ' AND (';

                     whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Email.Name);
                     whereString += whereEquateValues(email, true);
                    
                     whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Business_Email__c.Name);
                     whereString += whereEquateValues(email, true);
                     
                     whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_1__c.Name);
                     whereString += whereEquateValues(email, true);
                
                     whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_2__c.Name);
                     whereString += whereEquateValues(email, true);

                     whereString = whereString.removeEnd(' OR ');
                     whereString += ') ';
                }*/
                if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Student_Id')) 
                {
                    if(!String.isBlank(studentId)) 
                    {
                        whereString += 'AND (';
                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Student_ID__c.Name);
                        whereString += whereEquateValues(studentId, true);
                        
                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Advance_Entity_ID__c.Name);
                        whereString += whereEquateValues(studentId, true);
                        
                        whereString = whereString.removeEnd(' OR ');
                        whereString += ')';
                    }
                }
                else if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Former_Email')) 
                {
                    if(!String.isBlank(formerEmail)) 
                    {
                        whereString += 'AND (';
                        //whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Former_Email__c.Name);
                        //whereString += whereEquateValues(String.valueOf(formerEmail), true);

                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Email.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);

                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Business_Email__c.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);

                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Business_Email__c.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);
                        
                        whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_1__c.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);
                
                        whereString +=   String.escapeSingleQuotes(SobjectType.Contact.fields.Historical_Email_2__c.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);
                        
                        whereString = whereString.removeEnd(' OR ');
                        whereString += ') ';
                    }
                }
                
                
                
                /*if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Student_Id')) {
                    if(!String.isBlank(studentId)) {
                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Banner_ID__c.Name);
                        whereString += whereEquateValues(studentId, true);
                    }
                }
                else if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Former_Email')) {
                    if(!String.isBlank(formerEmail)) {
                        whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Former_Email__c.Name);
                        whereString += whereEquateValues(String.valueOf(formerEmail), true);
                    }
                }*/
                
            } 

            /*if(!String.isBlank(lastName)) {
                whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.LastName.Name);
                whereString += whereEquateValues(lastName, true);
            } 

            if(!String.isBlank(email)) {
                whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Email.Name);
                whereString += whereEquateValues(email, true);
            }*/

            /*if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Student_Id')) {

                if(!String.isBlank(studentId)) {
                    whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Banner_ID__c.Name);
                    whereString += whereEquateValues(studentId, true);
                }

            } else if(selectedSearchOption != null && selectedSearchOption.equalsIgnoreCase('Former_Email')) {

                if(!String.isBlank(selectedDegree)) {
                    whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Degree__c.Name);
                    whereString += whereEquateValues(selectedDegree, true);
                }

                if(!String.isBlank(formerEmail)) {
                    whereString += String.escapeSingleQuotes(SobjectType.Contact.fields.Former_Email__c.Name);
                    whereString += whereEquateValues(String.valueOf(formerEmail), false);
                }
            }*/

            if(whereString.equalsIgnoreCase('where')) {
                whereString = '';
            }
            system.debug('whereString=====>>> '+whereString);
            whereString = whereString.removeEnd(' OR ');
        }

        system.debug(' buildQueryWhere return whereString >>> ' + whereString);
        return whereString;
    }
    
    //Add the equating values.
    public static String whereEquateValues(String equateValue, Boolean isString) {

        String whereString = '';
        if(isString) {
            whereString += String.escapeSingleQuotes(' = ');
            whereString += '\''+equateValue+'\'';
            whereString += String.escapeSingleQuotes(' OR ');
        } else {
            whereString += String.escapeSingleQuotes(' = ');
            whereString += Integer.valueOf(equateValue);
            whereString += String.escapeSingleQuotes(' OR ');
        }

        return whereString;
    }

    //Method to clear search fields and renders the form
    public Pagereference clearFields(){
        firstName = '';
        lastName = '';
        email = '';
        studentId = '';
        formerEmail = '';
        degree ='';
        selectedSearchOption = '';
        selectedDegree = '';
        IsTryAgain = false;
        isPasswordReset = false;
        IsInfoWindow = false;
            
        return null;
    }
    
    //Method to redirect to More Information page. 
    public Pagereference redirectToMoreInformation(){
        ProfileDomainName__c profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
        Pagereference pageRef = new Pagereference('/' + profileDomainCustomSetting.DomainName__c + '/apex/MoreInformationRequired?firstname=' + firstName + '&lastname=' + lastName + '&email=' + email);
        return pageRef;
    }
    
    public void resetUserPassword(){
        //if(validUser != null){
        //system.Resetpasswordresult res=  system.resetPassword(validUser.Id, true);
        //system.debug('***validUser' +  res.getPassword());
        //}
        system.resetPassword(validUser.Id, true);
    }
    
        //Method to send an Email
    public void sendEmail(String toEmailAddress, String emailBody){
        system.debug('***toEmailAddress' + toEmailAddress);
        system.debug('***emailBody' + emailBody);
        
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = 
        new List<Messaging.SingleEmailMessage>();

        // Step 1: Create a new Email
          Messaging.SingleEmailMessage mail = 
          new Messaging.SingleEmailMessage();
        
          // Step 2: Set list of people who should get the email
          List<String> sendTo = new List<String>();
          sendTo.add(toEmailAddress);
          mail.setToAddresses(sendTo);

          // Step 3: Set who the email is sent from
          mail.setReplyTo(toEmailAddress);
          //mail.setSenderDisplayName('Alumni Tufts');
        
          // (Optional) Set list of people who should be CC'ed
         //List<String> ccTo = new List<String>();
         //ccTo.add('business@bankofnigeria.com');
         //mail.setCcAddresses(ccTo);
    
          // Step 4. Set email contents - you can use variables!
          mail.setSubject(emailBody);
          /*String body = 'User Details :  \n' ;
          body += 'First name : ' + firstName;
          body += '\n Preferred first name : ' + preferredFirstName;
          body += '\n Last name : ' + lastName;
          body += '\n Former last name : ' + formerlastName;
          body += '\n Graduate Info : ' + GraduateInfo;*/
          
          

          mail.setHtmlBody(emailBody);
        
          // Step 5. Add your email to the master list
          mails.add(mail);
          // Step 6: Send all emails in the master list
          
          //Commented to restrict sending emails
          try{ 
            Messaging.sendEmail(mails);
          }
          catch(EmailException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          }
    }//End Method
    
   
    
}//End Class