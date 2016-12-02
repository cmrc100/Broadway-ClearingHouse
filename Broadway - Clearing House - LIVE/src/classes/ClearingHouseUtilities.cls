global without sharing class ClearingHouseUtilities {

	
	webservice static void closeTask(string taskId){
		
		Task t = [select Status from Task where Id = :taskId];
		
		t.status= 'Completed';
		
		update t;
		
	}
	

}