public with sharing class CaseTriggerHelper {

 		static final id beddedContactRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('CHAIN bedded down contact').RecordTypeId;
 		static final id tenancyRecordTypeId = Schema.SObjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Tenancy').RecordTypeId;
 		
 		public static void updateHousingSustainmentStartDate(set<Id> caseIds){
 			
 			try {	
	 			set<Id> housingIdList = new set<Id>();
	 			Global_Settings__c orgSettings = Global_Settings__c.getOrgDefaults();
				integer countLimit = integer.valueOf(orgSettings.Bedded_down_contact_count_limit__c);
								
	 			list<Case> caseList = [select Date_of_bedded_down_street_contact__c, Nomination_Tenancy__c 
	 										from Case 
	 										where Id in:caseIds
	 										ALL ROWS];
	 			for (Case c :caseList){
	 				housingIdList.add(c.Nomination_Tenancy__c);
	 			}
	 			Date yearAgo = system.today().addDays(-365);
	 			
	 			list<Nomination_Tenancy__c> housingList = [select Sustainment_start_date__c, Bedded_down_count_since_sust_start__c,
	 														(select Date_of_bedded_down_street_contact__c 
	 															from Cases__r
	 															where recordtypeid =:beddedContactRecordTypeId
	 															order by Date_of_bedded_down_street_contact__c asc)
	 														from Nomination_Tenancy__c 
	 														where Id in:housingIdList
	 														and (End_date__c = null or End_Date__c < TODAY)
	 														and Sustainment_PBR__c = null
	 														and Sustainment_start_date__c != null
	 														and RecordTypeId = :tenancyRecordTypeId];
	 			
	 			
	 			for (Nomination_Tenancy__c h :housingList){
	 				list<Case> tenancyCaseList = h.Cases__r;
	 				if (!tenancyCaseList.isEmpty()){		
	 					integer caseCount = tenancyCaseList.size();
	 					list<Case> currentTenancyCaseList = new list<Case>();
	 					for (Case c :tenancyCaseList){
	 						if (c.Date_of_bedded_down_street_contact__c >  h.Sustainment_start_date__c){
	 							integer daysAfter = h.Sustainment_start_date__c.daysBetween(c.Date_of_bedded_down_street_contact__c);
	 							if (daysAfter > 365){ //after a year
	 								// ?? do anything different ?	
	 							}
	 							currentTenancyCaseList.add(c);
	 						}
	 					}
	 					caseCount = currentTenancyCaseList.size();
	 					date leastRecent = null;
	 					if (caseCount > countLimit){
	 						leastRecent = currentTenancyCaseList[caseCount - countLimit - 1].Date_of_bedded_down_street_contact__c;
	 					}
						if (leastRecent != null){
							h.Sustainment_start_date__c = leastRecent;
							h.Bedded_down_count_since_sust_start__c = countLimit;
						} else {
							h.Bedded_down_count_since_sust_start__c = caseCount;
						}
	 				} else {
	 					h.Bedded_down_count_since_sust_start__c = null;
	 				}
	 				
	 			}
	 			update housingList;
 			
 			} catch(exception e){
 				system.debug(' @@@@@@@@@@    ERROR !!!!    ' + e.getMessage() + ' : ' + e.getStackTraceString());
 			}
 		
 		}
 		   
}