({
    init: function (cmp, event, helper) {
        helper.getTotalContacts(cmp,event,helper);
        helper.getDataMap(cmp, event, helper);
    },

 
    searchKeyChange : function(cmp, event, helper)
    {
       helper.searchForContactsMap(cmp,event,helper);
    },

    updateContactInfo: function(cmp, event, helper)
    {
        // console.log("PaymentUpdated event received");
        helper.getUpdatedContactData(cmp, event, helper);
    },

    //more code here

 })