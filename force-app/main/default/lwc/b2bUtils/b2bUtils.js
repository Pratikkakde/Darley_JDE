import { setCookieConsent } from 'lightning/userConsentCookie';
import isGuest from '@salesforce/user/isGuest';
import storeId from '@salesforce/community/Id';
import Id from '@salesforce/user/Id';
import communityBasePath from '@salesforce/community/basePath';
import { addItemToCart, addItemsToCart, updateItemInCart, deleteItemFromCart } from 'commerce/cartApi';
import { getSessionContext } from 'commerce/contextApi';

import { IS } from './lib/is';
import { RANDOM } from './lib/random';
import { REGEXP } from './list/regexp';
import { DISPATCHER } from './lib/dispatcher';
import { STORAGE } from './lib/storage';
import { TOAST } from './lib/toast';
import { MOCK } from './lib/mock';

const STATUS = 'status';
const DATA = 'data';
const MESSAGE = 'message';
const TIMEOUT = 'timeout';
const CART_CHANGED = 'cartchanged';

const STATUS_KEY = 'isSuccess';
const DATA_KEY = 'responseData';
const MESSAGE_KEY = 'responseMessage';

const SUCCESS = 'success';
const ERROR = 'error';

const LEFT = 'left';
const RIGHT = 'right';
const CENTER = 'center';

const TOP = 'top';
const MIDDLE = 'middle';
const BOTTOM = 'bottom';
const STRETCH = 'stretch';

const BUILDER_POSTFIX = ['.livepreview.', '.live-preview.'];

const CUSTOM_CSS_CONTAINER = 'custom-css-container';
const DEFAULT_EFFECTIVE_ACCOUNT_ID = '000000000000000';

const BASE_64 = 'base64';

function Utils() {
    this.customCssContainer = CUSTOM_CSS_CONTAINER;
    this.isGuest = isGuest ? true : false;
    this.storeId = storeId;
    this.userId = Id;
    this.communityBasePath = communityBasePath;

    this.currencyIsoCode = 'USD';
    this.quantityMin = 1;
    this.quantityMax = 100000000;

    this.reduceErrors = (errors) => {
        if (!IS.array(errors)) errors = [errors];
        return (errors
            .filter((error) => IS.true(!!error))
            .map((error) => {
                if (IS.array(error.body)) return error.body.map((e) => e.message);
                else if (IS.stringNotEmpty(error.body.message)) return error.body.message;
                else if (IS.stringNotEmpty(error.message)) return error.message;
                return error.statusText;
            })
            .reduce((previous, current) => previous.concat(current), [])
            .filter((message) => IS.true(!!message))
        );
    }

    this.parseFetchErrorResponse = (response) => {
        let result = {};
        if (
            IS.objectNotEmpty(response)
            && IS.objectNotEmpty(response.body)
            && IS.arrayNotEmpty(response.body.pageErrors)
            && IS.stringNotEmpty(response.body.pageErrors[0].statusCode)
            && IS.stringNotEmpty(response.body.pageErrors[0].message)
        ) {
            result[STATUS_KEY] = false;
            result[DATA_KEY] = response.body.pageErrors[0].statusCode;
            result[MESSAGE_KEY] = response.body.pageErrors[0].message;
        } else {
            return null;
        }
        return result;
    }

    /**
     * Displaying notifications in the form of a toast at the top of the screen
     * @param {string} variant - Changes the appearance of the notice. Toasts inherit styling
     * from toasts in the Lightning Design System. Valid values are: info (default), success,
     * warning, and error.
     * @param {string} title - The title of the toast, displayed as a heading.
     * @param {object} options - Additional params for "B2B Toast" component.
     * @param {string} options.message - Additional text that is displayed under the title.
     * @param {string} options.mode - Determines how persistent the toast is. Valid values are:
     * dismissible (default), remains visible until you click the close button or 3 seconds has
     * elapsed, whichever comes first; pester, remains visible for 3 seconds and disappears
     * automatically. No close button is provided; sticky, remains visible until you click the
     * close button.
     * @param {integer} options.duration - The duration of the toast visibility in seconds.
     * @param {string} options.richtext - HTML code that is displayed instead of title and
     * message.
     */
    this.showToast = (variant, title, options) => {
        TOAST.showToast(variant, title, options);
    }

    // It is advisable not to use this method on scrach org
    // This method in some cases does not see the "template" for the guest
    this.addCustomCssStyles = (template, styleText) => {
        if (template) {
            styleText = IS.stringNotEmpty(styleText) ? this.prepareString(styleText) : '';
            let styleElement = document.createElement('style');
            styleElement.innerText = styleText;

            let parenNode = template.querySelector(`.${CUSTOM_CSS_CONTAINER}`);
            if (parenNode) {
                while (parenNode.firstChild) {
                    parenNode.removeChild(parenNode.firstChild);
                }
                parenNode.appendChild(styleElement);
            }
        }
        return null;
    }

    this.onlyNumbers = (str) => {
        if (IS.stringNotEmpty(str) && IS.regexp(REGEXP.onlyNumbers)) {
            return str.replace(REGEXP.onlyNumbers, '');
        }
        return null;
    };

    this.onlyLetters = (str) => {
        if (IS.stringNotEmpty(str) && IS.regexp(REGEXP.onlyLetters)) {
            return str.replace(REGEXP.onlyLetters, '');
        }
        return null;
    };

    this.onlyLettersAndNumbers = (str) => {
        if (IS.stringNotEmpty(str) && IS.regexp(REGEXP.onlyLettersAndNumbers)) {
            return str.replace(REGEXP.onlyLettersAndNumbers, '');
        }
        return null;
    };

    this.removeUnsupportedCharacters = (str) => {
        if (IS.stringNotEmpty(str) && IS.regexp(REGEXP.unsupportedCharacters)) {
            return str.replace(REGEXP.unsupportedCharacters, '');
        }
        return null;
    };

    this.removeTwoSpaces = (str) => {
        if (IS.stringNotEmpty(str) && IS.regexp(REGEXP.twoSpaces)) {
            return str.replace(REGEXP.twoSpaces, '');
        }
        return null;
    };

    this.prepareString = (str) => {
        if (IS.stringNotEmpty(str)) {
            str = this.removeUnsupportedCharacters(str);
            str = this.removeTwoSpaces(str);
            return str;
        }
        return null;
    };

    this.response = (options) => {
        // options = {
        //     status: 'boolean',
        //     data: 'any',
        //     message: 'string',
        //     timeout: 'integer',
        // }
        return new Promise((resolve, reject) => {
            try {
                let timeout = 2000;
                let response = {};
                response[STATUS_KEY] = false;

                if (IS.objectNotEmpty(options)) {
                    if (IS.objectProperty(options, STATUS) && IS.boolean(options[STATUS])) {
                        response[STATUS_KEY] = options[STATUS];
                    }
                    if (IS.objectProperty(options, DATA)) {
                        response[DATA_KEY] = options[DATA];
                    }
                    if (IS.objectProperty(options, MESSAGE) && IS.stringNotEmpty(options[MESSAGE])) {
                        response[MESSAGE_KEY] = options[MESSAGE];
                    }
                    if (
                        IS.objectProperty(options, TIMEOUT) &&
                        IS.integer(options[TIMEOUT]) &&
                        options[TIMEOUT] > 500 &&
                        options[TIMEOUT] < 5000
                    ) {
                        timeout = options[TIMEOUT];
                    }
                } else {
                    response[MESSAGE_KEY] = ERROR;
                }

                setTimeout(() => {
                    resolve(response);
                }, timeout);

            } catch (error) {
                reject(error);
            }
        });
    };

    this.addCookie = (name, value, days) => {
        if (
            IS.stringNotEmpty(name)
            && (
                IS.boolean(value)
                || IS.numeric(value)
                || IS.stringNotEmpty(value)
            )
        ) {
            name = encodeURIComponent(name);
            value = encodeURIComponent(value);
            let expires = '';

            if (IS.numeric(days)) {
                const cookieDate = new Date();
                cookieDate.setTime(cookieDate.getTime() + (days * 24 * 60 * 60 * 1000));
                expires = "; expires=" + cookieDate.toGMTString();
            }

            document.cookie = `${name}=${value}${expires}; path=/`;
        } else {
            console.warn('Cookie was not created');
        }
    };

    this.setSFCookie = (value) => {
        setCookieConsent({
            Preferences : value,
            Marketing : value,
            Statistics : value
        });
    };

    this.parseCookie = (str) => {
        return str
            .split(';')
            .map(v => v.split('='))
            .reduce((acc, v) => {
                acc[decodeURIComponent(v[0].trim())] = decodeURIComponent(v[1].trim());
                return acc;
            }, {});
    };

    this.sessionId = (str) => {
        if (IS.stringNotEmpty(str)) {
            let cookies = this.parseCookie(str);
            if (
                IS.objectNotEmpty(cookies) &&
                IS.stringNotEmpty(cookies['sfdc-stream']) &&
                IS.stringNotEmpty(cookies['force-proxy-stream'])
            ) {
                return `${cookies['sfdc-stream']}${cookies['force-proxy-stream']}`;
            }
        }
        return null;
    }

    this.getRecord18SymbolsId = (id15Symbols) => {
        if (IS.stringNotEmpty(id15Symbols) && id15Symbols.length === 15) {
            let result = `${id15Symbols}`;
            for (let block = 0; block < 3; block++) {
                let loop = 0;
                for (let position = 0; position < 5; position++) {
                    let current = id15Symbols.charAt(block * 5 + position);
                    if (current >= "A" && current <= "Z")
                        loop += 1 << position;
                }
                result += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(loop);
            }
            return result;
        }
        return null;
    }

    this.link = (link) => {
        if (IS.stringNotEmpty(link)) {
            if (IS.url(link)) {
                return link;
            } else {
                if (link === '/s/') {
                    link = '/';
                }
                if (link.indexOf('/s/') !== -1) {
                    link = link.replace('/s/', '/');
                }
                if (link[0] !== '/') {
                    link = `/${link}`;
                }
                if (link.indexOf(`/${this.communityBasePath}/`) === -1) {
                    link = `${this.communityBasePath}${link}`;
                }
                if (link.indexOf('/login/') !== -1) {
                    link = link.replace('/login/', '/');
                }
                return link;
            }
        }
        return this.communityBasePath;
    }

    this.cmsLink = (cmsId) => {
        if (IS.stringNotEmpty(cmsId)) {
            let link = `${this.communityBasePath}/sfsites/c/cms/delivery/media/${cmsId}`;
            if (link.indexOf('/login/') !== -1) {
                link = link.replace('/login/', '/');
            }
            return link;
        }
        return null;
    }

    this.cmsImage = (link) => {
        if (
            IS.stringNotEmpty(link) &&
            !IS.stringIncludes(link, '/img/b2b/default-product-image.svg')
        ) {
            if (
                !IS.url(link) &&
                IS.stringIncludes(link, '/cms/delivery/media/')
            ) {
                try {
                    let id = link.split('?')[0].split('/').reverse()[0];
                    if (IS.stringNotEmpty(id)) {
                        return this.cmsLink(id);
                    } else {
                        throw 'Id is not parsed';
                    }
                } catch (error) {
                    console.error(error);
                    return link;
                }
            }
            return link;
        }
        return null;
    }

    this.random = {
        integer: RANDOM.integer,
        componentId: RANDOM.componentId,
    };

    this.wrapper = (componentName) => {
        if (IS.stringNotEmpty(componentName)) {
            return `${componentName}__wrapper`;
        }
        return null;
    }

    this.wrapperId = (componentName, componentId) => {
        if (IS.stringNotEmpty(componentName)) {
            return `${componentName}__${componentId || this.random.componentId()}`;
        }
        return null;
    }

    this.responseData = (response) => {
        if (
            IS.objectNotEmpty(response) &&
            IS.objectProperty(response, STATUS_KEY) &&
            IS.true(response[STATUS_KEY]) &&
            IS.objectProperty(response, DATA_KEY) &&
            (
                IS.boolean(response[DATA_KEY]) ||
                IS.numeric(response[DATA_KEY]) ||
                IS.stringNotEmpty(response[DATA_KEY]) ||
                IS.arrayNotEmpty(response[DATA_KEY]) ||
                IS.objectNotEmpty(response[DATA_KEY])
            )
        ) {
            return response[DATA_KEY];
        }
        return null;
    }

    this.responseSuccess = (response) => {
        if(
            IS.objectNotEmpty(response)
            && (
                (
                    IS.objectProperty(response, STATUS_KEY)
                    && IS.true(response[STATUS_KEY])
                )
                || (
                    IS.objectProperty(response, MESSAGE_KEY)
                    && IS.stringNotEmpty(response[MESSAGE_KEY])
                    && response[MESSAGE_KEY].toLowerCase() === SUCCESS
                )
            )
        ) {
            return true;
        }
        return false;
    }

    this.textAlign = (align) => {
        if (IS.stringNotEmpty(align)) {
            align = align.toLowerCase();
            if ([LEFT, CENTER, RIGHT].indexOf(align) !== -1) {
                return align;
            }
        }
        return null;
    }

    this.justifyContent = (align) => {
        if (IS.stringNotEmpty(align)) {
            align = align.toLowerCase();
            if (align === LEFT) {
                return 'flex-start';
            } else if (align === CENTER) {
                return 'center';
            } else if (align === RIGHT) {
                return 'flex-end';
            }
        }
        return null;
    }

    this.alignItems = (align) => {
        if (IS.stringNotEmpty(align)) {
            align = align.toLowerCase();
            if (align === TOP) {
                return 'flex-start';
            } else if (align === MIDDLE) {
                return 'center';
            } else if (align === BOTTOM) {
                return 'flex-end';
            } else if (align === STRETCH) {
                return 'stretch';
            }
        }
        return null;
    }

    this.prepareUrlParams = (params) => {
        let paramsString = null;
        if (IS.objectNotEmpty(params)) {
            let paramArr = [];
            Object.keys(params).forEach((key) => {
                if (IS.stringNotEmpty(key) && IS.stringNotEmpty(params[key])) {
                    paramArr.push(`${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`);
                }
            });
            if (IS.arrayNotEmpty(paramArr)) {
                paramsString = `?${paramArr.join('&')}`;
            }
        }
        return paramsString;
    }

    this.addUrlParams = (params) => {
        if (history.pushState) {
            let baseUrl = window.location.protocol + '//' + window.location.host + window.location.pathname;
            let paramsString = this.prepareUrlParams(params);
            history.pushState(null, null, `${baseUrl}${IS.stringNotEmpty(paramsString) ? paramsString : ''}`);
        } else {
            console.warn('History API is not supported');
        }
    }

    this.getUrlParams = (string) => {
        let params = {};
        let search = string || window.location.search;

        if (IS.stringNotEmpty(search)) {
            if (search[0] === '?') {
                search = search.slice(1);
            }

            let paramsArr = search.split('&');
            if (IS.arrayNotEmpty(paramsArr)) {
                paramsArr.forEach((item) => {
                    let paramArr = item.split('=');
                    params[decodeURIComponent(paramArr[0])] = decodeURIComponent(paramArr[1]);
                });
            }
        }

        return params;
    }

    this.doRequest = async (method, params) => {
        let response = null;
        if (IS.function(method)) {
            await method(IS.objectNotEmpty(params) ? params : {})
                .then((result) => {
                    response = result;
                })
                .catch((error) => {
                    let fetchErrorResponse = this.parseFetchErrorResponse(error);
                    response = IS.objectNotEmpty(fetchErrorResponse)
                        ? fetchErrorResponse
                        : error;
                });
        }
        if (!this.responseSuccess(response)) {
            console.error(response);
        }
        return response;
    }

    this.getInlineAddressString = (options) => {
        // options = {
        //     street: '',
        //     city: '',
        //     state: '',
        //     stateCode: '',
        //     postalCode: '',
        //     country: '',
        //     countryCode: '',
        // };
        if (!IS.objectNotEmpty(options)) return null;

        let result = [];
    
        if (IS.stringNotEmpty(options.street)) result.push(options.street);
        if (IS.stringNotEmpty(options.city)) result.push(options.city);

        if (
            IS.stringNotEmpty(options.state) ||
            IS.stringNotEmpty(options.stateCode) ||
            IS.stringNotEmpty(options.postalCode)
        ) {
            let resultArr = [];
            if (IS.stringNotEmpty(options.state)) {
                resultArr.push(options.state);
            } else if (IS.stringNotEmpty(options.stateCode)) {
                resultArr.push(options.stateCode);
            }
            if (IS.stringNotEmpty(options.postalCode)) resultArr.push(options.postalCode);
            result.push(resultArr.join(' '));
        }

        if (IS.stringNotEmpty(options.country)) {
            result.push(options.country);
        } else if (IS.stringNotEmpty(options.countryCode)) {
            result.push(options.countryCode);
        }
    
        return IS.arrayNotEmpty(result) ? result.join(', ') : null;
    }

    this.dispatchEvent = (that, name, detail, options) => {
        if (!IS.stringNotEmpty(name)) return;

        that.dispatchEvent(
            new CustomEvent(name, {
                detail,
                bubbles: IS.objectProperty(options, 'bubbles') && IS.true(options.bubbles)
                    ? true
                    : false,
                composed: IS.objectProperty(options, 'composed') && IS.true(options.composed)
                    ? true
                    : false,
            })
        );
    }

    this.parseOptions = (array) => {
        let result = [];
        if (IS.arrayNotEmpty(array)) {
            array.forEach((item) => {
                if (
                    IS.stringNotEmpty(item.label) &&
                    IS.stringNotEmpty(item.value)
                ) {
                    result.push({
                        label: item.label,
                        value: item.value,
                    });
                }
            });
        }
        return result;
    }

    // Working in aura theme
    this.updateCartQuantity = (that) => {
        this.dispatchEvent(that, CART_CHANGED, null, {
            bubbles: true,
            composed: true
        });
    }

    // TODO: need to replace all updateCartQuantity() to this method
    this.updateCartQuantityLWR = async (productId, productQuantity) => {
        productQuantity = Number(productQuantity);
        if (IS.stringNotEmpty(productId) && IS.integer(productQuantity)) {
            return await updateItemInCart(productId, productQuantity);
        }
        return false;
    }

    this.deleteItemFromCartLWR = async (itemId) => {
        if (IS.stringNotEmpty(itemId)) {
            return await deleteItemFromCart(itemId);
        }
    }

    this.refreshCartLWR = async () => {
        return await deleteItemFromCart(null);
    }

    this.navigateTo = (path) => {
        if (IS.stringNotEmpty(path)) {
            window.location.href = `${window.location.origin}${this.link(path)}`;
        }
    }

    this.parseVideosString = (str, separator) => {
        let result = [];
        if (IS.stringNotEmpty(str) && IS.stringNotEmpty(separator)) {
            let videosArr = str.split(separator);
            if (IS.arrayNotEmpty(videosArr)) {
                videosArr.forEach((item) => {

                    // YOUTUBE EMBED
                    if (
                        IS.stringIncludes(item, 'youtube')
                        && IS.stringIncludes(item, '/embed/')
                    ) {
                        result.push(item);

                    // YOUTUBE
                    } else if (
                        IS.stringIncludes(item, 'youtube')
                        && IS.stringIncludes(item, '/watch')
                    ) {
                        let params = this.getUrlParams(item.split('?')[1]);
                        if (IS.objectNotEmpty(params) && IS.stringNotEmpty(params.v)) {
                            result.push(`https://www.youtube.com/embed/${params.v}`);
                        }

                    // YOUTU.BE
                    } else if (IS.stringIncludes(item, 'youtu.be')) {
                        let id = item.split('youtu.be/').reverse()[0];
                        if (IS.stringNotEmpty(id)) {
                            result.push(`https://www.youtube.com/embed/${id}`);
                        }

                    // VIMEO PLAYER
                    } else if (
                        IS.stringIncludes(item, 'player.vimeo')
                        && IS.stringIncludes(item, '/video/')
                    ) {
                        let id = item.split('?')[0].split('/').reverse()[0];
                        if (IS.stringNotEmpty(id)) {
                            result.push(`https://player.vimeo.com/video/${id}`);
                        }

                    // VIMEO
                    } else if (item.indexOf('vimeo') !== -1) {
                        let id = item.split('/').reverse()[0];
                        if (IS.stringNotEmpty(id)) {
                            result.push(`https://player.vimeo.com/video/${id}`);
                        }
                    }
                });
            }
        }
        return IS.arrayNotEmpty(result) ? result : null;
    }

    this.prepareLabel = (str, values) => {
        if (IS.stringNotEmpty(str) && IS.arrayNotEmpty(values)) {
            let newStr = `${str}`;
            values.forEach((item, index) => {
                let newRegexp = new RegExp(`\\{${index}\\}`);
                newStr = newStr.replace(newRegexp, item);
            });
            return IS.stringNotEmpty(newStr) ? newStr : null;
        }
        return IS.stringNotEmpty(str) ? str : null;
    }

    this.generateCssVar = (prefix, key, value) => {
        if (
            IS.stringNotEmpty(prefix) &&
            IS.stringNotEmpty(key) &&
            (
                IS.stringNotEmpty(value) ||
                IS.numeric(value)
            )
        ) {
            return `--b2b-${prefix}-${key}: ${value};`;
        }
        return '';
    }

    this.isBuilder = () => {
        let result = false;
        if (IS.arrayNotEmpty(BUILDER_POSTFIX)) {
            BUILDER_POSTFIX.forEach((item) => {
                if (IS.stringIncludes(window.location.origin, item)) {
                    result = true;
                }
            });
        }
        return result;
    }

    // Necessary use asyns / await
    this.getEffectiveAccountId = async () => {
        let result = DEFAULT_EFFECTIVE_ACCOUNT_ID;
        await getSessionContext()
            .then((response) => {
                // response: {
                //     effectiveAccountId: string
                //     effectiveAccountName: string
                //     isAnonymousPreview: boolean
                //     isLoggedIn: boolean
                //     isPreview: boolean
                //     userId: string
                //     userName: string
                // }
                if (
                    IS.objectNotEmpty(response)
                    && IS.stringNotEmpty(response.effectiveAccountId)
                    && IS.true(response.isLoggedIn)
                ) {
                    result = response.effectiveAccountId;
                }
            })
            .catch((error) => {
                console.error(error);
            });
        return result;
    }

    /**
    * @description return next properties:
    * effectiveAccountId: string
    * effectiveAccountName: string
    * isAnonymousPreview: boolean
    * isLoggedIn: boolean
    * isPreview: boolean
    * userId: string
    * userName: string
    **/
    this.getSessionContext = async () => {
        let result = null;
        await getSessionContext()
            .then((response) => {
                result = response;
            })
            .catch((error) => {
                console.error(error);
            });
        return result;
    }

    this.addItemToCart = async (productId, quantity) => {
        let result = null;
        await addItemToCart(productId, quantity)
            .then((response) => {
                result = response;
            })
            .catch((error) => {
                console.error(error);
            });
        return result;
    }

    this.addItemToCart2 = async (productId, quantity) => {
        let result = {
            [STATUS_KEY]: false,
            [DATA_KEY]: null,
            [MESSAGE_KEY]: null
        };

        await addItemToCart(productId, quantity)
            .then((response) => {
                if (response) {
                    result[STATUS_KEY] = true;
                }
                result[DATA_KEY] = response;
            })
            .catch((error) => {
                console.error(error);
                result[DATA_KEY] = error;
                result[MESSAGE_KEY] = IS.stringNotEmpty(error.message) ? error.message : null;
            });
        return result;
    }

    /**
     * @param {object} products - List of products where the key is the product ID
     * and the value is the quantity
     * @returns {B2BResponse} 
     */
    this.addItemsToCart = async (products) => {
        let result = {
            [STATUS_KEY]: false,
            [DATA_KEY]: null,
            [MESSAGE_KEY]: null
        };
        await addItemsToCart(products)
            .then((response) => {
                if (IS.false(response.hasErrors)) {
                    result[STATUS_KEY] = true;
                    if (IS.arrayNotEmpty(response.results)) {
                        result[DATA_KEY] = [];
                        response.results.forEach((item) => {
                            result[DATA_KEY].push(item.result);
                        });
                    }
                } else {
                    console.error(response);
                    result[DATA_KEY] = response;
                }
            })
            .catch((error) => {
                console.error(error);
                result[DATA_KEY] = error;
                result[MESSAGE_KEY] = IS.stringNotEmpty(error.message) ? error.message : null;
            });
        return result;
    }

    this.scrollToTop = () => {
        window.scrollTo(0, 0);
    }

    getBase64 = async (file) => {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = () => {
                resolve(reader.result);
            };
            reader.onerror = (error) => {
                reject(error)
            };
        });
    };

    this.readFile = async (file, type) => {
        let result = {
            [STATUS_KEY]: false,
            [DATA_KEY]: null,
            [MESSAGE_KEY]: null
        };

        try {
            if (!IS.stringNotEmpty(type)) {
                type = BASE_64;
            }

            if (file) {
                if (type === BASE_64) {
                    await getBase64(file)
                        .then((response) => {
                            result[DATA_KEY] = response;
                        })
                        .catch((error) => {
                            throw error;
                        });
                }
                result[STATUS_KEY] = true;
            }
        } catch(error) {
            result[DATA_KEY] = error;
            console.error(error);
        }
        return result;
    };

    this.getSessionContext = async () => {
        let result = null;
        await getSessionContext()
            .then((response) => {
                if (IS.objectNotEmpty(response)) {
                    result = response;
                }
            })
            .catch((error) => {
                console.error(error);
            });
        return result;
    };

    let DIGITS = '0123456789abcdef';
    let HEX_BASE = 16;
    this.encodeMessage = (input, MODULE, PUBLIC_EXPONENT) => {
        let pnDec = this.hexToDecimal(this.convertToHex(input));
        let modDec = this.hexToDecimal(MODULE);
        let expDec = this.hexToDecimal(PUBLIC_EXPONENT);

        let result = this.modPow(pnDec, expDec, modDec);

        let hexResult = this.decimalToHex(result);

        if ((hexResult.length & 1) === 1) {
            hexResult = '0' + hexResult;
        }

        return hexResult;
    }

    this.convertToHex = (input) => {
        let result = '';
        for (let i = 0; i < input.length; i++) {
            let charCode = input[i].charCodeAt();
            result += charCode.toString(16);
        }

        return result;
    }

    this.decimalToHex = (d) => {
        let hex = '';
        while (d > 0) {
            let digit = this.modulus(d, BigInt(HEX_BASE));
            hex = DIGITS.substring(digit, digit + 1) + hex;
            d = this.div(d,16n);
        }

        return hex;
    }

    this.modulus = (dividend, divisor) => {
        let d = this.div(dividend, divisor);
        return Number(dividend - (d * divisor));
    }

    this.div = (val, by) => {
        return (val - val % by) / by;
    }

    this.hexToDecimal = ( hex ) => {
        let result = BigInt(0);
        let length = hex.length;
        let i = 0;
        while(i < length) {
            let hexByte = DIGITS.indexOf(hex.substring(i, i + 1).toLowerCase());
            i++;
            let pow = length - i === 0 ? BigInt(1) : BigInt(HEX_BASE);

            for (let j = 1; j < length - i; j++) {
                pow *= BigInt(HEX_BASE);
            }

            result += BigInt(hexByte) * pow;
        }

        return result;
    }

     this.modPow = (x, e, N) => {
        var r = 1n, base = x % N;
        while (e > 0) {
            if (base == 0n) return 0n;
            if ((e & 1n) === 1n) r = (r * base) % N;
            e = e >> 1n;
            base = (base * base) % N;
        }
        return r;
    }

    this.BROWSER_OPERA = 'Opera';
    this.BROWSER_CHROME = 'Chrome';
    this.BROWSER_INTERNET_EXPLORER = 'Internet Explorer';
    this.BROWSER_FIREFOX = 'Firefox';
    this.BROWSER_SAFARI = 'Safari';
    this.NO_BROWSER_DETECTION = 'No Browser Detection';

    this.isBrowserFirefox = () => {
        return this.getBrowserName() === this.BROWSER_FIREFOX;
    }

    this.getBrowserName = () => {
        let browserName = this.NO_BROWSER_DETECTION;
        if (navigator && navigator.userAgent) {
            let userAgent = navigator.userAgent;
            if (userAgent.indexOf("OP") > -1) {
                browserName = this.BROWSER_OPERA;
            } else if (userAgent.indexOf('Chrome') > -1) {
                browserName = this.BROWSER_CHROME;
            } else if (userAgent.indexOf('Firefox') > -1) {
                browserName = this.BROWSER_FIREFOX;
            } else if (userAgent.indexOf('Safari') > -1) {
                browserName = this.BROWSER_SAFARI;
            } else if (userAgent.indexOf('MSIE') > -1 || userAgent.indexOf('rv:') > -1) {
                browserName = this.BROWSER_INTERNET_EXPLORER;
            }
        }

        return browserName;
    }
}

const UTILS = new Utils();
export { UTILS, IS, DISPATCHER, STORAGE, TOAST, MOCK };