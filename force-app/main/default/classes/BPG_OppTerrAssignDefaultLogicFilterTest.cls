/******************************************************************************************
 *  Date:           26JUL20
 *  Author:         Pooja Deokar
 *  Description:    Test class for BPG_OppTerrAssignDefaultLogicFilter and BPG Constant
 * ***************************************************************************************/
@isTest
private with sharing class BPG_OppTerrAssignDefaultLogicFilterTest {
 	//Test setup class
    @testSetup
    static void setup() {   
            List<Account> lstSoldToAccounts = new PCRM_Utility().createAccount(1, 'Customer', 'Sold-To Party');
            insert lstSoldToAccounts;
            List<Opportunity> lstOpportunity = new PCRM_Utility().createOpportunity(lstSoldToAccounts,1, 'PCRM_PetChems_Acetyls');
            insert lstOpportunity;
    }
    
    //Test method for Territory assignment
    @isTest
    static void testTerrirotyAssignment()
    { 
       Id opportunityId = [Select Id From Opportunity].Id;
   	   BPG_OppTerrAssignDefaultLogicFilter filter = new BPG_OppTerrAssignDefaultLogicFilter();

        Test.startTest();
    
        Map<Id, Id> resultMap = filter.getOpportunityTerritory2Assignments(new List<Id> {opportunityId});
        BPG_OppTerrAssignDefaultLogicFilter.Territory2Priority tp = new BPG_OppTerrAssignDefaultLogicFilter.Territory2Priority(opportunityId, 1, false);
    
        Test.stopTest();
    
        System.assertEquals(1, resultMap.size());
        System.assertEquals(tp.territory2Id, opportunityId);
        System.assertEquals(1, tp.priority);
        System.assertEquals(false, tp.moreTerritoriesAtPriority);
    }
}