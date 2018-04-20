/**
 * Created by Adelchi on 16/04/2018.
 */
({
    doInit: function(component, event, helper) {
        console.log('Start Init');
        var action = component.get("c.getMedicationList");
        console.log('Action set');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Start Callback'+state);
            if (state === "SUCCESS") {
                console.log('Inside Callback');
                component.set("v.medicationNames", response.getReturnValue());
                console.log('Return Value Callback'+JSON.stringify(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        var action1 = component.get("c.getConsumablesList");
        console.log('Action set');
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Start Callback'+state);
            if (state === "SUCCESS") {
                console.log('Inside Callback');
                component.set("v.consumablesNames", response.getReturnValue());
                console.log('Return Value Callback'+JSON.stringify(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
    },
    setMedicationName: function(component, event, helper) {
        var medName = event.getSource().get("v.value");
        console.log(medName);
        component.set("v.InventoryName", medName);
    },

    setConsumableName: function(component, event, helper) {
        var consName = event.getSource().get("v.value");
        console.log(consName);
        component.set("v.consumableName", consName);
    },
    StoreBatchNumber: function(component, event, helper) {
        var bNumb = event.getSource().get("v.value");
        component.set("v.BatchNr", bNumb);
    },

    StoreExpDate: function(component, event, helper) {
        var exDate = event.getSource().get("v.value");
        component.set("v.ExpirationDate", exDate);
    },
    addItem: function(component, event, helper) {
        var invName = component.get("v.InventoryName");
        console.log(invName);
        var invQty = component.get("v.InventoryQty");
        console.log(invQty);
        var batchNr = component.get("v.BatchNr");
        console.log(batchNr);
        var exDat = component.get("v.ExpirationDate");
        console.log(exDat);
        var action = component.get("c.addItems");
        action.setParams({ Name : invName, Quantity : invQty, batchNumber : batchNr, expireDate : exDat });
        action.setCallback(this, function(response) {
            console.log("inside call back started");
            var state = response.getState();
            console.log("inside call back started >>>  "+state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "Records saved successfully."
                });
                resultsToast.fire();
            } else if (state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Error",
                            "message": "Error message: " +
                            errors[0].message
                        });
                        resultsToast.fire();
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        });
        $A.enqueueAction(action);
        component.find("MedSelect").set("v.value", "");
        component.find("MedSelect1").set("v.value", "");
        component.find("MedSelect2").set("v.value", "");
        component.find("MedSelect3").set("v.value", "");
    },

    addConsumableItem: function(component, event, helper) {
        var consName = component.get("v.consumableName");
        console.log(consName);
        var consQty = component.get("v.consQty");
        console.log(consQty);
        var batchNr = component.get("v.consBatchNr");
        console.log(batchNr);
        var exDat = component.get("v.consExpirationDate");
        console.log(exDat);
        var action = component.get("c.addItems");
        action.setParams({ Name : consName, Quantity : consQty, batchNumber : batchNr, expireDate : exDat });
        action.setCallback(this, function(response) {
            console.log("inside call back started");
            var state = response.getState();
            console.log("inside call back started >>>  "+state);
            var resultsToast = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "Records saved successfully."
                });
                resultsToast.fire();
            } else if (state === "No Items are Available with this Batch Number!") {
                console.log("No Items are Available with this Batch Number!");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "No Items are Available with this Batch Number!"
                });
                resultsToast.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Error",
                            "message": "Error message: " +
                            errors[0].message
                        });
                        resultsToast.fire();
                    } else {
                        console.log("Unknown error");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    removeItems: function(component, event, helper){
    },

    removeConsumableItems: function(component, event, helper){
    },

    toggleRemoveView: function(component, event, helper){
        if(component.get("v.removalToggle")){
            component.set("v.removalToggle", false);
        }else{
            component.set("v.removalToggle", true);
        }
        if(component.get("v.addToggle")){
            component.set("v.addToggle", false);
        }
    },

    toggleAddView: function(component, event, helper){
        if(component.get("v.addToggle")){
            component.set("v.addToggle", false);
        }else{
            component.set("v.addToggle", true);
        }
        if(component.get("v.removalToggle")){
            component.set("v.removalToggle", false);
        }
    }
})