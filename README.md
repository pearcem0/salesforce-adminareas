# salesforce-adminareas
Map administrative area information to a custom salesforce object using the records postcode and external api calls.

#What is it?
A new custom object will be created in Salesforce that maps the UK postcode of and organisation to administrative areas. Itâ€™s useful for anyone who has a registered postcode for an organisation in the UK, and needs to find out what region, constituency, or council it lies within.

#Fields
It will contain 4 main fields - Name, Area ID (Hidden), Area Type, Area Org ID (Master-detail, hidden). The main page layout will be arranged so that general users are not able to alter the records in any way.

#Tabs
No tab should be created for the object.

#Layout
The Object and related items will be created and deployed once, and added to the main page layout. The object then contains records for each administrative area that is returned by the MapIt API that is uses (some have more than others).
The object will also include a custom list button (Area_Info_List) which opens link to more information about related areas via map it API. The button uses onclick javascript to open a new tab in the web browser.

#Reports
A custom report type (Administrative Areas) will be deployed to the Accounts & Contacts category.

#How it works
The record creation will be initiated by a process (p_createAreaRecords, created using the process builder) - whenever a record is created, or edited it will trigger a flow (f_createAreaRecords). The flow takes Org ID and Registered Postcode. The flow uses 2 main APEX classes, firstly it uses the createAreaRecords.cls which takes in the org id and postcode using @invocableVariable. An API call is made using the postcode, which returns information about the administrative areas in the form of JSON. The class then calls the Util_JSONParser.cls to parse the json into serialised data that is lastly used to insert the area records into the organisation that started the process. Before the Area records are inserted the status of the callout response from the API is checked, if something is wrong it stops the process, if it is okay it will delete all of the current Area records for that organisation before inserting the most recent information from the API.

#Other Classes
Other Apex classes involved are the test classes createAreaRecords_Test.cls, Util_JSONParser_Test.cls and HttpMockResponse.cls.

#Going forward
A schedule or bulk update will be used to start the process for all organisations in order to make sure that records are firstly created, and then kept up to date, even when not edited. This is especially important in the case of reports.
