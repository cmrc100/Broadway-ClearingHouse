trigger CaseTriggers on Case (after delete, after insert, after update) {
	
	if (trigger.isAfter && (trigger.isUpdate || trigger.isInsert || trigger.isDelete)){
		
		if (trigger.isDelete){
			CaseTriggerHelper.updateHousingSustainmentStartDate(trigger.oldMap.keySet());
			
		} else {
			CaseTriggerHelper.updateHousingSustainmentStartDate(trigger.newMap.keySet());
		}
	}
	    
}