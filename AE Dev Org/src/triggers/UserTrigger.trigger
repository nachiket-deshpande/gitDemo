trigger UserTrigger on User (after update) {

    if(trigger.isAfter && trigger.isUpdate && ContactTriggerHandler_ContactToUserSync.avoidRecursion()) {
        system.debug('This is Userk trigger...');
        new UserTriggerHandler_UserToContactSync(trigger.newMap, trigger.oldMap);
    } 
}