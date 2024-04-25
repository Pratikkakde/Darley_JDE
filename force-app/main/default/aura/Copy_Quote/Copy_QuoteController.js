({
    handleClick: function (component, event, helper) {
        var quList = component.get("c.copyquote");
        quList.setParams({
            quoteId: component.get("v.recordId"),
            name: component.get("v.QuoteName"),
            Opportunityid: component.get("v.selItem").val
        });


        quList.setCallback(this, function (data) {
            console.log('data', data);
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                component.set("v.quoteId", result.quoteId)
                console.log('result1-->', result);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.quoteId,
                    "slideDevName": "Detail"
                });
                console.log('test')
                navEvt.fire();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success ',
                    message: 'Quote copied Successfully!!',
                    duration: ' 200',
                    key: 'info_alt',
                    type: 'success'
                });
                toastEvent.fire();
                console.log('test1')
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();

            }
            else if (state === "ERROR") {

                var errors = data.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMessage = errors[0].message;
if(errorMessage.includes(' Please select the same Record Type as Opportunity')){
    var error1='The opportunity and quote should have same recordtype.';
}
else{
    error1='Error in Copying the Quote'
}
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: error1,
                        type: "error"
                    });
                    toastEvent.fire();
                }
            }

            //  else{
            //     var toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         title : 'Error',
            //         message: 'Error in cloning the Quote',
            //         duration:' 200',
            //         key: 'info_alt',
            //         type: 'Error'
            //     });
            //     toastEvent.fire();
            // //     alert('Please add contact role on opportunity to create quote ');
            //  }
        });

        $A.enqueueAction(quList);

    },

    doInit: function (component, event, helper) {
        var quList1 = component.get("c.selectquote");
        quList1.setParams({
            quoteId: component.get("v.recordId")

        });
        var quList2 = component.get("c.inactiveProductCheck");
        quList2.setParams({
            quoteId: component.get("v.recordId")

        });
        quList1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //  alert(response.getReturnValue());
                component.set("v.QuoteName", response.getReturnValue());
                // alert(component.get("v.QuoteName"));
                console.log('result -', response.getReturnValue());

            }
        });
        quList2.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //  alert(response.getReturnValue());
                component.set("v.quoteLineItems", response.getReturnValue());
                // alert(component.get("v.QuoteName"));
                console.log('resultactive -', response.getReturnValue());
                result.forEach(function (item) {
                    console.log('item', item);

                    component.set("v.quoteLineItems", result)


                    // Perform any desired operations with each item
                });
                if (result.length > 0) {
                    component.set("v.showModal1", false);
                    component.set("v.showModal", true);
                    console.log('open modalsss');
                    console.log('v.showModalss', component.get("v.showModal"));
                }
                else {
                    component.set("v.showModal", false);
                    component.set("v.showModal1", true);
                    console.log('open modalsss');

                }


            }
        });

        $A.enqueueAction(quList1);
        $A.enqueueAction(quList2);
    },



    handleClickFinish: function (component, event, helper) {
        component.set("v.showModal1", true);
        component.set("v.showModal", false);

    }
})