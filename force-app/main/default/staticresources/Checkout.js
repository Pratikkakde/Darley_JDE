// Code downloaded from: https://static-na.payments-amazon.com/checkout.js

// Changes added to the original code for using in the LWC components:
// 1. Commented code in the line 498.
// 2. Added code in the line 499.

this.checkout = this.checkout || {}, this.checkout.js = function(t) {
    "use strict";

    function n(t, n) {
        if (0 == t.length) return [];
        for (var e = [], o = 0; o < t.length; o++) {
            var a = t[o];
            n(a) && e.push(a)
        }
        return e
    }

    function e(t, n) {
        if (0 == t.length) return !1;
        for (var e = 0; e < t.length; e++) {
            if (n(t[e])) return !0
        }
        return !1
    }

    function o(t, n, e, o) {
        void 0 === o && (o = !1);
        var a = "",
            i = o ? "; secure" : "";
        if (e) {
            var r = new Date;
            r.setTime(r.getTime() + 24 * e * 60 * 60 * 1e3), a = "; expires=" + r.toUTCString()
        }
        document.cookie = t + "=" + n + a + "; path=/" + i
    }

    function a(t) {
        for (var n = t + "=", e = document.cookie.split(";"), o = 0; o < e.length; o++) {
            for (var a = e[o];
                " " == a.charAt(0);) a = a.substring(1, a.length);
            if (0 == a.indexOf(n)) return a.substring(n.length, a.length)
        }
        return null
    }

    function i(t) {
        return null == t
    }
    var r, u = (r = i, function(t) {
        return !r(t)
    });

    function s(t) {
        var n = ["originDomain", "returnDomain"];
        return Object.keys(t).map(function(e) {
            if (i(t[e])) return null;
            return e + "=" + (n.indexOf(e) > -1 ? t[e] : encodeURIComponent(t[e]))
        }).filter(u).join("&")
    }

    function c(t) {
        try {
            var n = document.createElement("a");
            n.href = t;
            var e = n.origin;
            return e || n.protocol && n.hostname && -1 != (e = n.protocol + "//" + n.hostname + (n.port ? ":" + n.port : "")).search(/:443/) && (e = e.replace(":443", "")), !e || "null" != e && "file://" != e ? e : null
        } catch (t) {
            return null
        }
    }

    function d() {
        return void 0 !== performance && void 0 !== performance.getEntries && void 0 !== performance.getEntriesByName
    }

    function l(t, n) {
        return String.prototype.startsWith || Object.defineProperty(String.prototype, "startsWith", {
            value: function(t, n) {
                var e = n > 0 ? 0 | n : 0;
                return this.substring(e, e + t.length) === t
            }
        }), t.startsWith(n)
    }

    function m(t) {
        return null == t || "object" == typeof t && 0 === Object.keys(t).length || "string" == typeof t && 0 === t.trim().length
    }
    var b = function() {
            return (b = Object.assign || function(t) {
                for (var n, e = 1, o = arguments.length; e < o; e++)
                    for (var a in n = arguments[e]) Object.prototype.hasOwnProperty.call(n, a) && (t[a] = n[a]);
                return t
            }).apply(this, arguments)
        },
        f = "AmazonPay:";

    function y(t) {
        throw f + "\n" + t
    }
    var h = "tiab1y2",
        p = "ACTIVE",
        _ = "language",
        g = "ledgerCurrency",
        v = "checkout.js",
        L = "maxo-button-render-start",
        E = "maxo-web-components-render-finish",
        S = "maxo-iframe-button-render-finish",
        A = "maxo-redirect-start",
        w = "maxo-redirect-finish",
        C = "maxo-button-render-measure",
        I = "apay-button-redirect-time",
        G = "maxo-button",
        x = "amazonpay-button-parent-container-checkout",
        T = ["merchantId", "ledgerCurrency", "placement"],
        k = "/checkout/initiate",
        z = "/checkout/initiate_auth",
        O = "/checkout/lwaPreAuthError",
        P = "D0000",
        D = "C0001",
        B = "default",
        M = "custom",
        N = "Gold",
        U = [N, "LightGray", "DarkGray"],
        R = "SignIn",
        j = "signin",
        J = "signInConfig",
        K = "createCheckoutSessionConfig",
        H = "div[data-amazonpay-merchant-id]",
        F = "amazonpay-checkoutbutton-container-",
        Y = "MAXO_MODALVIEW",
        X = "CV2_DISABLED_TOOLTIP",
        q = "redirectView",
        W = "modalView",
        V = "apay-session-set",
        Z = "SANDBOX-",
        Q = "LIVE-",
        $ = "animate-chevron",
        tt = "amazonpay-button-disabled",
        nt = "T1",
        et = "signature-button-session-config",
        ot = "signature-button-empty-object",
        at = "signature-button-redirect",
        it = {
            buttonColor: N,
            productType: "PayAndShip",
            sandbox: !1,
            publicKeyIdMismatch: !1,
            design: P,
            scopes: [],
            publicKeyId: "",
            estimatedOrderAmount: {},
            alwaysRedirect: !1
        },
        rt = {
            en: "en_US",
            fr: "fr_FR",
            it: "it_IT",
            es: "es_ES",
            de: "de_DE",
            ja: "ja_JP",
            "en-us": "en_US",
            "en-gb": "en_GB",
            "fr-fr": "fr_FR",
            "it-it": "it_IT",
            "es-es": "es_ES",
            "de-de": "de_DE",
            "ja-jp": "ja_JP"
        },
        ut = "https://m.media-amazon.com/images/G/",
        st = {
            NA: "01",
            EU: "02",
            FE: "09"
        },
        ct = {
            en_US: "NA",
            en_GB: "EU",
            de_DE: "EU",
            ja_JP: "FE",
            fr_FR: "EU",
            it_IT: "EU",
            es_ES: "EU"
        },
        dt = {
            Home: "default_button",
            Product: "product_button",
            Cart: "default_button",
            Checkout: "default_button",
            Other: "default_button"
        },
        lt = {
            Gold: "amazonpay-button-view1-gold",
            LightGray: "amazonpay-button-view1-gray",
            DarkGray: "amazonpay-button-view1-ink"
        },
        mt = "/AmazonPay/Maxo/logo._CB452516594_.svg",
        bt = "/AmazonPay/Maxo/sandbox_icon._CB452516595_.svg",
        ft = "/AmazonPay/Maxo/AmazonPay_button_chevron._CB1558391205_.svg",
        yt = "/AmazonPay/Maxo/Button-SignIn-ProductPage-en_US.svg",
        ht = "/AmazonPay/Maxo/logo-amazonpay-gray_scalable._CB1582942856_.svg",
        pt = "/AmazonPay/Maxo/logo-amazonpay-ink-scalable._CB1198675309_.svg",
        _t = {
            en_US: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            en_GB: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            de_DE: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            ja_JP: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            fr_FR: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            it_IT: "/AmazonPay/Maxo/logo._CB452516594_.svg",
            es_ES: "/AmazonPay/Maxo/logo._CB452516594_.svg"
        },
        gt = {
            en_US: ht,
            en_GB: ht,
            de_DE: ht,
            ja_JP: ht,
            fr_FR: ht,
            it_IT: ht,
            es_ES: ht
        },
        vt = {
            en_US: pt,
            en_GB: pt,
            de_DE: pt,
            ja_JP: pt,
            fr_FR: pt,
            it_IT: pt,
            es_ES: pt
        },
        Lt = {
            Gold: {
                product_button: {
                    C0001: {
                        en_US: "/AmazonPay/Maxo/Button-Shopify-ProductPg-en_US._CB1575503625_.svg",
                        en_GB: "/AmazonPay/Maxo/Button-Shopify-ProductPg-en_GB._CB446302581_.svg",
                        de_DE: "/AmazonPay/Maxo/Button-Shopify-ProductPg-de_DE._CB1575508532_.svg",
                        ja_JP: "/AmazonPay/Maxo/Button-Shopify-ProductPg-jp_JP._CB446302411_.svg",
                        fr_FR: "/AmazonPay/Maxo/Button-Shopify-ProductPg-fr_FR._CB1198675309_.svg",
                        it_IT: "/AmazonPay/Maxo/Button-Shopify-ProductPg-it_IT._CB446302291_.svg",
                        es_ES: "/AmazonPay/Maxo/Button-Shopify-ProductPg-es_ES._CB1198675309_.svg"
                    },
                    D0000: _t
                },
                default_button: {
                    C0001: _t,
                    D0000: _t
                }
            },
            LightGray: {
                product_button: {
                    D0000: gt
                },
                default_button: {
                    D0000: gt
                }
            },
            DarkGray: {
                product_button: {
                    D0000: vt
                },
                default_button: {
                    D0000: vt
                }
            }
        },
        Et = {
            Gold: {
                en_US: "/AmazonPay/Maxo/Button-SignIn-ProductPage-en_US.svg",
                en_GB: "/AmazonPay/Maxo/Button-SignIn-ProductPage-en_GB.svg",
                de_DE: "/AmazonPay/Maxo/Button-SignIn-ProductPage-de_DE.svg",
                ja_JP: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ja_JP.svg",
                fr_FR: "/AmazonPay/Maxo/Button-SignIn-ProductPage-fr_FR.svg",
                it_IT: "/AmazonPay/Maxo/Button-SignIn-ProductPage-it_IT.svg",
                es_ES: "/AmazonPay/Maxo/Button-SignIn-ProductPage-es_ES.svg"
            },
            LightGray: {
                en_US: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-en_US.svg",
                en_GB: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-en_GB.svg",
                de_DE: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-de_DE.svg",
                ja_JP: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-ja_JP.svg",
                fr_FR: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-fr_FR.svg",
                it_IT: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-it_IT.svg",
                es_ES: "/AmazonPay/Maxo/Button-SignIn-ProductPage-gray-es_ES.svg"
            },
            DarkGray: {
                en_US: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-en_US.svg",
                en_GB: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-en_GB.svg",
                de_DE: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-de_DE.svg",
                ja_JP: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-ja_JP.svg",
                fr_FR: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-fr_FR.svg",
                it_IT: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-it_IT.svg",
                es_ES: "/AmazonPay/Maxo/Button-SignIn-ProductPage-ink-es_ES.svg"
            }
        },
        St = {
            Gold: "/AmazonPay/Maxo/AmazonPay_button_chevron._CB1558391205_.svg",
            LightGray: "/AmazonPay/Maxo/AmazonPay_button_chevron._CB1558391205_.svg",
            DarkGray: "/AmazonPay/Maxo/button-v2-chevrons-white_scaled_1._CB1582929584_.svg"
        },
        At = {
            en_US: "/AmazonPay/Maxo/mt-en_us._CB1558571088_.svg",
            en_GB: "/AmazonPay/Maxo/mt-en_gb._CB1558571088_.svg",
            de_DE: "/AmazonPay/Maxo/mt-de_de._CB1558571088_.svg",
            ja_JP: "/AmazonPay/Maxo/mt-ja_jp._CB1568869902_.svg",
            fr_FR: "/AmazonPay/Maxo/mt-fr_fr._CB1558571088_.svg",
            it_IT: "/AmazonPay/Maxo/mt-it_it._CB1558571088_.svg",
            es_ES: "/AmazonPay/Maxo/mt-es_es._CB1558571088_.svg"
        };

    function wt(t, n) {
        return "" + ut + st[ct[n]] + t
    }
    var Ct = {
            en_US: "Amazon Pay - Use your Amazon Pay Sandbox test account",
            en_GB: "Amazon Pay - Use your Amazon Pay Sandbox test account",
            de_DE: "Amazon Pay - Verwenden Sie Ihr Amazon Pay-Sandbox-Testkonto",
            ja_JP: "Amazon Pay - Amazon Payãƒ†ã‚¹ãƒˆã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ãŠä½¿ã„ãã ã•ã„",
            fr_FR: "Amazon Pay - Utilisez votre compte test Amazon Pay",
            it_IT: "Amazon Pay - Usa il tuo account di prova Sandbox Amazon Pay",
            es_ES: "Amazon Pay - Usa tu cuenta de prueba de Sandbox de Amazon Pay"
        },
        It = {
            en_US: "Amazon Pay - Use your Amazon account",
            en_GB: "Amazon Pay - Use your Amazon account",
            de_DE: "Amazon Pay - Verwenden Sie Ihr Amazon-Konto",
            ja_JP: "Amazon Pay - Amazonã‚¢ã‚«ã‚¦ãƒ³ãƒˆã‚’ãŠä½¿ã„ãã ã•ã„",
            fr_FR: "Amazon Pay - Utilisez votre compte Amazon",
            it_IT: "Amazon Pay - Usa il tuo account Amazon",
            es_ES: "Amazon Pay - Usa tu cuenta de Amazon"
        },
        Gt = {
            en_US: "Amazon Pay is currently not available on this site. Try a different payment option.",
            en_GB: "Amazon Pay is currently not available on this site. Try a different payment option.",
            de_DE: "Amazon Pay ist auf dieser Website derzeit nicht verfÃ¼gbar. Versuchen Sie es mit einer anderen Zahlungsart.",
            ja_JP: "ç¾åœ¨ã€AmazonPayã¯ã“ã®ã‚µã‚¤ãƒˆã§ã¯ã”åˆ©ç”¨ã„ãŸã ã‘ã¾ã›ã‚“ã€‚åˆ¥ã®æ”¯æ‰•ã„æ–¹æ³•ã‚’ãŠè©¦ã—ãã ã•ã„ã€‚",
            fr_FR: "Amazon Pay 'est pas disponible actuellement sur ce site. Essayez une autre option de paiement",
            it_IT: "Amazon Pay non Ã¨ attualmente disponibile su questo sito. Prova un'altra opzione di pagamento.",
            es_ES: "Amazon Pay no estÃ¡ disponible actualmente en este sitio. Prueba con una opciÃ³n de pago diferente."
        },
        xt = {
            en_US: "Pay using the information already stored in your Amazon account",
            en_GB: "Pay using the information already stored in your Amazon account",
            de_DE: "Nutzen Sie zum Bezahlen die Angaben, die Sie bereits in Ihrem Amazon-Konto gespeichert haben",
            ja_JP: "Amazonã‚¢ã‚«ã‚¦ãƒ³ãƒˆã«ç™»éŒ²ã•ã‚Œã¦ã„ã‚‹æƒ…å ±ã‚’åˆ©ç”¨ã—ã¦ãŠæ”¯æ‰•ã„",
            fr_FR: "Payez en ligne grÃ¢ce aux informations dÃ©jÃ  enregistrÃ©es dans votre compte Amazon",
            it_IT: "Paga usando i dati giÃ  presenti nel tuo account Amazon",
            es_ES: "Paga usando la informaciÃ³n que ya tienes guardada en tu cuenta de Amazon"
        },
        Tt = {
            en_US: "Sign in to your Amazon account",
            en_GB: "Sign in to your Amazon account",
            de_DE: "Melden Sie sich in Ihrem Amazon-Konto an",
            ja_JP: "Amazon ã‚¢ã‚«ã‚¦ãƒ³ãƒˆã§ãƒ­ã‚°ã‚¤ãƒ³",
            fr_FR: "Connectez-vous Ã  votre compte Amazon",
            it_IT: "Accedi al tuo account Amazon",
            es_ES: "Inicia sesiÃ³n en tu cuenta de Amazon"
        },
        kt = {
            EUR: 2,
            GBP: 2,
            AUD: 2,
            DKK: 2,
            HKD: 2,
            JPY: 0,
            NZD: 2,
            NOK: 2,
            ZAR: 2,
            SEK: 2,
            CHF: 2,
            USD: 2
        },
        zt = {
            apchsHost: "https://apay-us.amazon.com",
            defaultAuthUIHost: "https://apay-us.amazon.com",
            authUIHostByLang: {
                en_US: "https://apay-us.amazon.com",
                en_GB: "https://payments.amazon.co.uk",
                it_IT: "https://payments.amazon.it",
                de_DE: "https://payments.amazon.de",
                es_ES: "https://payments.amazon.es",
                fr_FR: "https://payments.amazon.fr",
                ja_JP: "https://payments.amazon.co.jp"
            },
            microTextVersion: {
                it_it: "_CB1558571088_",
                de_de: "_CB1558571088_",
                es_es: "_CB1558571088_",
                fr_fr: "_CB1558571088_",
                en_us: "_CB1558571088_",
                en_gb: "_CB440556592_",
                ja_jp: "_CB1568869902_"
            },
            coe: {
                USD: "US",
                EUR: "DE",
                GBP: "UK",
                JPY: "JP"
            },
            regionCode: "01",
            allowedLedgerCurrencies: "USD",
            domainFallbackLanguage: "en_US",
            allowedCheckoutLanguages: "en_US",
            supportedBrowserLanguages: "en,en-us",
            boltDomain: "https://connect.bolt.com",
            allowedCurrencyCodes: "USD"
        },
        Ot = !!HTMLElement.prototype.attachShadow,
        Pt = {
            checkoutLanguage: zt.allowedCheckoutLanguages.split(","),
            color: ["Gold"],
            ledgerCurrency: zt.allowedLedgerCurrencies.split(","),
            productType: ["PayAndShip", "PayOnly", "SignIn", "Donation"],
            placement: ["Home", "Product", "Cart", "Checkout", "Other"],
            sandbox: [!0, !1]
        },
        Dt = zt.allowedCurrencyCodes.split(","),
        Bt = 800,
        Mt = 670;

    function Nt(t, n) {
        void 0 === n && (n = "");
        var e = window.innerWidth / 2 - Bt / 2 + window.screenLeft,
            o = window.innerHeight / 2 - Mt / 2 + window.screenTop + (window.innerHeight - Mt) / 2,
            a = t + (new Date).getTime(),
            i = "toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=" + Bt + ", height=" + Mt + ",top=" + o + ",left=" + e,
            r = window.open(n, a, i);
        return window.focus && r && r.focus(), r
    }

    function Ut(t, n) {
        var e;
        (i(e = t[n]) || "" === e) && y("Missing field " + n + " in the options object in amazon.Pay.bindChangeAction(selector, options) API.")
    }

    function Rt(t, n) {
        return "GBP" === t ? zt.authUIHostByLang.en_GB : n ? "en_GB" === n ? zt.authUIHostByLang.de_DE : zt.authUIHostByLang[n] : zt.defaultAuthUIHost
    }

    function jt(t) {
        var n = c(t);
        if (n && n.toLowerCase() === zt.boltDomain.toLowerCase()) try {
            var e = new URL(document.referrer).searchParams.get("referrer");
            return e || t
        } catch (n) {
            return t
        }
        return t
    }

    function Jt(t) {
        var n = function() {
                var t = navigator.languages;
                if (i(t) && !i(navigator.language) && (t = [navigator.language]), !i(t))
                    for (var n = 0; n < t.length; n++)
                        if (zt.supportedBrowserLanguages.split(",").indexOf(t[n].toLowerCase()) > -1) return rt[t[n].toLowerCase()];
                return null
            }(),
            e = "" + zt.domainFallbackLanguage;
        return t || n || e
    }

    function Kt(t) {
        return t === D
    }

    function Ht(t, n) {
        return t === R || !i(n)
    }

    function Ft(t, n) {
        return Kt(n) ? N : t && U.indexOf(t) > -1 ? t : N
    }

    function Yt(t) {
        t.preventDefault(), t.stopPropagation()
    }

    function Xt(t) {
        return t && "T1" == t[Y]
    }

    function qt(t) {
        return t && "T1" == t[X]
    }

    function Wt(t) {
        return !!(t && t.shadowRoot && t.shadowRoot.children && t.shadowRoot.children[1]) && (t && t.shadowRoot && t.shadowRoot.children && t.shadowRoot.children[1].classList)
    }

    function Vt(t, n) {
        t || y(n)
    }

    function Zt(t, n, e) {
        Vt(n, "Missing 'selector' parameter in amazon.Pay." + t + "(selector, options) API."), Vt(e, "Missing 'options' parameter in amazon.Pay." + t + "(selector, options) API.");
        // var o = document.querySelector(n);
        var o = n;
        return Vt(o, "Can not find element " + n + " for amazon.Pay." + t + "."), {
            ele: o,
            options: e
        }
    }

    function Qt(t, n, e) {
        return i(t[n]) ? e && "function" == typeof e ? e(n) : "Missing parameter '" + n + "' in the options object." : null
    }

    function $t(t, n) {
        void 0 === n && (n = !1);
        var e, o, a, i, r = !0;
        if ("string" == typeof t) try {
            t = JSON.parse(t)
        } catch (t) {
            console.error("Estimated Order Amount in the payload is not in correct Json format."), r = !1
        }
        try {
            return n && console.log("Estimated order amount for sandbox is " + JSON.stringify(t)), !!(r && (a = t.amount, i = Number(a), !isNaN(Number(i)) && i > 0 || (console.error("Invalid value '" + a + "' for 'amount', please check again as only positive numbers are allowed."), 0)) && (e = t.currencyCode, o = Dt, o.includes(e) || (console.error("Invalid value '" + e + "' for 'currencyCode', please use from one of the available values: " + o), 0)) && function(t, n) {
                var e = kt[n],
                    o = t.toString().split(".");
                return e >= (o.length > 1 ? o[1].length : 0) || (console.error("Invalid value '" + t + "' for 'amount', please pass valid fractional digits for " + n), !1)
            }(t.amount, t.currencyCode))
        } catch (t) {
            return console.error("Something wrong while validating estimated order total"), !1
        }
    }

    function tn(t, n, e) {
        ! function(t, n) {
            var e = n.map(function(n) {
                return Qt(t, n)
            }).filter(u).join("\n");
            "" !== e && y(e)
        }(t, n),
        function(t, n) {
            var e = n.map(function(n) {
                var e = t[n],
                    o = !(-1 === T.indexOf(n)),
                    a = Pt[n] && Pt[n].indexOf(e) < 0,
                    r = o && a,
                    u = !i(e) && a;
                return r || u ? "Invalid value '" + e + "' for '" + n + "', please use one of the available values: " + Pt[n].join(", ") + "." : null
            }).filter(u).join("\n");
            "" !== e && y(e)
        }(t, e),
        function(t) {
            null != t.publicKeyId && "" == t.publicKeyId && y("Invalid value '' for 'publicKeyId', please check again.")
        }(t),
        function(t) {
            t.estimatedOrderAmount && !m(t.estimatedOrderAmount) && ($t(t.estimatedOrderAmount, t.sandbox) || delete t.estimatedOrderAmount)
        }(t)
    }

    function nn(t) {
        var n, e, o, a;
        null == t.sandbox ? (t.publicKeyId && l(t.publicKeyId, Z) || (null === (n = t.createCheckoutSessionConfig) || void 0 === n ? void 0 : n.publicKeyId) && l(null === (e = t.createCheckoutSessionConfig) || void 0 === e ? void 0 : e.publicKeyId, Z) || (null === (o = t.signInConfig) || void 0 === o ? void 0 : o.publicKeyId) && l(null === (a = t.signInConfig) || void 0 === a ? void 0 : a.publicKeyId, Z)) && (t.sandbox = !0) : function(t) {
            t.publicKeyId && (l(t.publicKeyId, Z) && !t.sandbox || l(t.publicKeyId, Q) && t.sandbox) && y("PublicKeyId '" + t.publicKeyId + "' does not match 'sandbox: " + t.sandbox + "'. Please check again. ")
        }(t)
    }

    function en(t) {
        t.publicKeyId && (t.createCheckoutSessionConfig && (null == t.createCheckoutSessionConfig.publicKeyId ? t.createCheckoutSessionConfig.publicKeyId = t.publicKeyId : t.createCheckoutSessionConfig.publicKeyId != t.publicKeyId && (t.publicKeyIdMismatch = !0)), t.signInConfig && (null == t.signInConfig.publicKeyId ? t.signInConfig.publicKeyId = t.publicKeyId : t.signInConfig.publicKeyId != t.publicKeyId && (t.publicKeyIdMismatch = !0)))
    }

    function on(t) {
        return b(b(b({}, it), t), {
            checkoutLanguage: Jt(t.checkoutLanguage)
        })
    }
    var an = {
        "live-custom-DarkGray-default_button-de_DE-tiab1y2.html": "31px3fO8ogL",
        "live-custom-DarkGray-default_button-en_GB-tiab1y2.html": "31D8kCnyX6L",
        "live-custom-DarkGray-default_button-en_US-tiab1y2.html": "31gBPBnhNwL",
        "live-custom-DarkGray-default_button-es_ES-tiab1y2.html": "31dge8knK1L",
        "live-custom-DarkGray-default_button-fr_FR-tiab1y2.html": "31zCZ6bRa7L",
        "live-custom-DarkGray-default_button-it_IT-tiab1y2.html": "31Z4OaJc9KL",
        "live-custom-DarkGray-default_button-ja_JP-tiab1y2.html": "31fEpPy74tL",
        "live-custom-DarkGray-product_button-de_DE-tiab1y2.html": "31HaMipfboL",
        "live-custom-DarkGray-product_button-en_GB-tiab1y2.html": "31uwv9Q8s+L",
        "live-custom-DarkGray-product_button-en_US-tiab1y2.html": "315eCuiL-8L",
        "live-custom-DarkGray-product_button-es_ES-tiab1y2.html": "31WSpwAhowL",
        "live-custom-DarkGray-product_button-fr_FR-tiab1y2.html": "31NgHewY0PL",
        "live-custom-DarkGray-product_button-it_IT-tiab1y2.html": "31ocKdB9N-L",
        "live-custom-DarkGray-product_button-ja_JP-tiab1y2.html": "31hWLveQkgL",
        "live-custom-Gold-default_button-de_DE-tiab1y2.html": "31uyID479LL",
        "live-custom-Gold-default_button-en_GB-tiab1y2.html": "315ylz8kLOL",
        "live-custom-Gold-default_button-en_US-tiab1y2.html": "31xDAWwHG8L",
        "live-custom-Gold-default_button-es_ES-tiab1y2.html": "31zfZByhONL",
        "live-custom-Gold-default_button-fr_FR-tiab1y2.html": "31iSD4jzHuL",
        "live-custom-Gold-default_button-it_IT-tiab1y2.html": "31iWjSGUFiL",
        "live-custom-Gold-default_button-ja_JP-tiab1y2.html": "31qjB259B7L",
        "live-custom-Gold-product_button-de_DE-tiab1y2.html": "31YaVLvjvVL",
        "live-custom-Gold-product_button-en_GB-tiab1y2.html": "31dcpSwcd5L",
        "live-custom-Gold-product_button-en_US-tiab1y2.html": "316mrhYCeEL",
        "live-custom-Gold-product_button-es_ES-tiab1y2.html": "31VDATDfaoL",
        "live-custom-Gold-product_button-fr_FR-tiab1y2.html": "31531-6ukyL",
        "live-custom-Gold-product_button-it_IT-tiab1y2.html": "319psHX53wL",
        "live-custom-Gold-product_button-ja_JP-tiab1y2.html": "31YEe65AtTL",
        "live-custom-LightGray-default_button-de_DE-tiab1y2.html": "31boC3Oh28L",
        "live-custom-LightGray-default_button-en_GB-tiab1y2.html": "31BwVcmexuL",
        "live-custom-LightGray-default_button-en_US-tiab1y2.html": "31OfduY70cL",
        "live-custom-LightGray-default_button-es_ES-tiab1y2.html": "310PZwB5khL",
        "live-custom-LightGray-default_button-fr_FR-tiab1y2.html": "31QIV9VBBWL",
        "live-custom-LightGray-default_button-it_IT-tiab1y2.html": "31sAvBMqW8L",
        "live-custom-LightGray-default_button-ja_JP-tiab1y2.html": "319t4Qch7ZL",
        "live-custom-LightGray-product_button-de_DE-tiab1y2.html": "31EppYNMfRL",
        "live-custom-LightGray-product_button-en_GB-tiab1y2.html": "31McLSCKLZL",
        "live-custom-LightGray-product_button-en_US-tiab1y2.html": "31gN32iacZL",
        "live-custom-LightGray-product_button-es_ES-tiab1y2.html": "31rRKMOHtpL",
        "live-custom-LightGray-product_button-fr_FR-tiab1y2.html": "31Y-YstkswL",
        "live-custom-LightGray-product_button-it_IT-tiab1y2.html": "31d5rIA2dFL",
        "live-custom-LightGray-product_button-ja_JP-tiab1y2.html": "316NTA+3aqL",
        "live-default-DarkGray-default_button-de_DE-tiab1y2.html": "31n8g8yrYSL",
        "live-default-DarkGray-default_button-en_GB-tiab1y2.html": "31YQJZ6smeL",
        "live-default-DarkGray-default_button-en_US-tiab1y2.html": "313QCaws9sL",
        "live-default-DarkGray-default_button-es_ES-tiab1y2.html": "31tDUTrBm4L",
        "live-default-DarkGray-default_button-fr_FR-tiab1y2.html": "31qFafoMJVL",
        "live-default-DarkGray-default_button-it_IT-tiab1y2.html": "319O-rMYnwL",
        "live-default-DarkGray-default_button-ja_JP-tiab1y2.html": "31pw8nUB92L",
        "live-default-DarkGray-product_button-de_DE-tiab1y2.html": "31n8g8yrYSL",
        "live-default-DarkGray-product_button-en_GB-tiab1y2.html": "31YQJZ6smeL",
        "live-default-DarkGray-product_button-en_US-tiab1y2.html": "313QCaws9sL",
        "live-default-DarkGray-product_button-es_ES-tiab1y2.html": "31tDUTrBm4L",
        "live-default-DarkGray-product_button-fr_FR-tiab1y2.html": "31qFafoMJVL",
        "live-default-DarkGray-product_button-it_IT-tiab1y2.html": "319O-rMYnwL",
        "live-default-DarkGray-product_button-ja_JP-tiab1y2.html": "31pw8nUB92L",
        "live-default-Gold-default_button-de_DE-tiab1y2.html": "31m-HXqzBTL",
        "live-default-Gold-default_button-en_GB-tiab1y2.html": "31aCmqqIEdL",
        "live-default-Gold-default_button-en_US-tiab1y2.html": "31oYBTS68iL",
        "live-default-Gold-default_button-es_ES-tiab1y2.html": "31vaOb+RHQL",
        "live-default-Gold-default_button-fr_FR-tiab1y2.html": "31VN-IWMtrL",
        "live-default-Gold-default_button-it_IT-tiab1y2.html": "316n37knHEL",
        "live-default-Gold-default_button-ja_JP-tiab1y2.html": "31AZIMVjUwL",
        "live-default-Gold-product_button-de_DE-tiab1y2.html": "31m-HXqzBTL",
        "live-default-Gold-product_button-en_GB-tiab1y2.html": "31aCmqqIEdL",
        "live-default-Gold-product_button-en_US-tiab1y2.html": "31oYBTS68iL",
        "live-default-Gold-product_button-es_ES-tiab1y2.html": "31vaOb+RHQL",
        "live-default-Gold-product_button-fr_FR-tiab1y2.html": "31VN-IWMtrL",
        "live-default-Gold-product_button-it_IT-tiab1y2.html": "316n37knHEL",
        "live-default-Gold-product_button-ja_JP-tiab1y2.html": "31AZIMVjUwL",
        "live-default-LightGray-default_button-de_DE-tiab1y2.html": "31kUBuB1dhL",
        "live-default-LightGray-default_button-en_GB-tiab1y2.html": "31+GKLY9m-L",
        "live-default-LightGray-default_button-en_US-tiab1y2.html": "31IXJ5BgvIL",
        "live-default-LightGray-default_button-es_ES-tiab1y2.html": "31ket5ZXbtL",
        "live-default-LightGray-default_button-fr_FR-tiab1y2.html": "31uALmhd6qL",
        "live-default-LightGray-default_button-it_IT-tiab1y2.html": "31-AleiLTQL",
        "live-default-LightGray-default_button-ja_JP-tiab1y2.html": "31mn4XdS3AL",
        "live-default-LightGray-product_button-de_DE-tiab1y2.html": "31kUBuB1dhL",
        "live-default-LightGray-product_button-en_GB-tiab1y2.html": "31+GKLY9m-L",
        "live-default-LightGray-product_button-en_US-tiab1y2.html": "31IXJ5BgvIL",
        "live-default-LightGray-product_button-es_ES-tiab1y2.html": "31ket5ZXbtL",
        "live-default-LightGray-product_button-fr_FR-tiab1y2.html": "31uALmhd6qL",
        "live-default-LightGray-product_button-it_IT-tiab1y2.html": "31-AleiLTQL",
        "live-default-LightGray-product_button-ja_JP-tiab1y2.html": "31mn4XdS3AL",
        "live-signin-DarkGray-de_DE-tiab1y2.html": "31z+cpq3DGL",
        "live-signin-DarkGray-en_GB-tiab1y2.html": "31q-oztLUCL",
        "live-signin-DarkGray-en_US-tiab1y2.html": "31-GcxYb-0L",
        "live-signin-DarkGray-es_ES-tiab1y2.html": "313YvGe7tzL",
        "live-signin-DarkGray-fr_FR-tiab1y2.html": "318zCxZ9CZL",
        "live-signin-DarkGray-it_IT-tiab1y2.html": "31w9t5MpomL",
        "live-signin-DarkGray-ja_JP-tiab1y2.html": "31ihnvfHEGL",
        "live-signin-Gold-de_DE-tiab1y2.html": "315e13n5SbL",
        "live-signin-Gold-en_GB-tiab1y2.html": "31d0485ktGL",
        "live-signin-Gold-en_US-tiab1y2.html": "31uEHQPxmKL",
        "live-signin-Gold-es_ES-tiab1y2.html": "31AF0PIfq+L",
        "live-signin-Gold-fr_FR-tiab1y2.html": "31t9Qmr76OL",
        "live-signin-Gold-it_IT-tiab1y2.html": "31QwCu1cU0L",
        "live-signin-Gold-ja_JP-tiab1y2.html": "31mwiGgAM0L",
        "live-signin-LightGray-de_DE-tiab1y2.html": "310ZHavetYL",
        "live-signin-LightGray-en_GB-tiab1y2.html": "31boKs2cA8L",
        "live-signin-LightGray-en_US-tiab1y2.html": "31RVULR+yiL",
        "live-signin-LightGray-es_ES-tiab1y2.html": "31Ak7zHtIOL",
        "live-signin-LightGray-fr_FR-tiab1y2.html": "31zmvQcO84L",
        "live-signin-LightGray-it_IT-tiab1y2.html": "31mAZ9mYCTL",
        "live-signin-LightGray-ja_JP-tiab1y2.html": "31mI+HgzKWL",
        "sandbox-custom-DarkGray-default_button-de_DE-tiab1y2.html": "31TPdt09xHL",
        "sandbox-custom-DarkGray-default_button-en_GB-tiab1y2.html": "31kYXg6nYcL",
        "sandbox-custom-DarkGray-default_button-en_US-tiab1y2.html": "31yUukBgKjL",
        "sandbox-custom-DarkGray-default_button-es_ES-tiab1y2.html": "31Hkgb9N7xL",
        "sandbox-custom-DarkGray-default_button-fr_FR-tiab1y2.html": "31-EakjBuYL",
        "sandbox-custom-DarkGray-default_button-it_IT-tiab1y2.html": "31it8OoCyIL",
        "sandbox-custom-DarkGray-default_button-ja_JP-tiab1y2.html": "31geE63lYOL",
        "sandbox-custom-DarkGray-product_button-de_DE-tiab1y2.html": "31zxzO4A9FL",
        "sandbox-custom-DarkGray-product_button-en_GB-tiab1y2.html": "31rIhGeB6OL",
        "sandbox-custom-DarkGray-product_button-en_US-tiab1y2.html": "31zB-FtLRsL",
        "sandbox-custom-DarkGray-product_button-es_ES-tiab1y2.html": "31Q8rlrh+nL",
        "sandbox-custom-DarkGray-product_button-fr_FR-tiab1y2.html": "313SZZt3qGL",
        "sandbox-custom-DarkGray-product_button-it_IT-tiab1y2.html": "31RolT6lhsL",
        "sandbox-custom-DarkGray-product_button-ja_JP-tiab1y2.html": "31mSAymSoML",
        "sandbox-custom-Gold-default_button-de_DE-tiab1y2.html": "31qfLXiFseL",
        "sandbox-custom-Gold-default_button-en_GB-tiab1y2.html": "31K8Kq9tGAL",
        "sandbox-custom-Gold-default_button-en_US-tiab1y2.html": "31CV1wVl2DL",
        "sandbox-custom-Gold-default_button-es_ES-tiab1y2.html": "31tHtLChinL",
        "sandbox-custom-Gold-default_button-fr_FR-tiab1y2.html": "31Yg210gUAL",
        "sandbox-custom-Gold-default_button-it_IT-tiab1y2.html": "310KfyUZW-L",
        "sandbox-custom-Gold-default_button-ja_JP-tiab1y2.html": "31GZbljVktL",
        "sandbox-custom-Gold-product_button-de_DE-tiab1y2.html": "31prK11SKZL",
        "sandbox-custom-Gold-product_button-en_GB-tiab1y2.html": "31QToAgVs9L",
        "sandbox-custom-Gold-product_button-en_US-tiab1y2.html": "319oBvpsQlL",
        "sandbox-custom-Gold-product_button-es_ES-tiab1y2.html": "31oE3e99anL",
        "sandbox-custom-Gold-product_button-fr_FR-tiab1y2.html": "31Ahk5i1KNL",
        "sandbox-custom-Gold-product_button-it_IT-tiab1y2.html": "31V7T8qcfqL",
        "sandbox-custom-Gold-product_button-ja_JP-tiab1y2.html": "31TwULWKB2L",
        "sandbox-custom-LightGray-default_button-de_DE-tiab1y2.html": "31DlYrS-VBL",
        "sandbox-custom-LightGray-default_button-en_GB-tiab1y2.html": "31OwQwe943L",
        "sandbox-custom-LightGray-default_button-en_US-tiab1y2.html": "31CugaR7SfL",
        "sandbox-custom-LightGray-default_button-es_ES-tiab1y2.html": "31yJL6s1JmL",
        "sandbox-custom-LightGray-default_button-fr_FR-tiab1y2.html": "31JxkJG4n+L",
        "sandbox-custom-LightGray-default_button-it_IT-tiab1y2.html": "31O5oiRiMfL",
        "sandbox-custom-LightGray-default_button-ja_JP-tiab1y2.html": "31kWd6d3zUL",
        "sandbox-custom-LightGray-product_button-de_DE-tiab1y2.html": "31cY1DzM1oL",
        "sandbox-custom-LightGray-product_button-en_GB-tiab1y2.html": "31zh-SZ-zfL",
        "sandbox-custom-LightGray-product_button-en_US-tiab1y2.html": "31bKnwm8QnL",
        "sandbox-custom-LightGray-product_button-es_ES-tiab1y2.html": "31XXOTRuNTL",
        "sandbox-custom-LightGray-product_button-fr_FR-tiab1y2.html": "31pnMvSIneL",
        "sandbox-custom-LightGray-product_button-it_IT-tiab1y2.html": "31lM79UBpsL",
        "sandbox-custom-LightGray-product_button-ja_JP-tiab1y2.html": "31NQgF8ExDL",
        "sandbox-default-DarkGray-default_button-de_DE-tiab1y2.html": "31ndz3eA5iL",
        "sandbox-default-DarkGray-default_button-en_GB-tiab1y2.html": "31iWWGasetL",
        "sandbox-default-DarkGray-default_button-en_US-tiab1y2.html": "31ElGyYbrqL",
        "sandbox-default-DarkGray-default_button-es_ES-tiab1y2.html": "310qKHO+c-L",
        "sandbox-default-DarkGray-default_button-fr_FR-tiab1y2.html": "31M62xoS3SL",
        "sandbox-default-DarkGray-default_button-it_IT-tiab1y2.html": "31VH6HY1bWL",
        "sandbox-default-DarkGray-default_button-ja_JP-tiab1y2.html": "31sGskR0AIL",
        "sandbox-default-DarkGray-product_button-de_DE-tiab1y2.html": "31ndz3eA5iL",
        "sandbox-default-DarkGray-product_button-en_GB-tiab1y2.html": "31iWWGasetL",
        "sandbox-default-DarkGray-product_button-en_US-tiab1y2.html": "31ElGyYbrqL",
        "sandbox-default-DarkGray-product_button-es_ES-tiab1y2.html": "310qKHO+c-L",
        "sandbox-default-DarkGray-product_button-fr_FR-tiab1y2.html": "31M62xoS3SL",
        "sandbox-default-DarkGray-product_button-it_IT-tiab1y2.html": "31VH6HY1bWL",
        "sandbox-default-DarkGray-product_button-ja_JP-tiab1y2.html": "31sGskR0AIL",
        "sandbox-default-Gold-default_button-de_DE-tiab1y2.html": "31aus3MNDeL",
        "sandbox-default-Gold-default_button-en_GB-tiab1y2.html": "31OIUlB47pL",
        "sandbox-default-Gold-default_button-en_US-tiab1y2.html": "31BjH+eTNKL",
        "sandbox-default-Gold-default_button-es_ES-tiab1y2.html": "312wpthNkdL",
        "sandbox-default-Gold-default_button-fr_FR-tiab1y2.html": "31RhGhaUGAL",
        "sandbox-default-Gold-default_button-it_IT-tiab1y2.html": "31wkcThO3sL",
        "sandbox-default-Gold-default_button-ja_JP-tiab1y2.html": "3150dOzH1JL",
        "sandbox-default-Gold-product_button-de_DE-tiab1y2.html": "31aus3MNDeL",
        "sandbox-default-Gold-product_button-en_GB-tiab1y2.html": "31OIUlB47pL",
        "sandbox-default-Gold-product_button-en_US-tiab1y2.html": "31BjH+eTNKL",
        "sandbox-default-Gold-product_button-es_ES-tiab1y2.html": "312wpthNkdL",
        "sandbox-default-Gold-product_button-fr_FR-tiab1y2.html": "31RhGhaUGAL",
        "sandbox-default-Gold-product_button-it_IT-tiab1y2.html": "31wkcThO3sL",
        "sandbox-default-Gold-product_button-ja_JP-tiab1y2.html": "3150dOzH1JL",
        "sandbox-default-LightGray-default_button-de_DE-tiab1y2.html": "31KESRYRhYL",
        "sandbox-default-LightGray-default_button-en_GB-tiab1y2.html": "31ttiYGtMnL",
        "sandbox-default-LightGray-default_button-en_US-tiab1y2.html": "31zw+i8HJLL",
        "sandbox-default-LightGray-default_button-es_ES-tiab1y2.html": "31H0fHVQfML",
        "sandbox-default-LightGray-default_button-fr_FR-tiab1y2.html": "31MBbrC5jdL",
        "sandbox-default-LightGray-default_button-it_IT-tiab1y2.html": "313KKJsYpqL",
        "sandbox-default-LightGray-default_button-ja_JP-tiab1y2.html": "31-cniEKATL",
        "sandbox-default-LightGray-product_button-de_DE-tiab1y2.html": "31KESRYRhYL",
        "sandbox-default-LightGray-product_button-en_GB-tiab1y2.html": "31ttiYGtMnL",
        "sandbox-default-LightGray-product_button-en_US-tiab1y2.html": "31zw+i8HJLL",
        "sandbox-default-LightGray-product_button-es_ES-tiab1y2.html": "31H0fHVQfML",
        "sandbox-default-LightGray-product_button-fr_FR-tiab1y2.html": "31MBbrC5jdL",
        "sandbox-default-LightGray-product_button-it_IT-tiab1y2.html": "313KKJsYpqL",
        "sandbox-default-LightGray-product_button-ja_JP-tiab1y2.html": "31-cniEKATL",
        "sandbox-signin-DarkGray-de_DE-tiab1y2.html": "31Zy3g5nU5L",
        "sandbox-signin-DarkGray-en_GB-tiab1y2.html": "31qo+aUYusL",
        "sandbox-signin-DarkGray-en_US-tiab1y2.html": "31Mj4NRDWIL",
        "sandbox-signin-DarkGray-es_ES-tiab1y2.html": "317sM3ifszL",
        "sandbox-signin-DarkGray-fr_FR-tiab1y2.html": "310T0pDkSqL",
        "sandbox-signin-DarkGray-it_IT-tiab1y2.html": "31rxWvDyTkL",
        "sandbox-signin-DarkGray-ja_JP-tiab1y2.html": "31tNbGpz30L",
        "sandbox-signin-Gold-de_DE-tiab1y2.html": "31oc0a9VqjL",
        "sandbox-signin-Gold-en_GB-tiab1y2.html": "318UB9gVxdL",
        "sandbox-signin-Gold-en_US-tiab1y2.html": "31xbo7e1tmL",
        "sandbox-signin-Gold-es_ES-tiab1y2.html": "319SE3wNkcL",
        "sandbox-signin-Gold-fr_FR-tiab1y2.html": "313cRZFVaEL",
        "sandbox-signin-Gold-it_IT-tiab1y2.html": "316a-DY2rwL",
        "sandbox-signin-Gold-ja_JP-tiab1y2.html": "31McsMUufwL",
        "sandbox-signin-LightGray-de_DE-tiab1y2.html": "311MZ9ZzlAL",
        "sandbox-signin-LightGray-en_GB-tiab1y2.html": "31NngLBHAML",
        "sandbox-signin-LightGray-en_US-tiab1y2.html": "31RCOSt2xgL",
        "sandbox-signin-LightGray-es_ES-tiab1y2.html": "319xLg7opIL",
        "sandbox-signin-LightGray-fr_FR-tiab1y2.html": "31k3VAd7Z3L",
        "sandbox-signin-LightGray-it_IT-tiab1y2.html": "31MmrSn0HLL",
        "sandbox-signin-LightGray-ja_JP-tiab1y2.html": "31O6Jx68EQL"
    };

    function rn(t) {
        window.performance && "function" == typeof window.performance.mark && window.performance.mark(t)
    }

    function un(t, n, e) {
        window.performance && "function" == typeof window.performance.measure && window.performance.measure(t, n, e)
    }

    function sn(t) {
        window.performance && "function" == typeof window.performance.clearMeasures && window.performance.clearMeasures(t)
    }

    function cn(t) {
        window.performance && "function" == typeof window.performance.clearMarks && window.performance.clearMarks(t)
    }

    function dn(t) {
        var n = function(t, n) {
            return window.performance && "function" == typeof window.performance.getEntriesByName ? window.performance.getEntriesByName(t, n) : []
        }(t, "measure");
        return n && n.length > 0 ? n[0].duration : 0
    }

    function ln(t, n, e, o) {
        void 0 === e && (e = !0), void 0 === o && (o = !0);
        var a = new XMLHttpRequest;
        if ("withCredentials" in a) a.open(t, n, o), a.withCredentials = e;
        else {
            if ("undefined" == typeof XDomainRequest) return null;
            (a = new XDomainRequest).open(t, n)
        }
        return a
    }

    function mn() {
        var t = navigator.userAgent.toLowerCase();
        return !e(["tablet", "mobile", "android", "webos", "ipad", "iemobile", "iphone", "ipod", "series60", "symbian", "opera mini", "windows ce", "blackberry", "palm"], function(n) {
            return t.indexOf(n) > -1
        })
    }

    function bn() {
        return navigator.userAgent.toLowerCase().indexOf("msie") > -1 || !!window.MSInputMethodContext && !!document.documentMode
    }
    var fn = {},
        yn = !1,
        hn = !1,
        pn = [];

    function _n(t) {
        for (; pn.length > 0;) {
            var n = pn.pop();
            "function" == typeof n && n(fn)
        }
    }

    function gn(t, n) {
        if (!yn)
            if (t.ledgerCurrency) {
                var e = t.sandbox || !1,
                    o = t.merchantId || null,
                    a = ln("GET", function(t, n, e, o) {
                        return [zt.apchsHost, "/abTestV2", "?", s({
                            countryOfEstablishment: t,
                            ledgerCurrency: n,
                            isSandbox: e,
                            merchantId: o
                        })].join("")
                    }(zt.coe[t.ledgerCurrency], t.ledgerCurrency, e, o), !0);
                ! function(t, n, e) {
                    t && (t.onload = n, t.onerror = e, t.send())
                }(a, function() {
                    var t;
                    try {
                        var n = JSON.parse((null === (t = a) || void 0 === t ? void 0 : t.responseText) || "{}");
                        fn = n.abTestResults
                    } catch (t) {
                        fn = {}
                    }
                    _n(), hn = !1
                }, function() {
                    fn = {}, _n(), hn = !1
                }), yn = !0, hn = !0, n && pn.push(n)
            } else n && n(fn)
    }

    function vn(t, n, e) {
        if (!e && (bn() || !mn())) return t({});
        hn ? pn.push(t) : !yn && n && t ? gn(n, t) : t(fn)
    }
    var Ln = "register-amazonpay-button-click",
        En = "amazonpay-button-clicked",
        Sn = "amazonpay-button-click-disabled",
        An = "amazonpay-button-disabled-click-event";

    function wn(t, n, e, o) {
        t.style.position = "relative";
        var a, i = document.createElement("iframe"),
            r = e.sandbox ? "sandbox" : "live",
            u = dt[e.placement];
        a = Kt(e.design) ? M : B;
        var s, c = Ft(e.buttonColor, e.design);
        s = Ht(e.productType) ? an[r + "-" + j + "-" + c + "-" + e.checkoutLanguage + "-" + h + ".html"] : an[r + "-" + a + "-" + c + "-" + u + "-" + e.checkoutLanguage + "-" + h + ".html"], i.src = "https://m.media-amazon.com/images/I/" + s + ".html", i.setAttribute("frameborder", "0"), i.setAttribute("scrolling", "no"), i.setAttribute("style", "width: 100%; height: 100%; background-color: transparent; position: absolute; left: 0; right: 0; top: 0; bottom: 0;"), i.onload = function() {
                i.contentWindow && i.contentWindow.postMessage(Ln + "=" + n, "*")
            }, t.appendChild(i),
            function(t, n, e) {
                window.addEventListener("message", function(t) {
                    0 === t.data.indexOf(En) && t.data === En + "=" + n && e()
                })
            }(0, n, o), rn(S)
    }

    function Cn(t, n, e) {
        var o = Gt[e.checkoutLanguage],
            a = t.querySelector("iframe");
        a && a.contentWindow && (a.tabIndex = -1, a.addEventListener("click", Yt, !0), a.addEventListener("keyup", Yt, !0), a.contentWindow.postMessage(Sn + "=" + o, "*"), vn(function(t) {
            a && a.contentWindow && qt(t) && a.contentWindow.postMessage(An + "=" + o, "*")
        }, e, !0))
    }
    var In = "sandbox",
        Gn = new RegExp("^[a-z-]*(fe|jp)[a-z.-]*$"),
        xn = new RegExp("^[a-z-]*(eu|uk|de)[a-z.-]*$"),
        Tn = "https://",
        kn = function(t, n) {
            for (var e = [], o = t.length, a = 0; a < o; a++) {
                var i = t[a];
                e.push(n(i))
            }
            return e
        }(["payments", "payments-eu", "payments-sandbox", "payments-eu-sandbox", "payments-fe", "pmt.integ", "payments-eu.integ", "payments-fe.integ", "payments-preprod", "payments-eu-preprod-dub.dub.proxy", "payments-jp-preprod"], function(t) {
            return "https://" + t + ".amazon.com/checkout/signin"
        });

    function zn(t) {
        return !!t && kn.indexOf(t.action) >= 0
    }

    function On(t) {
        return zn(t) ? (n = t.action, (e = document.createElement("a")).href = n, e.hostname) : null;
        var n, e
    }

    function Pn(t) {
        return xn.test(t) ? "GBP" : Gn.test(t) ? "JPY" : "USD"
    }

    function Dn(t) {
        var e = function(t, e) {
            if (t) {
                var o = n(Array.prototype.slice.call(t.querySelectorAll("input[type=hidden]")), function(t) {
                    return t.name == e
                })[0];
                if (o) return o.value
            }
            return "unknown"
        }(t, In);
        return "unknown" != e && "true" == e
    }

    function Bn(t) {
        for (var e = 0, o = function(t) {
                var e;
                return t ? t instanceof HTMLElement && (e = t.querySelectorAll("form")) : e = document.querySelectorAll("form"), e ? n(Array.prototype.slice.call(e), zn) : []
            }(t); e < o.length; e++) {
            var a = o[e];
            if (zn(a)) return a
        }
        return null
    }
    var Mn = [],
        Nn = "/gp/widgets/sessionstabilizer",
        Un = 365,
        Rn = "true",
        jn = !1;

    function Jn(t, n) {
        if (null != a(V)) t();
        else if (Mn.push(t), !jn) {
            var e = n || function() {
                var t, n = Bn();
                if (n) {
                    var e = On(n);
                    if (e) return "" + Tn + e + Nn + "?" + s({
                        countryOfEstablishment: (t = e, xn.test(t) ? "UK" : Gn.test(t) ? "JP" : "US"),
                        ledgerCurrency: Pn(e),
                        isSandbox: Dn(n)
                    })
                }
                return null
            }();
            if (jn = !0, e) {
                var i = ln("GET", e, !0);
                i && (i.onload = function() {
                    if (jn = !1, i && 200 === i.status) {
                        var t = JSON.parse(i.responseText);
                        t && (Rn = t.apaySessionSet)
                    }
                    for (o(V, Rn, Un, !0); Mn.length > 0;) {
                        var n = Mn.pop();
                        "function" == typeof n && n()
                    }
                }, i.send())
            }
        }
    }
    var Kn = {
            HTML_BUTTON_RENDER: "apay-html-button-render",
            HTML_BUTTON_RENDER_TAG: "pwa",
            SUB_PAGE_TYPE: "sub-page-type",
            CSS_BUTTON: "css_button",
            PAGE_ACTION: "page-action",
            ADDITIONAL_REQUEST_DATA: "additional-request-data",
            MERCHANT_DOMAIN_KEY: "window",
            SESSION_ID: "session-id",
            CORS_FAILURE: "cors-failure",
            INVALID_RESPONSE: "invalid-response",
            LATENCY: "cookie-creation-latency",
            MAXO_BUTTON: "maxo-button",
            MAXO_BUTTON_RENDER: "maxo-button-render",
            MAXO_WEBLAB_RESPONSE_RECIEVED: "maxo-weblab-response-received",
            MAXO_BUTTON_REDIRECT: "maxo-button-redirect",
            MAXO_BUTTON_CLICK: "maxo-button-click",
            MAXO_BUTTON_TAG: "maxo-button-tag",
            MAXO_BUTTON_RENDER_LATENCY: "maxo-button-render-latency",
            MAXO_BUTTON_REDIRECT_LATENCY: "maxo-button-redirect-latency",
            MAXO_BUTTON_DESIGN: "button-design",
            MAXO_BUTTON_COLOR: "color",
            BUTTON_PLACEMENT: "button-placement",
            CHECKOUT_SESSION_PRODUCT_TYPE: "checkout-session-product-type",
            CHANGE_SHIPPING_ADDRESS: "change-shipping-address",
            CHANGE_PAYMENT_METHOD: "change-payment-method",
            CHECKOUT_SESSION_ID: "checkout-session-id",
            MAXO_ADDITIONAL_INFO: "maxo-additional-info",
            INTEGRATION_TYPE: "integration-type",
            MAXO_DEFAULT_INTEGRATION: "maxo-default-integration",
            SIGNATURE_BUTTON_SESSION_CONFIG: "maxo-button-signature-session-config",
            SIGNATURE_BUTTON_OBJECT: "maxo-button-signature-object",
            SIGNATURE_BUTTON_REDIRECT: "maxo-button-signature-redirect",
            WEBLAB_DATA: "weblab-data",
            MAXO_BUTTON_VIEW_INITIATED: "maxo-button-view-initiated",
            VIEW_TYPE: "viewType",
            BIND_UPGRADE_ACTION: "bind-upgrade-action",
            MAXO_JS_LOAD_TIME: "maxo-js-load-time"
        },
        Hn = function() {
            function t(t, n) {
                this.merchantId = t, this.metrics = {
                    counters: [],
                    timings: [],
                    info: []
                }, this.metricsPublisher = n
            }
            return t.prototype.addCounter = function(t) {
                this.metrics.counters.push(t)
            }, t.prototype.addTiming = function(t) {
                this.metrics.timings.push(t)
            }, t.prototype.addInfo = function(t) {
                this.metrics.info.push(t)
            }, t.prototype.publish = function(t) {
                this.metricsPublisher && this.metricsPublisher(this, t)
            }, t.prototype.reset = function() {
                this.metrics.timings = [], this.metrics.counters = []
            }, t.prototype.toQueryString = function() {
                return "sellerId=" + this.merchantId + "&data=" + encodeURIComponent(JSON.stringify(this.metrics))
            }, t
        }(),
        Fn = function(t, n, e, o, i) {
            void 0 === i && (i = !1);
            var r = n + "/cs/uedata",
                u = function(t, n, e) {
                    return "" + t + Nn + "?" + s({
                        ledgerCurrency: n,
                        isSandbox: e
                    })
                }(n, o, i),
                c = t.toQueryString() + "&countryOfEstablishment=" + e + "&ledgerCurrency=" + o + "&isSandbox=" + i;
            Jn(function() {
                var t = a(V);
                t && (c = c + "&apaySessionSet=" + encodeURI(t));
                try {
                    var n = new Blob([c], {
                        type: "application/x-www-form-urlencoded"
                    });
                    navigator.sendBeacon(r, n)
                } catch (t) {
                    var e = ln("POST", r, !0);
                    e && (e.setRequestHeader("Content-type", "application/x-www-form-urlencoded"), e.onload = function() {}, e.send(c))
                }
            }, u)
        };

    function Yn(t, n, e) {
        var o = {
            name: n,
            time: e,
            tags: [Kn.MAXO_BUTTON_TAG]
        };
        t.addTiming(o)
    }

    function Xn(t) {
        return !(!t.name || -1 === t.name.indexOf(v))
    }

    function qn() {
        var t = n(window.performance && "function" == typeof window.performance.getEntries ? window.performance.getEntries() : [], Xn);
        return t && t.length > 0 ? t[0].duration : 0
    }

    function Wn(t, n) {
        var e = Kn.INTEGRATION_TYPE + ":" + function(t) {
            switch (t) {
                case et:
                    return Kn.SIGNATURE_BUTTON_SESSION_CONFIG;
                case ot:
                    return Kn.SIGNATURE_BUTTON_OBJECT;
                case at:
                    return Kn.SIGNATURE_BUTTON_REDIRECT;
                case G:
                    return Kn.MAXO_DEFAULT_INTEGRATION;
                default:
                    return null
            }
        }(t);
        return n && n.viewType && (e && "" !== e && (e += "|"), e += Kn.VIEW_TYPE + ":" + n.viewType), e
    }

    function Vn() {
        var t = "",
            n = fn;
        if (n !== {})
            for (var e in n) "" !== t && (t += "|"), t += e + ":" + n[e];
        return t
    }

    function Zn(t, n, e, o, i, r) {
        null == r && (r = window.location.host);
        var u = new Hn(t.merchantId),
            s = zt.apchsHost;
        u.addInfo({
            name: Kn.SUB_PAGE_TYPE,
            value: Kn.MAXO_BUTTON
        }), u.addInfo({
            name: Kn.PAGE_ACTION,
            value: n
        }), u.addInfo({
            name: Kn.SESSION_ID,
            value: a(Kn.SESSION_ID)
        }), u.addInfo({
            name: Kn.BUTTON_PLACEMENT,
            value: t.placement
        }), u.addInfo({
            name: Kn.CHECKOUT_SESSION_PRODUCT_TYPE,
            value: t.productType
        }), u.addTiming({
            name: Kn.MAXO_JS_LOAD_TIME,
            time: qn()
        });
        var c = Vn();
        "" !== c && u.addInfo({
            name: Kn.WEBLAB_DATA,
            value: c
        });
        var d = Kn.MERCHANT_DOMAIN_KEY + ":" + r + "|" + Kn.MAXO_BUTTON_COLOR + ":" + t.buttonColor;
        null != o && (o.checkoutSessionId && u.addInfo({
            name: Kn.CHECKOUT_SESSION_ID,
            value: o.checkoutSessionId
        }), o.buttonHeight && o.buttonWidth && (d += "|dimension:" + o.buttonWidth + "x" + o.buttonHeight)), u.addInfo({
            name: Kn.ADDITIONAL_REQUEST_DATA,
            value: d
        }), t.design && u.addInfo({
            name: Kn.MAXO_BUTTON_DESIGN,
            value: t.design
        });
        var l = Wn(i, o);
        if ("" !== l && u.addInfo({
                name: Kn.MAXO_ADDITIONAL_INFO,
                value: l
            }), u.addCounter({
                name: n,
                tags: [Kn.MAXO_BUTTON_TAG]
            }), n === Kn.MAXO_BUTTON_RENDER) {
            var m = Kn.MAXO_BUTTON_RENDER_LATENCY;
            i && (m = i + "-render-latency"), Yn(u, m, e)
        }
        if (n === Kn.MAXO_BUTTON_REDIRECT) {
            m = Kn.MAXO_BUTTON_REDIRECT_LATENCY;
            i && (m = i + "-redirect-latency"), Yn(u, m, e)
        }
        Fn(u, s, zt.coe[t.ledgerCurrency], t.ledgerCurrency, t.sandbox)
    }

    function Qn(t, n, e, o, a) {
        !bn() && vn(function(e) {
            ! function(t, n, e) {
                Zn(t, Kn.MAXO_WEBLAB_RESPONSE_RECIEVED, void 0, n, e)
            }(n, o, a),
            function(t, n) {
                var e = Wt(n);
                t && t.MAXO_BUTTON_CONTENT_EXPERIMENT === nt && e && !e.contains(tt) && e.add($)
            }(e, t)
        }, n, e)
    }
    var $n = function() {
        return !1
    };

    function te(t) {
        var n = t.merchantId;
        return n && n.length > 0 ? x + "-" + n : x
    }

    function ne(t) {
        var n = document.createElement("picture");
        Ht(t.productType) ? n.setAttribute("class", "amazonpay-signin-button-sandbox-logo") : n.setAttribute("class", "amazonpay-button-sandbox-logo"), n.ondragstart = $n, n.ondrop = $n;
        var e, o = document.createElement("img");
        return o.src = (e = t.checkoutLanguage, wt(bt, e)), n.appendChild(o), n
    }

    function ee(t) {
        var n = document.createElement("picture");
        n.setAttribute("class", "amazonpay-button-chevrons"), n.ondragstart = $n, n.ondrop = $n;
        var e, o, a = document.createElement("img"),
            i = t.buttonColor || N;
        return a.src = (e = t.checkoutLanguage, (o = i) && St[o] ? wt(St[o], e) : wt(ft, e)), n.appendChild(a), n
    }

    function oe(t) {
        var n = document.createElement("picture");
        Ht(t.productType) ? n.setAttribute("class", "amazonpay-signin-button-logo") : n.setAttribute("class", "amazonpay-button-logo"), n.ondragstart = $n, n.ondrop = $n;
        var e, o, a = document.createElement("img");
        return Ht(t.productType) ? a.src = (e = t.checkoutLanguage, o = t.buttonColor || N, Et[o] && Et[o][e] ? wt(Et[o][e], e) : wt(yt, e)) : a.src = function(t, n, e, o) {
            var a = dt[n];
            return Lt[o] && Lt[o][a] && Lt[o][a][e] && Lt[o][a][e][t] ? wt(Lt[o][a][e][t], t) : wt(mt, t)
        }(t.checkoutLanguage, t.placement, t.design || P, t.buttonColor || N), n.appendChild(a), n
    }

    function ae(t, n) {
        var e = document.createElement("div");
        return e.setAttribute("class", "amazonpay-button-view1"), e.tabIndex = 0, t.buttonColor = Ft(t.buttonColor, t.design), e.classList.add(lt[t.buttonColor ? t.buttonColor : N]), e.appendChild(oe(t)), t.sandbox && e.appendChild(ne(t)), n && e.appendChild(ee(t)), e
    }

    function ie(t) {
        return "ja_JP" === t || /Edge/.test(navigator.userAgent) || bn() ? wt(At[t], t) : "https://static-" + ct[t].toLowerCase() + ".payments-amazon.com/assets/maxo/microtext/" + t + ".svg"
    }

    function re(t, n, e, o) {
        ! function(t, n) {
            if (t.style.position = "relative", !bn() && !Ht(n.productType)) {
                var e = te(n);
                t.classList.add(e)
            }
            t.setAttribute("role", "button"), t.setAttribute("aria-label", n.sandbox ? Ct[n.checkoutLanguage] : It[n.checkoutLanguage]), t.title = Ht(n.productType) ? Tt[n.checkoutLanguage] : xt[n.checkoutLanguage]
        }(t, e);
        var a, i = function(t) {
            var n = t.attachShadow({
                    mode: "open"
                }),
                e = document.createElement("div");
            e.setAttribute("class", "amazonpay-button-container amazonpay-button-enabled");
            var o = document.createElement("style");
            return o.textContent = "\n.amazonpay-button-container {\n  display: grid;\n  justify-items: stretch;\n  min-height: 42px;\n  min-width: 113px;\n  max-width: 600px;\n  height: 100%;\n  width: 100%;\n  touch-action: manipulation;\n  max-height: 193px;\n  position: absolute;\n  left: 0px;\n  right: 0px;\n  top: 0px;\n  bottom: 0px;\n}\n\n.amazonpay-button-container-rows {\n    grid-template-rows: 65% 10% 25%;\n}\n\n.amazonpay-custom-button-container-rows {\n    grid-template-rows: 100%;\n}\n\n.amazonpay-button-view1 {\n  grid-row: 1/2;\n  border-radius: 3px;\n  box-shadow: 0 1px 0 rgba(255, 255, 255, 0.4) inset;\n  border-style: solid;\n  border-width: 1px;\n  box-sizing: border-box;\n  width: 100%;\n  display: grid;\n  grid-template-rows: 13% 13% 1fr 1fr 10% 16%;\n  grid-template-columns: 4% 10% 6% 1fr 6% 10% 4%;\n  justify-items: center;\n  justify-self: stretch;\n  align-self: stretch;\n}\n\n.amazonpay-button-view1-gold {\n  border-color: #a88734 #9c7e31 #846a29;\n  background: linear-gradient(to bottom, #f7dfa5, #f0c14b);\n}\n\n.amazonpay-button-view1-gray {\n  border-color: #ADB1B8 #A2A6AC #8D9096;\n  background: linear-gradient(to bottom, #F7F8FA, #E7E9EC);\n}\n\n.amazonpay-button-view1-ink {\n border-color: #3d444c #2f353b #2c3137;\n  background: linear-gradient(to bottom, #71777D, #444C54);\n}\n\n.amazonpay-button-enabled {\n  cursor: pointer;\n}\n\n.amazonpay-button-disabled {\n  cursor: default;\n  opacity: 0.25;\n  filter: grayscale(100%);\n}\n\n.amazonpay-button-view1 .amazonpay-button-sandbox-logo {\n  grid-row: 2/4;\n  grid-column: 2/3;\n}\n\n.amazonpay-button-view1 .amazonpay-button-logo {\n  grid-row: 3/6;\n  grid-column: 4/5;\n}\n\n.amazonpay-button-view1 .amazonpay-signin-button-sandbox-logo {\n  grid-row: 1/3;\n  grid-column: 1/2;\n}\n\n.amazonpay-button-view1 .amazonpay-signin-button-logo {\n  grid-row: 3/6;\n  grid-column: 2/7;\n}\n\n.amazonpay-button-view1 .amazonpay-button-chevrons {\n  grid-row: 3/5;\n  grid-column: 6/7;\n }\n\n.amazonpay-button-view1-gold:active {\n  background: #f0c14b;\n  outline: none;\n  border-color: #e77600;\n  box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n.amazonpay-button-view1-gray:active {\n  background: #DCDFE3;\n  outline: none;\n  border-color: #e77600;\n  box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n.amazonpay-button-view1-ink:active {\n  background: #444C54;\n  outline: none;\n  border-color: #32373e #24282d #212429;\n    box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n\n.amazonpay-button-view1-gold:focus {\n  outline: none;\n  border-color: #e77600;\n  box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n.amazonpay-button-view1-gray:focus {\n  outline: none;\n  border-color: #e77600;\n  box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n.amazonpay-button-view1-ink:focus {\n  outline: none;\n  border-color: #32373e #24282d #212429;\n  box-shadow: 0 0 3px 2px rgba(228, 121, 17, 0.5);\n}\n\n.amazonpay-button-view1-gold:hover {\n  background: linear-gradient(to bottom, #f5d78e, #eeb933);\n}\n.amazonpay-button-view1-gray:hover {\n  background: linear-gradient(to bottom, #E6E9EF, #D9DCE1);\n}\n.amazonpay-button-view1-ink:hover {\n  background: linear-gradient(to bottom,  #64696F, #393F47);\n}\n\n.amazonpay-button-view2 {\n  grid-row: 2/3;\n}\n\n.amazonpay-button-view3 {\n  grid-row: 3/4;\n  justify-items: center;\n  justify-self: stretch;\n  align-self: stretch;\n}\n\n.amazonpay-button-view1 .amazonpay-button-sandbox-logo img,\n.amazonpay-button-view1 .amazonpay-signin-button-sandbox-logo img,\n.amazonpay-button-view1 .amazonpay-button-logo img,\n.amazonpay-button-view1 .amazonpay-signin-button-logo img,\n.amazonpay-button-view1 .amazonpay-button-chevrons img,\n.amazonpay-button-view3 .amazonpay-button-microtext img  {\n  display: block;\n  height: 100%;\n  width: 100%;\n  user-select: none;\n  -webkit-touch-callout: none;\n}\n\n.amazonpay-button-view1 .amazonpay-button-sandbox-logo img,\n.amazonpay-button-view1 .amazonpay-signin-button-sandbox-logo img,\n.amazonpay-button-view1 .amazonpay-button-logo img,\n.amazonpay-button-view1 .amazonpay-signin-button-logo img,\n.amazonpay-button-view1 .amazonpay-button-chevrons img  {\n  object-fit: contain;\n}\n\n.amazonpay-button-view3 .amazonpay-button-microtext img {\n  object-fit: contain;\n}\n\n.animate-chevron .amazonpay-button-chevrons{\n  -webkit-animation: slide 2s ease-out;\n  -webkit-animation-direction: running;\n  -webkit-animation-iteration-count: 3;\n  -webkit-animation-delay: 0.5s;\n  animation: slide 2s ease-out;\n  animation-direction: running;\n  animation-iteration-count: 3;\n  animation-delay: 0.5s;\n }\n\n@keyframes slide {\n  from {\n    grid-column: 5/6;\n    opacity: 1; \n  }\n  10% {\n    opacity: 0.5;\n  }\n  25% {\n    opacity: 0.1; \n  }\n  50% {\n    grid-column: 5/7;\n    opacity: 1;\n  }\n  60% {\n    opacity:0.5\n  }\n  75% {\n    opacity: 0.1; \n  }\n  to {\n    grid-column: 6/7; \n    opacity: 1;\n  }\n\n", n.appendChild(o), n.appendChild(e), e
        }(t);
        Ht(e.productType) || Kt(e.design) ? (i.classList.add("amazonpay-custom-button-container-rows"), i.appendChild(ae(e, !1))) : (i.classList.add("amazonpay-button-container-rows"), i.appendChild(ae(e, !0)), i.appendChild(((a = document.createElement("div")).setAttribute("class", "amazonpay-button-view2"), a)), i.appendChild(function(t) {
                var n = document.createElement("div");
                n.setAttribute("class", "amazonpay-button-view3");
                var e = document.createElement("picture");
                e.setAttribute("class", "amazonpay-button-microtext"), e.ondragstart = $n, e.ondrop = $n;
                var o = document.createElement("img");
                return o.src = ie(t.checkoutLanguage), e.appendChild(o), n.appendChild(e), n
            }(e))),
            function(t, n, e) {
                t.addEventListener("click", function(t) {
                    e(t)
                }), t.addEventListener("keyup", function(t) {
                    13 == t.keyCode && (t.preventDefault(), e(t))
                })
            }(t, 0, o)
    }

    function ue(t, n, e) {
        var o = Gt[e.checkoutLanguage],
            a = Wt(t);
        if (t.setAttribute("aria-label", o), t.title = "", t.addEventListener("click", Yt, !0), t.addEventListener("keyup", Yt, !0), !bn() && !Ht(e.productType)) {
            var i = te(e);
            t.classList.remove(i)
        }
        var r = t.shadowRoot;
        if (r) {
            var u = r.querySelector(".amazonpay-button-container"),
                s = r.querySelector(".amazonpay-button-view1");
            u && (u.classList.remove("amazonpay-button-enabled"), u.classList.add("amazonpay-button-disabled")), s && (s.tabIndex = -1), a && a.contains($) && a.remove($)
        }
        vn(function(n) {
            t && qt(n) && (t.addEventListener("click", function() {
                window.alert(o)
            }, !0), t.addEventListener("keyup", function() {
                window.alert(o)
            }, !0))
        }, e, !0)
    }
    var se, ce = "amazonpay-checkout-signature-data-form";

    function de(t) {
        var n, e, o = function(t) {
            var n, e = document.createElement("form");
            for (var o in t) {
                var a = document.createElement("input");
                a.type = "hidden", a.name = o;
                var i = t[o],
                    r = null == (n = i) || "object" != typeof n || Array.isArray(n) ? String(i) : JSON.stringify(i);
                a.value = r, e.appendChild(a)
            }
            return e
        }(t);
        return o.setAttribute("style", "display: none !important;"), o.method = "POST", o.name = ce, o.action = function(t, n, e) {
            var o = Rt(n, e);
            return Object.keys(t).length > 0 ? "" + o + k + "?" + s(t) : "" + o + k
        }({}, (n = t.ledgerCurrency, e = a(g), n || e), Jt(t.checkoutLanguage)), o
    }

    function le(t, n, e) {
        n.addEventListener ? n.addEventListener(t, e, !1) : n.attachEvent && n.attachEvent("on" + t, e)
    }
    var me, be = !1,
        fe = "maxo_widgets_success",
        ye = "amazonpay-maxo-checkout-freezing-overlay",
        he = "amazonpay-maxo-checkout-freezing-overlay-display-class",
        pe = "#" + ye + " { display: none; } #" + ye + "." + he + " { display: block; }",
        _e = "position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 1000000; opacity: 0.75; background-color: black; pointerEvents: none;",
        ge = ["amazon.com", "amazon.co.uk", "amazon.de", "amazon.co.jp", "amazon.it", "amazon.fr", "amazon.es"];

    function ve() {
        se && !se.closed && se.close(), se = null
    }

    function Le(t) {
        return t.preventDefault(), t.stopPropagation(), !1
    }

    function Ee(t) {
        t && t.classList.toggle(he)
    }

    function Se() {
        Ee(document.querySelector("#" + ye)), window.removeEventListener("keydown", Le, !0)
    }

    function Ae() {
        clearInterval(me)
    }

    function we() {
        var t = document.querySelector("#" + ye);
        if (!t) {
            (t = document.createElement("div")).id = ye;
            var n = document.createElement("style"),
                e = pe;
            t.setAttribute("style", _e), n.appendChild(document.createTextNode(e)), t.appendChild(n), document.body.appendChild(t),
                function(t) {
                    t && t.addEventListener("click", function() {
                        se && se.focus()
                    })
                }(t)
        }
        Ee(t)
    }

    function Ce(t) {
        if (t && t.data && t.origin && se) {
            var n = t.origin,
                o = t.data;
            if (!e(ge, function(t) {
                    return n.indexOf(t) > -1
                })) return;
            Ae(), ve(), o.action && o.action == fe && o.url ? window.location.href = o.url : Se()
        }
    }

    function Ie(t) {
        se = t, le("message", window, Ce), le("beforeunload", window, ve), me = window.setInterval(function() {
            se && se.closed && (Ae(), se = null, Se())
        }, 200), we(), window.addEventListener("keydown", Le, !0)
    }

    function Ge() {
        return be
    }

    function xe(t, n) {
        se && !se.closed && (se.location.href = function(t, n) {
            return "" + Rt(t, n) + O
        }(t, n))
    }
    var Te = ["amazonCheckoutSessionId", "checkoutSessionId"];

    function ke(t, n, e, o, a) {
        var i = new XMLHttpRequest;
        i.onload = function() {
            if (i.status >= 200 && i.status < 300) try {
                var r = JSON.parse(i.responseText),
                    u = function(t, n) {
                        if ("object" != typeof t) return null;
                        for (var e = 0, o = n; e < o.length; e++) {
                            var a = o[e];
                            if (t && "string" == typeof t[a]) return t[a]
                        }
                        return null
                    }(r, Te);
                "string" == typeof t.extractAmazonCheckoutSessionId ? n(r[t.extractAmazonCheckoutSessionId]) : "function" == typeof t.extractAmazonCheckoutSessionId ? n(t.extractAmazonCheckoutSessionId(r)) : u ? n(u) : (a && xe(e, o), y("There is no amazonCheckoutSessionId found in the response: " + i.responseText))
            } catch (t) {
                a && xe(e, o), y("Can not parse the result of creating checkout session's response: " + i.responseText)
            } else xe(e, o), y("Create checkout session failed, create checkout session error returns " + i.status + ".")
        };
        var r = t.method ? t.method.toUpperCase() : "POST";
        i.open(r, t.url), i.send()
    }

    function ze(t, n, e) {
        if ("object" == typeof t.createCheckoutSession) ke(t.createCheckoutSession, n, t.ledgerCurrency, t.checkoutLanguage, e);
        else if ("function" == typeof t.createCheckoutSession) {
            var o = t.createCheckoutSession();
            if ("string" == typeof o) n(o);
            else if ("object" == typeof o && "function" == typeof o.then) o.then(function(t) {
                n(t)
            }), o.catch(function() {
                e && xe(t.ledgerCurrency, t.checkoutLanguage)
            });
            else if ("object" == typeof o && "string" == typeof o.url) {
                ke(o, n, t.ledgerCurrency, t.checkoutLanguage, e)
            } else xe(t.ledgerCurrency, t.checkoutLanguage), y("createCheckoutSession has to return a Promise object which can then be resolved into a amazonCheckoutSessionId.")
        } else xe(t.ledgerCurrency, t.checkoutLanguage), y("Wrong type of argument for createCheckoutSession, it accepts an object (required attributes: url) or a function")
    }
    var Oe = "amazonpay-checkout-signature-data-form",
        Pe = "AMZN-PAY-RSASSA-PSS",
        De = "AmazonPayMAXOCheckout";

    function Be(t, n) {
        rn(w), d() && function(t, n) {
            un(I, A, w), Zn(t, Kn.MAXO_BUTTON_REDIRECT, dn(I), void 0, n), sn(I), cn(A), cn(w)
        }(t, n)
    }

    function Me(t, n, e) {
        mn() && Zn(t, Kn.MAXO_BUTTON_VIEW_INITIATED, null, {
            viewType: n
        }, e)
    }

    function Ne() {
        var t = a(V);
        return t || ""
    }

    function Ue(t, n, e, o, a) {
        var i = de(function(t, n, e) {
            return {
                amazonCheckoutSessionId: t,
                checkoutLanguage: n.checkoutLanguage,
                ledgerCurrency: n.ledgerCurrency,
                merchantId: n.merchantId,
                productType: n.productType,
                environment: n.sandbox ? "SANDBOX" : "LIVE",
                scopes: n.scopes,
                merchantDomain: window.location.hostname,
                origin_url: window.location.href,
                viewType: e,
                weblabData: Vn(),
                apaySessionSet: Ne(),
                estimatedOrderAmount: n.estimatedOrderAmount
            }
        }(t, n, e));
        a ? a.document.body.appendChild(i) : document.body.appendChild(i), o && (Be(n), Me(n, e)), i.submit()
    }

    function Re() {
        for (var t, n = document.querySelectorAll("form[name='" + Oe + "']"), e = 0, o = Array.prototype.slice.call(n); e < o.length; e++) {
            var a = o[e];
            null === (t = a.parentNode) || void 0 === t || t.removeChild(a)
        }
    }

    function je(t, n, e) {
        var o, a, i, r = function(o, a) {
            ! function(t, n, e, o, a) {
                var i, r = Ge();
                if (t && !r) {
                    var u = Nt(De);
                    if (u) return Ie(u), n.viewType = W, i = de(n), u.document.body.appendChild(i), o && (Be(e, a), Me(e, W, a)), void i.submit()
                }
                n.viewType = q, i = de(n), document.body.appendChild(i), o && (Be(e, a), Me(e, q, a)), i.submit()
            }(o, a, t, n, e)
        };
        if (Ht(t.productType, t.signInConfig)) {
            "" !== (c = (a = t.productType, i = t.signInConfig, a === R && i ? ["payloadJSON", "signature", "publicKeyId"].map(function(t) {
                return Qt(i, t, function(t) {
                    return "Missing field " + t + " for signInConfig parameter."
                })
            }).filter(u).join("\n") : "Invalid button definition, productType " + a + " and configName do not match.\n")) && y(c), Re();
            var s = function(t) {
                return {
                    payloadJSON: t.signInConfig.payloadJSON,
                    signature: t.signInConfig.signature,
                    publicKeyId: t.signInConfig.publicKeyId,
                    publicKeyIdMismatch: t.publicKeyIdMismatch ? "true" : "false",
                    checkoutLanguage: t.checkoutLanguage,
                    algorithm: t.signInConfig.algorithm || Pe,
                    ledgerCurrency: t.ledgerCurrency,
                    merchantId: t.merchantId,
                    productType: t.productType,
                    environment: t.sandbox ? "SANDBOX" : "LIVE",
                    scopes: t.scopes,
                    merchantDomain: window.location.hostname,
                    origin_url: window.location.href,
                    viewType: q,
                    weblabData: Vn(),
                    apaySessionSet: Ne()
                }
            }(t);
            if (1 == t.alwaysRedirect) return void r(!1, s);
            vn(function(t) {
                r(Xt(t), s)
            }, t)
        } else if (t.createCheckoutSessionConfig) {
            var c;
            "" !== (c = (o = t.createCheckoutSessionConfig, ["payloadJSON", "signature", "publicKeyId"].map(function(t) {
                return Qt(o, t, function(t) {
                    return "Missing field " + t + " for createCheckoutSessionConfig parameter."
                })
            }).filter(u).join("\n"))) && y(c), Re();
            var d = function(t) {
                var n = {
                    payloadJSON: t.createCheckoutSessionConfig.payloadJSON,
                    signature: t.createCheckoutSessionConfig.signature,
                    publicKeyId: t.createCheckoutSessionConfig.publicKeyId,
                    publicKeyIdMismatch: t.publicKeyIdMismatch ? "true" : "false",
                    algorithm: t.createCheckoutSessionConfig.algorithm || Pe,
                    checkoutLanguage: t.checkoutLanguage,
                    ledgerCurrency: t.ledgerCurrency,
                    merchantId: t.merchantId,
                    productType: t.productType,
                    environment: t.sandbox ? "SANDBOX" : "LIVE",
                    scopes: t.scopes,
                    merchantDomain: window.location.hostname,
                    origin_url: jt(window.location.href),
                    viewType: q,
                    weblabData: Vn(),
                    apaySessionSet: Ne(),
                    estimatedOrderAmount: t.estimatedOrderAmount
                };
                return t.createCheckoutSessionConfig.authorizationToken && (n.authorizationToken = t.createCheckoutSessionConfig.authorizationToken), n
            }(t);
            if (1 == t.alwaysRedirect) return void r(!1, d);
            vn(function(t) {
                r(Xt(t), d)
            }, t)
        } else ! function(t, n) {
            vn(function(e) {
                var o = Xt(e),
                    a = Ge();
                if (o && !a) {
                    var i = Nt(De);
                    if (i) return Ie(i), void ze(t, function(e) {
                        Ue(e, t, W, n, i)
                    }, i)
                }
                ze(t, function(e) {
                    Ue(e, t, q, n, null)
                }, null)
            }, t)
        }(t, n)
    }

    function Je(t, n) {
        var e;
        !m(t) && $t(t, null === (e = n) || void 0 === e ? void 0 : e.sandbox) && (n.estimatedOrderAmount = t)
    }
    var Ke = function() {
            if ("undefined" != typeof Map) return Map;

            function t(t, n) {
                var e = -1;
                return t.some(function(t, o) {
                    return t[0] === n && (e = o, !0)
                }), e
            }
            return function() {
                function n() {
                    this.__entries__ = []
                }
                return Object.defineProperty(n.prototype, "size", {
                    get: function() {
                        return this.__entries__.length
                    },
                    enumerable: !0,
                    configurable: !0
                }), n.prototype.get = function(n) {
                    var e = t(this.__entries__, n),
                        o = this.__entries__[e];
                    return o && o[1]
                }, n.prototype.set = function(n, e) {
                    var o = t(this.__entries__, n);
                    ~o ? this.__entries__[o][1] = e : this.__entries__.push([n, e])
                }, n.prototype.delete = function(n) {
                    var e = this.__entries__,
                        o = t(e, n);
                    ~o && e.splice(o, 1)
                }, n.prototype.has = function(n) {
                    return !!~t(this.__entries__, n)
                }, n.prototype.clear = function() {
                    this.__entries__.splice(0)
                }, n.prototype.forEach = function(t, n) {
                    void 0 === n && (n = null);
                    for (var e = 0, o = this.__entries__; e < o.length; e++) {
                        var a = o[e];
                        t.call(n, a[1], a[0])
                    }
                }, n
            }()
        }(),
        He = "undefined" != typeof window && "undefined" != typeof document && window.document === document,
        Fe = "undefined" != typeof global && global.Math === Math ? global : "undefined" != typeof self && self.Math === Math ? self : "undefined" != typeof window && window.Math === Math ? window : Function("return this")(),
        Ye = "function" == typeof requestAnimationFrame ? requestAnimationFrame.bind(Fe) : function(t) {
            return setTimeout(function() {
                return t(Date.now())
            }, 1e3 / 60)
        },
        Xe = 2;
    var qe = 20,
        We = ["top", "right", "bottom", "left", "width", "height", "size", "weight"],
        Ve = "undefined" != typeof MutationObserver,
        Ze = function() {
            function t() {
                this.connected_ = !1, this.mutationEventsAdded_ = !1, this.mutationsObserver_ = null, this.observers_ = [], this.onTransitionEnd_ = this.onTransitionEnd_.bind(this), this.refresh = function(t, n) {
                    var e = !1,
                        o = !1,
                        a = 0;

                    function i() {
                        e && (e = !1, t()), o && u()
                    }

                    function r() {
                        Ye(i)
                    }

                    function u() {
                        var t = Date.now();
                        if (e) {
                            if (t - a < Xe) return;
                            o = !0
                        } else e = !0, o = !1, setTimeout(r, n);
                        a = t
                    }
                    return u
                }(this.refresh.bind(this), qe)
            }
            return t.prototype.addObserver = function(t) {
                ~this.observers_.indexOf(t) || this.observers_.push(t), this.connected_ || this.connect_()
            }, t.prototype.removeObserver = function(t) {
                var n = this.observers_,
                    e = n.indexOf(t);
                ~e && n.splice(e, 1), !n.length && this.connected_ && this.disconnect_()
            }, t.prototype.refresh = function() {
                this.updateObservers_() && this.refresh()
            }, t.prototype.updateObservers_ = function() {
                var t = this.observers_.filter(function(t) {
                    return t.gatherActive(), t.hasActive()
                });
                return t.forEach(function(t) {
                    return t.broadcastActive()
                }), t.length > 0
            }, t.prototype.connect_ = function() {
                He && !this.connected_ && (document.addEventListener("transitionend", this.onTransitionEnd_), window.addEventListener("resize", this.refresh), Ve ? (this.mutationsObserver_ = new MutationObserver(this.refresh), this.mutationsObserver_.observe(document, {
                    attributes: !0,
                    childList: !0,
                    characterData: !0,
                    subtree: !0
                })) : (document.addEventListener("DOMSubtreeModified", this.refresh), this.mutationEventsAdded_ = !0), this.connected_ = !0)
            }, t.prototype.disconnect_ = function() {
                He && this.connected_ && (document.removeEventListener("transitionend", this.onTransitionEnd_), window.removeEventListener("resize", this.refresh), this.mutationsObserver_ && this.mutationsObserver_.disconnect(), this.mutationEventsAdded_ && document.removeEventListener("DOMSubtreeModified", this.refresh), this.mutationsObserver_ = null, this.mutationEventsAdded_ = !1, this.connected_ = !1)
            }, t.prototype.onTransitionEnd_ = function(t) {
                var n = t.propertyName,
                    e = void 0 === n ? "" : n;
                We.some(function(t) {
                    return !!~e.indexOf(t)
                }) && this.refresh()
            }, t.getInstance = function() {
                return this.instance_ || (this.instance_ = new t), this.instance_
            }, t.instance_ = null, t
        }(),
        Qe = function(t, n) {
            for (var e = 0, o = Object.keys(n); e < o.length; e++) {
                var a = o[e];
                Object.defineProperty(t, a, {
                    value: n[a],
                    enumerable: !1,
                    writable: !1,
                    configurable: !0
                })
            }
            return t
        },
        $e = function(t) {
            return t && t.ownerDocument && t.ownerDocument.defaultView || Fe
        },
        to = ro(0, 0, 0, 0);

    function no(t) {
        return parseFloat(t) || 0
    }

    function eo(t) {
        for (var n = [], e = 1; e < arguments.length; e++) n[e - 1] = arguments[e];
        return n.reduce(function(n, e) {
            return n + no(t["border-" + e + "-width"])
        }, 0)
    }

    function oo(t) {
        var n = t.clientWidth,
            e = t.clientHeight;
        if (!n && !e) return to;
        var o = $e(t).getComputedStyle(t),
            a = function(t) {
                for (var n = {}, e = 0, o = ["top", "right", "bottom", "left"]; e < o.length; e++) {
                    var a = o[e],
                        i = t["padding-" + a];
                    n[a] = no(i)
                }
                return n
            }(o),
            i = a.left + a.right,
            r = a.top + a.bottom,
            u = no(o.width),
            s = no(o.height);
        if ("border-box" === o.boxSizing && (Math.round(u + i) !== n && (u -= eo(o, "left", "right") + i), Math.round(s + r) !== e && (s -= eo(o, "top", "bottom") + r)), ! function(t) {
                return t === $e(t).document.documentElement
            }(t)) {
            var c = Math.round(u + i) - n,
                d = Math.round(s + r) - e;
            1 !== Math.abs(c) && (u -= c), 1 !== Math.abs(d) && (s -= d)
        }
        return ro(a.left, a.top, u, s)
    }
    var ao = "undefined" != typeof SVGGraphicsElement ? function(t) {
        return t instanceof $e(t).SVGGraphicsElement
    } : function(t) {
        return t instanceof $e(t).SVGElement && "function" == typeof t.getBBox
    };

    function io(t) {
        return He ? ao(t) ? function(t) {
            var n = t.getBBox();
            return ro(0, 0, n.width, n.height)
        }(t) : oo(t) : to
    }

    function ro(t, n, e, o) {
        return {
            x: t,
            y: n,
            width: e,
            height: o
        }
    }
    var uo = function() {
            function t(t) {
                this.broadcastWidth = 0, this.broadcastHeight = 0, this.contentRect_ = ro(0, 0, 0, 0), this.target = t
            }
            return t.prototype.isActive = function() {
                var t = io(this.target);
                return this.contentRect_ = t, t.width !== this.broadcastWidth || t.height !== this.broadcastHeight
            }, t.prototype.broadcastRect = function() {
                var t = this.contentRect_;
                return this.broadcastWidth = t.width, this.broadcastHeight = t.height, t
            }, t
        }(),
        so = function() {
            return function(t, n) {
                var e, o, a, i, r, u, s, c = (o = (e = n).x, a = e.y, i = e.width, r = e.height, u = "undefined" != typeof DOMRectReadOnly ? DOMRectReadOnly : Object, s = Object.create(u.prototype), Qe(s, {
                    x: o,
                    y: a,
                    width: i,
                    height: r,
                    top: a,
                    right: o + i,
                    bottom: r + a,
                    left: o
                }), s);
                Qe(this, {
                    target: t,
                    contentRect: c
                })
            }
        }(),
        co = function() {
            function t(t, n, e) {
                if (this.activeObservations_ = [], this.observations_ = new Ke, "function" != typeof t) throw new TypeError("The callback provided as parameter 1 is not a function.");
                this.callback_ = t, this.controller_ = n, this.callbackCtx_ = e
            }
            return t.prototype.observe = function(t) {
                if (!arguments.length) throw new TypeError("1 argument required, but only 0 present.");
                if ("undefined" != typeof Element && Element instanceof Object) {
                    if (!(t instanceof $e(t).Element)) throw new TypeError('parameter 1 is not of type "Element".');
                    var n = this.observations_;
                    n.has(t) || (n.set(t, new uo(t)), this.controller_.addObserver(this), this.controller_.refresh())
                }
            }, t.prototype.unobserve = function(t) {
                if (!arguments.length) throw new TypeError("1 argument required, but only 0 present.");
                if ("undefined" != typeof Element && Element instanceof Object) {
                    if (!(t instanceof $e(t).Element)) throw new TypeError('parameter 1 is not of type "Element".');
                    var n = this.observations_;
                    n.has(t) && (n.delete(t), n.size || this.controller_.removeObserver(this))
                }
            }, t.prototype.disconnect = function() {
                this.clearActive(), this.observations_.clear(), this.controller_.removeObserver(this)
            }, t.prototype.gatherActive = function() {
                var t = this;
                this.clearActive(), this.observations_.forEach(function(n) {
                    n.isActive() && t.activeObservations_.push(n)
                })
            }, t.prototype.broadcastActive = function() {
                if (this.hasActive()) {
                    var t = this.callbackCtx_,
                        n = this.activeObservations_.map(function(t) {
                            return new so(t.target, t.broadcastRect())
                        });
                    this.callback_.call(t, n, t), this.clearActive()
                }
            }, t.prototype.clearActive = function() {
                this.activeObservations_.splice(0)
            }, t.prototype.hasActive = function() {
                return this.activeObservations_.length > 0
            }, t
        }(),
        lo = "undefined" != typeof WeakMap ? new WeakMap : new Ke,
        mo = function() {
            return function t(n) {
                if (!(this instanceof t)) throw new TypeError("Cannot call a class as a function.");
                if (!arguments.length) throw new TypeError("1 argument required, but only 0 present.");
                var e = Ze.getInstance(),
                    o = new co(n, e, this);
                lo.set(this, o)
            }
        }();
    ["observe", "unobserve", "disconnect"].forEach(function(t) {
        mo.prototype[t] = function() {
            var n;
            return (n = lo.get(this))[t].apply(n, arguments)
        }
    });
    var bo = void 0 !== Fe.ResizeObserver ? Fe.ResizeObserver : mo,
        fo = 200,
        yo = 45,
        ho = 113,
        po = 600,
        _o = 42,
        go = 600 / 2.6,
        vo = function(t, n, e) {
            n = n < ho ? fo : Math.max(Math.min(n, Math.max(2.6 * e, _o), po), Math.min(n, Math.max(10 * e, _o), po), ho), t.style.width = n + "px", e = e < _o ? yo : Math.max(Math.min(e, 1 / 2.6 * n), Math.min(e, .1 * n), _o), t.style.height = e + "px"
        };

    function Lo(t) {
        var n;
        (n = t).clientWidth < ho ? n.style.width = fo + "px" : n.clientWidth > po && (n.style.width = po + "px"), n.clientHeight < _o ? n.style.height = yo + "px" : n.clientHeight > go && (n.style.height = go + "px"), new bo(function(n, e) {
            for (var o = function(n) {
                    window.requestAnimationFrame(function() {
                        var e = n.contentRect,
                            o = e.width,
                            a = e.height;
                        (o || a) && vo(t, o, a)
                    })
                }, a = 0, i = n; a < i.length; a++) {
                o(i[a])
            }
        }).observe(t), window.addEventListener("resize", function() {
            t && (t.style.width = "inherit")
        })
    }
    var Eo = "AmazonPayMAXOChange";

    function So(t, n) {
        var e = {
                amazonCheckoutSessionId: t.amazonCheckoutSessionId,
                changeAction: t.changeAction,
                viewType: n
            },
            o = a(_);
        return function(t, n, e) {
            return "" + Rt(n, e) + z + "?" + s(t)
        }(e, a(g), o)
    }

    function Ao(t, n) {
        var e, o = it,
            i = a(g);
        i && (o.ledgerCurrency = i), "changeAddress" == t.changeAction ? e = Kn.CHANGE_SHIPPING_ADDRESS : "changePayment" == t.changeAction && (e = Kn.CHANGE_PAYMENT_METHOD), Zn(o, e, null, n, null)
    }

    function wo(t, n) {
        var e, o, a;
        Ut(n, "amazonCheckoutSessionId"), Ut(n, "changeAction"), o = ["changeAddress", "changePayment"], a = n[e = "changeAction"], o.indexOf(a) < 0 && y("Invalid value '" + a + "' for '" + e + "', please use one of the available values: " + o.join(", ") + ".")
    }
    var Co = "recurringUpgrade";

    function Io(t, n) {
        if (n.upgradeAction == Co) {
            var e = de(function(t) {
                try {
                    var n = JSON.parse(t.payloadJSON),
                        e = n.merchantId,
                        o = {
                            payloadJSON: t.payloadJSON,
                            signature: t.signature,
                            publicKeyId: t.publicKeyId,
                            merchantId: e,
                            algorithm: t.algorithm || Pe,
                            upgradeAction: t.upgradeAction,
                            merchantDomain: window.location.hostname,
                            origin_url: window.location.href
                        };
                    return n.checkoutLanguage && (o.checkoutLanguage = n.checkoutLanguage), n.scopes && (o.scopes = n.scopes), n.productType && (o.productType = n.productType), n.ledgerCurrency && (o.ledgerCurrency = n.ledgerCurrency), o
                } catch (t) {
                    return y("Please pass valid JSON payload for upgradeAction."), {}
                }
            }(n));
            document.body.appendChild(e), e.submit()
        }
    }

    function Go(t, n, e) {
        var o, a, i, r = e.createCheckoutSessionConfig || e.signInConfig;
        if (r && r.payloadJSON) try {
            (i = JSON.parse(r.payloadJSON)) && (i.storeId && (o = i.storeId), a = i.webCheckoutDetails ? i.webCheckoutDetails.checkoutReviewReturnUrl : i.signInReturnUrl)
        } catch (t) {}
        return ln("GET", function(t, n, e, o) {
            var a, i = zt.apchsHost,
                r = {
                    ledgerCurrency: n
                },
                u = c(window.location.href);
            if (u)
                if (u.toLowerCase() === zt.boltDomain.toLowerCase()) {
                    var d = c(document.referrer);
                    r.originDomain = d || u
                } else r.originDomain = u;
            return e && (r.storeId = e), o && (a = c(o)) && (r.returnDomain = a), [i, "merchantAccount", t, "accountStatus?" + s(r)].join("/")
        }(t, n, o, a), !1)
    }
    var xo = "/checkout/signout";

    function To(t, n) {
        t && y("amazon.Pay.signout() failed."), n && "function" == typeof n && n()
    }

    function ko(t) {
        return Object.keys(t).forEach(function(n) {
            t[n] || delete t[n]
        }), t
    }

    function zo(t) {
        var n = {};
        if (t && t.dataset) {
            n.ledgerCurrency = t.dataset.ledgerCurrency, n.sandbox = "true" == t.dataset.sandbox, n.checkoutLanguage = t.dataset.language, n.productType = t.dataset.productType, n.placement = t.dataset.placement, n.design = t.dataset.design, n.buttonColor = t.dataset.buttonColor, n.merchantId = t.dataset.amazonpayMerchantId;
            var e = function(t) {
                var n = {};
                return n.amount = t.dataset.amount, n.currencyCode = t.dataset.currencyCode, ko(n)
            }(t);
            Object.keys(e).length > 0 && (n.estimatedOrderAmount = e);
            var o = function(t) {
                var n = {};
                return n.payloadJSON = t.dataset.payload, n.publicKeyId = t.dataset.publicKeyId, n.signature = t.dataset.signature, ko(n)
            }(t);
            if (Object.keys(o).length > 0) n[n.productType == R ? J : K] = o;
            tn(n, T, Object.keys(Pt))
        }
        return ko(n)
    }

    function Oo(t, n) {
        Array.prototype.forEach.call(t, function(t) {
            var e = Math.random().toString(36).substring(2, 6) + Math.random().toString(36).substring(2, 4);
            t.classList.add("" + F + e);
            var o = n("." + F + e, zo(t));
            (function(t) {
                if (!t) return !1;
                var n = "function" == typeof t.onClick,
                    e = "function" == typeof t.initCheckout;
                return n && e
            })(o) && ("function" == typeof window.amznButtonClickHandler ? window.amznButtonClickHandler(o) : (document.addEventListener("DOMContentLoaded", function(t) {
                "function" == typeof window.amznButtonClickHandler && window.amznButtonClickHandler(t)
            }.bind(o)), "interactive" !== document.readyState && "complete" !== document.readyState || y("Unable to locate a window.amznButtonClickHandler function")))
        })
    }
    var Po = "UBPSandboxMessage",
        Do = "APAYCOMPUserActionStripeClick",
        Bo = "APAYCOMPUserActionStripeRender",
        Mo = "APAYCOMPUserActionStripeDismissClick",
        No = "APAYCOMPUserActionStripeLearnMoreClick",
        Uo = {
            CLICK: "maxo-stripe-click",
            RENDER: "maxo-stripe-render",
            DISMISS: "stripe-dismiss-click",
            LEARN_MORE: "stripe-learn-more-click"
        };

    function Ro(t, n) {
        var e = new Hn(t),
            o = zt.apchsHost;
        e.addInfo({
            name: Kn.PAGE_ACTION,
            value: n
        }), e.addInfo({
            name: Kn.SESSION_ID,
            value: a(Kn.SESSION_ID)
        }), e.addInfo({
            name: Kn.SUB_PAGE_TYPE,
            value: Kn.MAXO_BUTTON
        });
        var i = window.location.host,
            r = Kn.MERCHANT_DOMAIN_KEY + ":" + i;
        e.addInfo({
            name: Kn.ADDITIONAL_REQUEST_DATA,
            value: r
        }), e.addCounter({
            name: n,
            tags: [Kn.MAXO_BUTTON_TAG]
        });
        var u = a(g);
        return u && Fn(e, o, zt.coe[u], u), e.toQueryString()
    }

    function jo(t) {
        if (!(t && t.data && t.data.data && t.data.data.mType)) return "";
        var n, e, o = t.data.data.mType,
            a = function() {
                var t = "[class*=" + x + "]",
                    n = document.querySelector(t),
                    e = "-1";
                if (n)
                    for (var o = n.classList, a = 0; a < o.length; a++) {
                        var i = o[a];
                        if (0 === i.indexOf(x)) {
                            var r = i.lastIndexOf("-");
                            if (r === x.length) return e = i.substr(r + 1)
                        }
                    }
                return e
            }(),
            i = "";
        switch (o) {
            case Do:
                Ro(a, Uo.CLICK), n = "[class*=" + x + "]", (e = document.querySelector(n)) && e.click(), i = Uo.CLICK;
                break;
            case Bo:
                Ro(a, Uo.RENDER), i = Uo.RENDER;
                break;
            case No:
                Ro(a, Uo.LEARN_MORE), i = Uo.LEARN_MORE;
                break;
            case Mo:
                Ro(a, Uo.DISMISS), i = Uo.DISMISS
        }
        return i
    }

    function Jo(t) {
        var n;
        t && t.data && t.origin && void 0 !== (n = t) && void 0 !== n.data && n.data.mType === Po && jo(t)
    }
    var Ko = function(t, n) {
            rn(L);
            var e = Zt("renderButton", t, n),
                a = e.ele,
                i = e.options,
                r = G;
            tn(i, T, Object.keys(Pt)), en(i), nn(i);
            var u = on(i),
                s = "amazonpaybutton" + "-" + Date.now(),
                c = Ot ? {
                    renderButton: re,
                    enableButton: function() {},
                    disableButton: ue
                } : {
                    renderButton: wn,
                    enableButton: function() {},
                    disableButton: Cn
                };
            Lo(a);
            var l = {
                    buttonWidth: a.offsetWidth,
                    buttonHeight: a.offsetHeight
                },
                m = null,
                b = function(t, n) {
                    var e;
                    return null == n.createCheckoutSession && null == n.createCheckoutSessionConfig && null == n.signInConfig ? {
                        returnObject: {
                            onClick: function(t) {
                                e = t
                            },
                            initCheckout: function(t) {
                                n.createCheckoutSession = t.createCheckoutSession, n.createCheckoutSessionConfig = t.createCheckoutSessionConfig, en(n), t.estimatedOrderAmount && 0 == Object.keys(n.estimatedOrderAmount).length && (n.estimatedOrderAmount = t.estimatedOrderAmount), rn(A), je(n, !0, ot)
                            },
                            updateButtonInfo: function(t) {
                                Je(t, n)
                            }
                        },
                        buttonClickHandler: function() {
                            e ? e() : n.productType !== R || n.signInConfig || y("Invalid button definition, productType " + n.productType + " and configName do not match.")
                        }
                    } : function() {
                        rn(A);
                        var t = G;
                        n.createCheckoutSessionConfig && (t = et), Zn(n, Kn.MAXO_BUTTON_CLICK, null, null, t), je(n, !0, t)
                    }
                }(0, u);
            if ("function" == typeof b ? c.renderButton(a, s, u, b) : (c.renderButton(a, s, u, b.buttonClickHandler), (m = b.returnObject) && (r = ot)), i.createCheckoutSessionConfig && (r = et), null == m && u.productType !== R && (m = function(t) {
                    return {
                        updateButtonInfo: function(n) {
                            Je(n, t)
                        }
                    }
                }(u)), o(_, u.checkoutLanguage, 1), o(g, i.ledgerCurrency, 1), rn(E), d() && function(t, n, e) {
                    var o = qn();
                    un(C, L, Ot ? E : S), Zn(t, Kn.MAXO_BUTTON_RENDER, o + dn(C), n, e), sn(C), cn(L), cn(Ot ? E : S)
                }(u, l, r), function(t, n, e, o) {
                    if (!o.sandbox) {
                        var a = Go(o.merchantId, o.ledgerCurrency, o);
                        ! function(t, n, e) {
                            t && (t.onload = n, t.onerror = e, t.send())
                        }(a, function() {
                            if (a) try {
                                var i = JSON.parse(a.responseText);
                                200 == a.status && i && i.merchantAccountStatus !== p && e.disableButton(t, n, o)
                            } catch (t) {}
                        }, function() {})
                    }
                }(a, s, c, u), setTimeout(function() {
                    !bn() && mn() && gn(u), Qn(a, u, !0, l, r)
                }, 0), m) return m
        },
        Ho = function(t) {
            for (var n = t.split("."), e = window, o = 0, a = n; o < a.length; o++) {
                var i = a[o];
                e[i] || (e[i] = {}), e = e[i]
            }
            return e
        }("amazon.Pay");
    return Ho.renderButton = Ko, Ho.bindChangeAction = function(t, n) {
            var e = Zt("bindChangeAction", t, n),
                o = e.ele,
                i = e.options;
            wo(0, i), o.addEventListener("click", function() {
                var t, n, e, o;
                n = {
                    checkoutSessionId: (t = i).amazonCheckoutSessionId
                }, e = {
                    ledgerCurrency: a(g) || null,
                    sandbox: !1
                }, o = function(e) {
                    var o = Ge();
                    if (e && !o) {
                        var a = So(t, W),
                            i = Nt(Eo, a);
                        if (i) return Ie(i), n.viewType = W, void Ao(t, n)
                    }
                    var r = So(t, q);
                    n.viewType = q, Ao(t, n), window.location.href = r
                }, 1 == t.alwaysRedirect ? o(!1) : vn(function(t) {
                    o(Xt(t))
                }, e)
            })
        }, Ho.bindUpgradeAction = function(t, n) {
            var e, o = (e = n, ["payloadJSON", "signature", "publicKeyId", "upgradeAction"].map(function(t) {
                return Qt(e, t, function(t) {
                    return "Missing field " + t + " for bindUpgradeAction parameter."
                })
            }).filter(u).join("\n"));
            "" !== o && y(o);
            var a = Zt("bindUpgradeAction", t, n),
                i = a.ele,
                r = a.options;
            ! function(t) {
                try {
                    var n = JSON.parse(t.payloadJSON),
                        e = it;
                    e.merchantId = n.merchantId, e.ledgerCurrency = n.ledgerCurrency, Zn(e, Kn.BIND_UPGRADE_ACTION, null, null, null)
                } catch (t) {}
            }(n), i.addEventListener("click", function() {
                Io(0, r)
            })
        }, Ho.signout = function(t) {
            var n = a(_),
                e = a(g);
            if (n && e) {
                var o = Rt(e, n);
                "GBP" === e ? n = "en_GB" : "EUR" === e && "en_GB" === n && (n = "de_DE");
                var i = ln("GET", "" + o + xo + "?" + s({
                    language: n
                }), !0, !1);
                i && (i.onload = function() {
                    var n, e;
                    if (i) try {
                        var o = JSON.parse(i.responseText);
                        200 == i.status && o ? (n = o.result, e = "amazon.Pay.signout() completed successfully.", console.log(f + "\n" + e)) : n = void 0
                    } catch (t) {
                        n = void 0
                    } finally {
                        To(!n, t)
                    }
                }, i.onerror = function() {
                    To(!0, t)
                }, i.send())
            }
        }, Ho.initCheckout = function(t) {
            if ("object" != typeof t) y("Missing options parameter for amazon.Pay.initCheckout");
            else {
                rn(A), tn(t, T, Object.keys(Pt));
                var n = on(t),
                    e = G;
                if (t.createCheckoutSessionConfig) {
                    e = at;
                    var a = (i = document.referrer, (r = document.createElement("a")).href = i, r.hostname);
                    Zn(n, Kn.MAXO_BUTTON_RENDER, null, null, e, a), Zn(n, Kn.MAXO_BUTTON_CLICK, null, null, e)
                }
                o(_, n.checkoutLanguage, 1), o(g, t.ledgerCurrency, 1), je(n, !0, e)
            }
            var i, r
        },
        function t(n) {
            var e = document.querySelectorAll(H);
            e && e.length > 0 ? Oo(e, n) : document.addEventListener("DOMContentLoaded", function() {
                t(n)
            })
        }(Ko), le("beforeunload", window, function() {
            be = !0
        }), void 0 !== window.postMessage && le("message", window, Jo), t.renderButton = Ko, t
}({});