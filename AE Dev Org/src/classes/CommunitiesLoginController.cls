/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {
    public String currentPageName{get; set; } 
    public String page_url { get; set; }
    public static final String BACK_SLASH ='/';
    public boolean mobile{ get; set; }
    global CommunitiesLoginController () {
       //currentPageName = 'CommunitiesLogin';
        //currentPageName = UtilityGeneral.getPageNameFromUrl(ApexPages.CurrentPage().getUrl());
        page_url = '';
    }
    
    /*public Sobject getNextPageDetails(map<integer, Sobject> pMapPageInfo, String pCurrentPageName){
       list<Sobject> lstCustomFlowSetting = pMapPageInfo.values();
       Sobject objSetting;
       integer pageNumber = 0;
       for(Sobject objCustomSetting : lstCustomFlowSetting){
            if(String.valueOf(objCustomSetting.get('PageName__c')).equalsIgnoreCase(pCurrentPageName)){
                pageNumber = integer.valueOf(objCustomSetting.get('PageNumber__c')) + 1;
                if(pMapPageInfo.containskey(pageNumber)){
                    return pMapPageInfo.get(pageNumber);
                }
            }
       }
       return objSetting;   
   }*/
    
     //Get mobile parameter passed form the javascript
   public void populateMobile()
    {
        list<Url_Pattern__c> lstUrlPatterns = Url_Pattern__c.getall().values();
        system.debug('lstUrlPatterns***' + lstUrlPatterns);
        if(lstUrlPatterns != null){
            Pattern MyPattern = Pattern.compile(lstUrlPatterns.get(0).Url_User_Agent__c);
	        Matcher MyMatcher = MyPattern.matcher(ApexPages.currentPage().getHeaders().get('USER-AGENT'));
	        system.debug('***Matches? ' +MyMatcher.find());
	        if(MyMatcher.find()){
	            mobile = true;
	            //return new PageReference('/alumni/one/one.app'); 
	        }
	        else{
	            //return new PageReference('/alumni/home/home.jsp');
	            mobile = false;
	        }
    	}
        
       /*if(!String.isBlank(Apexpages.currentPage().getParameters().get('p1')))
        mobile = boolean.valueOf(Apexpages.currentPage().getParameters().get('p1'));*/
    }//End Method
    
    
    // Code we will invoke on page load.
   global PageReference forwardToAuthPage() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //String displayType = System.currentPageReference().getParameters().get('display');
        //return Network.forwardToAuthPage(startUrl, displayType);
        map<integer, Sobject> mapPageDetails = new map<integer, Sobject>();
        //map<integer, String> mapPageDetails = new map<integer, String>();
        integer pageNumber = 0 ;
        
        ProfileDomainName__c Domain_Name = UtilityGeneral.getProfileDomainName();
        
        if(UserInfo.getUserType() == 'Guest')
        {
            
            page_url = Domain_Name.DomainName__c + '/login';
            return UtilityGeneral.redirect(page_Url, true);
        }//End If
        else
        {
            
            currentPageName = UtilityGeneral.getPageNameFromUrl(ApexPages.CurrentPage().getUrl());
            
            Sobject sobj;
            //ProfileDomainName__c Domain_Name = UtilityGeneral.getProfileDomainName();
            mapPageDetails = UtilityGeneral.getRedirectionPageInfo();
            if(mapPageDetails != null){
                sobj = UtilityGeneral.getNextPageDetails(mapPageDetails, currentPageName);
            }
            
            if(sobj != null){
	            if(mobile){
	                system.debug('**mobileUrl__c' + sobj.get('MobileUrl__c'));
	                page_url = String.valueOf(sobj.get('MobileUrl__c'));
	                return (new Pagereference(page_url));
	            }
	            else{
	                if(sobj.get('PageName__c') != null){
	                   page_url =  BACK_SLASH + Domain_Name.DomainName__c + BACK_SLASH + String.valueOf(sobj.get('PageName__c'));
	                }
                    return (new Pagereference(page_url));
	            }
            }
	            system.debug('***page_url' + page_url);
	            return UtilityGeneral.redirect(page_url, true);
            
           /* //page_url = Domain_Name.DomainName__c + '/HP_CommunityOptIn';
           list<Sobject> lstLoginFlow = LoginFlowCustomSetting__c.getall().values();
           mapPageDetails = UtilityGeneral.getRedirectionPageDetails(lstLoginFlow,'PageNumber__c', 'PageName__c');
            //mapPageDetails = getRedirectionPageDetails(lstLoginFlow);
           system.debug('***mapPageDetails' + mapPageDetails);
           if(mapPageDetails != null){
               //Get current page number
               for(integer i = 0 ; i < lstLoginFlow.size(); i++){
                   if(String.valueOf(lstLoginFlow[i].get('PageName__c')).equalsIgnoreCase(currentPageName)){
                       pageNumber = integer.valueOf(lstLoginFlow[i].get('PageNumber__c'));
                   }
               }//End For
             pageNumber +=1;
             
            //Check for next PageNumber
            if(pageNumber !=0 && mapPageDetails.containsKey( pageNumber)){
                page_url = BACK_SLASH + Domain_Name.DomainName__c + BACK_SLASH + mapPageDetails.get(pageNumber);
            }//End If
            else{
                //page_url = '/' + Domain_Name.DomainName__c +'/home/home.jsp';
                if(!String.isBlank(ApexPages.currentPage().getParameters().get('PageName'))){
                    page_url = BACK_SLASH + Domain_Name.DomainName__c + BACK_SLASH + String.isBlank(ApexPages.currentPage().getParameters().get('PageName')); 
                } //End If
                else{
                    page_url = BACK_SLASH + Domain_Name.DomainName__c +'/home/home.jsp';
                }//End Else
                
            }//End else
            system.debug('****page_Url' + page_Url);
        }//End If
            return UtilityGeneral.redirect(page_Url, true);
        }//End else*/
    }//End method
    
}
    /*global PageReference forwardToCustomAuthPage() {
        return new PageReference('/HP_CommunityOptIn');
    }*/
}//End class