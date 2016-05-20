@isTest(SeeAllData=true)
public class ClassSubmissionControllerTest {
	public static testmethod void testClassNoteSubmission(){
		 Account a = new Account(name='testAcc');
        insert a;
      
        Contact c = new Contact(lastName='TestContact', AccountId=a.Id);
        insert c;
        
        Profile p = [select id from profile where name='Customer Community Login User'];
        User userComm = new User(alias = 'standt', email='standarduser@testorg.com',
          				  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          				  localesidkey='en_US', profileid = p.Id,
          				  timezonesidkey='America/Los_Angeles', username='standarduser@test.com',
          				  ContactId=c.Id);
        insert userComm;
      	 System.runAs(userComm) {
             //Setting Url Params
      	     Contact userContact = new Contact();
      	     system.debug('***userContact' + userComm.id);
			 userContact = [select firstname,lastname, email,Reunion_Year__c from Contact where id =: userComm.ContactId];
		     ClassnoteSubmissionController objClassNoteSubmission = new ClassnoteSubmissionController();
		     objClassNoteSubmission.SubmitClassNote();
		     system.assertEquals(objClassNoteSubmission.classNoteObject.Photo_Upload__c == null, true);
      	 }
	}//End Testmethod
}//End Class