({
    disableExcelInput: function(cmp) {
        cmp.set("v.disabled", true);
        cmp.set("v.isLoading", true);
    },
    
    enableExcelInput: function(cmp) {
        cmp.set("v.disabled", false);
        cmp.set("v.isLoading", false);
    },
    
    importTableAndThrowEvent: function(cmp, evt, helper) {
        evt.stopPropagation();
        evt.preventDefault();
        try {
            const file = helper.validateFile(cmp, evt);
            cmp.set("v.file",file);
            helper.readExcelFile(cmp, file, helper)
            .then($A.getCallback(excelFile => {
                helper.throwSuccessEvent(cmp, excelFile);
            }))
                .catch($A.getCallback(exceptionMessage => {
                helper.throwExceptionEvent(cmp, exceptionMessage);
                
            }))
                .finally($A.getCallback(() => {
                helper.enableExcelInput(cmp);
            }))
            } catch (exceptionMessage) {
                helper.throwExceptionEvent(cmp, exceptionMessage);
                helper.enableExcelInput(cmp);
            }
            },
                
                validateFile: function(cmp, evt) {
                    const files = evt.getSource().get("v.files");
                    if (!files || files.length === 0 || $A.util.isUndefinedOrNull(files[0])) {
                        throw cmp.get("v.messageNoFileSpecified");
                    }
                    
                    const file = files[0];
                    const fileSizeThreshold = cmp.get("v.fileSizeThreshold");
                    if (file.size > fileSizeThreshold) {
                        throw (cmp.get("v.messageFileSizeExceeded") + ': ' + fileSizeThreshold + 'b');
                    }
                    return file;
                },
                
                readExcelFile: function(cmp, file, helper) {
                    return new Promise(function (resolve, reject) {
                        const fileReader = new FileReader();
                        fileReader.onload = event => {
                            let filename = file.name;
                            let binary = "";
                            new Uint8Array(event.target.result).forEach(function (byte) {
                            binary += String.fromCharCode(byte);
                            
                        });
                        
                        try {
                            resolve({
                                "fileName": filename,
                                "xlsx": XLSX.read(binary, {type: 'binary', header: 1})
                            });
                            console.log('XLSX.read::'+XLSX.read(binary, {type: 'binary', header: 1}));
                            console.log('END1::');
                            var workbook = XLSX.read(binary, { type: 'binary' }); 
                            
                            
                            var sheet_name_list = workbook.SheetNames;
                           // console.log('row',XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]));
                           //Logic for taking Second Sheet when FileName is RFQ
                          	console.log("Sheet Names"+sheet_name_list);
                           var XL_row_object;
                            if(filename.includes("RFQ")){
                                XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[1]]);
                                console.log('XL_row_object if::'+XL_row_object);
                            }
                            else{
                            XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);
                                console.log('XL_row_object else::'+XL_row_object);
                            }
                            console.log('XL_row_object::'+XL_row_object); 
                            var json_object = JSON.stringify(XL_row_object);
                            cmp.set("v.content", json_object);
                            console.log('After content set::'+cmp.get("v.content"));
                            helper.parseFile1(cmp);  
                            
                            console.log('END2::');
                            
                            //For Upload of a file
                        /*    var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success',
                                message: 'File has been uploaded Successfully!',
                                type: 'success'
                            });
                            toastEvent.fire(); */
                            
                        } catch (error) {
                            reject(error);
                            console.log('Reject',error);
                            
                            //Error Toast
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:'Error while reading the File',           
                                type: 'error'
                                
                            });
                            toastEvent.fire();
                        }
                    };
                                       console.log('After content set1::'+cmp.get("v.content"));
                    fileReader.readAsArrayBuffer(file);
                    
                    
                });
                
            },
                                 
                                 throwExceptionEvent: function(component, message) {
                  const errorEvent = component.getEvent("onImport");
            errorEvent.setParams({
                "type": "ERROR",
                "message": message
            });
            errorEvent.fire();
        },
            
            throwSuccessEvent: function(component, parsedFile) {
                const successEvent = component.getEvent("onImport");
                successEvent.setParams({
                    "type": "SUCCESS",
                    "fileName": parsedFile.fileName,
                    "table": parsedFile.xlsx
                });
                successEvent.fire();
            },
                
                parseFile1: function (cmp) {
                    console.log('json_object::');
                    console.log('KInside::'+cmp.get("v.content"));
                    var file = cmp.get("v.file");
                    var action = cmp.get("c.parseFile");
                    action.setParams({
                        base64Data: cmp.get("v.content"),
                        fileName: file.name,
                    });
                    action.setCallback(this, function (response) {
                        if (response.getReturnValue() == 'Records have been Successfully Created') {  
                            console.log('Successful');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success',
                                message: 'Records have been created Successfully!',
                                type: 'success'
                            });
                            toastEvent.fire();
                        }
                        
                        if(response.getReturnValue() == 'Duplicate Records Have Been Found While Creating Records'){
                             var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Warning',
                                message: 'Duplicate Records Have Been Found',
                                type: 'warning'
                            });
                            toastEvent.fire();
                        }
                        
                         if(response.getReturnValue() == 'Wrong File have been inserted'){
                             var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Warning',
                                message: 'Wrong File has been Inserted',
                                type: 'warning'
                            });
                            toastEvent.fire();
                        }
                        

                        if(response.getReturnValue() == 'Error While Creating Records') {
                            console.log('errorMsg');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message:'Error while creating record',           
                                type: 'error'
                                
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);
                }
    })