import { IS } from './is';

const GUEST_CART_KEY = 'guest_cart_id';
const CART_ICON_ITEMS_KEY = 'cart_icon_items';
const CART_ICON_PRODUCTS_KEY = 'cart_icon_products';
const FOOTER_MENU = 'footer_menu';
const MY_ACCOUNT_MENU = 'my_account_menu';
const COOKIE_STORE_DELAY = 'cookie_store_delay';

function Storage() {
    this.getItem = (key) => {
        if (localStorage && localStorage.setItem) {
            if (IS.stringNotEmpty(key)) {
                return localStorage.getItem(key);
            }
        } else {
            console.warn('"Local Storage" is not supported');
        }
        return false;
    }

    this.setItem = (key, value) => {
        if (localStorage && localStorage.setItem) {
            if (IS.stringNotEmpty(key)) {
                localStorage.setItem(key, value);
                return true;
            }
        } else {
            console.warn('"Local Storage" is not supported');
        }
        return false;
    }

    this.removeItem = (key) =>  {
        if (localStorage && localStorage.setItem) {
            if (IS.stringNotEmpty(key)) {
                localStorage.removeItem(key);
                return true;
            }
        } else {
            console.warn('"Local Storage" is not supported');
        }
        return false;
    }

    // GUEST CART ID
    this.getGuestCartId = () => {
        let guestCartId = this.getItem(GUEST_CART_KEY);
        return IS.stringNotEmpty(guestCartId) ? guestCartId : null;
    }

    this.setGuestCartId = (value) => {
        return this.setItem(GUEST_CART_KEY, value);
    }

    this.clearGuestCartId = () => {
        return this.removeItem(GUEST_CART_KEY);
    }

    // GUEST CART ICON QUANTITY
    this.getGuestCartIconItems = () => {
        let guestCartIconItems = this.getItem(CART_ICON_ITEMS_KEY);
        return IS.numeric(+guestCartIconItems) ? +guestCartIconItems : null;
    }

    this.getGuestCartIconProducts = () => {
        let guestCartIconProducts = this.getItem(CART_ICON_PRODUCTS_KEY);
        return IS.numeric(+guestCartIconProducts) ? +guestCartIconProducts : null;
    }

    this.setGuestCartIconItems = (value) => {
        return this.setItem(CART_ICON_ITEMS_KEY, value);
    }

    this.setGuestCartIconProducts = (value) => {
        return this.setItem(CART_ICON_PRODUCTS_KEY, value);
    }

    this.clearGuestCartIconItems = () => {
        return this.removeItem(CART_ICON_ITEMS_KEY);
    }

    this.clearGuestCartIconProducts = () => {
        return this.removeItem(CART_ICON_PRODUCTS_KEY);
    }

    // FOOTER
    this.getFooterMenu = () => {
        let footerMenu = this.getItem(FOOTER_MENU);
        return IS.stringNotEmpty(footerMenu) ? JSON.parse(footerMenu) : null;
    }

    this.setFooterMenu = (value) => {
        return this.setItem(FOOTER_MENU, JSON.stringify(value));
    }

    this.clearFooterMenu = () => {
        return this.removeItem(FOOTER_MENU);
    }

    // MY ACCOUNT MENU
    this.getMyAccountMenu = () => {
        let footerMenu = this.getItem(MY_ACCOUNT_MENU);
        return IS.stringNotEmpty(footerMenu) ? JSON.parse(footerMenu) : null;
    }

    this.setMyAccountMenu = (value) => {
        return this.setItem(MY_ACCOUNT_MENU, JSON.stringify(value));
    }

    this.clearMyAccountMenu = () => {
        return this.removeItem(MY_ACCOUNT_MENU);
    }

    // COOKIE DELAY
    this.getCookieDelay = (delayDays) => {
        let result = false;
        let cookieStoreDelayed = this.getItem(COOKIE_STORE_DELAY);
        if (
            IS.stringNotEmpty(cookieStoreDelayed)
            && IS.integer(delayDays)
            && Date.now() < cookieStoreDelayed + (delayDays * 24 * 60 * 60 * 1000)
        ) {
            result = true;
        } else {
            this.removeItem(COOKIE_STORE_DELAY);
        }
        return result;
    }

    this.setCookieDelay = (delayDays) => {
        if (IS.integer(delayDays)) {
            return this.setItem(COOKIE_STORE_DELAY, `${Date.now() + (delayDays * 24 * 60 * 60 * 1000)}`);
        }
        return false;
    }

    this.clearCookieDelay = () => {
        return this.removeItem(COOKIE_STORE_DELAY);
    }

}

const STORAGE = new Storage();
export { STORAGE };