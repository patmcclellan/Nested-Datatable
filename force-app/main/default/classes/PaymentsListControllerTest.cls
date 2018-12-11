@isTest

private class PaymentsListControllerTest {

    @testSetup private static void setup()
    {
        //create Account
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
        insert Contacts;
        //create & insert Projects testProject0 - testProject99
        List<Project__c> Projects = new List<Project__c>();
        for (integer i = 0; i<100; i++)
        {
            Projects.add(new Project__c(
                Name = 'testProject' + i,
                Payments__c = i * 1.00 ));
        }
        insert Projects;
        //create & insert 2000 Payments

        List<Payment__c> Payments = new List<Payment__c>();
        for(integer i=101; i<2101; i++)
        {
            integer index = i - 100;
            Payments.add(new Payment__c(
                Name = 'testPayment' + index,
                Amount__c = i * .15,
                Payment_Date__c = date.today() - integer.valueOf(math.random() * 100),
                Contact__c = Contacts[math.mod(i,100)].Id,
                Project__c = Projects[math.mod(i,100)].Id));
        }
        insert Payments;
    }

@isTest
    private static void test_constructor()
    {
        PaymentsListController plc = new PaymentsListController();
        System.assertEquals(100,plc.total_size);
    }
@isTest
    private static void test_getPaymentsMap()
     {
        PaymentsListController plc = new PaymentsListController();
        Map<Id,List<Payment__c>> payMap = plc.getPaymentsMap();
        Set<Id> contactIds = payMap.keySet();
        String firstId = null;
        for (Id setElement : contactIds) {
            firstId = setElement;
            break;
        }
        List<Payment__c> payList = payMap.get(firstId);
        System.assertEquals(20, payMap.size());
        System.assertEquals(20, payList.size());
     }

@isTest
    private static void allContacts()
    {
        PaymentsListController plc = new PaymentsListController();
        plc.allContacts();
        System.assertEquals(100,plc.total_size);
    }


@isTest
    private static void searchContacts()
    {
        PaymentsListController plc = new PaymentsListController();
        plc.searchKey = 'test';
        plc.searchContacts();
        System.assertEquals(100,plc.getTotal_size());
        System.assertEquals(5,plc.getTotalPages());
    }

@isTest
    private static void coverage()
    {
        PaymentsListController plc = new PaymentsListController();       
        plc.getDisableNext();
        plc.getDisablePrevious();
        plc.Next();
        plc.Previous();  
        plc.End();
        plc.Beginning(); 
    }

}
