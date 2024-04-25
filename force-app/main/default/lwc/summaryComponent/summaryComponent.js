import { LightningElement, wire, track, api} from 'lwc';
import getAllsummary from '@salesforce/apex/opportunityProduct.getAllsummary';


export default class SummaryComponent extends LightningElement {
// @api arrayfromrelated;
@api pumpid;
@api pumpname;
@api reqdata;
@api optdata;
@api stringarray;
SummaryDatas;
totalPrice;

  
connectedCallback(){
  console.log('stringarray in summary ...',this.stringarray);  
  // console.log('arrayfromrelated',this.arrayfromrelated);
    console.log('reqdata in summary.....',this.reqdata);
    console.log('optdata in summary ......',this.optdata);
    // var arayvalue = JSON.stringify(this.arrayfromrelated).replaceAll('"', '');
    //   var arayvalue1 = arayvalue.replaceAll(']', '');
    //   this.arayvalue = arayvalue1.replaceAll('[', '');
    //   console.log('arayvalue',this.arayvalue);
    console.log('pumpid',this.pumpid);
}

@wire(getAllsummary,{pumpId : '$pumpid', choosenarray:'$stringarray'})

  wiredSummaryMethod({ error, data }) {
    if (data) {
      console.log('Summary data...',data);
      
      this.SummaryDatas = data;
      this.totalPrice = 0;
      for(let dataSumm of this.SummaryDatas){
        this.totalPrice += dataSumm.selectedlist[0].price;
      }
      console.log('totalPrice...',this.totalPrice);

      this.error = undefined;
    }
    else if (error) {
      this.error = error;
      console.log('relatedError',error);
      this.data = undefined;
    }
}




backToShowProduct(event){
    this.dispatchEvent(new CustomEvent('showparent',{detail: {showchild : false,pumpid:this.pumpid,requireddata:this.reqdata,optionaldata:this.optdata}}));
    window.scrollTo(0, 0);
    
    
    }
    
    nextButton(event){
    this.dispatchEvent(new CustomEvent('hidechild',{detail: {summarydata : this.SummaryDatas}}));
    window.scrollTo(0, 0);
    }

}