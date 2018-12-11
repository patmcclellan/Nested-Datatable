({
    getDataMap : function(cmp, event, helper) 
    {
        if (cmp.get("v.totalContacts")>=parseInt(cmp.get("v.offset")))
        {
            var spinner = cmp.find("spinner");
            $A.util.toggleClass(spinner, "slds-hide");
            var action = cmp.get("c.getContactsMap");
            var offset =  cmp.get("v.offset");
            var recordId =  cmp.get("v.recordId");
            var currentMap = cmp.get("v.ContactsMap");
            action.setParams({
                "offset": offset,
                "contactsMap": currentMap,
                "recordId": recordId
            });
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS"){
                    var contactsMap = response.getReturnValue();
                    // console.log('🍇 ' + JSON.stringify(contactsMap));
                    cmp.set("v.ContactsMap", contactsMap);
                    // console.log("🍎 ContactsMap: " + JSON.stringify(cmp.get("v.ContactsMap")));
                    var mapClone = {};
                    Object.assign(mapClone, contactsMap);
                    cmp.set("v.ContactsMapCopy", mapClone);
                    
                    var contacts = Object.values(contactsMap);
                    var formatter = new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD',
                        minimumFractionDigits: 2,
                    });
                    for(var i in contacts)
                    {
                        contacts[i].Payments = formatter.format(contacts[i].Payments__c);
                    }
                    cmp.set('v.Contacts', contacts);
                    //clone Contacts
                    cmp.set("v.ContactsCopy", Object.values(contactsMap));
                    $A.util.toggleClass(spinner, "slds-hide");
                    var offsetI = parseInt(offset);
                    offsetI += 50;
                    cmp.set('v.offset', offsetI.toString());
                    // console.log("offset: " + offsetI + " | totalContacts: " + cmp.get("v.totalContacts"));
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
        }
    },

    getUpdatedContactData : function (cmp, event, helper)
    {
        // console.log('getUpdatedContactData fired');
        var ContactId = event.getParam("ContactId");
        var action = cmp.get("c.getUpdatedContact");
        action.setParams({
            "ContactId" : ContactId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS"){
                var updatedContact=response.getReturnValue();
                var formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                    minimumFractionDigits: 2,
                });
                
            var updatedContact = response.getReturnValue();
            updatedContact.Payments = formatter.format(updatedContact.Payments__c);
            var contactsMap = cmp.get("v.ContactsMap"); // could be search subset
            // console.log("ContactsMap: " + JSON.stringify(contactsMap));
            contactsMap[ContactId] = updatedContact;
            cmp.set("v.ContactsMap", contactsMap);
            // console.log("updatedContactsMap: " + JSON.stringify(cmp.get("v.ContactsMap")));

            var contactsMapCopy = cmp.get("v.ContactsMapCopy"); //full copy of downloaded contacts
            contactsMapCopy[ContactId] = updatedContact;
            cmp.set("v.ContactsMapCopy", contactsMapCopy);
            // console.log("updatedContactsMapCopy: " + JSON.stringify(cmp.get("v.ContactsMapCopy")));

            cmp.set('v.Contacts', Object.values(contactsMap));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
            var ContactUpdatedEvent = $A.get("e.c:ContactUpdated");
            ContactUpdatedEvent.setParams({ "ContactId" : ContactId });
            ContactUpdatedEvent.fire();
        }));
        $A.enqueueAction(action);
    },

    getTotalContacts : function (cmp, event, helper)
    {
        var action = cmp.get("c.getContactsCount");
        action.setParams({
            "recordId" : cmp.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function(response){
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                cmp.set("v.totalContacts", response.getReturnValue());
                // console.log("Total: " + cmp.get("v.totalContacts"));
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        
    },

    searchForContactsMap : function(cmp,event,helper)
    {
        var searchKey = event.getParam("searchKey");   
        if(searchKey == '')
        {
            // revert to previously downloaded list of contacts
            // console.log("empty search, revert");
           
            var prevContactsMap = cmp.get("v.ContactsMapCopy");
            Object.assign(cmp.get("v.ContactsMap"), prevContactsMap);
            var contacts = Object.values(prevContactsMap);
            var formatter = new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
                minimumFractionDigits: 2,
            });
            for(var i in contacts)
            {
                contacts[i].Payments = formatter.format(contacts[i].Payments__c);
            }
            cmp.set('v.Contacts', contacts);
            cmp.set("v.offset", contacts.length.toString());
            cmp.set("v.searching", false);
        }  else 
        {
            // console.log("Caught SearchKeyChange: " + searchKey);
            var action = cmp.get("c.searchContactsMap");
            action.setStorable();
            action.setParams(
                {
                    "searchKey": event.getParam("searchKey")
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS")
                {
                    var formatter = new Intl.NumberFormat('en-US', {
                        style: 'currency',
                        currency: 'USD',
                        minimumFractionDigits: 2,
                      });
                    var contactsMap = response.getReturnValue();
                    cmp.set("v.ContactsMap", contactsMap);
                    var contacts = Object.values(contactsMap);
                    for(var i in contacts)
                    {
                        contacts[i].Payments = formatter.format(contacts[i].Payments__c);
                    }
                    cmp.set("v.searching", true);
                    cmp.set("v.Contacts", contacts);
                }
            });
            $A.enqueueAction(action);
        }
    },

    // more code here


})