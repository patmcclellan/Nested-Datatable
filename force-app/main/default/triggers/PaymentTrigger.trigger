trigger PaymentTrigger on Payment__c (after insert, after update, after delete) {
    PaymentTriggerHandler handler = new PaymentTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.addPayments(Trigger.new);

    } else if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler.addPayments(Trigger.new);
        handler.deductPayments(Trigger.old);

    }else if(Trigger.isDelete && Trigger.isAfter)
    {
        handler.deductPayments(Trigger.old);
    }
}

