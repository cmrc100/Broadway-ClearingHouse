public without sharing class HousingHistoryListController {

	public list<Nomination_Tenancy__c> historyList {get; set;}
	static final Id housingRecTypeId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Housing History').RecordTypeId;
	static final Id tenancyRecTypeId = Schema.SobjectType.Nomination_Tenancy__c.RecordTypeInfosByName.get('Tenancy').RecordTypeId;
	static string clientId;
	static date fiveYearDate;
	private string referralId;
	
	public HousingHistoryListController(){
		
		referralId = ApexPages.currentPage().getParameters().get('Id');
		getHistoryData();
	}
	
	public HousingHistoryListController(ApexPages.StandardController controller){
		
		try {	
			referralId = controller.getId();
			Referral__c ref = (Referral__c)controller.getRecord();
			getHistoryData();
			
		} catch (exception e){
			string msg = ' An error has occured, please report to system administrator :';
			msg += e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(msg);				
		}
	}

	private void getHistoryData(){
		
		string query = getQueryString(this.referralId);
		this.historyList = Database.query(query);
		
	}	
	
	private static string getQueryString(string refId){
		
		string query = 'SELECT ';
		Referral__c ref  = [select createddate, client__c, Submitted_date__c from Referral__c where Id = :refId ];
		clientId = ref.client__c;
		fiveYearDate = null;
		
		if (ref.submitted_date__c != null){
			if (ref.createddate > ref.Submitted_date__c) {
				fiveYearDate = date.newInstance(ref.Submitted_date__c.year(), ref.Submitted_date__c.month(), ref.Submitted_date__c.day() ).addYears(-5);	
			} else {
				fiveYearDate = date.newInstance(ref.createddate.year(), ref.createddate.month(), ref.createddate.day()).addYears(-5);
			}
		} else {
			fiveYearDate = date.newInstance(ref.createddate.year(), ref.createddate.month(), ref.createddate.day()).addYears(-5);
		}
system.debug('@@@ ' + fiveYearDate);
		
		list<Schema.FieldSetMember> historyFlds = SObjectType.Nomination_Tenancy__c.FieldSets.Housing_History_List.getFields();
		for(Schema.FieldSetMember f :historyFlds) {
			query += f.getFieldPath() + ', ';
		}
		query += 'Id, Name ';  
		query += ' FROM Nomination_Tenancy__c WHERE Client__c = :clientId';
		query += ' AND (RecordTypeId =: housingRecTypeId or RecordTypeId =: tenancyRecTypeId)';
		query += ' AND (end_date__c >=: fiveYearDate or end_date__c = null)';
		query += ' ORDER BY Start_date__c desc';
system.debug('@@@ ' + query);		
		
		return query;
	}
	
	public list<Schema.FieldSetMember> getHistoryFields() {
		return SObjectType.Nomination_Tenancy__c.FieldSets.Housing_History_List.getFields();
	}	
	
	public static list<Nomination_Tenancy__c> getHousingHistoryList(string refId){
		
		string query = getQueryString(refId);
		
		list<Nomination_Tenancy__c> returnList = Database.query(query);
			
		return returnList;	
		
		
	}
	
}