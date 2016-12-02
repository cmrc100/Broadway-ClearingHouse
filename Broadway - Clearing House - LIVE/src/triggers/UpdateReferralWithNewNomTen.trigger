trigger UpdateReferralWithNewNomTen on Nomination_Tenancy__c (after insert) {

	List<Referral__c> referralsToUpdate = new List<Referral__c>{};
  
  	String rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Nomination_Tenancy' AND SobjectType = 'Nomination_Tenancy__c' LIMIT 1].Id;
  
	for(Nomination_Tenancy__c newRecord : Trigger.new)  {    
		
		if (newRecord.RecordTypeId == rt) {  
		      
			Referral__c Referral = [Select Id, Most_recent_nomination_tenancy__c from Referral__c WHERE Id = :newRecord.Referral__c ];
			Referral.Most_recent_nomination_tenancy__c = newRecord.id;
			referralsToUpdate.add(Referral);     
			
		}
		               
	}
	
	//Now outside the FOR Loop, perform a single Update DML statement. 
	update referralsToUpdate;

}