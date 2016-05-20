public class HP_QuickSearchController{
    public ProfileDomainName__c profileDomainCustomSetting {get; set;}
    public String profileDomain{ get; set; }
    //constructor
    public HP_QuickSearchController(){
        profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
        profileDomain = profileDomainCustomSetting.DomainName__c;
    }//End constructor
}//End class