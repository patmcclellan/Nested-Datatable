public with sharing class PaymentTriggerHandler {
    public PaymentTriggerHandler() {

    }

    public void addPayments(List<Payment__c> newList)
    {
        Map<Id,Contact> ContactMap = getContactMap(newList, 1);
        List<Contact> Contacts = contactMapToList(ContactMap);
        Contacts = updateLastPaymentDate(ContactMap, Contacts);
        contactDml(Contacts);

        Map<Id,Project__c> ProjectMap = getProjectMap(newList, 1);
        List<Project__c> Projects = projectMapToList(ProjectMap);
        projectDml(Projects);
    }

    public void deductPayments(List<Payment__c> oldList)
    {
        Map<Id,Contact> ContactMap = getContactMap(oldList, -1);
        List<Contact> Contacts = contactMapToList(ContactMap);
        Contacts = updateLastPaymentDate(ContactMap, Contacts);
        contactDml(Contacts);

        Map<Id,Project__c> ProjectMap = getProjectMap(oldList, -1);
        List<Project__c> Projects = projectMapToList(ProjectMap);
        projectDml(Projects);
    }

    private Map<Id,Contact> getContactMap(List<Payment__c> newList, integer x)
    // multiplier x is positive or negative 1, to add a positive or negative amount
    {
        Map<Id,Contact> ContactMap = new Map<Id,Contact>();
        for(Payment__c Payment : newList)
        {
            Id ContactId = Payment.Contact__c;
            if (ContactMap.containsKey(ContactId))
                //add new amount to existing value for this contact, set most recent date
            {   
                Contact c = ContactMap.get(ContactId);
                c.Payments__c += (Payment.Amount__c * x);
                if (c.Last_Payment_Date__c < Payment.Payment_Date__c)
                {
                    c.Last_Payment_Date__c = Payment.Payment_Date__c;
                } 
                ContactMap.put(ContactId, c);
            }else 
                //put new contact amount & date in the map
            {
                Contact c = new Contact();
                c.Payments__c = Payment.Amount__c * x;
                c.Last_Payment_Date__c = Payment.Payment_Date__c;
                ContactMap.put(ContactId, c);
            }
        }
        return ContactMap;
    }
    
    private Map<Id,Project__c> getProjectMap(List<Payment__c> newList, integer x)
    // multiplier x is positive or negative 1, to add a positive or negative amount
    {
        Map<Id,Project__c> ProjectMap = new Map<Id,Project__c>();
        for(Payment__c Payment : newList)
        {
            Id ProjectId = Payment.Project__c;
            if (ProjectMap.containsKey(ProjectId))
                //add new amount to existing value for this Projecte
            {   
                Project__c p = ProjectMap.get(ProjectId);
                p.Payments__c += (Payment.Amount__c * x);
                ProjectMap.put(ProjectId, p);
            }else 
                //put new project amount in the map
            {
                Project__c p = new Project__c();
                p.Payments__c = Payment.Amount__c * x;
                ProjectMap.put(ProjectId, p);
            }
        }
        return ProjectMap;
    }

    private List<Contact> contactMapToList(Map<Id,Contact> ContactMap)
    {
        List<Contact> Contacts = 
            [SELECT Id, Payments__c, Last_Payment_Date__c
             FROM Contact 
             WHERE Id IN: ContactMap.keySet()];
        for(Contact c : Contacts)
        {
            Contact fresh = ContactMap.get(c.Id);
            if (c.Payments__c != null)
            {
                c.Payments__c += fresh.Payments__c;
            }else 
            {
                c.Payments__c = fresh.Payments__c;
            }
            c.Last_Payment_Date__c = fresh.Last_Payment_Date__c;
            // Last_Payment_Date__c is a placeholder, perhaps to be updated by updateLastPaymentDate()
        }
        return Contacts;
    }

    private List<Project__c> projectMapToList(Map<Id,Project__c> ProjectMap)
    {
        List<Project__c> Projects = 
            [SELECT Id, Payments__c
             FROM Project__c
             WHERE Id IN: ProjectMap.keySet()];
        for (Project__c p : Projects)
        {
            Project__c fresh = ProjectMap.get(p.Id);
            if (p.Payments__c != null)
            {
                p.Payments__c += fresh.Payments__c;
            }else 
            {
                p.Payments__c = fresh.Payments__c;
            }
        }
        return Projects;
    }

    private List<Contact> updateLastPaymentDate(Map<id,Contact> ContactMap, List<Contact> Contacts)
    {
        List<Payment__c> Payments = [SELECT Payment_Date__c, Contact__c, Contact__r.Name
                                     FROM Payment__c 
                                     WHERE Contact__c IN: ContactMap.keySet()
                                     ORDER BY Payment_Date__c DESC];
        // system.debug('🌴 Payments: ' + Payments);
        Map<Id,Date> dateMap = new Map<Id,Date>();
        for(Payment__c Payment : Payments)
        {
            if(!dateMap.containsKey(Payment.Contact__c))
            {
                dateMap.put(Payment.Contact__c, Payment.Payment_Date__c);
                // system.debug('⚽️ set dateMap: ' + Payment.Payment_Date__c);
            }
        }
        for(Contact c : Contacts)
        {
            c.Last_Payment_Date__c = dateMap.get(c.Id);
        }
        return Contacts;
    }

    private void contactDml(List<Contact> Contacts)
    {
        try{
            update Contacts;
        }catch(DmlException e){
            system.debug('CONTACTS DML ERROR: ' + e);
        }
    }

    private void projectDml(List<Project__c> Projects)
    {
        try{
            update Projects;
        }catch(DmlException e){
            system.debug('PROJECTS DML ERROR: ' + e);
        }
    }
}


