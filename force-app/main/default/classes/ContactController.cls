public with sharing class ContactController {


    @AuraEnabled
    public static Contact getUpdatedContact(String ContactId) {
        Contact updatedContact =
                [SELECT Id, Name, Last_Payment_Date__c, Payments__c 
                 FROM Contact
                 WHERE Id =: ContactId
                 LIMIT 1];
        return updatedContact;
    }

    @AuraEnabled
    public static Map<Id,Contact> getContactsMap(String offset, Map<Id,Contact> contactsMap, String recordId) {
        Map<Id,Contact> newMap = new Map<Id,Contact>();
         if (recordId == null) 
         {
            newMap = getConListNoRecordId(offset);
        } else if (recordId.Left(3) == Schema.SObjectType.Contact.getKeyPrefix()) //it's a Contact record
        {  
            newMap = getConListForContact(recordId);
        } else if (recordId.Left(3) == Schema.SObjectType.Account.getKeyPrefix()) //it's an Account record
        {  
            system.debug('Looking for contacts by account: ' + recordId);
            newMap = getConListForAccount(offset, recordId);
        }else if (recordId.Left(3) == Schema.SObjectType.Project__c.getKeyPrefix()) //it's a Project record
        {  
            system.debug('Looking for contacts by project: ' + recordId);
            newMap = getConListForProject(offset, recordId);
        }
        
        contactsMap.putAll(newMap);
        return contactsMap;
    }

    private static Map<Id,Contact> getConListNoRecordId(String offset)
    {
        integer offsetI =integer.valueOf(offset);
        Map<Id,Contact> newMap = new Map<Id,Contact>(
                [SELECT Id, Name, Last_Payment_Date__c, Payments__c 
                 FROM Contact
                 WHERE Payments__c > 0.00
                 ORDER by LastName
                 LIMIT 50 
                 OFFSET :offsetI]);
        system.debug('Found contacts (home): ' + newMap);
        return newMap;
    }

    private static Map<Id,Contact> getConListForContact( Id recordId)
    {
        Map<Id,Contact> newMap = new Map<Id,Contact>(
                [SELECT Id, Name, Last_Payment_Date__c, Payments__c 
                 FROM Contact
                 WHERE Payments__c > 0.00 and Id =: recordId
                 ORDER by LastName
                 LIMIT 1]);
        return newMap;
    }

    private static Map<Id,Contact> getConListForAccount(String offset, Id recordId)
    {
        integer offsetI =integer.valueOf(offset);
        Map<Id,Contact> newMap = new Map<Id,Contact>(
                [SELECT Id, Name, Last_Payment_Date__c, Payments__c, AccountId
                 FROM Contact
                 WHERE Payments__c > 0.00 and AccountId =: recordId
                 ORDER by LastName
                 LIMIT 50 
                 OFFSET :offsetI]);
        system.debug('Found contacts: ' + newMap.size());
        return newMap;
    }

    private static Map<Id,Contact> getConListForProject(String offset, Id recordId)
    {
        integer offsetI =integer.valueOf(offset);
        List<Id> ContactIds = new List<Id>();
        List<Payment__c> Payments = [SELECT Contact__c FROM Payment__c WHERE Project__c =: recordId];
        for(Payment__c p : Payments)
        {
            ContactIds.add(p.Contact__c);
        }
        Map<Id,Contact> newMap = new Map<Id,Contact>(
                [SELECT Id, Name, Last_Payment_Date__c, Payments__c, AccountId
                 FROM Contact
                 WHERE Payments__c > 0.00 and Id IN :ContactIds
                 ORDER by LastName
                 LIMIT 50 
                 OFFSET :offsetI]);
        system.debug('Found contacts: ' + newMap);
        return newMap;
    }


    @AuraEnabled
    public static Integer getContactsCount(String recordId) 
    {
        if (recordId == null) 
         {
            return [SELECT Count() FROM Contact WHERE Payments__c > 0.00 ];
        } else if (recordId.Left(3) == Schema.SObjectType.Contact.getKeyPrefix()) //it's a Contact record
        {  
            return 1;
        } else if (recordId.Left(3) == Schema.SObjectType.Account.getKeyPrefix()) //it's an Account record
        {  
            return [SELECT Count() FROM Contact WHERE Payments__c > 0.00 and AccountId =: recordId];
        }else if (recordId.Left(3) == Schema.SObjectType.Project__c.getKeyPrefix()) //it's an Account record
        {  
            List<Id> ContactIds = new List<Id>();
            List<Payment__c> Payments = [SELECT Contact__c FROM Payment__c WHERE Project__c =: recordId];
            for(Payment__c p : Payments)
            {
                ContactIds.add(p.Contact__c);
            }
            return [SELECT Count() FROM Contact WHERE Payments__c > 0.00 and Id IN :ContactIds];
        }else return null;
    }

    @AuraEnabled
    public static Map<Id,Contact> searchContactsMap(String searchKey) {
        String keyName = '%' + searchKey + '%';
        Map<Id,Contact> contactsMap = new Map<Id,Contact>(
                [SELECT Id, Name, LastName, Last_Payment_Date__c, Payments__c 
                 FROM Contact
                 WHERE Payments__c > 0.00 AND (Name LIKE: keyName OR LastName LIKE: keyName)
                 ORDER by LastName
                 LIMIT 10]);
        return contactsMap;
    }
}