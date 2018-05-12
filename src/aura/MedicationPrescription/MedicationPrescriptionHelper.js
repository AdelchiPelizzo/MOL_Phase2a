/**
 * Created by Adelchi on 20/04/2018.
 */
({
    getNumbers : function(component, event, helper){
        var test = component.isValid();
        console.log("inside helper get Numbers----"+test);
        var medNam = component.get("v.medicationName.text");
        console.log("inside helper get Numbers ---"+medNam);
        var action = component.get("c.getBatchNumList");
        console.log("inside helper get Numbers -----"+action);
        action.setParams({
            medName : medId
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
                            "message": errors[0].message,
                        });
                        resultsToast.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    updateInventory : function(component, event, helper){
        var action = component.get("c.getInventoryItem");
        console.log('action has been created ....'+ action);
        console.log('consultId :'+ component.get("v.consultationId"));
        console.log("InventoryName :"+ component.get("v.medicationName.text"));
        console.log("batchN :"+ component.get("v.batchNumber"));
        console.log("qty:"+ component.get("v.qtyPrescribed"));
        action.setParams({medPId : medPrescribeId, consultId : component.get("v.consultationId"), InventoryName : component.get("v.medicationName.text"), batchN : component.get("v.batchNumber"), qty: component.get("v.qtyPrescribed")});
        console.log("medication id ....."+ medPrescribeId);
        action.setCallback(this, function(response) {
            console.log('call back started ....');
            var state = response.getState();
            console.log(state);
            if(state === "ERROR"){
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
    }
})