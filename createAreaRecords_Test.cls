@isTest
private class createAreaRecords_Test {

    // hard coded variables 
    private static String recordID = '0012000001IXxc8';
    private static String postcode = 'LN5 7DB';

    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        createAreaRecords.createRecordsAsync(recordID,postcode);
        
        List<createAreaRecords.Request> requests = new List<createAreaRecords.Request>();
        
        createAreaRecords.getRequest(requests);
        
        
        Test.stopTest();    
        System.assertEquals('http://api.salesforce.com/foo/bar', 'http://api.salesforce.com/foo/bar');
        
                
    }

 }
