import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCallQuestionnaireList from '@salesforce/apex/Chs_SectionOrderingUIController.getCallQuestionnaireList';
import getQuestionsList from '@salesforce/apex/Chs_SectionOrderingUIController.getQuestionsList';
import getQuestionnaireSectionsList from '@salesforce/apex/Chs_SectionOrderingUIController.getQuestionnaireSectionsList';
import reOrderQuestionItem from '@salesforce/apex/Chs_SectionOrderingUIController.reOrderQuestionItem';


import Question from "@salesforce/schema/Question__c.Question__c";
import Section from "@salesforce/schema/Question__c.Questionnaire_Section__c";
import ResponseType from "@salesforce/schema/Question__c.Response_Type__c";
import PickListAvialable from "@salesforce/schema/Question__c.Picklist_Options_if_applicable__c";
import OrderBy from "@salesforce/schema/Question__c.Order_By__c";

export default class Chs_QuestionOrderingUI extends LightningElement {
    @track TypeQuestionnaireOptions;
    @track TypeQuestionnaireSectionOptions;
    stratedDragIndx;
    @track selectedCallQuestionnaireId;
    @track selectedQuestionnaireSectionId;
    @track questionsList = [];

    @track orderedQuestion = [];
    @track unOrderedQuestion = [];

    @track showOrderQuestion = false;
    @track showUnOrderQuestion = false;

    @track isModalOpen = false;
    fields = [Question,Section,ResponseType,PickListAvialable,OrderBy];





    createQuestion() {
        this.isModalOpen = true;
    }
    closeModal(){
        this.isModalOpen = false;
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Question Created',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.isModalOpen = false;
    }

    @wire(getCallQuestionnaireList)
    wireGetCallQuestionnaireList({error,data}){
        if(data){
            console.log('data',data);
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id  });
            }
            this.TypeQuestionnaireOptions = options;
        }else{
           
        }
    }

    handleCallQuestionnaireChange(event){
        console.log('inside handleCallQuestionnaireChange');
        this.orderedQuestion = [];
        this.unOrderedQuestion = [];
        this.showOrderQuestion = false;
        this.showUnOrderQuestion = false;
        this.selectedCallQuestionnaireId = event.target.value;
        getQuestionnaireSectionsList({selectedCallQuestionnaireId : this.selectedCallQuestionnaireId})
        .then(data => {
            console.log('data',data);
            let options = [];
            for (var key in data) {
                options.push({ label: data[key].Name, value: data[key].Id  });
            }
            this.TypeQuestionnaireSectionOptions = options;
            
        })
        .catch(error => {
            console.log('error found');
        });
    }

    handleCallQuestionnaireSectionChange(event){
        console.log('selectedQuestionnaireSectionId'+event.target.value);
        //this.showOrderQuestion = false;
        //this.showUnOrderQuestion = false;
        this.selectedQuestionnaireSectionId = event.target.value;
        getQuestionsList({selectedQuestionnaireSectionId : event.target.value})
        .then(result => {
            console.log('data',result);
            //this.questionsList = data;
            this.orderedQuestion = [];
            this.unOrderedQuestion = [];
            console.log('result',result);
            for(var i =0;i<result.length;i++){
                //this.orderedSection.push(result[i]);
                if(result[i].Order_By__c != null){
                    this.orderedQuestion.push(result[i]);
                    console.log('ordered---Questions',result[i]);
                }else{
                    this.unOrderedQuestion.push(result[i]);
                    console.log('unordered---Question',result[i]);
                }
            } 

            if(this.orderedQuestion != null || this.orderedQuestion != undefined){
                this.showOrderQuestion = true;
                console.log('this.showOrderQuestion '+this.showOrderQuestion);
            }
            if(this.unOrderedQuestion != null || this.unOrderedQuestion != undefined){
                this.showUnOrderQuestion = true;
                console.log('this.showUnOrderQuestion '+this.showUnOrderQuestion);
            }
            
        })
    }

    DragStart(event) {
        console.log('drag start');
        event.target.classList.add('drag'); 
        this.stratedDragIndx = event.target.dataset.indx;
        console.log('this.stratedDragIndx'+this.stratedDragIndx);
    }
    onDragEnter(event) {
        console.log('onDragEnter');
        event.preventDefault();
        event.dataTransfer.dropEffect = 'move'
        event.target.closest('div').classList.add('droppable');
    }

    onDragLeave(event) {
        event.target.closest('div').classList.remove('droppable');
    }

    onDragOver(event) {
        event.preventDefault();
    }

    onDrop(event) {
        console.log('onDrop');
        let dropIndx = event.target.closest('div').dataset.indx;
        console.log('dropIndx',dropIndx);
        event.target.closest('div').classList.remove('droppable');
        if(this.stratedDragIndx === dropIndx){
            return false;
        }
        reOrderQuestionItem({'selectedQuestionnaireSectionId':this.selectedQuestionnaireSectionId, srcIndx: parseInt(this.stratedDragIndx)+1, destIndx: parseInt(dropIndx)+1})
        .then(result =>{
            
            this.orderedQuestion = [];
            this.unOrderedQuestion = [];


            console.log('result'+result);
           for(var i =0;i<result.length;i++){
            this.orderedQuestion.push(result[i]);
                // if(result[i].Sort_Order__c != null){
                //     this.orderedSection.push(result[i]);
                // }else{
                //     this.unOrderedSection.push(result[i]);
                // }
            }
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Question  Dragged successfully!!',
                variant: 'success'
            });
            this.dispatchEvent(event);
        });
        return false;
    }



}