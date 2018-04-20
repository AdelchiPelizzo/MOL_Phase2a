({
    doInit: function(component, event, helper) {
        console.log(" do init started ...");
        component.find("medicationRecordCreator").getNewRecord(
            "Medication_Prescribed__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newMedication");
                var error = component.get("v.newMedicationError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }else{
                    console.log("Record template initialized: " +  JSON.stringify(rec) );
                }
            })
        );
        var action = component.get("c.getMedicationList");
        action.setCallback(this, function(response) {
            console.log("inside call back started");
            if (response.getState() == "SUCCESS") {
                component.set("v.medicationNameList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    storeMedicationName: function(component, event, helper){
        var val = event.getSource().get('v.value');
        component.set('v.medicationName', val);
    },

    storeBatchNumber: function(component, event, helper){
        var val = event.getSource().get('v.value');
        component.set('v.batchNumber', val);
    },

    storeQty: function(component, event, helper){
        var val = event.getSource().get('v.value');
        component.set('v.qtyPrescribed', val);
    },

    handleSavePrecription: function(component, event, helper) {
        console.log('handleSavePrecription started ....');
        var isBatchNumberValid = true;
        console.log(isBatchNumberValid);
        var action = component.get("c.getInventoryItem");
        console.log('action has been created ....'+ action);
        action.setParams({ consultId : component.get("v.consultationId"), InventoryName : component.get("v.medicationName"), batchN : component.get("v.batchNumber"), qty: component.get("v.qtyPrescribed")});
        action.setCallback(this, function(response) {
            console.log('call back started ....');
            var state = response.getState();
            console.log(state);
            if(state === "ERROR"){
                isBatchNumberValid = false;
                console.log('isBatchNumberValid.......'+isBatchNumberValid);
                var errors = response.getError();
                console.log('error handling started ....');
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('error message ....'+errors[0].message);
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                        "title": "Error",
                        "message": errors[0].message,
                        });
                        resultsToast.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
        if(isBatchNumberValid){return};
        component.set("v.simpleNewMedication.Consultation__c", component.get("v.recordId"));
        component.set("v.simpleNewMedication.Medication_Name__c", component.get("v.medicationName"));
        component.set("v.simpleNewMedication.Quantity_Prescribed__c", component.get("v.qtyPrescribed"));
        component.set("v.simpleNewMedication.Prescription_Frequency__c", component.get("v.presFrequency"));
        component.set("v.simpleNewMedication.Prescribed_Dose__c", component.get("v.presDose"));
        component.set("v.simpleNewMedication.Prescriber__c", component.get("v.selItem2.val"));
        component.find("medicationRecordCreator").saveRecord(function(saveResult) {
            if ((saveResult.state === "SUCCESS" || saveResult.state === "DRAFT")&& isBatchNumberValid) {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "The record was saved."
                });
                console.log('before firing toast event');
                resultsToast.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
        $A.get("e.force:closeQuickAction").fire();
    }
})