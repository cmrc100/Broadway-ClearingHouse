@isTest(SeeAllData=true) 

//temporary test class to allow deployments .. 
	
	
private class WaitingListTableControllerTest {
	private static Contact client = new Contact();
	private static Referral__c referral = new Referral__c();
	private static Assessment__c assessment = new Assessment__c();
	private static Bedspace__c bedspace = new Bedspace__c ();
	private static Account provider = new Account();
	private static Scheme__c scheme = new Scheme__c();
	private static Nomination_Tenancy__c housingNomination = new Nomination_Tenancy__c();
	private static Nomination_Tenancy__c housingVoid = new Nomination_Tenancy__c();
	
	static final Id clientRecType = Schema.SobjectType.Contact.RecordTypeInfosByName.get('Client').RecordTypeId;
	static final Id referralRecTypeId = Schema.SobjectType.Referral__c.RecordTypeInfosByName.get('Referral').RecordTypeId;
	static final Id providerRecTypeId = Schema.SobjectType.Account.RecordTypeInfosByName.get('Housing Provider').RecordTypeId;
	static final Id nomReqId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Nomination Request').RecordTypeId;
	static final Id voidReqId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Void').RecordTypeId;
	
	static Nomination_Tenancy__c housing = new Nomination_Tenancy__c();
	
	
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
		
		list<Account> accList = [select Id, name from Account where RecordType.Name = 'TST' LIMIT 1];
		Account a = accList[0];
		
		scheme = new Scheme__c (Landlord__c = provider.Id, Name ='Test Scheme', Address_1__c = '1 Test Street',
									Borough__c = 'Westminster', Postcode__c = 'WC1 1AA', TST__c = a.Id );
		insert scheme;										
		
		bedspace = new Bedspace__c (Scheme__c = scheme.id, Active_bedspace__c = true, Floor_level__c = 'Ground');
		insert bedspace;	

		housingVoid = new Nomination_Tenancy__c(Bedspace__c = bedspace.Id, RecordtypeId = voidReqId, start_date__c = system.today(), 
												Waiting_list_category__c = 'Low Needs', Pets_Accepted__c = 'Dog',
												Location__c = 'London', City_Town_Country__c = 'London', Request__c = 'No');
//		insert housingVoid;
				
		housingNomination = new Nomination_Tenancy__c(Bedspace__c = bedspace.Id, RecordtypeId = nomReqId, start_date__c = system.today(), 
												Waiting_list_category__c = 'Low Needs', Pets_Accepted__c = 'Dog',
												Location__c = 'London', City_Town_Country__c = 'London', Request__c = 'No');
//		insert housingNomination;
		
	
		
		list<Nomination_Tenancy__c> housingList = [select Age_criteria__c, Couples_accepted__c, Gender_criteria__c,
								Pets_accepted__c,
								Waiting_list_category__c,
								(select Borough__c, Floor_level__c, Unit_type__c 
									from Bedspaces__r )
								from Nomination_Tenancy__c LIMIT 1]; 
							//	where recordTypeId = :nomReqId];
								
		housing = housingList[0];
	}

    static testMethod void unitTest() {
        // TO DO: implement unit test
        setupData();
		PageReference pg = new PageReference('/apex/WaitingListTable');
    	pg.getParameters().put('Id', housing.Id);
    	Test.setCurrentPage(pg);
    					    	
    	Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(housing);
		WaitingListTableController controller = new WaitingListTableController(stdController);        

        system.assert(controller.tableHtml.length() > 0);
        
        list<string> waitingCategories = controller.getWaitingCategories();
        
    }
}