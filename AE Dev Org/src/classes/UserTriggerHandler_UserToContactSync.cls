/*-----------------------------------------------------------------------
    ACF Solutions
    Modified By: Vikas Gadilkar
    Modified Date: Nov 4, 2015
    Description: Handler class to update contact records based on mapping fields
-----------------------------------------------------------------------*/

public with sharing class UserTriggerHandler_UserToContactSync {

    public static Map<String, String> userToContactFieldMapping;
    public Map<String, Schema.SObjectField> objectFieldsMap;
    public static Boolean runUser = true;

    //This method is to set the boolean value to avoid recursion.
    public static Boolean avoidRecursion() {
        system.debug('runUser====User>> ' +runUser);
        if(runUser) {
            runUser = false;
            return true;
        } else {
            return runUser;
        }
    }

    public UserTriggerHandler_UserToContactSync(Map<Id, User> newUsersMap, Map<Id, User> oldUsersMap) {

        init();
        updateContact(newUsersMap, oldUsersMap);
    }

    //Initialization block
    public static void init() {

        userToContactFieldMapping = new Map<String, String>();
        getUserContactMapping();
    }

    //Get the records from Custom setting and creates a map of Contact Field as key and User fields as value.
    public static void getUserContactMapping() {

        Map<String, UserContactMapping__c> userContactMappingCS = UserContactMapping__c.getAll();
        for(String name : userContactMappingCS.keySet()) {
            userToContactFieldMapping.put(userContactMappingCS.get(name).User_field__c, userContactMappingCS.get(name).Contact_field__c);
        }
        system.debug('userToContactFieldMapping====>> '+ userToContactFieldMapping);
    }

    //Generate the query in string format for Contact object.
    public static String generateContactQuery () {

        String queryUser = 'Select ';
        queryUser += getObjectFields() + ' from ';
        queryUser += SObjectType.Contact.Name;
        return queryUser;
    }

     //Generate the query in string format for User object.
    public static String generateUserQuery () {

        String queryUser = 'Select ';
        queryUser += getUserObjectFields() + ' from ';
        queryUser += SObjectType.User.Name;
        system.debug('queryUser >>>  '+queryUser);
        return queryUser;
    }

 //Getting all the fields of User object comma separated.
    private static string getUserObjectFields(){

        string userFields = 'Id,';
        /*objectFieldsMap = new Map<String, Schema.SObjectField>();
        if (objectName != null && Schema.getGlobalDescribe().get(objectName).getDescribe() != null){
            objectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            system.debug(objectFieldsMap);
            for (String s : objectFieldsMap.keySet()) {
                if ((objectFieldsMap.get(s).getDescribe().isAccessible())) {
                    contactFields += String.escapeSingleQuotes(s);
                    contactFields += ',';
                }
            }
            contactFields = contactFields.removeEnd(',');
        }*/
        for(String s : userToContactFieldMapping.keySet())
        {
            userFields += String.escapeSingleQuotes(s);
            userFields += ',';
        }
        userFields = userFields.removeEnd(',');
        System.debug('userFields >>>> ' + userFields);
        return userFields;
    }

    //Getting all the fields of User object comma separated.
    private static String getObjectFields(){

        string contactFields = 'Id,';
        /*objectFieldsMap = new Map<String, Schema.SObjectField>();
        if (objectName != null && Schema.getGlobalDescribe().get(objectName).getDescribe() != null){
            objectFieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            system.debug(objectFieldsMap);
            for (String s : objectFieldsMap.keySet()) {
                if ((objectFieldsMap.get(s).getDescribe().isAccessible())) {
                    contactFields += String.escapeSingleQuotes(s);
                    contactFields += ',';
                }
            }
            contactFields = contactFields.removeEnd(',');
        }*/
        //Code Commented by VRG on 05//11/2015
        for(String s : userToContactFieldMapping.Values())
        {
            contactFields += String.escapeSingleQuotes(s);
            contactFields += ',';
        }
        contactFields = contactFields.removeEnd(',');
        return contactFields;
    }

    //Creates a map of User
    public Map<Id, Contact> createContactUserMap(Map<Id, User> newUsersMap) {

        List<Contact> contactList = new List<Contact>();
        Set<Id> contactIdFromUser = new Set<Id>();
        Map<Id,Id> contactToUserIdMap = new Map<Id,Id>();
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        String queryContact = generateContactQuery();

        for(User user : newUsersMap.values()) {
            contactToUserIdMap.put(user.ContactId, user.Id);
        }

        if(contactToUserIdMap != null && contactToUserIdMap.keySet().size() > 0) {
            contactIdFromUser = contactToUserIdMap.keySet();
        }

        queryContact+= ' where Id IN : contactIdFromUser ';
        contactList = database.query(queryContact);
        system.debug('contactList.size()===>> '+contactList.size()+ 'contactList==>> '+contactList);
        if(contactList!= null && contactList.size() > 0) {
            for(Contact objContact : contactList) {
                if(contactToUserIdMap.containsKey(objContact.Id)) {
                    userIdToContactMap.put(contactToUserIdMap.get(objContact.Id), objContact);
                }
            }
        }
        system.debug('userIdToContactMap====> '+userIdToContactMap);
        return userIdToContactMap;
    }

    public void updateContact(Map<Id, User> newUsersMap, Map<Id, User> oldUsersMap) {
        Map<Id, Id> contactIdUserIdMap = new Map<Id,Id>();
        Set<Id> setChangedValues = new Set<Id>();
        system.debug('newUsersMap===>> '+newUsersMap);
        system.debug('oldUsersMap===>> '+oldUsersMap);
        system.debug('userToContactFieldMapping in processUser===>> '+userToContactFieldMapping);
        Set<Contact> updateContactSet = new Set<Contact>();
        Map<Id, Contact> userIdToContactMap = createContactUserMap(newUsersMap);
        system.debug('userIdToContactMap===>> '+userIdToContactMap);

        for(String userId : newUsersMap.keySet()) {
            Boolean conUpdated = false;
            if(userIdToContactMap.containsKey(userId)) {
                contactIdUserIdMap.put(userId, userIdToContactMap.get(userId).Id);
                for(String userField : userToContactFieldMapping.keySet()) {
                    if(String.valueOf(newUsersMap.get(userId).get(userField))!=String.valueOf(oldUsersMap.get(userId).get(userField))) {
                        setChangedValues.add(userId);
                    }
                }
            }
        }
        if(!system.isFuture()){
            system.debug('***In Future**');
            UpdateContactRecords(contactIdUserIdMap, setChangedValues);
        }
    }

    //Method to update contact Asynchronously using furture method
    @future
    public static void UpdateContactRecords(map<Id, Id> mapUserIdToContactId, set<Id> setUpdatedValues){

        //Get Contact Records from the map using dynamic query.
        set<Id> contactSet = new set<Id>();
        set<Id> userSet = new set<Id>();
        list<User> lstUser = new list<User>();
        map<Id, Contact> mapContactIdWithContact = new map<Id, Contact>();
        list<Contact> lstContactToUpdate = new list<Contact>();
        map<Id, User> mapUserIdWithUser = new map<Id, User>();

        init();
        contactSet.addAll(mapUserIdToContactId.values());
        userSet = mapUserIdToContactId.keySet();

        if(userSet != null) {
            system.debug('userSet != null >>' + userSet );
            String queryUser  = generateUserQuery();
            queryUser+=' where Id IN : userSet ';
            lstUser = Database.query(queryUser);
            system.debug('lstUser >>> ' + lstUser );
            if(lstUser != null) {
                for(User objUser : lstUser) {
                    mapUserIdWithUser.put(objUser.id, objUser);
                }
            }
        }
        system.debug('mapUserIdWithUser >>> ' + mapUserIdWithUser); 

        list<Contact> lstContact = new list<Contact>();
        if (contactSet != null) {
            System.debug('contactSet != null >>>' + contactSet );
            String queryContact = generateContactQuery(); 
            queryContact+= ' where Id IN : contactSet ';
            lstContact = Database.query(queryContact);
            system.debug('queryContact String >>>> ' + queryContact);
            system.debug('lstContact >>> ' + lstContact);
        }

        if(lstContact!= null) {
            system.debug('lstContact!= null >>> ' + lstContact);
            for(Contact objContact : lstContact) {
                mapContactIdWithContact.put(objContact.id, objContact);
            } 
        }
        system.debug('mapContactIdWithContact >>> ' + mapContactIdWithContact);

        //Iterate through userid map and populate list<Contact>
        for(Id userId : mapUserIdToContactId.keySet()){
            Contact objContact = mapContactIdWithContact.get(mapUserIdToContactId.get(userId));
            system.debug('objContact >>> ' + objContact); 
            if(setUpdatedValues.contains(userId)) {
                for(String userField : userToContactFieldMapping.keySet()) {
                    objContact.put(userToContactFieldMapping.get(userField), mapUserIdWithUser.get(userId).get(userField)); 
                    system.debug('objContact FOR userField Loop >>> ' + objContact); 
                }
            }
            lstContactToUpdate.add(objContact);
            system.debug('lstContactToUpdate >>> ' + lstContactToUpdate);
        }
        
        system.debug('lstContactToUpdate >>> ' + lstContactToUpdate);
        if (lstContactToUpdate != null && !lstContactToUpdate.isEmpty()){
            try{
               system.debug('lstContactToUpdate != null && !lstContactToUpdate.isEmpty()');
               update lstContactToUpdate;
               system.debug('updated lstContactToUpdate >>> ' + lstContactToUpdate);
                   
            } catch(DMLException objDmlException) {
                system.debug(' DMLException >>>' + objDmlException);
            }
        }
    }
}