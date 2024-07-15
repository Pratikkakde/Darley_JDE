import { LightningElement,track,wire,api} from 'lwc';
import searchProduct from '@salesforce/apex/opportunityProduct.searchProduct';
import ProductDetails from '@salesforce/apex/opportunityProduct.ProductDetails';
import forThenLogicPriceRule from '@salesforce/apex/opportunityProduct.forThenLogicPriceRule';
import forThenLogic from '@salesforce/apex/opportunityProduct.forThenLogic';
import bundlenameRefresh from '@salesforce/apex/opportunityProduct.bundlenameRefresh';
import reqBundle from '@salesforce/apex/opportunityProduct.reqBundle';
import OptBundle from '@salesforce/apex/opportunityProduct.OptBundle';
import ThenValidate from '@salesforce/apex/opportunityProduct.ThenValidate';

export default class QuickActionModal extends LightningElement {
   
   
    descrip;       
    comboProductName;
    productName='';
    @track productList=[];
    thenlogic=[];
    arraySelectedProduct = [];
    @track arrayForPricerule = [];
    @track arrayForPriceruleafterrefresh = [];
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
    @track priceRuleArrayInString
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
    thenValidate=[];
    showCombox = false;
    showSelectbutton= true;
    ifandlist=[];
    @track reqReserved =[];
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
    forthencall = true;
    isrefresh = false ;
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
        this.reqReserved = [...result.map(item => ({...item}))];
        console.log('reqReserved--->', this.reqReserved);
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
      console.log('Def Data ---->' ,this.priceRuleArrayInString);
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


forThenLogicmethod() {
    console.log('arrayForPricerule before then ....', this.arrayForPricerule);
    console.log('priceRuleArrayInString - insidethen --->',this.priceRuleArrayInString);
    forThenLogic({
            comboName: this.SecondarycomboProductName,
            Pumpname: this.selectedProductName,
            productBundleNameString: this.mainbundlename,
            stringBundlecode: this.priceRuleArrayInString
        })
        .then((result) => {
            this.then = result;
            console.log('Then Data --->', this.then);
            const shallowCopiesleftThen = this.ifandlist.map(item => ({ ...item }));

            shallowCopiesleftThen.forEach((item1) => {
                //Find matching item in list2
                let item2 = this.then.find((item2) => item1.Bname == item2.name);
                if (item2) {
                    console.log('insideThenlogic');
                    item1.forcombo = item2.innerLabelOptions;
                    item1.ProductName = item2.thenProductName;
                    item1.value = item2.value;

                }
            });

            this.ifandlist = [...shallowCopiesleftThen];
            this.allReqData = [];
            this.allReqData = this.ifandlist;
            console.log('reqData After then update--->', this.allReqData);


            this.optlist.forEach((item1) => {
                let item2 = this.then.find((item2) => item1.name == item2.name);
                if (item2) {
                    console.log('insideThenlogic');
                    item1.forcombo = item2.innerLabelOptions;

                }
            });
            this.allOptData = [];
            this.allOptData = this.optlist;
            this.arrayForPricerule = [];
            this.arrayForPricerule = this.arrayForPriceruleafterrefresh;
            console.log('allReqData before modify ---> ',this.allReqData);

            for (let i = 0; i < this.allReqData.length; i++) {
                if (this.allReqData[i].value != null) {
                    let index = this.arrayForPricerule.find(a => a.key == this.allReqData[i].Bname);
                    if (index != undefined) {
                        index.value = this.allReqData[i].value;
                        this.arrayForPricerule = [...this.arrayForPricerule];
                    } else {
                        this.arrayForPricerule.push({
                            'key': this.allReqData[i].Bname,
                            'value': this.allReqData[i].value
                        });
                    }
                }

            }
            console.log('priceRuleArrayInString inside then before modify ....', this.priceRuleArrayInString);
            console.log('arrayForPricerule inside then before modify ....', this.arrayForPricerule);
           
            this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
            console.log('priceRuleArrayInString inside then....', this.priceRuleArrayInString);
           

            this.error = undefined;

            // Call ThenValidate method after forThenLogic has completed
            return ThenValidate({
                comboNames: this.SecondarycomboProductName,
                Pumpname: this.selectedProductName,
                productBundleNameString: this.mainbundlename,
                stringBundlecode: this.priceRuleArrayInString
            });
        })
        .then((result) => {
           

            console.log('this.mainbundlename ---> ',this.mainbundlename);
           // result = result.filter(item => item.name !== this.mainbundlename);
            this.thenValidate = result;

            console.log('Then validate Data --->', this.thenValidate);


            const shallowCopiesleftThen = this.ifandlist.map(item => ({ ...item })); 
            shallowCopiesleftThen.forEach((item1) => {
                //Find matching item in list2
                let item2 = this.thenValidate.find((item2) => item1.Bname == item2.name);
                if (item2) {
                    console.log('item1.value ---> ',item1.value);
                    console.log('inside ThenValidate logic');
                    item1.forcombo = item2.innerLabelOptions;
                    item1.ProductName = item2.thenProductName;
                    item1.value = item2.value;

                }
            });
            this.ifandlist = [...shallowCopiesleftThen];
            this.allReqData = [];
            this.allReqData = this.ifandlist;
            console.log('reqData After then validate update--->', this.allReqData);
            this.arrayForPricerule = [];
            this.arrayForPricerule = this.arrayForPriceruleafterrefresh;
            console.log('reqReserved--->', this.reqReserved);


            this.optlist.forEach((item1) => {
                let item2 = this.thenValidate.find((item2) => item1.name == item2.name);
                if (item2) {
                    console.log('inside ThenValidate logic');
                    item1.forcombo = item2.innerLabelOptions;

                }
            });
            this.allOptData = [];
            this.allOptData = this.optlist;
            console.log('arrayForPricerule inside then before mdf....', this.arrayForPricerule);
            for (let i = 0; i < this.allReqData.length; i++) {
                if (this.allReqData[i].value != null) {
                    console.log('allReqData bName ---> ',this.allReqData[i].Bname);
                    let index = this.arrayForPricerule.find(a => a.key == this.allReqData[i].Bname);
                    if (index != undefined) {
                        index.value = this.allReqData[i].value;
                        this.arrayForPricerule = [...this.arrayForPricerule];
                    } else {
                        this.arrayForPricerule.push({
                            'key': this.allReqData[i].Bname,
                            'value': this.allReqData[i].value
                        });
                    }
                }

            }
            console.log('arrayForPricerule inside then aft mdf....', this.arrayForPricerule);
            this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
            console.log('priceRuleArrayInString inside then opt....', this.priceRuleArrayInString);
            this.isThenLoaded = false;

            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
        });
}



// ..........to refresh data , when user change there selection ..................................

bundlenameMethod() {
    return new Promise((resolve, reject) => {
        console.log('arrayForPricerule in refresh before---->', this.arrayForPricerule);
        bundlenameRefresh({
            comboName: this.codeToRefresh,
            Pumpname: this.selectedProductName,
            productBundleNameString: this.mainbundlename
        })
        .then((result) => {
            let data = result;
            console.log('Data in refresh--->' + data);
            console.log('ReservedData in refresh--->' + this.reservedReq);
            let tempArray = [];
            let tempArray2 = [];
            data.forEach((item1) => {
                let item2 = this.reservedReq.find((item2) => item1.Bundle_Sequence__c == item2.BSProductBundle);
                if (item2 !== undefined) {
                    tempArray.push(item2);
                }
            });

            this.reqReserved.forEach(item1 => {
                let item2 = tempArray.find(item2 => item1.Bname === item2.Bname);
                if (item2) {
                    item1.forcombo = item2.forcombo;
                    item1.ProductName = item2.ProductName;
                    item1.value =  item2.value;
                   
                }
            });

            tempArray.forEach(tempItem => {
                this.arrayForPricerule = this.arrayForPricerule.filter(item => item.key !== tempItem.Bname);
            });
            console.log('arrayForPricerule after filter ---> ',this.arrayForPricerule);
            
            this.allReqData = [];
            this.allReqData = this.reqReserved;
            this.ifandlist = this.reqReserved;
          
            console.log('allReqData after refresh --->',this.allReqData);
            let arrforPriceRuleShallowCopy = [...this.arrayForPricerule];
            this.arrayForPriceruleafterrefresh = arrforPriceRuleShallowCopy;
            this.arrayForPricerule = [];
            this.priceRuleArrayInString = '';
            this.priceRuleArrayInString = JSON.stringify(arrforPriceRuleShallowCopy);
            console.log('priceRuleArrayInString - after filter --->',this.priceRuleArrayInString);
            data.forEach((itemA) => {
                let itemB = this.reservedOpt.find((itemB) => itemA.Bundle_Sequence__c == itemB.BSProductBundle);
                if (itemB !== undefined) {
                    tempArray2.push(itemB);
                }
            });

            this.optlist.forEach((optlistItem) => {
                let tempArrayitem2 = tempArray2.find((tempArrayitem2) => optlistItem.name == tempArrayitem2?.name);
                if (tempArrayitem2) {
                    optlistItem.forcombo = tempArrayitem2.forcombo;
                    optlistItem.value = tempArrayitem2.value;
                }
            });

            this.allOptData = [];
            this.allOptData = this.optlist;
          

            resolve(); // Resolve the promise after bundlenameMethod completes successfully
        })
        .catch((error) => {
            reject(error); // Reject the promise if there's an error
        });
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
        console.log('bundlename---> ',bundlename);
        console.log('arrayForPricerule inside selectrequired---> ',this.arrayForPricerule);
        let index = this.arrayForPricerule.find(a=> a.key == bundlename);
        console.log('index---> ',index);
        if(index != undefined){
        this.codeToRefresh = index.value;
        this.forthencall = false;
        this.isrefresh = true;
        this.bundlenameMethod()
            .then(() => {
                
                var selectedproductsVar = this.allReqData.find(ele  => ele.Bname == bundlename).id;
                let selectedelement = this.allReqData.find(ele  => ele.id == selectedproductsVar);
                if(selectedelement!= undefined){
                    console.log('selectedelement ---> ',selectedelement);
                    selectedelement.value = this.SecondarycomboProductName;
                    this.allReqData = [...this.allReqData];
                    this.ifandlist = this.allReqData;
                console.log('priceRuleArrayInString---> ',this.priceRuleArrayInString);
                this.forThenLogicmethod();
                this.forThenLogicPriceRuleMethod();

                   
                 }
            })
            console.log('arrayForPricerule inside required before modify  --->',this.arrayForPricerule);
            if( this.isrefresh == true){
                this.arrayForPricerule = this.arrayForPriceruleafterrefresh;
            }
          

        this.arrayForPricerule = this.arrayForPricerule.map((item) => {
            if (item.key === bundlename) {
              return { ...item, value: codeasvalue };
            }
            return item;
          });
          console.log('arrayForPricerule after refresh --->',this.arrayForPricerule);
        }
         else{
            this.arrayForPricerule.push({'key':bundlename, 'value':codeasvalue});
         }
        
         if (this.forthencall == true) {
       var selectedproductsVar = this.allReqData.find(ele  => ele.Bname == bundlename).id;
        let selectedelement = this.allReqData.find(ele  => ele.id == selectedproductsVar);
        if(selectedelement!= undefined){
            console.log('selectedelement ---> ',selectedelement);
            selectedelement.value = this.SecondarycomboProductName;
            this.allReqData = [...this.allReqData];
            this.ifandlist = this.allReqData;
           
         }
    
        this.priceRuleArrayInString = JSON.stringify(this.arrayForPricerule);
        console.log('forthencall---> ',this.forthencall);
      
        this.forThenLogicmethod();
        console.log('arrayForPricerule---> after then called ',this.arrayForPricerule);
        this.forThenLogicPriceRuleMethod();
        }
        //console.log('this.arrayForPricerule---> after refresh ',this.arrayForPricerule);
    
      
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