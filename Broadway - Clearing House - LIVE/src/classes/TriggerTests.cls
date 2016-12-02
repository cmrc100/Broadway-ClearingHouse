@isTest 
private class TriggerTests {
/* 
    static testMethod void validateUpdateReferralRiskAssessment() {
    
      String rtRef = [SELECT Id FROM RecordType WHERE DeveloperName = 'Referral' AND SobjectType = 'Referral__c' LIMIT 1].Id;
      Referral__c ref = new Referral__c(Client__c = '0032000001K7qAD', RecordTypeId = rtRef);  
    insert ref;
    
      ref = [SELECT Id, Risk_Assessment__c FROM Referral__c WHERE Id =:ref.Id];
    
      String rtAss = [SELECT Id FROM RecordType WHERE DeveloperName = 'Risk_Assessment' AND SobjectType = 'Assessment__c' LIMIT 1].Id;
      Assessment__c ra = new Assessment__c(Referral__c = ref.Id, RecordTypeId = rtAss);  
    insert ra;

    ref = [SELECT Id, Risk_Assessment__c FROM Referral__c WHERE Id =:ref.Id];

    System.assertEquals(ref.Risk_Assessment__c, ra.Id);
    }

    static testMethod void validateUpdateReferralSubstanceUse() {
    
      String rtRef = [SELECT Id FROM RecordType WHERE DeveloperName = 'Referral' AND SobjectType = 'Referral__c' LIMIT 1].Id;
      Referral__c ref = new Referral__c(Client__c = '0032000001K7qAD', RecordTypeId = rtRef);  
    insert ref;
    
      ref = [SELECT Id, Substance_use_assessment__c FROM Referral__c WHERE Id =:ref.Id];
    
      String rtAss = [SELECT Id FROM RecordType WHERE DeveloperName = 'Substance_Use' AND SobjectType = 'Assessment__c' LIMIT 1].Id;
      Assessment__c ra = new Assessment__c(Referral__c = ref.Id, RecordTypeId = rtAss);  
    insert ra;

    ref = [SELECT Id, Substance_use_assessment__c FROM Referral__c WHERE Id =:ref.Id];

    System.assertEquals(ref.Substance_use_assessment__c, ra.Id);
    }
    
    static testMethod void validateUpdateReferralWithNewNomTen() {
      
      String rtRef = [SELECT Id FROM RecordType WHERE DeveloperName = 'Referral' AND SobjectType = 'Referral__c' LIMIT 1].Id;
      Referral__c ref = new Referral__c(Client__c = '0032000001K7qAD', RecordTypeId = rtRef);  
    insert ref;
      
      ref = [SELECT Id, Most_recent_nomination_tenancy__c FROM Referral__c WHERE Id =:ref.Id];
      
      String rtNom = [SELECT Id FROM RecordType WHERE DeveloperName = 'Nomination_Tenancy' AND SobjectType = 'Nomination_Tenancy__c' LIMIT 1].Id;
      Nomination_Tenancy__c ra = new Nomination_Tenancy__c(Referral__c = ref.Id, Client__c = '0032000001K7qAD', RecordTypeId = rtNom);  
    insert ra;
    
    ref = [SELECT Id, Most_recent_nomination_tenancy__c FROM Referral__c WHERE Id =:ref.Id];
    
    System.assertEquals(ref.Most_recent_nomination_tenancy__c, ra.Id);
    }

*/    
}