import { LightningElement, track, api } from 'lwc';
import { UTILS, IS } from 'c/b2bUtils';

// TEMPLATES
import linkedinTemplate from './templates/linkedin.html';
import facebookTemplate from './templates/facebook.html';
import instagramTemplate from './templates/instagram.html';
import youtubeTemplate from './templates/youtube.html';
import twitterTemplate from './templates/twitter.html';
import yelpTemplate from './templates/yelp.html';
import emailTemplate from './templates/email.html';

// ICONS
const LINKEDIN = 'linkedin';
const FACEBOOK = 'facebook';
const INSTAGRAM = 'instagram';
const YOUTUBE = 'youtube';
const TWITTER = 'twitter';
const YELP = 'yelp';
const EMAIL = 'email';

export default class B2bIcon extends LightningElement {
    @api iconName = null;

    @track iconOptions = [
        LINKEDIN, FACEBOOK, INSTAGRAM, YOUTUBE,
        TWITTER, YELP, EMAIL
    ];

    // GETTERS
    get showComponent() {
        return IS.stringNotEmpty(this.iconName)
            &&  IS.arrayNotEmpty(this.iconOptions)
            && IS.arrayIncludes(this.iconOptions, this.iconName);
    }

    get wrapperClass() {
        let result = 'b2b-icon__wrapper';
        if (this.showComponent) {
            result += ' b2b-icon_' + UTILS.onlyLetters(this.iconName).toLowerCase();
        }
        return result;
    }

    // LIFECYCLES
    render() {
        if (this.iconName === LINKEDIN) return linkedinTemplate;
        else if (this.iconName === FACEBOOK) return facebookTemplate;
        else if (this.iconName === INSTAGRAM) return instagramTemplate;
        else if (this.iconName === YOUTUBE) return youtubeTemplate;
        else if (this.iconName === TWITTER) return twitterTemplate;
        else if (this.iconName === YELP) return yelpTemplate;
        else if (this.iconName === EMAIL) return emailTemplate;
    }

}