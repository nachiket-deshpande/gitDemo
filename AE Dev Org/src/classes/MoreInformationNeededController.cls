/*-----------------------------------------------------------------------
    ACF Solutions
    Created By: Siddharth Pandit
    Created Date: July 1, 2015
    Description: This controller is used to send an email by giving extra information
                 needed for contact search.
-----------------------------------------------------------------------*/
public class MoreInformationNeededController {
    public String firstName{get; set;}
    public String preferredFirstName{get; set;}
    public String lastName{get; set;}
    public String formerlastName{get; set;}
    public String email{get; set;}
    public String GraduateInfo{get; set;}
    
    //Constructor
    public MoreInformationNeededController(){
        firstName = Apexpages.currentPage().getParameters().get('firstname');
        lastName = Apexpages.currentPage().getParameters().get('lastname');
        email = Apexpages.currentPage().getParameters().get('email');
       //String queryString = ApexPages.currentPage().getParameters().get(firstname);
       // system.debug('***queryString' +queryString);
    }
    
    //Method to send an Email
    public void sendEmail(){
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = 
        new List<Messaging.SingleEmailMessage>();

        // Step 1: Create a new Email
          Messaging.SingleEmailMessage mail = 
          new Messaging.SingleEmailMessage();
        
          // Step 2: Set list of people who should get the email
          List<String> sendTo = new List<String>();
          sendTo.add('alumni@tufts.edu');
          mail.setToAddresses(sendTo);

          // Step 3: Set who the email is sent from
          mail.setReplyTo(email);
          //mail.setSenderDisplayName('Alumni Tufts');
        
          // (Optional) Set list of people who should be CC'ed
         //List<String> ccTo = new List<String>();
         //ccTo.add('business@bankofnigeria.com');
         //mail.setCcAddresses(ccTo);
    
          // Step 4. Set email contents - you can use variables!
          mail.setSubject('More Information Needed');
          String body = 'User Details :  \n' ;
          body += 'First name : ' + firstName;
          body += '\n Preferred first name : ' + preferredFirstName;
          body += '\n Last name : ' + lastName;
          body += '\n Former last name : ' + formerlastName;
          body += '\n Graduate Info : ' + GraduateInfo;

          mail.setHtmlBody(body);
        
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