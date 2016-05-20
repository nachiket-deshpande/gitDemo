public class MobileCardTestController{

    public ProfileDomainName__c profileDomainCustomSetting {get; set;}
    public String profileDomain{ get; set; }
    public String url_Mobile { get; set; }
    //constructor
    public MobileCardTestController(ApexPages.StandardController stdController){
        profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
        profileDomain = profileDomainCustomSetting.DomainName__c;
       // url_Mobile = profileDomain + '/apex/Profile_Personal_V1?id=005o0000001BtzEAAS';
        url_Mobile = profileDomain + '/apex/Profile_Personal_V1?id='+Userinfo.getUserId();
    }//End constructor
}//End class