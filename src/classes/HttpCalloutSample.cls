//http://amitsalesforce.blogspot.in/2015/04/pagination-using-standardsetcontroller.html
public with sharing class HttpCalloutSample {

	private final BRPurchaseOrder__c record;   
	public BRPurchaseOrder__c acc {get;set;}   
    public ApexPages.StandardSetController con{get; set;} 
    
    public HttpCalloutSample(ApexPages.StandardController controller) {
        this.record = (BRPurchaseOrder__c)controller.getRecord();
   		acc = new BRPurchaseOrder__c();
       lstBRPurchaseOrder = new List<BRPurchaseOrder__c>();
       Search();
    }

    public List<BRPurchaseOrder__c> lstBRPurchaseOrder
    {  
        get  
        {  
            if(con != null)  
                return (List<BRPurchaseOrder__c>)con.getRecords();  
            else  
                return null ;  
        }  
        set;
    }

    public PageReference Search()
    {
        String query= '';
        String strFilter = '';
        if(acc.Name != null && (acc.Name ).trim() !='')
        {
           strFilter  = strFilter  +  ' where Name Like \''+acc.Name+'%\'' ;
        }
/*        if(acc.Phone != null && (acc.Phone).trim() !='' )
        {
           if(strFilter == '')
           { 
               strFilter  = strFilter  +  ' where Phone like \''+acc.Phone+'%\'' ;
           }
           else
           {
               strFilter  = strFilter  +  ' And Phone like \''+acc.Phone+'%\'' ;
           }
        }
*/
        {
            query = 'Select name ,id, transactionID__c, orderReceived__c, amount__c from BRPurchaseOrder__c '+strFilter+ ' limit 1000';
            System.debug('Query ---->'+ query );
            con = new ApexPages.StandardSetController(Database.getQueryLocator(query)); 
            con.setPageSize(20);
        }
       return null;
    }
    public Boolean hasNext  
    {  
        get  
        {  
            return con.getHasNext();  
        }  
        set;  
    }  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return con.getHasPrevious();  
        }  
        set;  
    }  
    public Integer pageNumber  
    {  
        get  
        {  
            return con.getPageNumber();  
        }  
        set;  
    }  
    public void previous()  
    {  
        con.previous();  
    }  
    public void next()  
    {  
        con.next();  
    }  
   
    public pageReference refresh() {
        con = null;
        con.setPageNumber(1);
        return null;
    }
	BRImportDefinition__c importDefinition = new BRImportDefinition__c();
	
	public BRImportDefinition__c getImportDefinition()
	{
		return importDefinition;
	}	
	
	public void setImportDefinition(BRImportDefinition__c importDefinition)
	{
		this.importDefinition = importDefinition;
	}
	
  // Pass in the endpoint to be used using the string url
  public PageReference getCalloutResponseContents() {

    // Instantiate a new http object
    Http h = new Http();

     // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
    HttpRequest req = new HttpRequest();
    Datetime startDatetime = importDefinition.Start_Date__c;
    Datetime endDatetime = importDefinition.End_Date__c;
    endDateTime = endDatetime.addDays(1);
    req.setEndpoint('callout:TEST_admin/api/v1/purchaseOrderHome/purchaseOrders?startOrderReceived='+EncodingUtil.urlEncode(startDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8')+'&endOrderReceived='+EncodingUtil.urlEncode(endDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8'));
//    req.setEndpoint('callout:TEST_admin/seam/resource/rest/purchaseOrderHome/purchaseOrders?startOrderReceived='+EncodingUtil.urlEncode(startDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8')+'&endOrderReceived='+EncodingUtil.urlEncode(endDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8'));
    req.setMethod('GET');
	system.debug('requrst: ' + 'callout:TEST_admin/api/v1/purchaseOrderHome/purchaseOrders?startOrderReceived='+EncodingUtil.urlEncode(startDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8')+'&endOrderReceived='+EncodingUtil.urlEncode(endDatetime.format('yyyy-MM-dd HH:mm:ss'), 'UTF-8'));
    // Send the request, and return a response
    HttpResponse res = h.send(req);
    system.debug('returned result');
    parseJSONString(res.getBody());
    system.debug('parsed');
    return null;
  }

  public void parseJSONString(String jsonStr) {
    // Parse entire JSON response.
//    JSONParser parser = JSON.createParser(jsonStr);
	List<BRPurchaseOrder__c> insertList = new List<BRPurchaseOrder__c>();
    system.debug(LoggingLevel.INFO,'jsonStr: ' + jsonStr);
    List<Object> maps = (List<Object>)JSON.deserializeUntyped(jsonStr);
    system.debug(LoggingLevel.INFO,'maps: ' + maps);
//    SimpleDateFormat sdf = new SimpleDateFormat('yyyy-MM-dd\'T\'HH:mm:ssX');
    for (Object res : maps) {
    	system.debug(LoggingLevel.INFO,'map: ' + res);
    	Map<String, Object> rmap = (Map<String, Object>)((Map<String, Object>)res).get('purchaseOrder');
    	BRPurchaseOrder__c po = new BRPurchaseOrder__c();
	    system.debug(LoggingLevel.INFO,'active: ' + rmap.get('active'));
	    system.debug(LoggingLevel.INFO,'anonAmount: ' + rmap.get('anonAmount'));
	    system.debug(LoggingLevel.INFO,'amount: ' + rmap.get('amount'));
    	po.active__c = (Boolean)rmap.get('active');
    	po.anonName__c = (Boolean)rmap.get('anonName');
    	po.anonAmount__c = (Boolean)rmap.get('anonAmount');
    	po.orderReceived__c = (Datetime)json.deserialize('"'+rmap.get('orderReceived')+'"', datetime.class);
    	po.transactionID__c = (String)rmap.get('transactionID');
        po.Name = 'po ' + (String)rmap.get('id');
        system.debug('po: ' + po);
        //  If transactionID exists, do not insert
        boolean doNotInsert = false;
       	if (po.transactionID__c == null || po.transactionID__c == '')
       		doNotInsert = true;
        if (!doNotInsert)
	        insertList.add(po);
    }
    
	try {
		system.debug('inserting: ' + insertList.size() + ' records');
	    upsert insertList;
	    refresh();
    } catch (Exception e) {
        System.debug('EXCEPTION:' + e.getMessage());
    }

}

}