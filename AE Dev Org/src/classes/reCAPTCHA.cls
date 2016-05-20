public class reCAPTCHA {

    /* Configuration */

    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = '6LfgSg0TAAAAAC2r5Es2_t0z2f0v2-7BvbP9uCt4';
    public String publicKey { 
        get { return '6LfgSg0TAAAAANIA3FcoFW_C0QKLgx51e-aM4ct0'; }
    } 

    /* Implementation */
    
    // Create properties for the non-VF component input fields generated
    // by the reCAPTCHA JavaScript.
    /*public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }*/
    
    // Whether the submission has passed reCAPTCHA validation or not
    public Boolean verified { get; private set; }
    
    public reCAPTCHA() {
        this.verified = false;
    }
    
    public Boolean verify(String response) {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
        /*if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return false; 
        }*/
                    
        HttpResponse r = makeRequest(baseUrl,
            'secret=' + privateKey + 
            '&response='  + response
        );
        
        system.debug(r);

        if ( r!= null ) 
        {
        	JSONParser parser = JSON.createParser(r.getBody());
        	while (parser.nextToken() != null) 
        	{
	    		if ((parser.getCurrentToken() == JSONToken.FIELD_NAME))
	    		{
	        		String fieldName = parser.getText();
	        		parser.nextToken();
	        		if(fieldName == 'success') 
	        		{
	            		this.verified = parser.getBooleanValue();
	        		} 
				}
			}
            //this.verified = (r.getBody().startsWithIgnoreCase('true'));
        }
        
        if(this.verified) 
        {
            // Pass verification
            return true;
        }
        else 
        {
            // stay on page to re-try reCAPTCHA
            return false;
        }
    }

    /*public PageReference reset() {
        return null; 
    }*/  

    /* Private helper methods */
    
    private static HttpResponse makeRequest(string url, string body)  {
        System.debug('reCAPTCHA body: ' + body);
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        System.debug('reCAPTCHA req: ' + req);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    /*private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }*/
}