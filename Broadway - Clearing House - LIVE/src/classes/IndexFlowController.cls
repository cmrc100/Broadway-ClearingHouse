public with sharing class IndexFlowController {

	public Flow.Interview.Index theFlow { get; set; }
	
	public IndexFlowController(ApexPages.StandardController controller){
		
	}
	
	public String getReferralID() {
		if (theFlow==null) return '';
			else return theFlow.ReferralID;
	}

	public PageReference getReferralPage(){
		PageReference p = new PageReference('/' + getReferralID());
		p.setRedirect(true);
		return p;
	}

   
}