@isTest

private class PaymentControllerTest {

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
    private static void test_getPayments()
    {
        Id cId = [SELECT Id FROM Contact WHERE LastName = 'testLastName03' LIMIT 1].Id;
        List<Payment__c> Payments = PaymentController.getPayments(cId);
        System.assertEquals(1, Payments.size()); 
        Payment__c Payment = Payments[0];
        System.assertEquals(103.00,Payment.Amount__c); 
    }
}