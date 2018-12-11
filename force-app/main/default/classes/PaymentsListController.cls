public with sharing class PaymentsListController {
    String contactId;
    List<Id> ContactIds;
    private integer counter=0;  //keeps track of the offset
    private integer list_size=20; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public String searchKey {get;set;}
    public List<Contact> Contacts {get;set;}
    public List<Payment__c> PaymentList = new List<Payment__c>();

    public PaymentsListController() 
    {
         Contacts =
                [SELECT Id, Name, Payments__c, Last_Payment_Date__c
                FROM Contact
                WHERE Payments__c > 0.00 
                ORDER BY LastName
                LIMIT :list_size
                OFFSET :counter];
        ContactIds = new List<Id>();
        for(Contact c : Contacts)
        {
            ContactIds.add(c.Id);
        }
        total_size = [SELECT Count() FROM Contact WHERE Payments__c > 0.00];
    }

    public map<Id,List<Payment__c>> getPaymentsMap() {
        PaymentList =
            [SELECT Id,Contact__c,Amount__c,Payment_Date__c, Project__c, Project__r.Name
             FROM Payment__c
             WHERE Contact__c IN :ContactIds
             ORDER BY Payment_Date__c DESC];
        map<Id,List<Payment__c>> PaymentsMap = new map<Id,List<Payment__c>>();
        for(Payment__c payment : PaymentList)
        {
            List<Payment__c> thisPayList;
            if(PaymentsMap.containsKey(payment.Contact__c))
            {
                thisPayList = PaymentsMap.get(payment.Contact__c);
                thisPayList.add(payment);
            }else 
            {
                thisPayList = new List<Payment__c>();
                thisPayList.add(payment);
            }
            PaymentsMap.put(payment.Contact__c,thisPayList);
        }
        return PaymentsMap;
    }

    public Pagereference showAllButton()
    {
        counter=0;
        allContacts();
        return null;
    }

    public Pagereference allContacts()
    {
        try
        {
            Contacts =
                [SELECT Id, Name, Payments__c, Last_Payment_Date__c
                FROM Contact
                WHERE Payments__c > 0.00 
                ORDER BY LastName
                LIMIT :list_size
                OFFSET :counter];
                searchKey = '';
        } catch (QueryException e)
        {
            ApexPages.addMessages(e);
        }
        ContactIds = new List<Id>();
        for(Contact c : Contacts)
        {
            ContactIds.add(c.Id);
        }
        total_size = [SELECT Count() FROM Contact WHERE Payments__c > 0.00];
        return null;
    }
    public Pagereference searchButton()
    {
        counter=0;
        searchContacts();
        return null;
    }

    public Pagereference searchContacts()
    {
        String name = '%' + searchKey + '%';
        try
        {
            Contacts =
                [SELECT Id, Name, Payments__c, Last_Payment_Date__c
                FROM Contact
                WHERE Payments__c > 0.00 AND Name LIKE :name
                ORDER BY LastName
                LIMIT :list_size
                OFFSET :counter];
        } catch (QueryException e)
        {
            ApexPages.addMessages(e);
        }
        ContactIds = new List<Id>();
        for(Contact c : Contacts)
        {
            ContactIds.add(c.Id);
        }
        total_size = [SELECT Count() FROM Contact WHERE Payments__c > 0.00 AND Name LIKE :name];
        return null;
    }

    public Pagereference saveChanges()
    {  
        try 
        {
            update PaymentList;
            searchContacts();
        }
        catch(Exception e)
        {
            System.debug('Exception occurred ' + String.valueOf(e));
        }
        return NULL;
    }

    public PageReference Beginning() { //user clicked beginning
      counter = 0;
      searchContacts();
      return null;
   }

   public PageReference Previous() { //user clicked previous button
      counter -= list_size;
      searchContacts();
      return null;
   }

   public PageReference Next() { //user clicked next button
      counter += list_size;
      searchContacts();
      return null;
   }

   public PageReference End() { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
      searchContacts();
      return null;
   }

   public Boolean getDisablePrevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }

   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return false; else return true;
   }

   public Integer getTotal_size() {
      return total_size;
   }

   public Integer getPageNumber() {
      return counter/list_size + 1;
   }

   public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
   }
}
