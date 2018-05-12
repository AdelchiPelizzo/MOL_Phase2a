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
    },

    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    storeMedicationName: function(component, event, helper){
        console.log("Inside storeMedicationName >>> val  "+val);
        var val = component.get("v.selItem3.val");
        /*var val = event.getSource().get('v.value');*/
        component.set('v.medicationName', val);
        console.log("inside storeMedicationName"+component.get("v.medicationName"));
        helper.getNumbers(component, event);
    },

    getBatchNumberList: function(component, event, helper){
        var test = component.isValid();
        console.log("inside getBatchNumberList get Numbers----"+test);
        var medNam = component.get("v.medicationName.text");
        console.log("inside getBatchNumberList get Numbers ---"+medNam);
        var medId = component.get("v.medicationName.val");
        console.log("inside getBatchNumberList get Id ---"+medId);
        var prescrMode = component.get("v.valueMode");
        var action = component.get("c.getBatchNumList");
        console.log("inside getBatchNumberList get Numbers -----"+action);
        action.setParams({
            medId : medId,
            prescriptionMode : prescrMode
        });
        action.setCallback(this, function(response) {
            console.log('call back started ....');
            var state = response.getState();
            console.log(state);
            console.log('response state <<>> '+state+'  results >> '+response.getReturnValue());
            if(state === "SUCCESS"){
                component.set("v.batchNumberList", response.getReturnValue());
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                console.log('error handling started ....');
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('error message ....'+errors[0].message);
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Error",
                            "message": "Not Available"+errors[0].message,
                        });
                        resultsToast.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
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
        var medPrescribeId = '';
        component.set("v.simpleNewMedication.Consultation__c", component.get("v.recordId"));
        console.log('handleSavePrecription recordId ....'+component.get("v.recordId"));
        component.set("v.simpleNewMedication.prescriptionMode__c", component.get("v.valueMode"));
        console.log('handleSavePrecription valueMode ....'+component.get("v.valueMode"));
        component.set("v.simpleNewMedication.Medication_Name__c", component.get("v.medicationName.text"));
        console.log('handleSavePrecription medicationName ....'+component.get("v.medicationName.text"));
        component.set("v.simpleNewMedication.Quantity_Prescribed__c", component.get("v.qtyPrescribed"));
        console.log('handleSavePrecription qtyPrescribed ....'+component.get("v.qtyPrescribed"));
        component.set("v.simpleNewMedication.Prescription_Frequency__c", component.get("v.presFrequency"));
        console.log('handleSavePrecription presFrequency ....'+component.get("v.presFrequency"));
        component.set("v.simpleNewMedication.Prescriber__c", component.get("v.selItem2.val"));
        console.log('handleSavePrecription selItem2 ....'+component.get("v.selItem2.val"));
        component.set("v.simpleNewMedication.Batch_Number__c", component.get("v.batchNumber"));
        console.log('handleSavePrecription batchNumber ....'+component.get("v.batchNumber"));
        component.find("medicationRecordCreator").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS") {
                console.log('saveResult.recordId..............'+saveResult.recordId);
                component.set("v.medPresId", saveResult.recordId);
                var action = component.get("c.setExistingQuantity");
                action.setStorable();
                var medPrescId = component.get("v.medPresId");
                action.setParams({medPId : medPrescId});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS"){console.log('update inventory');}
                    if(state === "ERROR"){
                        var errors = response.getError();
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
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success",
                    "message": "Medication Record has been created."
                });
                resultsToast.fire();
            }
        }));
        $A.get("e.force:closeQuickAction").fire();
    },

    /*handleSavePrecription: function(component, event, helper) {
        console.log('handleSavePrecription started ....');
        var medPrescribeId = '';
        component.set("v.simpleNewMedication.Consultation__c", component.get("v.recordId"));
        console.log('handleSavePrecription recordId ....'+component.get("v.recordId"));
        component.set("v.simpleNewMedication.prescriptionMode__c", component.get("v.valueMode"));
        console.log('handleSavePrecription valueMode ....'+component.get("v.valueMode"));
        component.set("v.simpleNewMedication.Medication_Name__c", component.get("v.medicationName.text"));
        console.log('handleSavePrecription medicationName ....'+component.get("v.medicationName.text"));
        component.set("v.simpleNewMedication.Quantity_Prescribed__c", component.get("v.qtyPrescribed"));
        console.log('handleSavePrecription qtyPrescribed ....'+component.get("v.qtyPrescribed"));
        component.set("v.simpleNewMedication.Prescription_Frequency__c", component.get("v.presFrequency"));
        console.log('handleSavePrecription presFrequency ....'+component.get("v.presFrequency"));
        component.set("v.simpleNewMedication.Prescriber__c", component.get("v.selItem2.val"));
        console.log('handleSavePrecription selItem2 ....'+component.get("v.selItem2.val"));
        component.set("v.simpleNewMedication.Batch_Number__c", component.get("v.batchNumber"));
        console.log('handleSavePrecription batchNumber ....'+component.get("v.batchNumber"));
        component.find("medicationRecordCreator").saveRecord($A.getCallback(function(saveResult) {
            console.log('saveResult.recordId..............'+saveResult.recordId);*/
            /*component.set("v.medPresId", saveResult.recordId);
            if (saveResult.state === "SUCCESS") {
                var action = component.get("c.setExistingQuantity");
                action.setStorable();
                var medPrescId = component.get("v.medPresId");
                action.setParams({medPId : medPrescId});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "ERROR"){
                        var errors = response.getError();
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
        }));
        $A.get("e.force:closeQuickAction").fire();
    },*/

    handleChangeMode: function(component, event, helper){
        var val = event.getSource().get('v.value');
        component.set('v.valueMode', val);
        console.log(val);
    }
})