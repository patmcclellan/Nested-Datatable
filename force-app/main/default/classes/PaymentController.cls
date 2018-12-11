public with sharing class PaymentController {
    @AuraEnabled
    public static List<Payment__c> getPayments(Id ContactId) 
    {
        System.debug('Contact: ' + ContactId);
        return [SELECT Id,Name, Project__r.Name,Amount__c,Payment_Date__c, Contact__c
                FROM Payment__c
                WHERE Contact__c =: ContactId
                ORDER BY Payment_Date__c DESC];
    }
}
