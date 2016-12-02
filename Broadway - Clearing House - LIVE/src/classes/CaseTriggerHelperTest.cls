/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CaseTriggerHelperTest {

	private static Contact client = new Contact();
	private static Referral__c referral = new Referral__c();
	private static Assessment__c assessment = new Assessment__c();
	private static Bedspace__c bedspace = new Bedspace__c ();
	private static Account provider = new Account();
	private static Scheme__c scheme = new Scheme__c();
	private static Nomination_Tenancy__c housingNomination = new Nomination_Tenancy__c();
	private static Nomination_Tenancy__c housingVoid = new Nomination_Tenancy__c();
	private static Nomination_Tenancy__c housingTenancy = new Nomination_Tenancy__c();

	static final Id clientRecType = Schema.SobjectType.Contact.RecordTypeInfosByName.get('Client').RecordTypeId;
	static final Id referralRecTypeId = Schema.SobjectType.Referral__c.RecordTypeInfosByName.get('Referral').RecordTypeId;
	static final Id providerRecTypeId = Schema.SobjectType.Account.RecordTypeInfosByName.get('Housing Provider').RecordTypeId;
	static final Id TSTRecTypeId = Schema.SobjectType.Account.RecordTypeInfosByName.get('TST').RecordTypeId;
	static final Id housingRecTypeId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Housing History').RecordTypeId;
	static final Id tenancyRecTypeId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Tenancy').RecordTypeId;
	static final id beddedContactRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('CHAIN bedded down contact').RecordTypeId;
	
	static void setupData(){
		
		client = new Contact (FirstName = 'Test', LastName = 'Client', CHAIN_number__c = 'CH00001', RecordTypeId = clientRecType);
		insert client;
		
		referral = new Referral__c (Client__c = client.Id, Waiting_list_category__c = 'Low Needs', RecordTypeId = referralRecTypeId);
		insert referral;
		
		assessment = new Assessment__c (referral__c = referral.id, Westminster__c = true, Pet__c = 'Dog', 
											Acceptable_floor_levels__c = 'Ground', Floor_property_restriction_reasons__c = 'Hates stairs');
		
		insert assessment;
		
		provider = new Account (RecordTypeId = providerRecTypeId, Name = 'Test Provider' );
		insert provider;
		
		Account tst = new Account (RecordTypeId = TSTRecTypeId, Name = 'Test tst' );
		insert tst;
		
		list<Account> accList = [select Id, name from Account where RecordType.Name = 'TST' LIMIT 1];
		Account a = accList[0];
		
		scheme = new Scheme__c (Landlord__c = provider.Id, Name ='Test Scheme', Address_1__c = '1 Test Street',
									Borough__c = 'Westminster', Postcode__c = 'WC1 1AA', TST__c = a.Id );
		insert scheme;										
		
		bedspace = new Bedspace__c (Scheme__c = scheme.id, Active_bedspace__c = true, Floor_level__c = 'Ground');
		insert bedspace;	

		//housingVoid = new Nomination_Tenancy__c(Bedspace__c = bedspace.Id, RecordtypeId = voidReqId, start_date__c = system.today(), 
		//										Waiting_list_category__c = 'Low Needs', Pets_Accepted__c = 'Dog');
		//insert housingVoid;
				
		housingTenancy = new Nomination_Tenancy__c(Bedspace__c = bedspace.Id, RecordtypeId = tenancyRecTypeId, start_date__c = system.today(), 
												Waiting_list_category__c = 'Low Needs', Pets_Accepted__c = 'Dog',
												Client__c = client.Id, referral__c = referral.id,
												Location__c = 'London', City_Town_Country__c = 'London');
		insert housingTenancy;
		
	
		
		list<Nomination_Tenancy__c> housingList = [select Age_criteria__c, Couples_accepted__c, Gender_criteria__c,
								Pets_accepted__c,
								Waiting_list_category__c,
								(select Borough__c, Floor_level__c, Unit_type__c 
									from Bedspaces__r )
								from Nomination_Tenancy__c 
								where recordTypeId = :tenancyRecTypeId];
								

	}

    static testMethod void unitTest() {
		
		setupData();
		
		housingTenancy = [select Sustainment_start_date__c, Bedded_down_count_since_sust_start__c, Sustainment_PBR__c
							from Nomination_Tenancy__c where id = :housingTenancy.Id];
							
		housingTenancy.Sustainment_start_date__c = system.today().addDays(-7);
		housingTenancy.Sustainment_PBR__c = null;
		
		update housingTenancy;					

		Case c = new Case (RecordTypeId = beddedContactRecordTypeId, Date_of_bedded_down_street_contact__c = system.today().addDays(-1),
							Nomination_Tenancy__c = housingTenancy.Id, Status = 'Working');
		
		insert c;
		
		// to do....add more cases, system asserts... but firstly verify solution is correct        
    }
}