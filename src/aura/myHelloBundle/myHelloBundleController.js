({
	myAction : function(component, event, helper) {
		var action = component.get("c.getBRPurchaseOrders");
		action.setCallback(this, function(data) {
		component.set("v.BRPurchaseOrders", data.getReturnValue());
		});
		$A.enqueueAction(action);		
	}
})