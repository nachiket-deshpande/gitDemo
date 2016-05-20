public with sharing class ContactController {
	@AuraEnabled
    public static Contact getContact() 
    {
        return [
            SELECT Id, Name, Email, Phone 
            FROM Contact
            limit 1
        ][0];
    }
}