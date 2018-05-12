/**
 * Created by Adelchi on 25/04/2018.
 */
({
    changeSiteN: function(component, event, helper){
        console.log('Start Helper >>>');
        /* window.setTimeout(function(){alert(component.get("v.Site.val"))}, 5000);*/
        var action = component.get("c.setSiteName");
        var site = component.get("v.Site.val");
        console.log('Inside Helper - site  >>>  '+site);
        console.log('Hello Site >> '+site);
        action.setParams({
            siteId : component.get("v.Site.val")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                // record is saved successfully
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "Hippie - Your Site was reassigned."
                });
                resultsToast.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saving Error",
                    "message": "Please make sure you entered values correctly."
                });
                resultsToast.fire();
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
        $A.enqueueAction(action);
    },


})