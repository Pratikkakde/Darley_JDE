import { IS } from './is';
import { RANDOM } from './random';

const STATUS_KEY = 'isSuccess';
const DATA_KEY = 'responseData';
const MESSAGE_KEY = 'responseMessage';

const SUCCESS = 'success';

function Mock() {

    this.response = (data) => {
        let response = {
            [STATUS_KEY]: true,
            [DATA_KEY]: data,
            [MESSAGE_KEY]: SUCCESS,
        };
        console.group('MOCK.response()');
        console.log(JSON.stringify(response));
        console.groupEnd();
        return response;
    },

    // # - Number (0-9)
    // ! - Number (2-9)
    // ^ - Number (5-9)
    // ? - Char
    // > - Char Uppercase
    // < - Char LowerCase
    // * - Any [Number, Char]

    this.order = {
        list: (count) => {
            let data = [];
            if (!IS.integer(count)) {
                count = 100;
            }

            for (let i = 0; i < count; i++) {
                let newItem = {
                    Id: RANDOM.recordId(),
                    OrderNumber: RANDOM.stringByPattern('000^^^^^!!!'),
                    AccountId: RANDOM.recordId(),
                    PoNumber: `#${RANDOM.stringByPattern('!!!^^^')}`,
                    TotalAmount: RANDOM.integer(1, 100000),
                    OrderedDate: '2022-02-24',
                    StoreStatus__c: RANDOM.arrayItem(['Submitted', 'Shipped']),
                };
                data.push(newItem);
            }
            return this.response(data);
        },

        detail: (count) => {
            let products = [];
            if (!IS.integer(count)) {
                count = 10;
            }

            let subtotal = 0;
            let discount = 0;
            let shipping = 0;
            let tax = 0;
            let total = 0;

            // for (let i = 0; i < count; i++) {
            //     let newItem = {
            //         Id: RANDOM.recordId(),
            //         OrderNumber: RANDOM.stringByPattern('000^^^^^!!!'),
            //         AccountId: RANDOM.recordId(),
            //         PoNumber: `#${RANDOM.stringByPattern('!!!^^^')}`,
            //         TotalAmount: RANDOM.integer(1, 100000),
            //         OrderedDate: '2022-02-24',
            //         StoreStatus__c: RANDOM.arrayItem(['Submitted', 'Shipped']),
            //     };
            //     products.push(newItem);
            // }

            return this.response({
                order: {
                    number: RANDOM.stringByPattern('000^^^^^!!!'),
                    orderDate: '2022-02-24',
                    status: 'Submitted',
                    currencyIsoCode: 'USD',
                },
                shipping: {
                    specialInstruction: 'Special Instruction',
                    street: '25 Beach 219th St',
                    city: 'Breezy Point',
                    state: 'NY',
                    postalCode: '11697',
                    country: 'United State',
                },
                billing: {
                    accountName: 'Account Name',
                    billingStreet: '6417 16th St',
                    billingCity: 'Alexandria',
                    billingState: 'VA',
                    billingPostalCode: '22307',
                    billingCountry: 'United State',
                },
                payment: {
                    poNumber: `#${RANDOM.stringByPattern('!!!^^^')}`,
                    creditCard: `**** ${RANDOM.stringByPattern('####')}`,
                },
                trackingLinks: ['http://google.com', 'http://google.com'],
                products,
                totals: {
                    subtotal,
                    discount,
                    shipping,
                    tax,
                    total
                },
            });
        },
    };

}

const MOCK = new Mock();
export { MOCK };