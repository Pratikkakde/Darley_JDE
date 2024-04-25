import { LightningElement, api } from 'lwc';

/**
* @slot themeHeader
* @slot themeFooter
*/

export default class B2bThemeEmpty extends LightningElement {
    @api themeName = null;
}