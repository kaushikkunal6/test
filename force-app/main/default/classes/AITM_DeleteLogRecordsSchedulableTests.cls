@IsTest 
private class AITM_DeleteLogRecordsSchedulableTests {

	@isTest 
	static void isLogsBeenClearedWhenTheyOlderThan30Days() {

		DeleteRecordsTestSetup testSetup = new DeleteRecordsTestSetup().generateData();
		Integer logsLess30daysCount = 9;

		Integer i = 0;
		for(AITM_Log__c log : testSetup.logs){
			if(i < logsLess30daysCount ){
				Test.setCreatedDate(log.Id, Date.today().addDays(-31));
			}
			i++;
		}

		Test.startTest();
			System.schedule('Test ClearLogs', '0 0 3 * * ?', new AITM_DeleteLogRecordsSchedulable()); 
		Test.stopTest();

		System.assertEquals(testSetup.logs.size() - logsLess30daysCount, [SELECT COUNT() FROM AITM_Log__c LIMIT 100]);
	}

	@isTest 
	static void isLogsNotBeenClearedWhenTheyLessThan30Days() {

		DeleteRecordsTestSetup testSetup = new DeleteRecordsTestSetup().generateData();
		Integer logsLess30daysCount = 9;

		Integer i = 0;
		for(AITM_Log__c log : testSetup.logs){
			if(i < logsLess30daysCount ){
				Test.setCreatedDate(log.Id, Date.today().addDays(-30));
			}
			i++;
		}

		Test.startTest();
			System.schedule('Test ClearLogs', '0 0 3 * * ?', new AITM_DeleteLogRecordsSchedulable()); 
		Test.stopTest();

		System.assertEquals(testSetup.logs.size(), [SELECT COUNT() FROM AITM_Log__c LIMIt 100]);
	}

	private class DeleteRecordsTestSetup {
		public List<AITM_Log__c> logs;

		public DeleteRecordsTestSetup generateData(){
			logs = generateLogs(20);
			insert logs;

			return this;
		}

		private List<AITM_Log__c> generateLogs(Integer counter){
			List<AITM_Log__c> logs = new List<AITM_Log__c>();
			for(Integer i = 0; i < counter; i++){
				logs.add(
					new AITM_Log__c(
						AITM_Description__c = 'Some error ' + counter
					)
				);
			}
		    return logs;
		}

	}

}