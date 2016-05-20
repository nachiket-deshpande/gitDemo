@RestResource(urlMapping='/HelloWorld/*')
global with sharing class HelloWorldWebService {

	@HttpGet
	global static String HelloWorld() {
        return 'Hello World';
    }

}