public with sharing class MyBRPurchaseOrderController {
 @AuraEnabled
public static List<BRPurchaseOrder__c> getBRPurchaseOrders() {
    return [SELECT Id, Name, transactionID__c, amount__c FROM BRPurchaseOrder__c];
}   
}