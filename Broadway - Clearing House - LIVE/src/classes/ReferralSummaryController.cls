public without sharing class ReferralSummaryController {

	
	private string referralId;
	private list<Referral_Summary__c> ReferralSummaryDef;
	private map<string, list<map<string, list<string>>>> relatedLookupIds = new map<string, list<map<string, list<string>>>>();
	
	public list<string> assessmentList {get; set;}
	public referralSummary referralSummary {get; set;}
	public Referral__c referralRecord = null;
	public map<string, string> sectionLabels {get; set;}
	
	public boolean error {get; set;}
	public string errorMessage {get; set;}
	
	public ReferralSummaryController(){
	
		referralId = ApexPages.currentPage().getParameters().get('Id');
		assessmentList = new list<string>();
		sectionLabels = new map<string, string>();
		getReferralSummary();
			
	}
	

	public ReferralSummaryController(ApexPages.StandardController controller){
		
		error = false;
		referralId = controller.getId();
		assessmentList = new list<string>();
		sectionLabels = new map<string, string>();
		getReferralSummary();

	}	
	
	
	private Referral__c getReferralRecord(){

		try {
			if (referralRecord == null){
				list<Referral_Summary__c> defList = getReferralSummaryDef();
								
				// objRef -> ListOf - objRef.LookupIds, ListOf - objRef Fields
				map<string, set<string>> uniqueFieldMap = new map<string, set<string>>();
				
				string queryIds = 'select ';
				
				for (Referral_Summary__c r :defList){					
					queryIds += r.API_Lookup_Field__c + ',';
				}
				queryIds += 'Id from Referral__c where Id =:referralId';
				
				Referral__c refIds = Database.query(queryIds);
				
				string query = '';

				list<Schema.FieldSetMember> referralFldList = readFieldSet('Referral_Summary', 'Referral__c');
				query = 'Select ';
				for (Referral_Summary__c r :defList){					
					query += r.API_Lookup_Field__c + ',';
				}
								
				for(Schema.FieldSetMember f : referralFldList) {
					if (!query.containsIgnoreCase(string.valueOf(f.getFieldPath())))
						query += f.getFieldPath() + ', ';
				}
				
				list<Schema.FieldSetMember> referralSectionFldList = readFieldSet('Referral_Summary_Section', 'Referral__c');
				for(Schema.FieldSetMember f : referralSectionFldList) {
					if (!query.containsIgnoreCase(string.valueOf(f.getFieldPath())))
						query += f.getFieldPath() + ', ';
				}
								
				map<string, string> objectFields = new map<string, string>();
				
				for (Referral_Summary__c refSummary :defList){					
					string defName = refSummary.Name;
					string objName = refSummary.Object_Name__c;
					assessmentList.add(defName);
					sectionLabels.put(defName, refSummary.Display_Label__c);
					string objRef = refSummary.Object_Reference__c;
					List<Schema.FieldSetMember> fldList = readFieldSet(defName, objName);
					string lookupId = string.valueOf(refIds.get(refSummary.API_Lookup_Field__c));
					if (lookupId == null){
						lookupId = refSummary.API_Lookup_Field__c;
					}
					list<string> lookupFlds = new list<string>();
					set<string> uniqueFields = uniqueFieldMap.get(objRef);
					if (uniqueFields == null){
						uniqueFields = new set<string>();
					}
					
					for(Schema.FieldSetMember f : fldList) {						
						string fld = f.getFieldPath();
						lookupFlds.add(fld);
						uniqueFields.add(fld);						
					}
					uniqueFieldMap.put(objRef, uniqueFields);
					list<map<string, list<string>>> relatedFields = relatedLookupIds.get(objRef);
					if (relatedFields == null){
						relatedFields = new list<map<string, list<string>>>(); 
					}
					
					map<string, list<string>> objFldMap = new map<string, list<string>>();
					objFldMap.put(lookupId, lookupFlds);
					relatedFields.add(objFldMap);					
					relatedLookupIds.put(objRef, relatedFields);					
				}
				for (string key :uniqueFieldMap.keySet()){
					query += '(select '; 
					for(string f :uniqueFieldMap.get(key)) {
						query += f + ', ';						
					}
					list<map<string, list<string>>> relatedIds = relatedLookupIds.get(key);
					list<string> relIds = new list<string>();			
					for (map<string, list<string>> idList :relatedIds){
						for (string idFld :idList.keySet()){
							relIds.add(idFld);
			system.debug(' @@@ idFlds ..  ' + idFld);
							//queryIds += idFld;
						}
					}
		system.debug(' @@@ relIds ..  ' + relIds);									
					query += 'Id from ' + key + ' where id in :relIds),';
				}					
				query += ' Id From Referral__c where Id =:referralId';
		system.debug(' @@@  query  ' + query);		
				this.referralRecord = Database.query(query);
			
			} else {
				return this.referralRecord;
			}
		system.debug(' @@@ referral record  ' + this.referralRecord);
		} catch (exception e){
			string msg = ' An error has occured, please report to system administrator :';
			msg += e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(msg);
			return null;			
		}
		return this.referralRecord;
	}	
	
	private list<Referral_Summary__c> getReferralSummaryDef(){

        if (ReferralSummaryDef == null){
	        ReferralSummaryDef = [select Id, Name, Object_Reference__c, Sequence__c, API_Lookup_Field__c,
	        											Object_Name__c, Lookup__c, Display_Label__c
	         												from Referral_Summary__c
	         												where Active__c = true
	        												order by Sequence__c asc];
        }
        	
		return ReferralSummaryDef;
		
	}
	
	private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
	
	
	    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
 
	    return fieldSetObj.getFields(); 
	}  	
	
	public referralSummary getReferralSummary(){
		try {		
			list<Referral_Summary__c> defList = getReferralSummaryDef(); 
			
			Referral__c referral = getReferralRecord();		
			map<string, list<Sobject>> childRecords = new map<string, list<Sobject>>();
			map<string, string> relatedGroupName = new map<string, string>();
system.debug('@@@@@  relatedLookupIds   ' + relatedLookupIds);			
			
			for (Referral_Summary__c def :defList){
				list<Sobject> objRecList = referral.getSObjects(def.Object_Reference__c);
				relatedGroupName.put(def.Name, def.API_Lookup_Field__c);		
				list<Sobject> objItemList = new list<Sobject>();
				for(Sobject obj :objRecList){
					if (string.valueOf(obj.get('Id')) == string.valueOf(referral.get(def.API_Lookup_Field__c))){					
						objItemList.add(obj);
						childRecords.put(def.Name, objItemList);
						break;
					}
				}
			}
			system.debug(' @@@@ Child Records ....  ' + childRecords);
			referralSummary = new referralSummary();
			
			referralSummary.referral = referral;
			referralSummary.relatedItems = childRecords;
			referralSummary.relatedGroupName = relatedGroupName;
			
			map<string, list<string>> relatedItemFieldMapLeft = new map<string, list<string>>();
			map<string, list<string>> relatedItemFieldMapRight = new map<string, list<string>>();
			map<string, list<string>> relatedItemFieldMap = new map<string, list<string>>();

			for (list<Sobject> objList :childRecords.values()){
				for (Sobject obj :objList){
					string recId = string.valueOf(obj.get('Id'));
					boolean found = false;
					for (list<map<string, list<string>>> fldMap :relatedLookupIds.values()){
						if (found)
							break;
						for (map<string, list<string>> fldList :fldMap){
							if (fldList.containsKey(recId)){
								relatedItemFieldMap.put(recId, fldList.get(recId));
								found = true;
								break;
							}
						}
						
					}
				}
			}
			for (string key :relatedItemFieldMap.keySet()){
				list<string>allFlds = relatedItemFieldMap.get(key);
				list<string> leftFlds = new list<string>();
				list<string> rightFlds = new list<string>();
				boolean left = true;
				for (string f :allFlds){
					
					if (left){
						left = false;
						leftFlds.add(f);
					} else {
						left = true;
						rightFlds.add(f);
					}
				}
				relatedItemFieldMapLeft.put(key, leftFlds); 
				relatedItemFieldMapRight.put(key, rightFlds);

			}

			list<Schema.FieldSetMember> referralSectionFldList = readFieldSet('Referral_Summary_Section', 'Referral__c');
			boolean left = true;
			referralSummary.referralFieldsLeft = new map<string, string>();
			referralSummary.referralFieldsRight = new map<string, string>();
			referralSummary.referralSectionFieldsLeft = new list<string>();
			referralSummary.referralSectionFieldsRight = new list<string>();
			for(Schema.FieldSetMember f : referralSectionFldList) {				
				if (left){
					left = false;
					referralSummary.referralFieldsLeft.put(f.getFieldPath(), f.getLabel());
					referralSummary.referralSectionFieldsLeft.add(f.getFieldPath());
				} else {
					left = true;
					referralSummary.referralFieldsRight.put(f.getFieldPath(), f.getLabel());
					referralSummary.referralSectionFieldsRight.add(f.getFieldPath());
				}		
			}			
			
			referralSummary.relatedItemFieldMap = relatedItemFieldMap;
			referralSummary.relatedItemFieldMapLeft = relatedItemFieldMapLeft;
			referralSummary.relatedItemFieldMapRight = relatedItemFieldMapRight;
			referralSummary.housingHistoryList = HousingHistoryListController.getHousingHistoryList(referralId);

system.debug(' @@@@ referralSummary.referralFieldsLeft  ' + referralSummary.referralFieldsLeft);
system.debug(' @@@@ referralSummary.referralFieldsRight  ' + referralSummary.referralFieldsRight);
system.debug(' @@@@ referralSummary.relatedItemFieldMap  ' + referralSummary.relatedItemFieldMap);
system.debug(' @@@@ referralSummary.relatedItemFieldMapLeft  ' + referralSummary.relatedItemFieldMapLeft);
system.debug(' @@@@ referralSummary.relatedItemFieldMapRight  ' + referralSummary.relatedItemFieldMapRight);
			
			try{
				constructTable();
				system.debug(' @@@@ Table ... ' + referralSummary.relatedTableHtml);
			} catch (exception e){
				system.debug(' @@@ Error constructing table ... ' +  e.getMessage() + ' : ' + e.getStackTraceString());	
				
				errorMessage = 'Print view is only available upon completion of the referral form.';
				error = true;
				
				system.debug('@@@ refrerralSummary 1 .. ' + referralSummary);	
				for (string grp :referralSummary.relatedGroupName.keySet()){
					referralSummary.relatedTableHtml.put(grp, '<p style="color:red">' + errorMessage + '</p>');
				}
				system.debug('@@@ refrerralSummary 2 .. ' + referralSummary);
			}
								
			
		} catch (exception e){
			
			string msg = ' An error has occured, please report to system administrator :';
			msg += e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(msg);
			return null;	
		}
		return referralSummary;
	}

	private void constructTable(){
		
		referralSummary.relatedTableHtml = new map<string, string>();
		map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType relSchema = schemaMap.get('Assessment__c');
		map<String, Schema.SObjectField> fieldMap = relSchema.getDescribe().fields.getMap();

		for (string grp :referralSummary.relatedGroupName.keySet()){
			string table = '<table style="width:100%" class="relatedLists">';
			for (Sobject obj :referralSummary.relatedItems.get(grp)){	 
				
				string recId = string.valueOf(obj.get('Id'));
				list<string> leftFields = referralSummary.relatedItemFieldMapLeft.get(recId);
				list<string> rightFields = referralSummary.relatedItemFieldMapRight.get(recId);
				for (integer i=0; i < leftFields.size(); i++){
					
					table += '<tr>';
					string leftValue = string.valueOf(obj.get(leftFields[i]));
					if (leftValue == null)
						leftValue = '';
						
					if (leftValue == 'Yes' || leftValue == 'true')
						leftValue = '&#x2714';
						
					if (leftValue == 'No' || leftValue == 'false')
						leftValue = '';	
							
					string leftLabel = fieldMap.get(leftFields[i]).getDescribe().getLabel();
					string rightValue = '';
					string rightLabel = '';
					
					if (i < rightFields.size()){
						rightValue = string.valueOf(obj.get(rightFields[i]));
						if (rightValue == null)
							rightValue = '';
						rightLabel = fieldMap.get(rightFields[i]).getDescribe().getLabel();
						
						if (rightValue == 'Yes' || rightValue == 'true')
							rightValue = '&#x2714';
							
						if (rightValue == 'No' || rightValue == 'false')
							rightValue = '';							
					}
					
					table += '<td  width="10%" style="font-weight:bold">';
					table += '<span style="font-weight:bold">' + leftLabel + '</span></td>';
					table += '<td width="40%">';
					table += leftValue + '</td>';
					
					
					if (i < rightFields.size()){
						table += '<td  width="10%" style="font-weight:bold">';
						table += '<span style="font-weight:bold">' + rightLabel + '</span></td>';
						table += '<td width="40%">';
						table += rightValue + '</td>';
					}
					
					table += '</tr>';
					
				}

				
			}
			referralSummary.relatedTableHtml.put(grp, table);
		}
		
		
	}
	
	public class referralSummary {
		
		public Referral__c referral {get; set;}
		public list<string> referralSectionFieldsLeft {get; set;}
		public list<string> referralSectionFieldsRight {get; set;}
		public map<string, string> referralFieldsLeft {get; set;}
		public map<string, string> referralFieldsRight {get; set;}
		public map<string, list<Sobject>> relatedItems {get; set;}
		public map<string, list<string>> relatedItemFieldMap {get; set;}
		public map<string, list<string>> relatedItemFieldMapLeft {get; set;}
		public map<string, list<string>> relatedItemFieldMapRight {get; set;}
		public map<string, string> relatedGroupName {get; set;}
		public map<string, string> relatedTableHtml {get; set;}
		public list<Nomination_Tenancy__c> housingHistoryList {get; set;}
		
		
	}

}