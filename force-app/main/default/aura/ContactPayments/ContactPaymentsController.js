({
    init: function (cmp, event, helper) {

        cmp.set('v.payColumns', [
            {label: 'Project', initialWidth:280, fieldName: 'ProjectName', type: 'text', sortable:true},
            {label: 'Amount', initialWidth:120, fieldName: 'Amount__c', sortable:true, type: 'currency',cellAttributes: { alignment: 'center' }, typeAttributes: {currencyCode: 'USD'}},
            {label: 'Payment Date', fieldName: 'Payment_Date__c',  type: 'date', sortable:true},
            {label: '', type: 'button', initialWidth: 50, typeAttributes:
                { label: { fieldName: 'actionLabel'},variant:"base", title: 'Edit', name: 'edit_payment', iconName: 'action:edit'}},
            {label: '', type: 'button', initialWidth: 50, typeAttributes:
                { label: { fieldName: 'actionLabel'},variant:"base", title: 'Delete', name: 'delete_payment', iconName: 'action:delete'}}
        ]);
        

        // console.log("payColumns:" + JSON.stringify(cmp.get("v.payColumns")));
    },

    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

    hidePayments: function(cmp, event, helper)
    {
        cmp.set('v.viewPayments', false);
        // console.log('viewPayments: ' + cmp.get('v.viewPayments'));
    },
    
    showPayments: function(cmp, event, helper)
    {
        helper.getPayments(cmp, event, helper);
        cmp.set('v.viewPayments', true);
        // console.log('viewPayments: ' + cmp.get('v.viewPayments'));
    },

    clickNewPayment : function(cmp, event, helper)
    {
        console.log('clicked New Payment');
        helper.newPayment(cmp,event,helper);
    },

    handleRowAction: function (cmp, event, helper) 
    {
        var action = event.getParam('action');
        var row = event.getParam('row');
        cmp.set("v.paymentId", row.Id);
        cmp.set("v.ContactId", row.Contact__c );
        // console.log("paymentId: " + cmp.get("v.paymentId"));
        // console.log('action: ' + action.name + ' | ' + 'row: ' + JSON.stringify(row));
        switch (action.name) {
            case 'delete_payment':
                cmp.set("v.projectName", row.ProjectName);
                cmp.set("v.deleteActive", true);
                break;
            case 'edit_payment': 
                cmp.set("v.editActive", true);
                break;
        };
    },

    handleContactUpdated : function(cmp, event, helper)
    {
        // console.log('ContactUpdated event caught: ' + event.getParam("ContactId") + ' | ' + cmp.get("v.Contact.Id") + ' | ' + (event.getParam('ContactId') == cmp.get("v.Contact.Id")));
        if(event.getParam('ContactId') == cmp.get("v.Contact.Id"))
        {
            helper.getPayments(cmp, event, helper);
            cmp.set('v.viewPayments', true);
        }
    },  

    cancel: function(cmp, event, helper)
    {
        cmp.set("v.deleteActive", false);
        cmp.set("v.editActive", false);
    },

    save : function(cmp, event, helper){
        cmp.find("edit").get("e.recordSave").fire();
        cmp.set("v.editActive", false);
        helper.refreshView(cmp, event, helper);
    },

    delete : function(cmp, event, helper){
        cmp.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                console.log("Record is deleted.");
            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
            }
        }));
        // cmp.get("v.paymentId").get("e.recordDelete").fire();
        cmp.set("v.deleteActive", false);
        helper.refreshView(cmp, event, helper);
    },





    //more code here
})
