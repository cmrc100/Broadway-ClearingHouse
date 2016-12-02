trigger UpdateReferralRiskAssessment on Assessment__c (after insert) {

	List<Referral__c> referralsToUpdate = new List<Referral__c>{};
  
	String rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Risk_Assessment' AND SobjectType = 'Assessment__c' LIMIT 1].Id;
  
	for(Assessment__c newRecord : Trigger.new)  { 
		       
		if (newRecord.RecordTypeId == rt) {  
			
			Referral__c Referral = [Select Id, Risk_Assessment__c from Referral__c WHERE Id = :newRecord.Referral__c ];
			Referral.Risk_Assessment__c = newRecord.id;
			referralsToUpdate.add(Referral);  
			    
		} 
		             
	}
	
	//Now outside the FOR Loop, perform a single Update DML statement. 
	update referralsToUpdate;

}