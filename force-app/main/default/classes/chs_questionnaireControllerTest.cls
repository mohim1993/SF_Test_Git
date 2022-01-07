@isTest
public class chs_questionnaireControllerTest {
    static testMethod void test1() {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        //Contact conObj = new Contact();
        Account conObj=new Account();
        conObj.LastName = 'Test';
        conObj.Recordtypeid=devRecordTypeId;
        insert conObj;
        
        Call_Questionnaire__c callQuestionnaire = new Call_Questionnaire__c();
        callQuestionnaire.Type__c = 'Glaucoma';
        insert callQuestionnaire;
            
            
        Patient_Questionnaire__c patientQuestionnaire = new Patient_Questionnaire__c();
        patientQuestionnaire.Call_Questionnaire__c = callQuestionnaire.Id;
        patientQuestionnaire.Is_Submitted__c		=	true;
        patientQuestionnaire.Patient__c = conObj.PersonContactid;
        patientQuestionnaire.Date_Completed__c = Date.today();
        insert patientQuestionnaire;
        
        Question__c questionDateTime  = new Question__c();
        questionDateTime.Response_Type__c = 'Date/Time';
        questionDateTime.Available_for__c = 'Glaucoma';
        questionDateTime.Order_By__c = 10;
        insert questionDateTime;
        
        Question__c questionPickList  = new Question__c();
        questionPickList.Response_Type__c = 'Picklist';
        questionPickList.Available_for__c = 'Glaucoma';
        questionPickList.Order_By__c = 10;
        insert questionPickList;
        
        Question__c questionFreeText  = new Question__c();
        questionFreeText.Response_Type__c = 'Free text';
        questionFreeText.Available_for__c = 'Glaucoma';
        questionFreeText.Order_By__c = 10;
        insert questionFreeText;
        
        
        Question__c questionMultiSelect  = new Question__c();
        questionMultiSelect.Response_Type__c = 'MultiSelect Picklist';
        questionMultiSelect.Available_for__c = 'Glaucoma';
        questionMultiSelect.Order_By__c = 10;
        insert questionMultiSelect;
        
        Question__c questionDate  = new Question__c();
        questionDate.Response_Type__c = 'Date';
        questionDate.Available_for__c = 'Glaucoma';
        questionDate.Order_By__c = 10;
        insert questionDate;
        
        
        Question__c questionBoolean  = new Question__c();
        questionBoolean.Response_Type__c = 'Boolean';
        questionBoolean.Available_for__c = 'Glaucoma';
        questionBoolean.Order_By__c = 10;
        insert questionBoolean;
        
        QuestionLink__c ql = new QuestionLink__c();
        ql.Question__c = questionDate.Id;
        ql.Call_Questionnaire__c = callQuestionnaire.Id;
        insert ql;
            
        
        
        
        //MultiSelect Picklist
        String createResponse =  '[{'+'"questionId":"'+questionDateTime.Id+'","response":"2021-09-08T13:22:00.000Z","responseType":"Date/Time","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'},{'+'"questionId":"'+questionFreeText.Id+'","response":"This is freetext","responseType":"Free text","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'},{'+'"questionId":"'+questionPickList.Id+'","response":"Pickup at store","responseType":"Picklist","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'},{'+'"questionId":"'+questionMultiSelect.Id+'","response":"Medication refills","responseType":"MultiSelect Picklist","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'},{'+'"questionId":"'+questionBoolean.Id+'","response":"true","responseType":"Boolean","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'},{'+'"questionId":"'+questionDate.Id+'","response":"2021-08-09","responseType":"Date","patientId":"'+conObj.Id+'","callQuestionnaireId":"'+callQuestionnaire.Id+'","recordId":"'+patientQuestionnaire.Id+'","isSubmitted":false'+'}]';
            
        chs_questionnaireController.getRecordIdObjectName(conObj.Id);
        chs_questionnaireController.getRecordIdObjectName(patientQuestionnaire.Id);
        chs_questionnaireController.getCallQuestionnaireList(conObj.Id);
        chs_questionnaireController.getQuestionnaireSectionList(patientQuestionnaire.Id,callQuestionnaire.Id);
        system.debug('conObj--- '+conObj.Id);
        chs_questionnaireController.getQuestionnaireSectionList(conObj.Id,callQuestionnaire.Id);
        chs_questionnaireController.getResponse(patientQuestionnaire.Id);
        //chs_questionnaireController.getResponse(conObj.PersonContactid);
		chs_questionnaireController.createResponse(createResponse);        
    }
}