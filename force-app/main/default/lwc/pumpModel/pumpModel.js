import { LightningElement,track,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class PumpModel extends NavigationMixin(LightningElement) {
    mainpumpID;
    ruleList;
    @track productID;
    PumpId;
    @track mainIdAttribute;
    @track jdeNameFromSumm;
    @track secondaryand;
    showparent=true;
    @track arrayFromRelated=[];
    fromSummary=[];
    showpriceProduct = false;
    showsummary = false;
    summarycmpdata;
    selectedarray;
    pumpName;
    ifcmps;
    backdata=false;
    selecteddata=[];
    requireddata;
    optionaldatalist;
    keyvalueArray;
    productsId=[];
    andArrayfromquick=[];
    secondaryAndfromquick=[];
    defultdata;
    parentcmp;
    selectedproductdata=[];  
    selectedoptionaldata=[];  
    rendertrue=false;
    showrelatedcmp = false;
    @track currentPageReference;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        console.log('currentPageReference',this.currentPageReference);
    }

    get recordId() {
        console.log('oppid',this.currentPageReference?.state?.c__recordId);
        return this.currentPageReference?.state?.c__recordId;
    }

    
       handlechild(event){
   this.showparent = false;

   this.showsummary = true;
   console.log('show child ---->',this.showChild);
    }


    handleonarrayradiotosumm(event){
       
        this.showparent = false;
        this.showsummary =  true;
         this.showpriceProduct = false;
         this.arrayFromRelated= event.detail.selected;
         this.PumpId = event.detail.pumpId;
         this.pumpName = event.detail.pumpName;
         this.requireddata =  event.detail.requireddata;
         console.log('requireddata', this.requireddata);
         this.optionaldatalist =  event.detail.optionaldata;
  
         this.keyvalueArray = event.detail.bundlewithcode;
         console.log('pumpName', this.pumpName)
  
      }


    handleparent(event){
        this.PumpId= event.detail.pumpid;
        this.requireddata = event.detail.requireddata;
        this.optionaldatalist = event.detail.optionaldata;
        this.backdata =  true;
        console.log('PumpIdback', this.PumpId);
        console.log('backdata', this.backdata);
        this.showparent = true;
       this.showsummary = false;
        
    }

   

    handlechildPrice(event){
    
    this.selectedarray =event.detail.arraychoosen;
    this.fromSummary = event.detail.summarydata;
    console.log('this.fromSummary. in parent component....',this.fromSummary);
    this.showpriceProduct = true;
    this.showparent = false;
    this.showsummary = false;
    }

    refresh(){
        window.location.reload();
    }
}