public with sharing class WaitingListTableController {


    public string tableHtml {get; set;}
    public list<colDef> colDefList {get; set;}
    public string waitingCategory {get;set;}
    public string categoryIndex {get; set;}
    public Nomination_Tenancy__c housing {get; set;}
    public list<string> housingCategories {get; set;}
    public string refIds {get;set;}
    public string housingId {get; set;}
    
    private ApexPages.StandardController stdController;
    
    private static final Id referralRecTypeId = Schema.SobjectType.Referral__c.RecordTypeInfosByName.get('Referral').RecordTypeId;
    private static final Id transferRecTypeId = Schema.SobjectType.Referral__c.RecordTypeInfosByName.get('Transfer').RecordTypeId;
    private static list<string> boroughNames = new list<string>{'Barking_Dagenham__c',
														'Barnet__c',
														'Bexley__c',
														'Brent__c',
														'Bromley__c',
														'Camden__c',
														'City__c',
														'Croydon__c',
														'Ealing__c',
														'Enfield__c',
														'Greenwich__c',
														'Hackney__c',
														'Hammersmith_Fulham__c',
														'Haringey__c',
														'Harrow__c',
														'Havering__c',
														'Hillingdon__c',
														'Hounslow__c',
														'Islington__c',
														'Kensington_Chelsea__c',
														'Kingston__c',
														'Lambeth__c',
														'Lewisham__c',
														'Merton__c',
														'Newham__c',
														'Redbridge__c',
														'Richmond__c',
														'Southwark__c',
														'Sutton__c',
														'Tower_Hamlets__c',
														'Waltham_Forest__c',
														'Wandsworth__c',
														'Westminster__c'};
														
    public WaitingListTableController(){

        housingId = ApexPages.currentPage().getParameters().get('Id');
        getHousing();
    	getTableHtml();
    }
    
    public WaitingListTableController(ApexPages.StandardController controller) {
   
        this.stdController = controller;
        housingId = controller.getId();
        getHousing();
        getTableHtml();
    }
	
	public Nomination_Tenancy__c getHousing(){
		
		if (string.isnotBlank(housingId)){
			
			this.housing = [select Age_criteria__c, Couples_accepted__c, Gender_criteria__c,
								Pets_accepted__c, 
								Waiting_list_category__c, Index__c,
								Bedspace__r.Borough__c, Bedspace__r.Floor_level__c, Bedspace__r.Unit_type__c,
								Bedspace__r.Name, referral__c, couples_referral__c 									
								from Nomination_Tenancy__c where Id = :housingId];
								
			waitingCategory = housing.Waiting_list_category__c;
			categoryIndex = housing.Index__c;
		}
		
		return housing;
	}
	
	public string getAllColumns(){
		
		return string.escapeSingleQuotes(json.serialize(colDefList));
	}
	
	public list<string> getWaitingCategories(){
		
		list<string> returnList = new list<string>();
		map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Nomination_Tenancy__c', 'Waiting_list_category__c', null);
		
		for (string key :optionsMap.keySet()){
			returnList.add('\b' + key + '\b');
		}
system.debug(returnList);
		return returnList;
		
	}

	public list<string> getCategoryIndexes(){
		
		list<string> returnList = new list<string>();
		map<string, string> optionsMap = PicklistUtilities.getPicklistValues('Nomination_Tenancy__c', 'Index__c', null);
		
		for (string key :optionsMap.keySet()){
			returnList.add('\b' + key + '\b');
		}
system.debug(returnList);
		return returnList;
		
	}	
    public string getTableHtml(){

				
		try {
	        colDefList = new list<colDef>();
	        map<string, string> boroughMap = null;
	        list<Waiting_List_Table_Def__c> defSequence = [select Id, Name, Label__c, Sequence__c,
	         												Column_API_Name__c, Filterable__c, Multiple_Picklist__c,
	         												Default_search_field__c, Default_search_Override__c,
	         												Column_Width__c
	         												from Waiting_List_Table_Def__c
	         												where Active__c = true
	        												order by Sequence__c asc];
	        map<string, decimal> defSequenceMap = new map<string, decimal>();
	        colDef colId = new colDef();

	        for (Waiting_List_Table_Def__c d :defSequence){
	            defSequenceMap.put(d.Name, d.Sequence__c);
	            colDef col = new colDef();
	            col.filterable = d.Filterable__c;
	            col.label = d.Label__c;
	            col.apiName = d.Column_API_Name__c;
	            col.defaultSearch = d.Default_Search_Override__c;
	            col.colWidth = integer.valueOf(d.Column_Width__c);
	            col.visible = true;
	            
	            if(string.isnotBlank(d.Default_search_field__c) && housing != null){
	            	string defaultValue = '';
	            	string defaultCol = d.Default_search_field__c;
	            	string[] fldArray = defaultCol.split('\\.');		
	                if (fldArray.size() < 2){               
	                    defaultValue = string.valueOf(housing.get(defaultCol));
	                                            
	                } else {
						try{	                	
	                    	defaultValue = string.valueOf(housing.getSObject(fldArray[0]).get(fldArray[1]));
						} catch (exception e){
	                   		system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
	                   		defaultValue = '';
	                   	}
	                }
	                if (defaultValue == d.Default_Search_Override__c){
	                	defaultValue = '';
	                }
					col.defaultSearch = defaultValue;
	            }
	            if (d.Multiple_Picklist__c){
	            	map<string, string> options = new map<string, string>();
	            	string apiFld = d.Column_API_Name__c;
	            	string[] fldArray = apiFld.split('\\.');		
	                if (fldArray.size() < 2){               
	                    options = PicklistUtilities.getPicklistValues('Referral__c', apiFld, null);
	                                            
	                } else {
	                	//string obj = Schema.SObjectType.Referral__c.fields.getMap().get(fldArray[1]).getDescribe().getReferenceTo()[0].getDescribe().getName();
						options = PicklistUtilities.getPicklistValues('Assessment__c', fldArray[1], null);
	                }
	            	col.optionsList = options.values();
	            }
	            if (d.Column_API_Name__c == 'Area_Selection__r.Borough__c'){
	            	if (boroughMap == null){
	            		boroughMap = getBoroughMap();
	            	}
	            	col.optionsList = boroughMap.values();
	            }
	            colDefList.add(col);	            
	        }
			// add checkbox
			colDef chkCol = new colDef();
			chkCol.filterable = false;
			chkCol.visible = true;
			colDefList.add(chkCol);
			
			// add hidden column(s)
			colDef hcol = new colDef();
            hcol.filterable = true;
            hcol.label = 'Waiting Category';
            hcol.apiName = 'Waiting_list_category__c';
            hcol.defaultSearch = '';
            hcol.visible = false;
			
			colDefList.add(hcol);
	        
			colDef hcol2 = new colDef();
            hcol2.filterable = true;
            hcol2.label = 'Category Index';
            hcol2.apiName = 'Index__c';
            hcol2.defaultSearch = '';
            hcol2.visible = false;
			
			colDefList.add(hcol2);
			
	        map<string, Waiting_List_Table_Def__c> tableDefs = Waiting_List_Table_Def__c.getAll();
	                	       	        
	        tableHtml  = '<thead>';

	        for (string key :defSequenceMap.keySet()) {
	            tableHtml  +=    '<th>'  + tableDefs.get(key).Label__c + '</th>';
	        }    
	        tableHtml  +=    '<th> Select</th>';

			// add hidden column(s)	  
			tableHtml  +=    '<th> Waiting Category</th>';
			tableHtml  +=    '<th> Category Index</th>';	
					
	        tableHtml  +=    '</tr>';
	        tableHtml  += '</thead>';
	        	                          
	        tableHtml  += '<tbody>';
			
	        for (referralItemWrapper item :this.referralItemWrapperList){
	            
	            Referral__c ref = item.ref;
	            string tr = '<tr>';
         
	            string value = '';
	            for (string key :defSequenceMap.keySet()) {          	
	                string col = tableDefs.get(key).Column_API_Name__c;                        
	                string[] fldArray = col.split('\\.');
 
	                value = '';
	                if (col == 'Area_Selection__r.Borough__c' && ref.getSObject('Area_Selection__r') != null){	                	
	                	if (boroughMap == null){
	            			boroughMap = getBoroughMap();
	            		}
	            		string boroughs = '';
	                	for (string borough :boroughNames) {
	                		value = string.valueOf(ref.getSObject('Area_Selection__r').get(borough));
	                		if(value == 'true'){
	                			boroughs += boroughMap.get(borough) + ';';
	                		}	                		            			
	                	}                	
	                	value = boroughs;
	                } else {
		                if (fldArray.size() < 2){               
		                    value = string.valueOf(ref.get(tableDefs.get(key).Column_API_Name__c));                        
		                } else {
							try{	                	
		                    	value = string.valueOf(ref.getSObject(fldArray[0]).get(fldArray[1]));
							} catch (exception e){
		                   		value = '';
		                   	}
		                }
	             	                	
	                }
	                
	                if (string.isBlank(value)){
	                	value = '-';
	                }
	                if (value == 'true'){
	                	value = 'Yes';
	                }
	                if (value == 'false'){
	                	value = 'No';
	                }                            
	                if (string.isBlank(tableDefs.get(key).link_URL__c)) {
	                    
	                    tr += '<td title="' + value + '"><span>\b' + value + '\b</span></td>';
	                } else {
	                    string tt = '';
	                    tt += 'Category : ' + item.ref.Waiting_list_Category__c;
	                    tt += '\r\nIndex : ' + item.ref.Index__c;
	                    if (item.weightedAcceptanceDate != null){
	                    	tt += '\r\nAccepted Date : ' + item.ref.Accepted_date__c.format('dd/MM/yyyy');
	                    	tt += '\r\nWeight Band Applied : ' + item.ref.Weighting__c;
	                    	tt += '\r\nWeighted Accepted Date : ' + item.weightedAcceptanceDate.format('dd/MM/yyyy');
	                    } else {
	                    	tt += '\r\n  Weighted Accepted Date : No date entered';
	                    }
	                    tr += '<td><a href=/' + ref.get(tableDefs.get(key).Link_URL__c) + ' target="_blank"  title="' + tt + '"  >'  + value  + '</a></td>';                

	                }
	            }
      			// add checkbox
	            tr += '<td><Input type="checkbox" id="' + ref.Id + '"  /> </td>';
	            
	            // add hidden column(s)
	            value = string.valueOf(ref.get('Waiting_list_category__c')) ;
	            if (string.isBlank(value)) value = '-';
	            tr += '<td>\b' + value + '\b</td>';

	            value = string.valueOf(ref.get('Index__c')) ;
	            if (string.isBlank(value)) value = '-';
	            tr += '<td>\b' + value + '\b</td>';
	            
	            tr += '</tr>';
	            tableHtml += tr;	            	
	        }

	        tableHtml  += '</tbody>'; 
		} catch (exception e){
			 system.debug(e.getMessage() + ' : ' + e.getStackTraceString());
		}
		
        return tableHtml;
    
    }
    
    public List<Referral__c> referralList {
        get {
			
			list<string> statusList = new list<string>();
			statusList.add('Accepted on waiting list');
			
            map<string, Waiting_List_Table_Def__c> tableDefs = Waiting_List_Table_Def__c.getAll();
            string soql = '';                        
            
            for (string key :tableDefs.keySet()) {
                soql += tableDefs.get(key).Column_API_Name__c  + ',';
                if (string.isnotBlank(tableDefs.get(key).Link_URL__c)){
                    soql += tableDefs.get(key).Link_URL__c  + ',';    
                }
            }
            
            soql += 'Accepted_Date__c,Weighting__c,Waiting_list_category__c,Index__c,';
            
            for (string borough :boroughNames){
            	soql += 'Area_Selection__r.' + borough + ',';
            }
            soql = soql.substring(0, soql.length() - 1);

			//housingCategories = new list<String>();
			//housingCategories = housing.Waiting_List_Category__c.split(';');
 
            soql = 'SELECT ' + soql + ' From Referral__c where (RecordTypeId =: referralRecTypeId';
            soql += ' Or RecordTypeId =: transferRecTypeId) and Status__c in :statusList';
			//soql += ' and Waiting_list_category__c in :housingCategories';
		
//soql =   'SELECT ' + soql + ' From Referral__c';            
            if (referralList == null) {
                referralList = Database.query(soql);                 
            }
            
            return referralList;
        }
        set;
    }
	
	private map<string, string> getBoroughMap(){
		
		map<string, string> returnMap = new map<string, string>();
		
		map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		map<string, string> boroughPickList = PicklistUtilities.getPicklistValues('Assessment__c', 'Borough__c', null);

		map <String, Schema.SObjectField> fieldMap = schemaMap.get('Assessment__c').getDescribe().fields.getMap();
		for(string borough :boroughNames){
			Schema.SObjectField fld = fieldMAP.get(borough);

			schema.describefieldresult dfield = fld.getDescribe();
			returnMap.put(dfield.getName(), dfield.getLabel());

		}		
		
		return returnMap;
	}
	
	public pageReference nominateReferrals(){

		try {
system.debug('Nominating ... ' + refIds);
			list<string> nomRefs = refIds.split(',');
			if (!nomRefs.isEmpty()){			
				housing.Referral__c = nomRefs[0];
				if(nomRefs.size() > 1){
					housing.Couples_Referral__c = nomRefs[1];
				}
				update housing;
			}

			
		} catch (exception e){
			string msg = ' An error has occured, please report to system administrator :';
			msg += e.getMessage() + ' : ' + e.getStackTraceString();
			system.debug(msg);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
			
		}
		return null;
	}


 	public List<referralItemWrapper> referralItemWrapperList {
        get {
			referralItemWrapperList = new list<referralItemWrapper>();
			//list<Referral__c> refList = this.referralList;
			decimal i = 0;
			
			map<string, Waiting_List_Weight_Bands__c> weightBands = Waiting_List_Weight_Bands__c.getAll();
			
			for (Referral__c ref :this.referralList){
				referralItemWrapper item = new referralItemWrapper();
				item.ref = ref;
				if (ref.Accepted_Date__c != null){
					if (string.isnotBlank(ref.Weighting__c)){
						if (weightBands.get(ref.Weighting__c) == null){
							i =0;
						} else {
							i = weightBands.get(ref.Weighting__c).Days__c;
						}
					} else {
						i = 0;
					}
					item.weightedAcceptanceDate = ref.Accepted_Date__c.addDays(integer.valueOf(i));
				}
				referralItemWrapperList.add(item);
				
			}
        
            referralItemWrapperList.sort();

            
            return referralItemWrapperList;
            
        }
        set;
    }
	
	public class colDef{
		
		public colDef(){
			
			this.visible = true;
			this.colWidth = 100;	
			
		}
		
		public boolean filterable {get; set;}
		public string apiName {get;set;}
		public string label {get; set;}
		public list<string> optionsList {get;set;}
		public string defaultSearch {get; set;}
		public string defaultOverride {get; set;}
		public boolean visible {get; set;}
		public integer colWidth {get; set;}
		
	}
	
	public class referralItemWrapper  implements Comparable {
		
		public Referral__c ref {get; set;}
		public datetime weightedAcceptanceDate {get; set;}

		
	    public Integer compareTo(Object compareTo) {

			DateTime compareWeightedAcceptanceDate = ((referralItemWrapper)compareTo).weightedAcceptanceDate != null ?
	                                          ((referralItemWrapper)compareTo).weightedAcceptanceDate : null;
	        
	        if (this.weightedAcceptanceDate == null && compareWeightedAcceptanceDate == null){
	        	return 0;
	        }
	        if(this.weightedAcceptanceDate == null && compareWeightedAcceptanceDate != null){
	        	return 1;
	        }	
	        if (compareWeightedAcceptanceDate == null && this.weightedAcceptanceDate != null){
	        	return -1;
	        } 
	        if (compareWeightedAcceptanceDate == this.weightedAcceptanceDate){
	        	return 0;
	    	} else {
	         //For descending (nulls last)
	            if (compareWeightedAcceptanceDate.getTime() > this.weightedAcceptanceDate.getTime() ){
	            	return -1;
	            } else {
	            	return 1;
	            }	
		    }
	    }    	
	}
		        
}