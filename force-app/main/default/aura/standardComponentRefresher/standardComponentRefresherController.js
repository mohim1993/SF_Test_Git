({
    refresh: function (component, event, helper) {
        console.log('in refresh component');
        $A.get('e.force:refreshView').fire();
    }
})