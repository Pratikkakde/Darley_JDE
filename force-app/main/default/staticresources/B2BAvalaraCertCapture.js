// CertCapture GenCert API
// Copyright (c) 2015-2016 Avalara
// http://www.certcapture.com
//
// GenCert
// This script serves as a Javascript/JSON callback class for the CertCapture certificate generation service.
// For more information and parameter options, please see the API documentation.


// At least one client has overwritten the browser's JSON object with one that has encode/decode functions instead of
// the standard JSON.stringify & JSON.parse functions.

// JSON.stringify || JSON.encode
function __gc_stringify(obj) {
    if (typeof JSON.stringify === 'function') {
        return JSON.stringify(obj);
    } else if (typeof JSON.encode === 'function') {
        return JSON.encode(obj);
    } else {
        throw new Error("GenCert - Unable to find serialize function.");
    }
}

// JSON.parse || JSON.decode
function __gc_parse(string) {
    if (typeof JSON.parse === 'function') {
        return JSON.parse(string)
    } else if (typeof JSON.decode === 'function') {
        return JSON.decode(string);
    } else {
        throw new Error('GenCert - Unable to parse string into literal.');
    }
}

var ___GCClientData    = __gc_stringify(null),
    ___GCAppBase       = 'https://app.certcapture.com/';
___GCisCertExpress =  false;

(function(window) {
    try {
        ___GCClientData = __gc_parse(___GCClientData)
    } catch(ex) {
        // Server provided bad JSON. Show error dialog?
        // This shouldn't happen, but you never know.
        throw ex;
    }
    // TODO: Determine why SigPlus1 isn't available at this point.
    var SigPlus1 = window.SigPlus1;

    var callbacks = ["onInit", "beforeShow", "afterShow",
        "beforeValidate", "onValidateSuccess", "onValidateFailure",
        "onCertSuccess", "onCertFailure", "onCancel","onManualSubmit",
        "onNotNeeded", "onUpload", "onSaveCustomer", "onSaveSignature"];

    var options   = ["debug", "submit_to_stack", "preview", "customer_list", "hide_sig", "upload_only", "upload", "fill_only", "edit_purchaser", "append_barcode", "certid_footer", "show_files", "upload_form_unavailable", "certificate_completion_notification", "show_cert_ids", "purge_data", "force_customer", "skip_signature", "ecm_flag", "certCaptureURL"];

    var GenCertPrototype = {
        // Informative and tracking variables
        version: '2.0.2',
        registered: false,
        ready: false,
        debug: false,
        loading: false,
        timeoutId: 0,

        // Status
        status: 0,
        preview: false,
        statusMsg: 'The CertCapture GenCert API has not been registered.',
        errorTitle: undefined,
        errorMsg: '',
        errorMsgHtml: '',
        errorPrefix: 'There was an error processing your request. Please try again or contact support.',
        topaz_signature: false,
        locationId: 0,

        // Required variables for function
        container: document.body,
        customerNumber: '',
        anonymousCustomerId: '',
        shipState: '',
        shipZone: '',
        taxCode: '',
        jwtToken: '',
        docType: '',
        token: '',
        primaryColor: '',
        secondaryColor: '',
        css: '',
        fileURL: '',
        certexpressClientId: '',
        sellerId: '',
        coverLetter: '',
        coverLetterOnly: false,
        deliveryType: '',
        emailAddress: '',
        customMessage: '',
        manualExpirationDate: '',
        ecm_flag: '',

        // Storage variables for calculated values
        clientData: ___GCClientData,
        customerData: {},
        signatureData: {},
        productExemptionData: {},

        // Callback functions
        onInit: function(){
            this.__alertDebug('Calling onInit callback.  Override this callback to perform a custom action here.');
        },
        beforeShow: function(){
            this.__alertDebug('Calling beforeShow callback.  Override this callback to perform a custom action here.');
        },
        afterShow: function(){
            this.__alertDebug('Calling afterShow callback.  Override this callback to perform a custom action here.');
        },
        beforeValidate: function(){
            this.__alertDebug('Calling beforeValidate callback.  Override this callback to perform a custom action here.');
        },
        onValidateSuccess: function(){
            this.__alertDebug('Calling onValidateSuccess callback.  Override this callback to perform a custom action here.');
        },
        onValidateFailure: function(){
            this.__alertDebug('Calling onValidateFailure callback.  Override this callback to perform a custom action here.');
        },
        onNotNeeded: function(){
            this.__alertDebug('Calling onNotNeeded callback.  Override this callback to perform a custom action here.');
        },
        onManualSubmit: function(){
            this.__alertDebug('Calling onManualSubmit callback.  Override this callback to perform a custom action here.');
        },
        onCertSuccess: function(){
            this.__alertDebug('Calling onCertSuccess callback.  Override this callback to perform a custom action here.');
        },
        onCertFailure: function(){
            this.__alertDebug('Calling onCertFailure callback.  Override this callback to perform a custom action here.');
        },
        onCancel: function(){
            this.__alertDebug('Calling onCancel callback.  Override this callback to perform a custom action here.');
            this.hide();
        },
        onUpload: function(){
            this.__alertDebug('Calling onUpload callback.  Override this callback to perform a custom action here.');
        },
        onSaveCustomer: function(){
            this.__alertDebug('Calling onSaveCustomer callback.  Override this callback to perform a custom action here.');
        },
        onSaveSignature: function(){
            this.__alertDebug('Calling oonSaveSignature callback.  Override this callback to perform a custom action here.');
        },

        ///////////////////////////////////////////////////////
        //                Internal functions                 //
        ///////////////////////////////////////////////////////
        // Debugging message builder
        __alertDebug: function (msg){
            if (this.debug){
                alert(msg);
            }
        },

        __apiIsStable: function() {
            return (this.status >= 0);
        },

        __setStatus: function (stat, msg){
            this.status    = stat;
            this.statusMsg = msg;
            if (stat < 0) {
                this.errorTitle   = "Error";
                this.errorMsg     = msg;
                this.errorMsgHtml = msg;
                this.errorMsg = this.errorMsg.replace(/<ul>/g, "\n\n");
                this.errorMsg = this.errorMsg.replace(/<\/ul>/g, '');
                this.errorMsg = this.errorMsg.replace(/<li>/g, '');
                this.errorMsg = this.errorMsg.replace(/<\/li>/g, "\n");
            }
            this.__alertDebug(msg);
        },

        __isDOMElement: function(element){
            return (
                typeof HTMLElement === "object" ? element instanceof HTMLElement :
                    typeof element === "object" && element.nodeType === 1 && typeof element.nodeName==="string"
            );
        },

        __serializeOptions: function(){

            var string = '';
            for (var i=0; i < options.length; i++) {
                var setOpt = this[options[i]];
                if (setOpt) {
                    string += '&'+options[i]+'='+setOpt;
                }
            }
            return string;
        },

        __reset: function(){
            try {
                this.container.removeChild(this.loadingDiv);
            }
            catch(e){
                try {
                    window.removeChild(this.loadingDiv);
                } catch(e){}
            }

            try {
                this.container.removeChild(this.gencertFrame);
            }
            catch(e){
                try {
                    window.removeChild(this.gencertFrame);
                } catch(e){}
            }

            this.registered           = false;
            this.ready                = false;
            this.debug                = false;
            this.css                  = false;
            this.fileURL              = '';
            this.loading              = false;
            this.timeoutId            = 0;
            this.status               = 0;
            this.topaz_signature      = false;
            this.locationId           = 0;
            this.preview              = false;
            this.statusMsg            = 'The CertCapture GenCert API has not been registered.';
            this.errorTitle           = undefined;
            this.errorMsg             = '';
            this.errorMsgHtml         = '';
            this.errorPrefix          = 'There was an error processing your request. Please try again or contact support.';
            this.container            = document.body;
            this.customerNumber       = '';
            this.anonymousCustomerId  = '';
            this.shipState            = '';
            this.shipZone             = '';
            this.taxCode              = '';
            this.jwtToken             = '';
            this.docType              = '';
            this.token                = '';
            this.customerData         = {};
            this.signatureData        = {};
            this.productExemptionData = {};
            this.certexpressClientId  = '';
            this.sellerId             = '';
            this.coverLetter          = '';
            this.coverLetterOnly      = false;
            this.deliveryType         = '';
            this.emailAddress         = '';
            this.customMessage        = '';
            this.manualExpirationDate = '';
            this.ecm_flag             = '';

            // Callback functions
            this.onInit = function(){
                this.__alertDebug('Calling onInit callback.  Override this callback to perform a custom action here.');
            };
            this.beforeShow = function(){
                this.__alertDebug('Calling beforeShow callback.  Override this callback to perform a custom action here.');
            };
            this.afterShow = function(){
                this.__alertDebug('Calling afterShow callback.  Override this callback to perform a custom action here.');
            };
            this.beforeValidate = function(){
                this.__alertDebug('Calling beforeValidate callback.  Override this callback to perform a custom action here.');
            };
            this.onValidateSuccess = function(){
                this.__alertDebug('Calling onValidateSuccess callback.  Override this callback to perform a custom action here.');
            };
            this.onValidateFailure = function(){
                this.__alertDebug('Calling onValidateFailure callback.  Override this callback to perform a custom action here.');
            };
            this.onNotNeeded = function(){
                this.__alertDebug('Calling onNotNeeded callback.  Override this callback to perform a custom action here.');
            };
            this.onManualSubmit = function(){
                this.__alertDebug('Calling onManualSubmit callback.  Override this callback to perform a custom action here.');
            };
            this.onCertSuccess = function(){
                this.__alertDebug('Calling onCertSuccess callback.  Override this callback to perform a custom action here.');
            };
            this.onCertFailure = function(){
                this.__alertDebug('Calling onCertFailure callback.  Override this callback to perform a custom action here.');
            };
            this.onCancel = function(){
                this.__alertDebug('Calling onCancel callback.  Override this callback to perform a custom action here.');
                this.hide();
            };
            this.onUpload = function(){
                this.__alertDebug('Calling onUpload callback.  Override this callback to perform a custom action here.');
            };
            this.onSaveCustomer = function(){
                this.__alertDebug('Calling onSaveCustomer callback.  Override this callback to perform a custom action here.');
            };
            this.onSaveSignature = function(){
                this.__alertDebug('Calling oonSaveSignature callback.  Override this callback to perform a custom action here.');
            };

        },

        __show: function(){
            if (!this.ready){
                setTimeout(function() {
                    this.__show()
                }.bind(this), 100);
                return;
            } else {
                this.container.style.display = 'block';
                this.gencertFrame.style.display = 'block';

                this.__alertDebug('Calling Show After Element');
                this.afterShow();
            }
        },

        __setOption: function(option, value) {
            // N.b., the previous version would only have worked correctly when
            // value is a boolean or number. It could now be used with any type.
            this[option] = value;
        },

        ///////////////////////////////////////////////////////
        //                External functions                 //
        ///////////////////////////////////////////////////////

        setDebug: function(enable){
            this.debug = enable;
            this.__alertDebug('Init: Debug is on.');
        },

        init: function(container, params, cid, key) {
            this.__reset();
            this.registered       = false;
            this.ready            = false;
            this.loading          = false;
            this.use_sigpad       = false;
            this.show_cert_ids    = false;
            this.clientData = this.clientData || {};

            if (cid) {
                this.clientData.cid = cid;
            }

            if (key) {
                this.clientData.key = key;
            }

            if (params.token) {
                this.setToken(params.token);
            }

            var optionCount = options.length;

            for (var i=0; i < optionCount; i++) {
                this[options[i]] = false;
            }

            // Parse options first to set debug if requested
            if (params){
                if (params.debug){
                    this.debug = params.debug;
                    this.__alertDebug('Init: Debug is on.');
                }
                if (params.css) {
                    this.css = params.css;
                    this.__alertDebug('Init: Loading Additional CSS into iframe.');
                }
                if (params.ecm_flag){
                    this.ecm_flag = params.ecm_flag;
                }
            }

            // Initialize parent container
            if (container && this.__isDOMElement(container)){
                this.container           = container;
                this.__alertDebug('Found supplied parent container.');
                this.container.innerHTML = '';

                // Build loading notifier
                this.loadingDiv     = document.createElement('div');
                this.loadingDiv.id  = 'gencert_loading';
                this.loadingDiv.style = 'width: 100%; display:block';

                if (params.loadingContent) {
                    this.loadingDiv.innerHTML = params.loadingContent;
                }
                else {
                    this.loadingDiv.innerHTML = "<img src='https://app.certcapture.com//img/loader.gif' style='margin: 0 auto; display: block;'/>";
                }

                this.container.appendChild(this.loadingDiv);

                this.gencertFrame               = document.createElement('iframe');
                this.gencertFrame.id            = 'gencert_iframe';
                this.gencertFrame.style.display = 'none';
                this.gencertFrame.setAttribute('frameborder','0');
                this.gencertFrame.setAttribute('width','100%');
                this.gencertFrame.setAttribute('scrolling','no');
                this.gencertFrame.style.width = '1px';
                this.gencertFrame.style.minWidth = '100%';
                this.gencertFrame.setAttribute('border','none');
                this.gencertFrame.setAttribute('border-width','0px');
                this.container.appendChild(this.gencertFrame);
            } else {
                this.__alertDebug('Supplied container is null or not a valid DOM element.');
            }

            if (params.token) {
                var loadUrl = ___GCAppBase + 'gencert2/load_gencert20?css='+this.css;
            }
            else {
                var loadUrl = ___GCAppBase + 'gencert2/load_gencert20?cid='+this.clientData.cid+'&key='+this.clientData.key+'&css='+this.css;
            }

            var xmlhttp = new XMLHttpRequest();
            xmlhttp.onreadystatechange = function() {
                if ( xmlhttp.readyState == XMLHttpRequest.DONE ) {
                    if ( xmlhttp.status == 200 && xmlhttp.responseText !== "" ) {
                        document.getElementById('gencert_iframe').contentWindow.document.write(xmlhttp.responseText);
                        document.getElementById('gencert_iframe').contentWindow.document.close();
                        if (params.token) {
                            console.log('Token successfully authenticated. All GenCert features are available.');
                        }
                    }
                    else  {
                        console.error(xmlhttp.statusText);
                        console.error(xmlhttp.responseText);
                        alert('Error loading GenCert.\n' + xmlhttp.statusText + ': ' + xmlhttp.responseText);
                    }
                }
            };

            xmlhttp.open( "GET", loadUrl, true );
            if (params.token) {
                xmlhttp.setRequestHeader( "authorization", "Bearer "+params.token );
            }
            xmlhttp.send();

            this.ready = true;
            this.registered = true;
            this.__setStatus(1, 'The CertCapture GenCert system has been registered.');

            if (params) {
                // Check for customized callbacks
                var callCount = callbacks.length;

                for (var i=0; i < callCount; i++) {
                    var optFunc = params[callbacks[i]];
                    if (optFunc && typeof optFunc === "function"){
                        this.__alertDebug('Setting customized "'+callbacks[i]+'" callback.');
                        this[callbacks[i]] = optFunc;
                    }
                }

                // Check options
                var optionCount = options.length;

                for (var i=0; i < optionCount; i++) {
                    var optSet = params[options[i]];
                    if (optSet){
                        this.__alertDebug('Toggling option "'+options[i]+'".');
                        this.__setOption(options[i], optSet);
                    }
                }

                if (params.customer_number)
                    this.setCustomerNumber(params.customer_number);
                else if (params.anonymous_customer_id)
                    this.__setAnonymousCustomerId(params.anonymous_customer_id);
                if (params.location_id)
                    this.setLocation(params.location_id);
                if (params.ship_zone)
                    this.setShipZone(params.ship_zone);
                if (params.tax_code)
                    this.setTaxCode(params.tax_code);
                if (params.doc_type)
                    this.setDocType(params.doc_type);
                if (params.primary_color)
                    this.setPrimaryColor(params.primary_color);
                if (params.secondary_color)
                    this.setSecondaryColor(params.secondary_color);
                if (params.error_prefix)
                    this.errorPrefix = params.error_prefix;
                if (params.use_sigpad)
                    this.setSignaturePad(params.use_sigpad);
                if (params.show_cert_ids)
                    this.setShowCertIds(params.show_cert_ids);
                if (params.signature_data)
                    this.setSignatureData(params.signature_data);
                if (params.certexpress_client_id)
                    this.setCertexpressClientId(params.certexpress_client_id);
                if (params.seller_id)
                    this.setSellerId(params.seller_id);
                if (params.delivery_type)
                    this.setDeliveryType(params.delivery_type);
                if (params.cover_letter)
                    this.setCoverLetter(params.cover_letter);
                if (params.cover_letter_only)
                    this.setCoverLetterOnly(params.cover_letter_only);
                if (params.email_address)
                    this.setEmailAddress(params.email_address);
                if (params.custom_message)
                    this.setCustomMessage(params.custom_message);
            }

            this.__setStatus(1, 'CertCapture API initialized.');
            this.onInit();
        },

        scrollTop: function() {
            window.scrollTo(0,0);
        },

        getStatus: function(){
            return this.status;
        },

        getStatusMsg: function(){
            return this.statusMsg;
        },

        setCustomerNumber: function(customerNumber){
            this.__alertDebug('Setting customer number to '+customerNumber);
            this.customerNumber = customerNumber;
        },

        getCustomerNumber: function(){
            return this.customerNumber;
        },

        __setAnonymousCustomerId: function(anonymousCustomerId){
            this.__alertDebug('Setting anonymous customer id to '+anonymousCustomerId);
            this.anonymousCustomerId = anonymousCustomerId;
        },

        getAnonymousCustomerId: function(){
            return this.anonymousCustomerId;
        },

        setShipZone: function(shipZone){
            this.__alertDebug('Setting ship zone to '+shipZone);
            this.shipZone = shipZone;
        },

        getShipZone: function(){
            return this.shipZone;
        },

        getTaxCode: function() {
            return this.taxCode;
        },

        setTaxCode: function(code){
            this.__alertDebug('Setting tax code to '+code);
            this.taxCode = code;
        },

        setToken: function(token) {
            this.jwtToken = token;
        },

        getToken: function() {
            return this.jwtToken;
        },

        getDocType: function() {
            return this.docType;
        },

        setDocType: function(type){
            this.__alertDebug('Setting document type to '+type);
            this.docType = type;
        },

        setManualExpirationDate: function(manualExpirationDate){
            this.manualExpirationDate = manualExpirationDate;
        },

        getManualExpirationDate: function(){
            return this.manualExpirationDate;
        },

        getPrimaryColor: function() {
            return this.primaryColor;
        },

        setPrimaryColor: function(color){
            this.__alertDebug('Setting primary color '+color);
            this.primaryColor = color;
        },

        getSecondaryColor: function() {
            return this.secondaryColor;
        },

        setSecondaryColor: function(color){
            this.__alertDebug('Setting secondary color '+color);
            this.secondaryColor = color;
        },

        setSignaturePad: function(use_sigpad){
            this.__alertDebug('Setting use sigpad to '+use_sigpad);
            this.use_sigpad = use_sigpad;
        },
        setSignatureData: function (signature_data) {
            this.__alertDebug('Setting signature data.');
            this.signatureData = signature_data;
        },
        setProductExemptionData: function (exemption_data) {
            this.productExemptionData = exemption_data;
        },
        setCertexpressClientId: function (certexpress_client_id) {
            this.__alertDebug('Setting CertExpress Client Id.');
            this.certexpressClientId = certexpress_client_id;
        },

        setSellerId: function (seller_id) {
            this.__alertDebug('Setting Seller Id.');
            this.sellerId = seller_id;
        },

        setDeliveryType: function (delivery_type) {
            this.deliveryType = delivery_type;
        },

        setCoverLetter: function (cover_letter) {
            this.coverLetter = cover_letter;
        },

        setCoverLetterOnly: function (cover_letter_only) {
            this.coverLetterOnly = cover_letter_only;
        },

        setEmailAddress: function (email_address) {
            this.emailAddress = email_address;
        },

        setCustomMessage: function (custom_message) {
            this.customMessage = custom_message;
        },

        setShowCertIds: function( show_cert_ids ){
            this.__alertDebug('Setting show certificate ids to '+show_cert_ids);
            this.show_cert_ids = show_cert_ids;
        },

        setLocation: function(location){
            this.__alertDebug('Setting location to '+location);
            this.locationId = location;
        },

        resizeIframe: function(id, height){
            document.getElementById(id).height = (height) + "px";
            document.getElementById(id).width = "100%";
        },

        hideLoader: function() {
            try {
                this.container.removeChild(this.loadingDiv);
            } catch(e) {
                try {
                    window.removeChild(this.loadingDiv);
                } catch(e){}
            }
        },

        setCustomerData: function(customer){
            if (this.loading){
                setTimeout(function(){this.setCustomerData(customer)}.bind(this), 100);
            }
            else {
                this.loading = true;
                if (customer){
                    console.log('customerStatic--' + customer);
                    if (customer.name)
                        this.customerData.name = customer.name;
                    if (customer.alternateid)
                        this.customerData.alternate_id = customer.alternateid;
                    if (customer.address1)
                        this.customerData.address_line1 = customer.address1;
                    if (customer.address2)
                        this.customerData.address_line2 = customer.address2;
                    if (customer.city)
                        this.customerData.city = customer.city;
                    if (customer.state)
                        this.customerData.state = customer.state;
                    if (customer.zip)
                        this.customerData.zip = customer.zip;
                    if (customer.phone)
                        this.customerData.phone_number = customer.phone;
                    if (customer.fax)
                        this.customerData.fax_number = customer.fax;
                    if (customer.email)
                        this.customerData.email_address = customer.email;
                    if (customer.country)
                        this.customerData.country = customer.country;

                    this.__alertDebug('Updated customer data:'+JSON.stringify(this.customerData));
                }
                else {
                    this.__alertDebug('Not updating customer data - customer record empty.');
                }
                this.loading = false;
            }
        },

        show: function(){
            this.beforeShow();
            this.__show();
        },

        hide: function(){
            this.__alertDebug('Hiding form interface.');
            this.gencertFrame.style.display = 'none';
        },

        // Turns tablet on
        OnSign: function() {
            SigPlus1.TabletState = 1;
        },

        //Clears the signature, in case of error or mistake
        OnClear: function() {
            SigPlus1.ClearTablet();
        },

        killIframe: function() {
            return;

            $('#gencert_iframe')[0].contentWindow.location.reload();
            setTimeout(function(){
                $('#gencert_iframe').remove();
            }.bind(this), 100);



            setTimeout(function() {
                this.gencertFrame.src = "about:blank";
                document.getElementById('gencert_iframe').contentWindow.document.write('');
                document.getElementById('gencert_iframe').contentWindow.close();
                this.container.removeChild(this.gencertFrame);
            }.bind(this), 0);

        },

        //Turns tablet off
        OnCancel: function() {
            SigPlus1.TabletState = 0;
        },

        OnSave: function() {
            // Turns tablet off, we want to keep it on for retail if they want to create multiple certs
            // SigPlus1.TabletState = 0;
            // Compresses the signature at a 2.5 to 1 ratio, making it smaller...to display the signature again later, you WILL HAVE TO set the SigCompressionMode of the new SigPlus object = 1, also
            // SigPlus1.SigCompressionMode = 1;

            if(SigPlus1.NumberOfTabletPoints() > 0) {
                // SigPlus1.TabletState = 0; //turn off pad
                SigPlus1.ImageFileFormat = 0; //0=bmp, 4=jpg, 6=tif
                SigPlus1.ImageXSize = 500; //width of resuting image in pixels
                SigPlus1.ImageYSize = 100; //height of resulting image in pixels
                SigPlus1.ImagePenWidth = 8; //thickness of ink in pixels
                SigPlus1.JustifyX = 10; //buffer on left and right to not lose pixels
                SigPlus1.JustifyY = 10; //buffer on top and bottom to not lose pixels
                SigPlus1.JustifyMode = 5; //Center and blow up signature as large as possible
                var bmpString = '';
                SigPlus1.BitMapBufferWrite();
                var bmpSize = SigPlus1.BitMapBufferSize();
                for(var a = 0; a < bmpSize; a++) {
                    var byte = SigPlus1.BitMapBufferByte(a).toString(16);
                    if(byte.length === 1) {
                        bmpString += '0';
                    }
                    bmpString += byte;
                }
                SigPlus1.BitMapBufferClose();
                return bmpString;
            }
        }
    };

    function GenCertClass() {
        if ( arguments.length > 0 ) {
            var argsArray = Array.prototype.slice.call(arguments);
            this.init.apply(this, argsArray);
        }
    }
    Object.keys(GenCertPrototype).forEach(function( prototypeProp ) {
        GenCertClass.prototype[prototypeProp] = GenCertPrototype[prototypeProp];
    });
    GenCertClass.prototype.constructor = GenCertClass;
    window.GenCertClass = GenCertClass;
    if (!___GCisCertExpress) {
        window.GenCert = new GenCertClass();
    }
})(window);