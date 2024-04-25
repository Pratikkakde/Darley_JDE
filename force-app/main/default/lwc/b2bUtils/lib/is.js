import { TYPES } from '../list/types';
import { REGEXP } from '../list/regexp';
import { ICONS } from '../list/icons';

const TRUE = 'true';
const FALSE = 'false';

function Is() {

    this.type = (value, type) => {
        if (!type || typeof type !== TYPES.string || type.length < 2) {
            return false;
        }

        let types = Object.values(TYPES);
        let typeOf = type.toLowerCase().trim();
        if (types.indexOf(typeOf) === -1) {
            return false;
        }

        let typeUppercase = `${typeOf[0].toUpperCase()}${typeOf.substring(1)}`;
        if (typeOf === TYPES.generator || typeOf === TYPES.async) {
            typeUppercase += `${TYPES.function[0].toUpperCase()}${TYPES.function.substring(1)}`;
        } else if (typeOf === TYPES.regexp) {
            typeUppercase = 'RegExp';
        }
        let typeString = `[${TYPES.object} ${typeUppercase}]`;

        if (typeOf === TYPES.null || typeOf === TYPES.array || typeOf === TYPES.date || typeOf === TYPES.regexp) {
            typeOf = TYPES.object;
        }

        return typeof value === typeOf && Object.prototype.toString.call(value) === typeString;
    };

    this.undefined = (value) => {
        return this.type(value, TYPES.undefined) && value === undefined;
    };

    this.null = (value) => {
        return this.type(value, TYPES.null) && value === null;
    };

    this.boolean = (value) => {
        if (
            this.stringNotEmpty(value) &&
            (value.toLowerCase() === TRUE || value.toLowerCase() === FALSE)
        ) {
            value = JSON.parse(value.toLowerCase());
        }
        return this.type(value, TYPES.boolean);
    };

    this.false = (value) => {
        return this.boolean(value) && Boolean(Number(value)) === false;
    };

    this.true = (value) => {
        return this.boolean(value) && Boolean(Number(value)) === true;
    };

    this.number = (value) => {
        return this.type(value, TYPES.number);
    };

    this.infiniteCondition = (value) => {
        return value === Infinity || value === -Infinity;
    };

    this.infinite = (value) => {
        return this.number(value) &&
            this.infiniteCondition(value);
    };

    this.nanCondition = (value) => {
        return value !== value;
    };

    this.nan = (value) => {
        return this.number(value) &&
            this.nanCondition(value);
    };

    this.numeric = (value) => {
        return this.number(value) &&
            !this.infiniteCondition(value) &&
            !this.nanCondition(value);
    };

    this.integer = (value) => {
        return this.numeric(value) &&
            value % 1 === 0;
    };

    this.decimal = (value) => {
        return this.numeric(value) &&
            value % 1 !== 0;
    };

    this.even = (value) => {
        return this.integer(value) &&
            value % 2 === 0;
    };

    this.odd = (value) => {
        return this.integer(value) &&
            value % 2 !== 0;
    };

    this.arrayLike = (value) => {
        return (
            !!value &&
            !this.boolean(value) &&
            Object.prototype.hasOwnProperty.call(value, 'length') &&
            isFinite(value.length) &&
            this.integer(value.length) &&
            value.length >= 0
        );
    };

    this.array = (value) => {
        return Array.isArray(value) || this.type(value, TYPES.array);
    };

    this.arrayEmpty = (value) => {
        return this.array(value) && value.length === 0;
    };

    this.arrayNotEmpty = (value) => {
        return this.array(value) && value.length !== 0;
    };

    this.arrayIncludes = (sourceArray, searchValue) => {
        let result = false;
        if (this.arrayNotEmpty(sourceArray)) {
            sourceArray.forEach((item) => {
                if (item === searchValue) {
                    result = true;
                }
            });
        }
        return result;
    };

    this.object = (value) => {
        return this.type(value, TYPES.object);
    };

    this.objectEmpty = (value) => {
        return this.object(value) && JSON.stringify(value) === '{}';
    };

    this.objectNotEmpty = (value) => {
        return this.object(value) && JSON.stringify(value) !== '{}';
    };

    this.objectProperty = (value, property) => {
        return this.objectNotEmpty(value) && value.hasOwnProperty(property);
    };

    this.function = (value) => {
        var isAlert = typeof window !== TYPES.undefined && value === window.alert;
        if (isAlert) {
            return true;
        }

        return this.type(value, TYPES.function) ||
            this.type(value, TYPES.generator) ||
            this.type(value, TYPES.async);
    };

    this.string = (value) => {
        return this.type(value, TYPES.string);
    };

    this.stringEmpty = (value) => {
        return this.string(value) && value.length === 0;
    };

    this.stringNotEmpty = (value) => {
        return this.string(value) && value.length !== 0;
    };

    this.stringIncludes = (sourceString, searchString) => {
        if (
            this.stringNotEmpty(sourceString) &&
            this.stringNotEmpty(searchString) &&
            sourceString.indexOf(searchString) !== -1
        ) {
            return true;
        }
        return false;
    };

    this.arguments = (value) => {
        return this.type(value, TYPES.arguments) || (
            !this.array(value) &&
            this.arrayLike(value) &&
            this.object(value) &&
            this.function(value.callee)
        );
    };

    this.argumentsEmpty = (value) => {
        return this.arguments(value) && value.length === 0;
    },

    this.argumentsNotEmpty = (value) => {
        return this.arguments(value) && value.length !== 0;
    };

    this.date = (value) => {
        return this.type(value, TYPES.date);
    };

    this.dateValid = (value) => {
        return this.date(value) && !this.nan(Number(value));
    };

    this.regexp = (value) => {
        return this.type(value, TYPES.regexp);
    };

    this.base64 = (value) => {
        return this.stringNotEmpty(value) && REGEXP.base64.test(value);
    };

    this.hex = (value) => {
        return this.stringNotEmpty(value) && REGEXP.hex.test(value);
    };

    this.symbol = (value) => {
        return (
            typeof Symbol === TYPES.function &&
            this.type(value, TYPES.symbol) &&
            typeof Symbol.prototype.valueOf.call(value) === TYPES.symbol
        );
    };

    this.url = (value) => {
        if (
            this.stringNotEmpty(value) &&
            (
                /^[a-z][a-z0-9+.-]*:/.test(value) ||
                value.indexOf('http://') !== -1 ||
                value.indexOf('https://') !== -1 ||
                value.indexOf('ftp://') !== -1 ||
                value.indexOf('/www.') !== -1
            )
        ) {
            return true;
        }
        return false;
    }

    this.promise = (value) => {
        return value !== null &&
            (typeof value === 'object' || typeof value === 'function') &&
            typeof value.then === 'function';
    }

    // FIELDS
    this.phoneNumber = (value) => {
        if (
            this.stringNotEmpty(value) && 
            this.regexp(REGEXP.phone) &&
            REGEXP.phone.test(value)
        ) {
            return true;
        }
        return false;
    }

    this.email = (value) => {
        if (
            this.stringNotEmpty(value) && 
            this.regexp(REGEXP.email) &&
            REGEXP.email.test(value)
        ) {
            return true;
        }
        return false;
    }

    this.dateString = (value) => {
        if (
            this.stringNotEmpty(value) && 
            this.regexp(REGEXP.date) &&
            REGEXP.date.test(value)
        ) {
            return true;
        }
        return false;
    }

    this.utilityIcon = (iconName) => {
        if (
            this.stringNotEmpty(iconName)
            && this.arrayIncludes(ICONS.utility, iconName.toLowerCase())
        ) {
            return true;
        }
        return false;
    }

}

const IS = new Is();
export { IS };