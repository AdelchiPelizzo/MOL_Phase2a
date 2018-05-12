/**
 * Created by Adelchi on 12/05/2018.
 */
({
    getTotal : function(component, event) {
        var report = component.get("v.report");
        var values = [];
        var i;
        for(i=0; i<report.length; i++ ){
            values.push(report[i].totBoxByNam);
        }

        var sum = values.reduce( function(values, amount){
            return total + amount
        });
        cmp.set("v.sum", sum);
    }
})