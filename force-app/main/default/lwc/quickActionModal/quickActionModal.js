import { LightningElement,track,wire,api} from 'lwc';
import searchProduct from '@salesforce/apex/opportunityProduct.searchProduct';
import ProductDetails from '@salesforce/apex/opportunityProduct.ProductDetails';
import forThenLogicPriceRule from '@salesforce/apex/opportunityProduct.forThenLogicPriceRule';
import forThenLogic from '@salesforce/apex/opportunityProduct.forThenLogic';
import bundlenameRefresh from '@salesforce/apex/opportunityProduct.bundlenameRefresh';
import reqBundle from '@salesforce/apex/opportunityProduct.reqBundle';
import OptBundle from '@salesforce/apex/opportunityProduct.OptBundle';


export default class QuickActionModal extends LightningElement {
   
   
    descrip;       
    comboProductName;
    productName='';
    @track productList=[];
    thenlogic=[];
    arraySelectedProduct = [];
    arrayForPricerule = [];
     @api productID;
     @api back;
     @api reqdata;
     @api optdata;
    @track allReqData;
     priceThen;
     allOptData;
     optlist;
     bundleWithPrice=[];
     priceData = 0;
     @api productid;
     @api selectedpumpid;
    datafalse= false
     @api mainattributeid;
     @api oppid;
     @api pumpname;
    selectedProductName;
    selectedProductId;
    productDetailsData;
    priceRuleArrayInString
    sendingreqlist=[];
    showProductData =  false;
    showSearchList = true;
    MainAttributeList;
    shownextbutton= false;
    othersIfOptions=[];
    reqBundleOptions=[];
    MainAttributeListOptions=[];
    ifANddata = [];
    then = [];
    showCombox = false;
    showSelectbutton= true;
    ifandlist=[];
    SecondarySelectedProductId;
    rulechild=false;
    onlyproductId=[];
    selectedpumpName;
    SecondarycomboProductName;
    mainbundlename;
    ruledata;
    arayrule;
    isLoaded = false;
    isThenLoaded = false;
    showcombobox = false;
    showPriceCard = false;
    codeToRefresh;
    reservedReq =[];
    reservedOpt = [];
    arrayForSwap = [];

    // it work when we click back button from sencond page!
     connectedCallback(){
      if(this.back == true){
        this.selectedProductId = this.productID;
        this.datafalse = true;
        this.showProductData = true;
         this.showSearchList = false;
         this.showSelectbutton=true;
         this.ProductDetailsMethod();
         this.showPriceCard = true;
         this.ifandlist=JSON.parse(JSON.stringify(this.reqdata));
         this.allOptData =JSON.parse(JSON.stringify(this.optdata));
         this.showcombobox = true;
         this.showSelectbutton = false;
         this.allReqData =  JSON.parse(JSON.stringify(this.reqdata));
         this.allReqiredData();
      }
}


handleKeyChange(event)
{
    this.productName=event.target.value;
}

    @wire(searchProduct,{p1:'$productName'})
    retrieveProducts({error,data}){

        if(data){
            this.productList= data;            
        }
        else if(error){
            // console.log('Error',error);
        }
    }

   
    handleRadio(event){
         this.productID = event.currentTarget.value;
         this.showProductData = true;
         this.showSearchList = false;
         this.showSelectbutton=true;
         this.ProductDetailsMethod();
         this.showcombobox = true;
        }

        ProductDetailsMethod() {
            ProductDetails({ productId: this.productID })
                .then((result) => {
                    this.productDetailsData = result;
                    this.selectedProductId = this.productDetailsData[0].Id;
                    this.selectedProductName =  this.productDetailsData[0].name;
                    this.descrip = this.productDetailsData[0].Description;
                    this.pumpImage = this.productDetailsData[0].ImageURL;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                });
        }
        


backToShowProduct(){
    this.showSearchList = true;
    this.showProductData = false;
    this.priceData = 0;
    this.isThenLoaded = false;
    window.scrollTo(0, 0)
}

//to show all required data.......................................!
allReqiredData(){
    reqBundle({pumpID: this.selectedProductId})
    .then((result) => {
        if(this.datafalse == false){
            
        this.ifandlist = result;
        this.allReqData =  result;
        this.reservedReq = JSON.parse(JSON.stringify(result));
        }
    for(let i=0; i<this.ifandlist.length; i++){
        if(this.ifandlist[i].value!=undefined){
                let index = this.arrayForPricerule.find(a=> a.key == this.ifandlist[i].Bname);
                if(index != undefined){
                    index.value = this.ifandlist[i].value;
                   this.arrayForPricerule = [...this.arrayForPricerule];
                }
                else{
                    this.arrayForPricerule.push({'key':this.ifandlist[i].Bname,'value':this.ifandlist[i].value});
                }
        }
      }

      this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
      this.allOptionalData();
      this.error = undefined;
        
    })
    .catch((error) => {
        this.error = error;
    });
}

//to show all optional data...........................
allOptionalData(){
    OptBundle({pumpID: this.selectedProductId})
    .then((result) => {
        if(this.datafalse == false){
       this.optlist = result;
       this.allOptData = result;
       this.reservedOpt = JSON.parse(JSON.stringify(result));
        }

        for(let i=0; i<this.allOptData.length; i++){
            if(this.allOptData[i].value!=undefined){
                    let index = this.arrayForPricerule.find(a=> a.key == this.allOptData[i].name);
                    if(index != undefined){
                        index.value = this.allOptData[i].value;
                       this.arrayForPricerule = [...this.arrayForPricerule];
                    }
                    else{
                        this.arrayForPricerule.push({'key':this.allOptData[i].name,'value':this.allOptData[i].value});
                    }
            }
          }
    
          this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);

       this.shownextbutton =  true;
       this.isLoaded= false;
        this.error = undefined;
    })
    .catch((error) => {
        this.error = error;
    });
}


forThenLogicmethod(){
    forThenLogic({comboName:this.SecondarycomboProductName ,Pumpname:this.selectedProductName, productBundleNameString : this.mainbundlename, stringBundlecode:this.priceRuleArrayInString})
    .then((result) => {
          this.then = result;
          console.log('Then Data --->', this.then);
          this.ifandlist.forEach((item1) => {
             //Find matching item in list2
            let item2 = this.then.find((item2) => item1.Bname == item2.name);
            if (item2) {
                console.log('insideThenlogic');
               item1.forcombo = item2.innerLabelOptions;
               item1.value = item2.value;
                
            }
          });
          this.allReqData = [];
           this.allReqData =  this.ifandlist;

           this.optlist.forEach((item1) => {
            let item2 = this.then.find((item2) => item1.name == item2.name);
            if (item2) {
               console.log('insideThenlogic');
               
              item1.forcombo
             = item2.innerLabelOptions;
               
           }
         });
         this.allOptData = [];
         this.allOptData =  this.optlist;

        for(let i=0; i<this.allReqData.length; i++){
            if(this.allReqData[i].value != null){
                let index = this.arrayForPricerule.find(a=> a.key == this.allReqData[i].Bname);
            if(index != undefined){
                index.value = this.allReqData[i].value;
                this.arrayForPricerule = [...this.arrayForPricerule];
            }
            else{
                this.arrayForPricerule.push({'key':this.allReqData[i].Bname,'value':this.allReqData[i].value});
            }
            }
            
        }
   
            this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
            console.log('string....',this.priceRuleArrayInString);
            this.isThenLoaded = false;
      
        this.error = undefined;
    })
    .catch((error) => {
        this.error = error;
    });
}


// ..........to refresh data , when user change there selection ..................................

bundlenameMethod(){
    bundlenameRefresh({comboName:this.codeToRefresh ,Pumpname:this.selectedProductName, productBundleNameString : this.mainbundlename})
    .then((result)=>{
        let data = result;        
        let tempArray = [];
        let tempArray2 = [];
        data.forEach((item1) => {
        let item2 = this.reservedReq.find((item2) => item1.Bundle_Sequence__c == item2.BSProductBundle);
        tempArray.push(item2);
         });

         this.ifandlist.forEach((ifandlistItem) => {
            
            let tempArrayitem = tempArray.find((tempArrayitem) => ifandlistItem.Bname == tempArrayitem?.Bname);
            if (tempArrayitem) {
               ifandlistItem.forcombo = tempArrayitem.forcombo;
               ifandlistItem.value = tempArrayitem.value;
               
           }
         });

           this.allReqData = [];
           this.allReqData =  this.ifandlist;

           data.forEach((itemA) => {
            
            let itemB = this.reservedOpt.find((itemB) => itemA.Bundle_Sequence__c == itemB.BSProductBundle);
            tempArray2.push(itemB);
         });

         this.optlist.forEach((optlistItem) => {
            
            let tempArrayitem2 = tempArray2.find((tempArrayitem2) => optlistItem.name == tempArrayitem2?.name);
            if (tempArrayitem2) {
                optlistItem.forcombo = tempArrayitem2.forcombo;
                optlistItem.value = tempArrayitem2.value;
               
           }
         });

           this.allOptData = [];
           this.allOptData =  this.optlist;

        this.error = undefined;
    })
    .catch((error) => {
        this.error = error;
    });
}

// .............................price rule like JDE ............................

forThenLogicPriceRuleMethod(){

forThenLogicPriceRule({comboName:this.SecondarycomboProductName ,Pumpname:this.selectedProductName, stringPriceproduct:this.priceRuleArrayInString, productBundleNameString : this.mainbundlename})
.then((result)=>{
    let data = result;
    this.priceData = Object.values(data)[0];
    for(let key in data) {
        if(data.hasOwnProperty(key)) {
          let index = this.bundleWithPrice.findIndex(obj => obj.key === key);
          if(index >= 0) {
            this.bundleWithPrice[index].value += data[key];
          } else {
            this.bundleWithPrice.push({ key: key, value: data[key] });
          }
        }
      }
      
    
    this.error = undefined;
})
.catch((error) => {
    this.error = error;
});
}
// .................................

SelectProduct(){ 
        this.MainAttributeListOptions=[];
        this.SecondaryMainAttributeListOptions = [];
        this.showcombobox = true;
        this.isLoaded= true;
        this.allReqiredData();
        this.showPriceCard = true;
        this.showSelectbutton = false;
    }

selectrequired(event){
    this.isThenLoaded = true; 
    this.SecondarycomboProductName = event.target.value;
    let codeasvalue = this.SecondarycomboProductName;
    this.mainbundlename = event.target.name;
    let bundlename = this.mainbundlename;
    let index = this.arrayForPricerule.find(a=> a.key == bundlename);
    if(index != undefined){
    this.codeToRefresh = index.value;
    this.bundlenameMethod();
    index.value = codeasvalue;
    this.arrayForPricerule = [...this.arrayForPricerule];
    }
     else{
        this.arrayForPricerule.push({'key':bundlename, 'value':codeasvalue});
     }
    
   var selectedproductsVar = this.allReqData.find(ele  => ele.Bname == bundlename).id;
    let selectedelement = this.allReqData.find(ele  => ele.id == selectedproductsVar);
    if(selectedelement!= undefined){
         selectedelement.value = this.SecondarycomboProductName;
        this.allReqData = [...this.allReqData];
        this.ifandlist = this.allReqData;
       
     }
    
    this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
    this.forThenLogicmethod();
    this.forThenLogicPriceRuleMethod();

  
}

reqOnchange(event){
    let manualInput = event.target.value;
    this.SecondarycomboProductName = manualInput;
    let bundlename = event.target.name;
    this.mainbundlename = bundlename;

    let index = this.arrayForPricerule.find(a=> a.key == bundlename);
    if(index != undefined){
        index.value = manualInput;
       this.arrayForPricerule = [...this.arrayForPricerule];
    }
     else{
        this.arrayForPricerule.push({'key':bundlename, 'value':manualInput});
     }
this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
    let element = this.ifandlist.find(b=>b.Bname == bundlename);
    if(element != undefined){
        element.value = manualInput;
        this.ifandlist = [...this.ifandlist];
    }
}




selectoptional(event){
    this.isThenLoaded = true;    
    let selctedproductName = event.target.value;
    this.SecondarycomboProductName = selctedproductName;
  
    let bundlename = event.target.name;
    this.mainbundlename = bundlename;
    let index = this.arrayForPricerule.find(a=> a.key == bundlename);
    if(index != undefined){
        index.value = selctedproductName;
       this.arrayForPricerule = [...this.arrayForPricerule];
    }
     else{
        this.arrayForPricerule.push({'key':bundlename, 'value':selctedproductName});
     }
    this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
    var selectedproductsVar = this.allOptData.find(ele  => ele.name == bundlename).id;
    let selectedelement = this.allOptData.find(ele  => ele.id == selectedproductsVar);
    if(selectedelement!= undefined){
        selectedelement.value = selctedproductName;
       this.allOptData = [...this.allOptData];
     }
    let element = this.arraySelectedProduct.find(ele  => ele.BundleId == selectedproductsVar);
    if(element!= undefined){
       element.productId = selctedproductName;
      this.arraySelectedProduct = [...this.arraySelectedProduct];
    }
    else {  
    this.arraySelectedProduct.push({'BundleId':selectedproductsVar,'productId':selctedproductName});
    }
    this.forThenLogicmethod();
    this.forThenLogicPriceRuleMethod();
}

// manual input on optional side ..................................................................
optOnchange(event){
    let manualInput = event.target.value;
    this.SecondarycomboProductName = manualInput;
    let bundlename = event.target.name;
    this.mainbundlename = bundlename;

    let index = this.arrayForPricerule.find(a=> a.key == bundlename);
    if(index != undefined){
        index.value = manualInput;
       this.arrayForPricerule = [...this.arrayForPricerule];
    }
    else{
        this.arrayForPricerule.push({'key':bundlename, 'value':manualInput});
    }
    this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);

    let element = this.allOptData.find(b=>b.name == bundlename);
    if(element != undefined){
        element.value = manualInput;
        this.allOptData = [...this.allOptData];
    }

}

isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.reqcombobox');
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) {
            inputField.reportValidity();
            isValid = false;
        }
       
    });
    return isValid;
}

     nextButton(){
        if(this.isInputValid()) {

        let sizeOfSelectedarray = this.arraySelectedProduct.length;
        for(let i=0; i<sizeOfSelectedarray; i++){
           let productIdFromarraySelectedProduct = this.arraySelectedProduct[i].productId;
           this.onlyproductId.push(productIdFromarraySelectedProduct);
        }
          this.dispatchEvent(new CustomEvent('arrayradiotosumm',{detail: {selected : this.onlyproductId, pumpId:this.productID,pumpName:this.selectedProductName,requireddata:this.allReqData,optionaldata:this.allOptData, bundlewithcode:this.priceRuleArrayInString}}));
          window.scrollTo(0, 0);
     }
    }
}