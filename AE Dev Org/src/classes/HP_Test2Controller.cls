public class HP_Test2Controller{
    public String imageUrl {set;get;}
    private static List<acfComm__Contact__c> IMAGE_URL_SETTINGS = acfComm__Contact__c.getall().values();
    public HP_Test2Controller(){
        init();
    }
    
    private void init(){
        system.debug('----IMAGE_URL_SETTINGS -----'+IMAGE_URL_SETTINGS );
        imageUrl  = IMAGE_URL_SETTINGS[0].acfComm__imgUrl__c;
        system.debug('---imageUrl  ---'+imageUrl  );
    }
}