public class Chs_SectionOrderingUIController {
	@AuraEnabled(Cacheable = true)
    public static List<Call_Questionnaire__c> getCallQuestionnaireList(){
      		List<Call_Questionnaire__c> listCallQuestionnaire = [SELECT Id, Name, Short_Name__c, Type__c, IsActive__c 
                                                                 FROM Call_Questionnaire__c 
                                                                 where IsActive__c = true];
         	return listCallQuestionnaire;
        }
    
    
    @AuraEnabled(Cacheable = true)
    public static List<Questionnaire_Section__c> getQuestionnaireSectionsList(String selectedCallQuestionnaireId){
        system.debug('getQuestionnaireSectionsList selectedCallQuestionnaireId'+selectedCallQuestionnaireId);
      		List<Questionnaire_Section__c> listQuestionnaireSections = [SELECT Call_Questionnaire__c,Sr_No__c, Sort_Order__c, Title__c, Name, OwnerId, Id 
                                                                 FROM Questionnaire_Section__c 
                                                                 where Call_Questionnaire__c = :selectedCallQuestionnaireId order BY Sr_No__c];
        for(Questionnaire_Section__c  qs : listQuestionnaireSections){
            system.debug('qs'+qs);
        }
         	return listQuestionnaireSections;
        }
    
    
     @AuraEnabled
    public static List<Questionnaire_Section__c> reOrderItem(String selectedCallQuestionnaireId,Integer srcIndx, Integer destIndx){
        system.debug('srcIndx'+srcIndx);
        system.debug('destIndx'+destIndx);
        system.debug('selectedCallQuestionnaireId'+selectedCallQuestionnaireId);
        String CallQuestionnair;
        List<Questionnaire_Section__c> lstPayableLines = new List<Questionnaire_Section__c>();
        Integer count = 1;
        Questionnaire_Section__c srcAPL;
        Questionnaire_Section__c destAPL;
        for(Questionnaire_Section__c apl : [SELECT Id, Name, Call_Questionnaire__c, Sort_Order__c, Title__c, Sr_No__c 
                                            FROM Questionnaire_Section__c  
                                            where Call_Questionnaire__c = :selectedCallQuestionnaireId order BY Sr_No__c])
        {
            if(count == srcIndx) {
                srcAPL = apl;
                srcAPL.Sr_No__c = destIndx;
            } else {
                lstPayableLines.add(apl);
            }
            count++;
        }
        update srcAPL;
        count = 1;
        for(Questionnaire_Section__c apl : lstPayableLines) {
            if(count == destIndx) count++;
            apl.Sr_No__c = count++;
        }
        update lstPayableLines;
        return getQuestionnaireSectionsList(selectedCallQuestionnaireId);
    }
    
    
    @AuraEnabled(Cacheable = true)
    public static List<Question__c> getQuestionsList(String selectedQuestionnaireSectionId){
        Set<Id>setQuestinId = new Set<Id>();
        List<QuestionLink__c> listQuestionsLink = [SELECT Order_By__c, Questionnaire_Section__c, Question__c, Call_Questionnaire__c, Name, Id 
                                                   FROM QuestionLink__c where Questionnaire_Section__c = :selectedQuestionnaireSectionId];
        for(QuestionLink__c  ql : listQuestionsLink){
            setQuestinId.add(ql.Question__c);
        }
        
        List<Question__c> listQuestions = [SELECT Id, IsDeleted, Name, Order_By__c, Questionnaire_Section__c, Picklist_Options_if_applicable__c, Response_Type__c, Available_for__c, Question__c 
                                           FROM Question__c where Id IN : setQuestinId];
        return listQuestions;
        
    }
    
    
     @AuraEnabled
    public static List<Question__c> reOrderQuestionItem(String selectedQuestionnaireSectionId,Integer srcIndx, Integer destIndx){
        
        system.debug('srcIndx'+srcIndx);
        system.debug('destIndx'+destIndx);
        system.debug('selectedCallQuestionnaireId'+selectedQuestionnaireSectionId);
        String CallQuestionnair;
        List<Question__c> listQuestions = new List<Question__c>();
        Integer count = 1;
        Question__c srcQUS;
        Question__c destQUS;
        
        
        Set<Id>setQuestinId = new Set<Id>();
        List<QuestionLink__c> listQuestionsLink = [SELECT Order_By__c, Questionnaire_Section__c, Question__c, Call_Questionnaire__c, Name, Id 
                                                   FROM QuestionLink__c where Questionnaire_Section__c = :selectedQuestionnaireSectionId];
        system.debug('listQuestionsLink'+listQuestionsLink.size());
        for(QuestionLink__c  ql : listQuestionsLink){
            setQuestinId.add(ql.Question__c);
        }
        
        for(Question__c ques : [SELECT Id, IsDeleted, Name, Order_By__c, Questionnaire_Section__c, Picklist_Options_if_applicable__c, Response_Type__c, Available_for__c, Question__c 
                                           FROM Question__c where Id IN : setQuestinId])
        {
            system.debug('ques'+ques);
            if(count == srcIndx) {
                srcQUS = ques;
                srcQUS.Sr_No__c = destIndx;
            } else {
                listQuestions.add(ques);
            }
            count++;
        }
        update srcQUS;
        count = 1;
        for(Question__c ques : listQuestions) {
            if(count == destIndx) count++;
            ques.Sr_No__c = count++;
        }
        update listQuestions;
        return getQuestionsList(selectedQuestionnaireSectionId);
    }
    
    
}