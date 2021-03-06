@istest
public with sharing class MobileLinkPageControllerTest {
    public static testmethod void testMobileLinkController(){
    
    
       //Test without creating custom setting data
        MobileLinkPageController mobController = new  MobileLinkPageController();
        Boolean boolMap = false;
        for(HP_Mobile_Links__c objMobLink: HP_Mobile_Links__c.getAll().values()){
            if(mobController.mapMobLink.containsKey(objMobLink)){
                boolMap = true;
            }
        }
        system.assertequals( boolMap ,false);
       
        boolMap = false;
        //Test after creating custom setting data
        AddMobileLinkSettingData();
        MobileLinkPageController mobController1 = new  MobileLinkPageController();
     
        for(HP_Mobile_Links__c objMobLink: HP_Mobile_Links__c.getAll().values()){
            if(mobController1.mapMobLink.containsKey(objMobLink)){
                boolMap = true;
            }
        }
        system.assertequals( boolMap ,true);
    }//End testmethod

    //method is called from MobileLinkPageControllerTest to create the custom setting data .
    public static void AddMobileLinkSettingData(){
        //insert HP_Mobile_Links__c custom setting data
        list<HP_Mobile_Links__c> lstMobContent = new list<HP_Mobile_Links__c>();
        lstMobContent.add(new HP_Mobile_Links__c(Name= 'ColumbiaUniversityResource', Custom_Setting__c='HP_Custom_Link__c',Title__c='ColumbiaUniversityResource'));
        insert lstMobContent ;
        
        // insert HP_Custom_Link__c custom setting data .
        list<HP_Custom_Link__c > lstMobLinkContent = new list<HP_Custom_Link__c >();
        lstMobLinkContent.add(new HP_Custom_Link__c (name = 'Admissions',Link_Text__c='Admissions',Link_URL__c='/Admissions'));
        insert lstMobLinkContent ;        
    }
}//End class