@isTest

private class PaymentTriggerHandlerTest 
{

    @testSetup private static void setup()
    {
        Account acc = new Account(Name='Proton 7 Group');
        insert acc;
        
        //create & insert Contacts with Payments__c & Last_Payment_Date__c
        List<Contact> Contacts = new List<Contact>();
        for(integer i = 0; i<100; i++)
        {
            Contacts.add(new Contact(
                AccountId = acc.Id,
                LastName = 'testLastName' + i,
                Payments__c = i * 1.00,
                Last_Payment_Date__c = date.today() - 7 ));
        }  
        Contacts.add(new Contact(
            AccountId = acc.Id,
            LastName = 'Solo',
            Payments__c = null,
            Last_Payment_Date__c = null));
        insert Contacts;      
        
        //create & insert Projects testProject0 - testProject99
        List<Project__c> Projects = new List<Project__c>();
        for (integer i = 0; i<100; i++)
        {
            Projects.add(new Project__c(
                Name = 'testProject' + i,
                Payments__c = i * 1.00 ));
        }
        Projects.add(new Project__c(
            Name = 'projectSolo',
            Payments__c = null ));
        insert Projects;

        //create & insert 1 Payment
        
        Payment__c paySolo = new Payment__c(
            Name = 'testPaymentSolo',
            Amount__c = 7.00,
            Payment_Date__c = date.today() - 4,
            Contact__c = Contacts[100].Id,
            Project__c = Projects[100].Id);
        insert paySolo;
  

        //create & insert 299 Payments
        List<Payment__c> Payments = new List<Payment__c>();
        Date payDate;
        for(integer i=101; i<400; i++)
        {
            integer index = i - 100;
            if (i < 300)
            {
                payDate = date.today() - 5;
            }else 
            {
                payDate = date.today() - 4;
            }
            Payments.add(new Payment__c(
                Name = 'testPayment' + index,
                Amount__c = i * 1.00,
                Payment_Date__c = payDate,
                Contact__c = Contacts[math.mod(i,100)].Id,
                Project__c = Projects[math.mod(i,100)].Id));
        }
        insert Payments;
    }
    
    @isTest
    private static void test_afterInsert1()
    {
        //system assert delta on Project__c payment total for projectSolo
        System.assertEquals(7.00, [SELECT Payments__c FROM Project__c WHERE Name='projectSolo'].Payments__c);
        Contact soloC = [SELECT Payments__c, Last_Payment_Date__c FROM Contact WHERE LastName = 'Solo' LIMIT 1];
        //system assert on Contact Last_Payment_Date__c for projectSolo z
        System.assertEquals(date.today() - 4 , soloC.Last_Payment_Date__c);
        //system assert delta on Contact payment
        System.assertEquals(7.00, soloC.Payments__c);
    }

    @isTest
    private static void test_afterInsert300()
    {
        //system assert payment total for testProject99 = initial 99.00 + payments of 199.00 + 299.00 + 399.00
        System.assertEquals(996.00, [SELECT Payments__c FROM Project__c WHERE Name = 'testProject99' LIMIT 1].Payments__c);
        Contact testC = [SELECT  Payments__c, Last_Payment_Date__c FROM Contact WHERE LastName = 'testLastName4' LIMIT 1];
        System.debug('🍎 testC: ' + testC);
        //system assert Contact payment should equal original value of 4.00 + payments of 104.00 + 204.00 + 304.00.
        System.assertEquals(616.00, testC.Payments__c);
        //system assert on Contact Last_Payment_Date__c
        System.assertEquals(date.today() - 4, testC.Last_Payment_Date__c);
    }
        
    @isTest
    private static void test_afterUpdate1()
    {
        //update Payment
        Payment__c paySolo = [SELECT Id, Amount__c, Payment_Date__c, Contact__c, Project__c FROM Payment__c WHERE Name='testPaymentSolo' LIMIT 1];
        paySolo.Amount__c += .02;
        paySolo.Payment_Date__c = date.today() - 2; 
        update paySolo;
        Contact soloC = [SELECT Payments__c, Last_Payment_Date__c FROM Contact WHERE Id =: paySolo.Contact__c LIMIT 1];
        //system assert on Contacts Last_Payment_Date__c
        System.assertEquals(date.today() - 2, soloC.Last_Payment_Date__c);
        //system assert delta on Contacts payments
        System.assertEquals(7.02, soloC.Payments__c);
        //system assert delta on Project__c payments total
        System.assertEquals(7.02, [SELECT Payments__c FROM Project__c WHERE Name='projectSolo'].Payments__c);
    }

    @isTest
    private static void test_afterUpdate300()
    {
        //update Payments
        List<Payment__c> oldPayments = [SELECT Id, Amount__c, Payment_Date__c FROM Payment__c WHERE Name LIKE 'testPayment%'];
        system.debug('🍋 oldPayments: ' + oldPayments);
        List<Payment__c> Payments = new List<Payment__c>();
        for(Payment__c p : oldPayments)
        {
            p.Payment_Date__c = date.today() - 6;
            p.Amount__c += .03;
            Payments.add(p);
        }
        system.debug('🍇 Payments: ' + Payments);
        update Payments;
        //system assert delta on Project__c payments total
        System.assertEquals(996.09, [SELECT Payments__c FROM Project__c WHERE Name LIKE 'testProject%' ORDER BY Name DESC LIMIT 1].Payments__c);
        Contact testC = [SELECT  LastName, Payments__c, Last_Payment_Date__c FROM Contact WHERE LastName = 'testLastName4' LIMIT 1];
        System.debug('🍑 testC: ' + testC);
        //system assert Contact payment should equal original value of 4.00 + payments of 104.03 + 204.03 + 304.03.
        System.assertEquals(616.09, testC.Payments__c);
        //system assert on Contact Last_Payment_Date__c
        System.assertEquals(date.today() - 6, testC.Last_Payment_Date__c);
    }

    @isTest
    private static void test_afterDelete1()
    {
        //delete 1 payment
        Payment__c testPaymentSolo = [SELECT Id FROM Payment__c WHERE Name = 'testPaymentSolo' LIMIT 1];
        delete testPaymentSolo;
        //system assert delta on Project__c payments total
        System.assertEquals(0.00, [SELECT Payments__c FROM Project__c WHERE Name='projectSolo'].Payments__c);
        Contact soloC = [SELECT Payments__c, Last_Payment_Date__c FROM Contact WHERE LastName = 'Solo' LIMIT 1];
        //system assert on Contact Last_Payment_Date__c for projectSolo z
        System.assertEquals(null , soloC.Last_Payment_Date__c);
        //system assert delta on Contact payment
        System.assertEquals(0.00, soloC.Payments__c);

    }

     @isTest
    private static void test_afterDelete300()
    {
        //delete 100 payments
        List<Payment__c> Payments = [SELECT Id FROM Payment__c WHERE Amount__c > 300.00];
        delete Payments;
        //system assert delta on Project__c payments total
        System.assertEquals(597.00, [SELECT Payments__c FROM Project__c WHERE Name = 'testProject99' LIMIT 1].Payments__c);
        Contact testC = [SELECT  LastName, Payments__c, Last_Payment_Date__c FROM Contact WHERE LastName = 'testLastName4' LIMIT 1];
        System.debug('🍑 testC: ' + testC);
        //system assert Contact payment should equal original value of 4.00 + payments of 104.00 + 204.00
        System.assertEquals(312.00, testC.Payments__c);
        //system assert on Contact Last_Payment_Date__c
        System.assertEquals(date.today() - 5, testC.Last_Payment_Date__c);
    }
    //
}

