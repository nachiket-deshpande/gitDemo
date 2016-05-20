public class DirectorySearchIframe{
    public ProfileDomainName__c profileDomainCustomSetting {get; set;}
    public String profileDomain{ get; set; }
    //Constructor
    public DirectorySearchIframe(){
        profileDomainCustomSetting = UtilityGeneral.getProfileDomainName();
        if(profileDomainCustomSetting != null){ 
             profileDomain = 'https://communityacc-developer-edition.na17.force.com' + profileDomainCustomSetting.DomainName__c +'/s/DirectorySearch';
        }//End If
        
    }//End Constructor
}//End class