import { IS } from './is';

const EVENTS = {};

function Dispatcher() {

    this.registerListener = (thisArg, pageId, eventName, callback) => {
        if (
            IS.stringNotEmpty(eventName) &&
            callback &&
            IS.stringNotEmpty(pageId)
        ) {
            if (!EVENTS[eventName]) {
                EVENTS[eventName] = [];
            }

            const duplicate = EVENTS[eventName].find((listener) => {
                return listener.callback === callback &&
                    listener.pageId === pageId &&
                    listener.thisArg === thisArg;
            });

            if (!IS.objectNotEmpty(duplicate)) {
                EVENTS[eventName].push({ callback, pageId, thisArg });
            }
        } else {
            console.warn('Unable to register a new event');
        }
    };

    this.unregisterListener = (pageId, eventName, callback) => {
        if (IS.arrayNotEmpty(EVENTS[eventName])) {
            EVENTS[eventName] = EVENTS[eventName].filter(
                (listener) => listener.callback !== callback || listener.pageId !== pageId
            );
        }
    };

    this.unregisterAllListeners = (pageId) => {
        Object.keys(EVENTS).forEach((eventName) => {
            EVENTS[eventName] = EVENTS[eventName].filter(
                (listener) => listener.pageId !== pageId
            );
        });
    };

    this.fireEvent = (pageId, eventName, payload) => {
        if (IS.arrayNotEmpty(EVENTS[eventName])) {
            EVENTS[eventName].forEach((listener) => {
                if (pageId === listener.pageId) {
                    try {
                        listener.callback.call(listener.thisArg, payload);
                    } catch (error) {
                        console.error(error);
                    }
                }
            });
        }
    };

}

const DISPATCHER = new Dispatcher();
export { DISPATCHER };