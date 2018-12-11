({
    getPayments : function(cmp, event, helper) 
    {
        var action = cmp.get('c.getPayments');
        var contact = cmp.get("v.Contact");
        // console.log('getPayments for ' + contact.Name);
        action.setParams({
            "ContactId": contact.Id
          });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var payments= response.getReturnValue();
                for(var i in payments )
                {
                    payments[i].ProjectName = payments[i].Project__r.Name;
                }
                cmp.set('v.Payments', payments);
                cmp.set('v.PaymentId', payments[0].Id);
                // console.log('payments: ' + JSON.stringify(payments));
                cmp.set('v.hasPayments', true);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.Payments");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.Payments", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }, 

    refreshView : function (cmp, event, helper)
    {
        console.log("refreshView fired.");
        var compEvent = cmp.getEvent("PaymentUpdated");
        compEvent.setParams({"ContactId" : cmp.get("v.Contact.Id") });
        compEvent.fire();
        
    },

    newPayment: function(cmp, event, helper)
    {
        var createRecordEvent = $A.get("e.force:createRecord");
        // console.log("processing newPayment: " + createRecordEvent);
        createRecordEvent.setParams({ 
            "entityApiName": "Payment__c",
            "defaultFieldValues":{"Contact__c" : cmp.get("v.Contact.Id")}
        });
        createRecordEvent.fire();
    },

    // more code here

})
