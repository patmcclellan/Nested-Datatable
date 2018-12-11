@isTest

private class ContactControllerTest {

    @testSetup private static void setup()
    {
        //create Account
        Account acc1 = new Account(Name='Proton 7 Group');
        insert acc1;
        Account acc2 = new Account(Name='Spockness');
        insert acc2;
        //create & insert Contacts with Payments__c & Last_Payment_Date__c
        List<Contact> Contacts = new List<Contact>();
        for(integer i = 0; i<95; i++)
        {
            String root = 'testLastName';
            if (i<10)
                {
                    root = 'testLastName0';
                } 
            
            Contacts.add(new Contact(
                AccountId = acc1.Id,
                
                LastName = root + i,
                Payments__c = i * 1.00,
                Last_Payment_Date__c = date.today() - 7 ));
        }  
        for(integer i = 95; i<100; i++)
        {
            Contacts.add(new Contact(
                AccountId = acc2.Id,
                LastName = 'testLastName' + i,
                Payments__c = i * 1.00,
                Last_Payment_Date__c = date.today() - 7 ));
        } 
        insert Contacts;
        system.debug('Inserted Contacts: ' + Contacts.size());
        //create & insert Projects testProject0 - testProject99
        List<Project__c> Projects = new List<Project__c>();
        for (integer i = 0; i<100; i++)
        {
            Projects.add(new Project__c(
                Name = 'testProject' + i,
                Payments__c = i * 1.00 ));
        }
        insert Projects;
        //create & insert 200 Payments

        List<Payment__c> Payments = new List<Payment__c>();
        for(integer i=0; i<100; i++)
        {
            Payments.add(new Payment__c(
                Name = 'testPayment' + i,
                Amount__c = i + 100.00,
                Payment_Date__c = date.today() - integer.valueOf(math.random() * 100),
                Contact__c = Contacts[i].Id,
                Project__c = Projects[i].Id));
        }
        insert Payments;
    }
    @isTest
    private static void test_getUpdatedContact()
    {
        Id cId = [SELECT Id FROM Contact WHERE LastName = 'testLastName03' LIMIT 1].Id;
        Contact c = ContactController.getUpdatedContact(cId);
        System.assertEquals(106.00,c.Payments__c); //original $3.00 + 1 payment of $103.00
    }

    @isTest
    private static void test_getContactsMapHome()
    {
        List<Contact> Contacts = [SELECT Id, Name, Payments__c, Last_Payment_Date__c FROM Contact WHERE Payments__c > 0.00 LIMIT 50];
        system.debug('Contacts: ' + Contacts.size());
        Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        for(Contact c : Contacts)
        {
            contactsMap.put(c.Id, c);
        }
        System.assertEquals(100,ContactController.getContactsMap('50',contactsMap,null).size());
        System.assertEquals(100,ContactController.getContactsCount(null));
    }

    @isTest
    private static void test_getContactsMapContact()
    {
        Map<Id,Contact> emptyMap = new Map<Id,Contact>();
        Id ContactId = [SELECT Id FROM Contact WHERE LastName = 'testLastName33' LIMIT 1].Id;
        System.assertEquals(1,ContactController.getContactsMap('0',emptyMap,ContactId).size());
        System.assertEquals(1,ContactController.getContactsCount(ContactId));
    }

    @isTest
    private static void test_getContactsMapAccount()
    {
        Map<Id,Contact> emptyMap = new Map<Id,Contact>();
        Id AccountId = [SELECT Id FROM Account WHERE Name = 'Spockness' LIMIT 1].Id;
        System.assertEquals(5,ContactController.getContactsMap('0',emptyMap,AccountId).size());
        System.assertEquals(5,ContactController.getContactsCount(AccountId));
    }

    @isTest
    private static void test_getContactsMapProject()
    {
        Map<Id,Contact> emptyMap = new Map<Id,Contact>();
        Id ProjectId = [SELECT Id FROM Project__c WHERE Name = 'testProject0' LIMIT 1].Id;
        System.assertEquals(1,ContactController.getContactsMap('0',emptyMap,ProjectId).size());
        System.assertEquals(1,ContactController.getContactsCount(ProjectId));
    }

    @isTest
    private static void test_searchContactsMap()
    {
        System.assertEquals(1,ContactController.searchContactsMap('Name33').size());
    }


}
