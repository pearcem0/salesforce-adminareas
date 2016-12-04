global class createAreaRecords{
    global class Request {
        @InvocableVariable
        global String recordID_In;
        @InvocableVariable
        global String postcode_In;
    }

    @InvocableMethod(label='get Request')
    global static List<String> getRequest(List<Request> requests) {
        String recordID;
        String postcode;
        for(Request r: requests){
            recordID = r.recordID_In;
            postcode = r.postcode_In;
        }
        
        createRecordsAsync(recordID, postcode);
        
        return null;
    }
    @future(callout=true) global static void createRecordsAsync(String recordID,String postcode) {
    // API call 
        HttpResponse res;
        // Instantiate a new http object
        Http h = new Http();

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        String requestURL='http://mapit.mysociety.org/postcode/';
        requestURL=requestURL+postcode;
        req.setEndpoint(requestURL);
        req.setMethod('GET');

        // Send the request, and return a response
        res = h.send(req);

    // Parse
        Util_JSONParser fullParser = Util_JSONParser.createParser(res.getbody());

        // look at status code. If result is not 'OK' then rage quit. 
        Integer returnstatus = res.getstatuscode();
        if (returnstatus != 200){
            return;
        }

        // create array of area id numbers
        String parsedAreas = fullParser.get('areas').Value;
        JSONParser areaIdParser = JSON.createParser(parsedAreas);

        String[] areaIDs = new List<string>();
        while (areaIdParser.nextToken() != null) {
            if ((areaIdParser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (areaIdParser.getText() == 'id')) {
                    // Get the value.
                    areaIdParser.nextToken();
                    // add it to the array
                    areaIDs.add(areaIdParser.getText());
                }
        }

    // Create records    
        // clean up any pre-existing area records
        List<Area__c> allAreaRecords = [Select Id from Area__c where Area_Org_ID__c = :recordID];
        delete allAreaRecords;

        // insert areas
        for (String i : areaIDs){
          
            String id = i;
            String type = fullParser.get('areas').get(id).get('type_name').Value;
            String name = fullParser.get('areas').get(id).get('name').Value;
                    // if area already exists, update not insert
            Area__c newArea = new Area__c(Area_ID__c=id,Area_Type__c=type,Name=name,Area_Org_ID__c=recordID);
                    //upsert newArea area__r.Name;
            insert newArea;
        }     
        /*
        Set<String> areaIDsSet = new Set<String>(areaIDs);
        String[] existingAreas = new List<string>();
        
        for (Area__c a : [SELECT Id, Area_ID__c, Area_Org_ID__c, Area_Type__c from Area__c where Area_Org_ID__c = :recordID] ) {
            existingAreas.add(a.Id);
        }

        String[] existingAreasMatchingID = new List<String>();
        for (String l : areaIDs){
            // 
            for (Area__c b : [SELECT Id, Area_ID__c, Area_Org_ID__c, Area_Type__c from Area__c where Area_Org_ID__c = :recordID AND Area_ID__c = :l] ){
                existingAreasMatchingID.add(b.Id);            }
        }
            
        for (Integer k = 0; k <existingAreas.size();k++){
            if (areaIDsSet.contains(string.valueof(existingAreas[k]))){ //update 
                for (String i : areaIDs){
                    for (String a : existingAreasMatchingID) {
            
                        String id = i;
                        String type = fullParser.get('areas').get(id).get('type_name').Value;
                        String name = fullParser.get('areas').get(id).get('name').Value;

                        // if area already exists, update not insert
                        Area__c newArea = [SELECT Id from Area__c where Area_Org_ID__c = :recordID AND Area_ID__c = :i];
                        newArea.Area_ID__c = i;
                        newArea.Area_Type__c = type;
                        //newArea.Name = name;
                        //newArea.Area_Org_ID__c = recordID;
                        //upsert newArea area__r.Name;
                        
                        update newArea;
                    }
                }
            }              
            else { // insert them
                for (String i : areaIDs){
          
                    String id = i;
                    String type = fullParser.get('areas').get(id).get('type_name').Value;
                    String name = fullParser.get('areas').get(id).get('name').Value;

                    // if area already exists, update not insert
                    Area__c newArea = new Area__c(Area_ID__c=id,Area_Type__c=type,Name=name,Area_Org_ID__c=recordID);
                    //upsert newArea area__r.Name;
                    insert newArea;
                }     
            }
        } /*
            
        

   /*
    if ( [SELECT Id from Area__c where Area_Org_ID__c = :recordID].size() > 0 ) {
        for (String i : areaIDs){
            for (Area__c a : [SELECT Id, Area_ID__c, Area_Org_ID__c, Area_Type__c from Area__c where Area_Org_ID__c = :recordID AND Area_ID__c = :i] ) {
            
                String id = i;
                String type = fullParser.get('areas').get(id).get('type_name').Value;
                String name = fullParser.get('areas').get(id).get('name').Value;

                // if area already exists, update not insert
                Area__c newArea = a;
                a.Area_ID__c = i;
                a.Area_Type__c = type;
                //newArea.Name = name;
                //newArea.Area_Org_ID__c = recordID;
                //upsert newArea area__r.Name;
                existingAreas.add(a.Id);

                update a;
            }
        }
    }
    else{
        for (String i : areaIDs){
          
                String id = i;
                String type = fullParser.get('areas').get(id).get('type_name').Value;
                String name = fullParser.get('areas').get(id).get('name').Value;

                // if area already exists, update not insert
                Area__c newArea = new Area__c(Area_ID__c=id,Area_Type__c=type,Name=name,Area_Org_ID__c=recordID);
                //upsert newArea area__r.Name;
                insert newArea;
                }
                      
        }
    */    
    

       // return null; 
    }
}
