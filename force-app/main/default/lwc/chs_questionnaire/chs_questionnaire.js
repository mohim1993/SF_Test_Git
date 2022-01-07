import { LightningElement,track,wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCallQuestionnaireList from '@salesforce/apex/chs_questionnaireController.getCallQuestionnaireList';
import getQuestionnaireSectionList from '@salesforce/apex/chs_questionnaireController.getQuestionnaireSectionList';
import getRecordIdObjectName from '@salesforce/apex/chs_questionnaireController.getRecordIdObjectName';
//import getQuestions from '@salesforce/apex/chs_questionnaireController.getQuestions';
import getResponse from '@salesforce/apex/chs_questionnaireController.getResponse';
import createResponse from '@salesforce/apex/chs_questionnaireController.createResponse';
export default class Chs_questionnaire extends LightningElement {
    @api recordId;
    @track questions;
    //@track checked = true;
    @track picklistValue;
    error;
    @track ResponseType = [];
    @track QuestionsRecords = [];
    options =[];
    multiSelectPicklistOptions = [];
    @track selectedOptions = [];
    @track patientQuestionnaireId;
    @track callQuestionnaireId;
    @track isSubmittedButton = false;
    @track patientNameToHeader;
    @track questionnaireNameToHeader;
    @track QuestionnaireType;
    @track dateToHeader;
    existingResponse = [];
    @track patientId;
    disabled = false;
    @track createdPatientQuestionnaireId;
    @track itIsFromContact;
    @track multiPickListSelectedOptionsValues = [];
    QuestionnaireSection = [];
    wrapperQuestionSet = {};
    @track questionSections = [];

    @track radiobuttonsoptions = [];
    @track isModalCallQuestionnaireOpen = false;
    @track isModalQuestionsOpen = false;
    callQuestionnaireSelectedId = 'a1z7d0000023Q6sAAE';

    closeCallQuestionnaireModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isModalCallQuestionnaireOpen = false;
    }

    @wire(getRecordIdObjectName,{recordIdToGetSobjectName: '$recordId'})
    wireGetRecordIdSobjectName({error,data}){
        console.log('data',data);
        if(data == 'Account'){
            getCallQuestionnaireList({accountRecordId : this.recordId})
            .then(result => {
                console.log('result',result);
                let optionsValues = [];
            console.log('result',result);
            for(var i=0;i<result.length;i++){
                //console.log('result',result[i].Name);
                optionsValues.push({ 
                    label: result[i].name,
                    value: result[i].Id 
                });
                
            }
            this.radiobuttonsoptions = optionsValues;
            this.isModalCallQuestionnaireOpen = true;
            this.isModalQuestionsOpen = false;
            console.log('========= after ========');
            })
            .catch(error => {
                console.log('error found');
            });
        }
            else{
            console.log('123456789');
            console.log('this.recordId',this.recordId);
            
            if(this.recordId !=undefined){
                getQuestionnaireSectionList({patientQuestionnaireOrContactId: this.recordId,callQuestionnaireSelectedId:this.callQuestionnaireSelectedId})
                .then(data=>{
                this.wrapperQuestionSet = JSON.parse(JSON.stringify(data));
                this.questionSections = this.wrapperQuestionSet.listSections;
                if( this.questionSections == undefined){
                    console.log('data.message'+data.message);
                    if(data.message =='No questionnaire found'){
                        const evt = new ShowToastEvent({
                            title: 'Failed To Get Records',
                            message: data.message,
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }else{
                        const evt = new ShowToastEvent({
                            title: 'title',
                            message: data.message,
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                    }
                    return;  
                }
                for(var j =0; j<this.questionSections.length;j++){
                    for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                        this.questionSections[j].QuestionsRecords = this.questionSections[j].listQuestions;
                        this.callQuestionnaireId = data.callQuestionnaireId;
                        this.patientNameToHeader = data.PatientName;
                        this.questionnaireNameToHeader = data.QuestionnaireName;
                        this.dateToHeader = data.patientQuestionnaireDate;
                        this.patientId = data.patientId;
                        this.itIsFromContact = data.itIsFromContact;
                        this.QuestionnaireType        = data.QuestionnaireType;
                        console.log('result.itIsFromContact---- '+data.itIsFromContact);
                        for(var i =0; i<this.questionSections[j].QuestionsRecords.length;i++ ){
                            var tempInputFieldText              = false;
                            var tempDateField                   = false;
                            var tempBooleanField                = false;
                            var tempPicklistField               = false;
                            var tempDateTimeField               = false;
                            var tempMultiSelectPicklistField    = false;
    
                            if(this.questionSections[j].QuestionsRecords[i].Response_Type__c        == 'Free text'){
                                tempInputFieldText = true;
                            }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'Date'){
                                tempDateField = true;
                            }
                            else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Boolean'){
                                tempBooleanField = true;
                            }
                            else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Date/Time'){
                                tempDateTimeField = true;
                            }
                            else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Picklist'){
                                tempPicklistField = true;
                                this.questionSections[j].QuestionsRecords[i].options=[];
                                this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                    this.questionSections[j].QuestionsRecords[i].options.push({ label: storedFields.trim(), value: storedFields.trim() });
                                });
                            }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'MultiSelect Picklist'){
                                tempMultiSelectPicklistField = true;
                                this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                    storedFields = storedFields.trim();
                                    this.multiSelectPicklistOptions.push({ label: storedFields, value: storedFields });
                                });
                            }                 
                            this.questionSections[j].QuestionsRecords[i].ResponseType = {
                                inputType : tempInputFieldText,
                                inputDate : tempDateField,
                                inputBoolean : tempBooleanField,
                                inputPickList : tempPicklistField,
                                inputDateTime : tempDateTimeField,
                                inputMultiSelectPickList : tempMultiSelectPicklistField,
                                userResponse : '',
                                checked : false
                            };
                           
                        }
                    }
                }
    
                this.isModalCallQuestionnaireOpen = false;
                this.isModalQuestionsOpen = true;
    
                if(data.itIsFromContact == false){
                    getResponse({patientQuestionnaireOrContactId : this.recordId})
                    .then(result => {
                        this.existingResponse = result;
                        console.log('this.existingResponse ----',this.existingResponse);
                        for(var j =0; j<this.questionSections.length;j++){
                            for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                                    for(var k =0; k<this.existingResponse.length;k++ )
                                    { 
                                        if(this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c == true){
                                            this.questionSections[j].listQuestions[i].disabled = true;
                                        }
                                        console.log('this.Is_Submitted__c',this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c);
                                        if(this.questionSections[j].listQuestions[i].Id == this.existingResponse[k].Question__c){
                                            if(this.existingResponse[k].Response_FreeText__c  != undefined){
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_FreeText__c;
                                            }
                                            if(this.existingResponse[k].Response_Picklist__c  != undefined){
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Picklist__c.trim();
                                            }
                                            if(this.existingResponse[k].Response_Date__c != undefined){
                                                console.log('this.existingResponse[j].Response_Date__c'+this.existingResponse[j].Response_Date__c);
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Date__c; 
                                            }
                                            if(this.existingResponse[k].Response_DateTime__c  != undefined){
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_DateTime__c; 
                                            }
                                            if(this.existingResponse[k].Response_MultiSelect__c != undefined){
                                                var multiOptions = this.existingResponse[k].Response_MultiSelect__c;
                                                var splittedValues =   multiOptions.split(',');
                                                splittedValues = splittedValues.map(function (el) {
                                                return el.trim();
                                                });
                                                this.multiPickListSelectedOptionsValues         = splittedValues;
                                                this.questionSections[j].listQuestions[i].multipickListValues    =  this.multiPickListSelectedOptionsValues;
                                            }
                                            if(this.existingResponse[k].Response_Boolean__c != undefined ){
                                                    console.log('this.existingResponse[k].Response_Boolean__c----',this.existingResponse[k].Response_Boolean__c);
                                                    this.questionSections[j].listQuestions[i].checked = this.existingResponse[k].Response_Boolean__c; 
                                                    console.log('this.questionSections[j].listQuestions[i].checked',this.questionSections[j].listQuestions[i].checked);
                                            }
                                        }
                                }
                        }
                    }
                        console.log(this.QuestionsRecords);
                    })
                }
                })
                .catch(error=>{
                    console.log('error',error);
                })
            }
           
        }
    }

   
  
    handleRBChnages(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
        this.callQuestionnaireSelectedId = event.detail.value;
            getQuestionnaireSectionList({patientQuestionnaireOrContactId: this.recordId,callQuestionnaireSelectedId:event.detail.value})
            .then(data=>{
            this.wrapperQuestionSet = JSON.parse(JSON.stringify(data));
            this.questionSections = this.wrapperQuestionSet.listSections;
            if( this.questionSections == undefined){
                const evt = new ShowToastEvent({
                    title: 'title',
                    message: data.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                return;  
            }
            for(var j =0; j<this.questionSections.length;j++){
                for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                    this.questionSections[j].QuestionsRecords = this.questionSections[j].listQuestions;
                    this.callQuestionnaireId = data.callQuestionnaireId;
                    this.patientNameToHeader = data.PatientName;
                    this.questionnaireNameToHeader = data.QuestionnaireName;
                    this.dateToHeader = data.patientQuestionnaireDate;
                    this.patientId = data.patientId;
                    this.itIsFromContact = data.itIsFromContact;
                    this.QuestionnaireType        = data.QuestionnaireType;
                    console.log('result.itIsFromContact---- '+data.itIsFromContact);
                    for(var i =0; i<this.questionSections[j].QuestionsRecords.length;i++ ){
                        var tempInputFieldText              = false;
                        var tempDateField                   = false;
                        var tempBooleanField                = false;
                        var tempPicklistField               = false;
                        var tempDateTimeField               = false;
                        var tempMultiSelectPicklistField    = false;

                        if(this.questionSections[j].QuestionsRecords[i].Response_Type__c        == 'Free text'){
                            tempInputFieldText = true;
                        }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'Date'){
                            tempDateField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Boolean'){
                            tempBooleanField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Date/Time'){
                            tempDateTimeField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Picklist'){
                            tempPicklistField = true;
                            this.questionSections[j].QuestionsRecords[i].options=[];
                            this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                this.questionSections[j].QuestionsRecords[i].options.push({ label: storedFields.trim(), value: storedFields.trim() });
                            });
                        }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'MultiSelect Picklist'){
                            tempMultiSelectPicklistField = true;
                            this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                storedFields = storedFields.trim();
                                this.multiSelectPicklistOptions.push({ label: storedFields, value: storedFields });
                            });
                        }                 
                        this.questionSections[j].QuestionsRecords[i].ResponseType = {
                            inputType : tempInputFieldText,
                            inputDate : tempDateField,
                            inputBoolean : tempBooleanField,
                            inputPickList : tempPicklistField,
                            inputDateTime : tempDateTimeField,
                            inputMultiSelectPickList : tempMultiSelectPicklistField,
                            userResponse : '',
                            checked : ''
                        };
                       
                    }
                }
            }

            this.isModalCallQuestionnaireOpen = false;
            this.isModalQuestionsOpen = true;

            if(data.itIsFromContact == false){
                getResponse({patientQuestionnaireOrContactId : this.recordId})
               /* .then(result => {
                    this.existingResponse = result;
                    console.log('this.existingResponse ----',this.existingResponse);
                    for(var j =0; j<this.questionSections.length;j++){
                        for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                                for(var k =0; k<this.existingResponse.length;k++ )
                                { 
                                    if(this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c == true){
                                        this.questionSections[j].listQuestions[i].disabled = true;
                                    }
                                    console.log('this.Is_Submitted__c',this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c);
                                    if(this.questionSections[j].listQuestions[i].Id == this.existingResponse[k].Question__c){
                                        if(this.existingResponse[k].Response_FreeText__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_FreeText__c;
                                        }
                                        if(this.existingResponse[k].Response_Picklist__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Picklist__c.trim();
                                        }
                                        if(this.existingResponse[k].Response_Date__c != undefined){
                                            console.log('this.existingResponse[j].Response_Date__c'+this.existingResponse[j].Response_Date__c);
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Date__c; 
                                        }
                                        if(this.existingResponse[k].Response_DateTime__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_DateTime__c; 
                                        }
                                        if(this.existingResponse[k].Response_MultiSelect__c != undefined){
                                            var multiOptions = this.existingResponse[k].Response_MultiSelect__c;
                                            var splittedValues =   multiOptions.split(',');
                                            splittedValues = splittedValues.map(function (el) {
                                            return el.trim();
                                            });
                                            this.multiPickListSelectedOptionsValues         = splittedValues;
                                            this.questionSections[j].listQuestions[i].multipickListValues    =  this.multiPickListSelectedOptionsValues;
                                        }
                                        if(this.existingResponse[k].Response_Boolean__c != undefined 
                                            && result[k].Response_Boolean__c != false ){
                                                console.log('this.existingResponse[k].Response_Boolean__c',this.existingResponse[k].Response_Boolean__c);
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Boolean__c; 
                                        }
                                    }
                            }
                    }
                }
                    console.log(this.QuestionsRecords);
            })*/
        }
    })
    .catch(error=>{

    })
       
    }



 
    

    /*@wire(getQuestionnaireSectionList, {patientQuestionnaireOrContactId: '$recordId'}) 
    WireContactRecords({error, data}){
        console.log('data----wire');
        console.log('data',data);
        if(error,data){
            console.log('data',data);
            console.log('wire method');
            //alert(this.recordId);
            this.wrapperQuestionSet = JSON.parse(JSON.stringify(data));
            console.log('result',data.message);
            this.questionSections = this.wrapperQuestionSet.listSections;
            console.log('this.questionSections',this.questionSections);
            console.log('this.questionSections',this.message);
            
            if( this.questionSections == undefined){
                const evt = new ShowToastEvent({
                    title: 'title',
                    message: data.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                return;  
            }
            for(var j =0; j<this.questionSections.length;j++){
                for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                    this.questionSections[j].QuestionsRecords = this.questionSections[j].listQuestions;
                    this.callQuestionnaireId = data.callQuestionnaireId;
                    this.patientNameToHeader = data.PatientName;
                    this.questionnaireNameToHeader = data.QuestionnaireName;
                    this.dateToHeader = data.patientQuestionnaireDate;
                    this.patientId = data.patientId;
                    this.itIsFromContact = data.itIsFromContact;
                    this.QuestionnaireType        = data.QuestionnaireType;
                    console.log('result.itIsFromContact---- '+data.itIsFromContact);
                    for(var i =0; i<this.questionSections[j].QuestionsRecords.length;i++ ){
                        var tempInputFieldText              = false;
                        var tempDateField                   = false;
                        var tempBooleanField                = false;
                        var tempPicklistField               = false;
                        var tempDateTimeField               = false;
                        var tempMultiSelectPicklistField    = false;

                        if(this.questionSections[j].QuestionsRecords[i].Response_Type__c        == 'Free text'){
                            tempInputFieldText = true;
                        }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'Date'){
                            tempDateField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Boolean'){
                            tempBooleanField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Date/Time'){
                            tempDateTimeField = true;
                        }
                        else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c   == 'Picklist'){
                            tempPicklistField = true;
                            this.questionSections[j].QuestionsRecords[i].options=[];
                            this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                this.questionSections[j].QuestionsRecords[i].options.push({ label: storedFields.trim(), value: storedFields.trim() });
                            });
                        }else if(this.questionSections[j].QuestionsRecords[i].Response_Type__c  == 'MultiSelect Picklist'){
                            tempMultiSelectPicklistField = true;
                            this.questionSections[j].QuestionsRecords[i].Picklist_Options_if_applicable__c.split("\n").forEach((storedFields) => {
                                storedFields = storedFields.trim();
                                this.multiSelectPicklistOptions.push({ label: storedFields, value: storedFields });
                            });
                        }                 
                        this.questionSections[j].QuestionsRecords[i].ResponseType = {
                            inputType : tempInputFieldText,
                            inputDate : tempDateField,
                            inputBoolean : tempBooleanField,
                            inputPickList : tempPicklistField,
                            inputDateTime : tempDateTimeField,
                            inputMultiSelectPickList : tempMultiSelectPicklistField,
                            userResponse : ''
                        };
                       
                    }
                }
            }

            if(data.itIsFromContact == false){
                getResponse({patientQuestionnaireOrContactId : this.recordId})
                .then(result => {
                    this.existingResponse = result;
                    console.log('this.existingResponse ----',this.existingResponse);
                    for(var j =0; j<this.questionSections.length;j++){
                        for(var i =0;i<this.questionSections[j].listQuestions.length;i++){
                                for(var k =0; k<this.existingResponse.length;k++ )
                                { 
                                    if(this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c == true){
                                        this.questionSections[j].listQuestions[i].disabled = true;
                                    }
                                    console.log('this.Is_Submitted__c',this.existingResponse[k].Patient_Questionnaire__r.Is_Submitted__c);
                                    if(this.questionSections[j].listQuestions[i].Id == this.existingResponse[k].Question__c){
                                        if(this.existingResponse[k].Response_FreeText__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_FreeText__c;
                                        }
                                        if(this.existingResponse[k].Response_Picklist__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Picklist__c.trim();
                                        }
                                        if(this.existingResponse[k].Response_Date__c != undefined){
                                            console.log('this.existingResponse[j].Response_Date__c'+this.existingResponse[j].Response_Date__c);
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Date__c; 
                                        }
                                        if(this.existingResponse[k].Response_DateTime__c  != undefined){
                                            this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_DateTime__c; 
                                        }
                                        if(this.existingResponse[k].Response_MultiSelect__c != undefined){
                                            var multiOptions = this.existingResponse[k].Response_MultiSelect__c;
                                            var splittedValues =   multiOptions.split(',');
                                            splittedValues = splittedValues.map(function (el) {
                                            return el.trim();
                                            });
                                            this.multiPickListSelectedOptionsValues         = splittedValues;
                                            this.questionSections[j].listQuestions[i].multipickListValues    =  this.multiPickListSelectedOptionsValues;
                                        }
                                        if(this.existingResponse[k].Response_Boolean__c != undefined 
                                            && result[k].Response_Boolean__c != false ){
                                                console.log('this.existingResponse[k].Response_Boolean__c',this.existingResponse[k].Response_Boolean__c);
                                                this.questionSections[j].listQuestions[i].answer = this.existingResponse[k].Response_Boolean__c; 
                                        }
                                    }
                            }
                    }
                }
                    console.log(this.QuestionsRecords);
                })
            }
    }else{
            this.error = error;
            this.questions = undefined;
        }
    }*/

   

    handleMultiSelectPickListChange(event) {
        const selectedOptionsList = event.detail.value;
        const qidx = event.currentTarget.dataset.qidx;
        const secindx = event.currentTarget.dataset.secindx;
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.value;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse'+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
        console.log(`Options selected: ${selectedOptionsList}`);
    }

    handlePickListChange(event){
        console.log('handlePickListChange---'+event.target.value);
        const qidx = event.currentTarget.dataset.qidx;
        const secindx = event.currentTarget.dataset.secindx;
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.value;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse'+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
    }

    handleDateChange(event){
        console.log('handleDateChange'+event.target.value);
        const qidx = event.currentTarget.dataset.qidx;
        const secindx = event.currentTarget.dataset.secindx;
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.value;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse'+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
    }

    handleDateTimeChange(event){
        console.log('handleDateTimeChange'+event.target.value);
        const qidx = event.currentTarget.dataset.qidx;
        console.log('qidx',qidx);
        const secindx = event.currentTarget.dataset.secindx;
        console.log('secindx',secindx);
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.value;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse'+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
    }

    handleBooleanChange(event){ 
        const qidx = event.currentTarget.dataset.qidx;
        console.log('qidx',qidx); 
        const secindx = event.currentTarget.dataset.secindx;
        console.log('secindx',secindx);
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.checked;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse---- '+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.checked;
        //this.checked = event.target.checked;
        this.questionSections[secindx].QuestionsRecords[qidx].checked = event.target.checked;
    }

    handleBooleanChangeReset(){
        this.checked = false;
    }

    handleTextChange(event){
        console.log('------handleTextChange-----'+event.target.value);
        const qidx = event.currentTarget.dataset.qidx;
        const secindx = event.currentTarget.dataset.secindx;
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse = event.target.value;
        console.log('this.questionSections[secindx].QuestionsRecords[qidx].userResponse'+
        this.questionSections[secindx].QuestionsRecords[qidx].userResponse);
    }


    handleSave(event){
        console.log('Clicked Button Name Is: '+event.currentTarget.name);
        if(event.currentTarget.name=='submit'){
            this.isSubmittedButton  = true;
        }else{
            this.isSubmittedButton  = false;
        }
        console.log('this.isSubmittedButton'+this.isSubmittedButton);
        console.log('questionSections'+this.questionSections.length);

        var responseList  = [];
        for(var i =0; i<this.questionSections.length;i++){
            console.log('1st loop');
            for(let j= 0; j<this.questionSections[i].QuestionsRecords.length;j++){
                console.log('2nd loop');
                console.log('QuestionsRecords[j].Response_Type__c',this.questionSections[i].QuestionsRecords[j].Response_Type__c);
                console.log('QuestionsRecords[j].userResponse',this.questionSections[i].QuestionsRecords[j].userResponse);
                responseList.push({
                    questionId :    this.questionSections[i].QuestionsRecords[j].Id,
                    response   :    this.questionSections[i].QuestionsRecords[j].userResponse,
                    responseType :  this.questionSections[i].QuestionsRecords[j].Response_Type__c,
                    patientId  : this.patientId,
                    callQuestionnaireId : this.callQuestionnaireId,
                    recordId : this.recordId,
                    isSubmitted : this.isSubmittedButton,
                    createdPatientQuestionnaireId : this.createdPatientQuestionnaireId
    
                });
            }
        }
        
        console.log('responseList---',responseList);
        createResponse({responseList: JSON.stringify(responseList)})
        .then(result=> {
            console.log('result'+result.status);
            console.log('result'+result.isSubmitted);
            this.createdPatientQuestionnaireId = result.createdPatientQuestionnaireId;
            console.log('createdPatientQuestionnaireId--'+this.createdPatientQuestionnaireId);
            if( result.status == 'success' && result.isSubmitted == false ){
                const evt = new ShowToastEvent({
                    title: 'title',
                    message:result.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);  
            }else{
                const evt = new ShowToastEvent({
                    title: 'title',
                    message:result.message,
                    variant: 'success',
                });
                this.dispatchEvent(evt);  
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error => {
            console.log('error-->',error);
        });
    }
  
    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}