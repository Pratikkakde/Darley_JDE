import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getAllsummary from '@salesforce/apex/opportunityProduct.getAllsummary';
import findOpportunity from '@salesforce/apex/opportunityProduct.findOpportunity';
import createQuote from '@salesforce/apex/opportunityProduct.createQuote';


export default class PriceProductcmp extends NavigationMixin(LightningElement){
  
@api summdata;
@api pumpname;
@api oppid;
quoteId;
quoteArray = [];
@track data;
@track error;
@track afterFinalDiscount;
@track discountNum = 0;
@track discountNumber;
@track indexQuantity;
@track indexDis;
@track bundleid;
@track quantityNumber;
@track finalPrice;
@track totalPrice;
@track finalonlyforprice;
@track afterdiscount;
@track arrayvaluedataforprice=[];
@track forBackend = [];
@track showModal = false;
@track oppList=[];
@track isValueSelected;
@track searchKey='';
@track oppName='';
 modaloppId;

connectedCallback(){
  for(let i=0;i<this.summdata.length; i++){
    if(this.summdata[i].selectedlist[0].componentTypeInside == 'Product'){
      this.arrayvaluedataforprice.push({'Bundleattribute':this.summdata[i].name,'bundleid':this.summdata[i].id,'productid':this.summdata[i].selectedlist[0].id,'productName':this.summdata[i].selectedlist[0].name,'productcode':this.summdata[i].selectedlist[0].component,'componentType':this.summdata[i].selectedlist[0].componentTypeInside, 'price':this.summdata[i].selectedlist[0].price,'quantity': 1,'discount':0,'finalprice':this.summdata[i].selectedlist[0].price});
    }
  }
  for(let i=0;i<this.summdata.length; i++){
    
      this.forBackend.push({'Bundleattribute':this.summdata[i].name,'bundleid':this.summdata[i].id,'productid':this.summdata[i].selectedlist[0].id,'productName':this.summdata[i].selectedlist[0].name,'productcode':this.summdata[i].selectedlist[0].component,'componentType':this.summdata[i].selectedlist[0].componentTypeInside, 'price':this.summdata[i].selectedlist[0].price,'quantity': 1,'discount':0,'finalprice':this.summdata[i].selectedlist[0].price});
    
  }

  console.log('forBackend in 3rd screen ....',JSON.parse(JSON.stringify(this.forBackend)));
  console.log('string forBackend in 3rd screen ....',JSON.stringify(this.forBackend));
if(this.oppid != null){
  this.modaloppId = this.oppid;
}
this.calculateTotalPrice();
}


QuantityChange(event){
    this.quantityNumber = event.currentTarget.value;
    this.indexQuantity = event.currentTarget.name;
    let element = this.arrayvaluedataforprice.find(ele  => ele.bundleid ==  this.indexQuantity);
    console.log('element for quantity',element);
    if(element.discount=='null'){
    let finalonlyforprice = element.price*this.quantityNumber;
    element.finalprice = finalonlyforprice;
    element.quantity = this.quantityNumber;
    this.arrayvaluedataforprice = [...this.arrayvaluedataforprice];
    console.log('quantity');
    }
    else{
      let finalonlyforprice = element.price*this.quantityNumber;
      let randomforquantity  = finalonlyforprice*(element.discount/100);
      element.finalprice = finalonlyforprice-randomforquantity;
      element.quantity = this.quantityNumber;
    this.arrayvaluedataforprice = [...this.arrayvaluedataforprice];
    }
    this.calculateTotalPrice();
    
}
    
          


discountChange(event){
  this.discountNumber = event.currentTarget.value;
    this.indexDis = event.currentTarget.name;
    let element = this.arrayvaluedataforprice.find(ele  => ele.bundleid ==  this.indexDis);
    console.log('element',element);
    if(element.quantity==1){
    let random =  element.price*(this.discountNumber/100);
    console.log('random',random);
    this.afterdiscount = element.price-random;
    element.finalprice =  this.afterdiscount;
    element.discount = this.discountNumber;
    this.arrayvaluedataforprice = [...this.arrayvaluedataforprice];
    }
    else{
      let quantityBasedPrice= element.price*element.quantity;
      let random =  quantityBasedPrice*(this.discountNumber/100);
    console.log('random',random);
    this.afterdiscount = quantityBasedPrice-random;
    element.finalprice =  this.afterdiscount;
    element.discount = this.discountNumber;
    this.arrayvaluedataforprice = [...this.arrayvaluedataforprice];
    }
    this.calculateTotalPrice();
}

calculateTotalPrice(){
  let priceTotal =0;
  for(let toGetFinalPrice of this.arrayvaluedataforprice){
    priceTotal += toGetFinalPrice.finalprice;
  }
  this.totalPrice = priceTotal;
  this.afterFinalDiscount = this.totalPrice;
  console.log('this.totalPrice...>>',this.totalPrice);
}


totaldiscountChange(event){
this.discountNum = event.target.value;
let toSubtract = this.totalPrice*(this.discountNum/100);
this.afterFinalDiscount = this.totalPrice - toSubtract;
console.log('this.afterFinalDiscount...>>',this.afterFinalDiscount);
}

finalPriceChange(event){
  let editFinalPrice = event.target.value;
  this.afterFinalDiscount = editFinalPrice;
  console.log('this.afterFinalDiscount in finalPriceChange event...>>',this.afterFinalDiscount);
}

createproductQuoteitem() {
  console.log('modalOppId - ', this.modaloppId);
  console.log('pumpname - ', this.pumpname);
  for(let i =0 ; i< this.forBackend.length; i++){
    let index = this.arrayvaluedataforprice.find(a=> a.Bundleattribute == this.forBackend[i].Bundleattribute);
    if(index != undefined){
      this.forBackend[i].quantity = index.quantity;
      this.forBackend[i].discount = index.discount;
      this.forBackend[i].finalprice = index.finalprice;
      this.forBackend = [...this.forBackend];
    }
  }
  console.log('array forBackend  - ', this.forBackend);
  createQuote({ Opportunityid: this.modaloppId, maincmp:this.pumpname, requireddata:JSON.stringify(this.forBackend), totalDiscount:this.discountNum , totalPrice:this.afterFinalDiscount})
    .then((result) => {
      this.quoteArray= result;
      console.log('result',result);
     this.error = undefined;

    if(result.length==1){
      console.log('this.quoteArray[0].....',this.quoteArray[0]);
      this.quoteId = this.quoteArray[0];
      this.showToast();
      this.handleRecordClick();
    }
    else{
      this.showError();
    }
    })
    .catch((error) => {
        this.error = error;
    });
}

isValidRecordId(id) {
  // Salesforce record Ids are 15 or 18 characters long, consisting of uppercase letters A-Z and digits 0-9
  return /^[A-Za-z0-9]{15,18}$/.test(id);
}

showToast() {
const event = new ShowToastEvent({
    title: 'Success',
  
    message:
        'Quote has Created Succesfully redirecting to the qoute record',
});
this.dispatchEvent(event);
}

handleRecordClick() {
  if(this.isValidRecordId(this.quoteId)){
    this[NavigationMixin.Navigate]({

      type: 'standard__recordPage',
      attributes: {
          recordId: this.quoteId,
          objectApiName: 'Quote',
          actionName: 'view'
    }    });
  }
  else{
    this.showError();
  }
  
 }

 showError(){
  console.log('error');
  const event = new ShowToastEvent({
    title: 'Error',
  
    message:
        'Product name which are not there in price book: '+this.quoteArray,
});
this.dispatchEvent(event);
 }
// .......................................................................................



handleSearch(event){
    this.searchKey = event.target.value;
    console.log('Search key - ',this.searchKey);
    this.getLookupResultforOpportunity();
    }
    onLeave(event){
        setTimeout(() => {
            this.searchKey = "";
            this.oppList= null;
        }, 300);
        }
        removeRecordOnLookup(){
            this.searchKey = "";
            this.modaloppId = null;
            this.oppName= null;
            this.oppList= null;
            }
         getLookupResultforOpportunity(){
            findOpportunity({
            opps : this.searchKey
            })
                .then(result =>{
                    if(result){
                        this.oppList = result;
                        console.log('opp List - ',JSON.parse(JSON.stringify(this.oppList )));
                    }
                })
                }
                handleSelectPerformer(event){
                    this.isValueSelected = true;
                    this.modaloppId = event.target.dataset.key;
                    console.log('selectedId - ',this.modaloppId );
                    this.oppName = event.target.dataset.name;
                    console.log('selectedOPPName - ',this.oppName );
                    this.searchKey = "";
                    }
 // ..................................................................
nextButton(){
  console.log('***************click on save button************');
if(this.oppid != null){
  this.createproductQuoteitem();
}
else{
  this.showModal = true;
}

}

closeModal() {
  
  this.showModal = false;
}
submitDetails(event) {
  this.showModal = false;
 this.createproductQuoteitem();
}

}