import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { UTILS, IS } from 'c/b2bUtils';

// METHODS
import getVariations from '@salesforce/apex/B2BProductDetailVariationController.getVariations';

const OBJECT_API_NAME = 'Product2';

export default class B2bProductVariants extends LightningElement {
    @track recordId = null;
    @track isLoading = false;
    @track isFirstRender = true;
    @track customCssContainer = UTILS.customCssContainer;

    @track variations = [];
    @track dependencies = [];

    @wire(CurrentPageReference)
    wireCurrentPageReference(response) {
        if (
            IS.objectNotEmpty(response)
            && IS.objectNotEmpty(response.attributes)
            && IS.stringNotEmpty(response.attributes.objectApiName)
            && response.attributes.objectApiName === OBJECT_API_NAME
            && IS.stringNotEmpty(response.attributes.recordId)
        ) {
            this.recordId = response.attributes.recordId;
            this.getInitialData();
        }
    };

    // GETTERS

    get showComponent() {
        return IS.arrayNotEmpty(this.variations)
            && IS.arrayNotEmpty(this.dependencies);
    }

    // LIFECYCLES

    renderedCallback() {
        if (this.isFirstRender) {
            this.isFirstRender = false;
            this.addCustomCssStyles();
        }
    }

    // METHODS

    addCustomCssStyles() {
        UTILS.addCustomCssStyles(this.template, `
            c-b2b-product-variants {
                margin-top: -0.5rem;
            }

            c-b2b-product-variants c-b2b-select .slds-input {
                font-size: 14px;
            }
        `);
    }

    async getInitialData() {
        if (this.isLoading || !IS.stringNotEmpty(this.recordId)) {
            return;
        }

        this.isLoading = true;
        let response = await UTILS.doRequest(getVariations, {
            productId: this.recordId,
        });
        if (UTILS.responseSuccess(response)) {
            this.parseResponse(UTILS.responseData(response));
        }
        this.isLoading = false;
    }

    // METHODS

    parseResponse(data) {
        let variations = [];
        let dependencies = [];
        let defaultId = null;

        if (IS.objectNotEmpty(data)) {

            // PARSE VARIATIONS
            let variantIds = [];
            if (IS.arrayNotEmpty(data.variations)) {
                data.variations.forEach((item) => {
                    let newVariant = {
                        id: IS.stringNotEmpty(item.fieldDeveloperName) ? item.fieldDeveloperName : null,
                        label: IS.stringNotEmpty(item.fieldLabel) ? item.fieldLabel : null,
                        value: null,
                        disabled: null,
                        options: IS.arrayNotEmpty(item.values) ? UTILS.parseOptions(item.values) : []
                    };
                    if (
                        IS.stringNotEmpty(newVariant.id)
                        && IS.stringNotEmpty(newVariant.label)
                        && IS.arrayNotEmpty(newVariant.options)
                    ) {
                        newVariant.options.forEach((option) => {
                            option.disabled = null;
                        });
                        variantIds.push(newVariant.id);
                        variations.push(newVariant);
                    }
                });
            }

            // PARSE DEPENDENCIES
            if (IS.arrayNotEmpty(data.dependencies) && IS.arrayNotEmpty(variantIds)) {
                data.dependencies.forEach((item) => {
                    let isError = false;
                    let newDependence = {
                        id: IS.stringNotEmpty(item.productId) ? item.productId : null,
                        isDefault: IS.true(item.default) ? true : false,
                    };

                    variantIds.forEach((variantId) => {
                        if (IS.stringNotEmpty(item[variantId])) {
                            newDependence[variantId] = item[variantId];
                        } else {
                            isError = true;
                            console.error('DEPENDENCE HAS ERROR:', item);
                        }
                    });

                    if (!isError && IS.stringNotEmpty(newDependence.id)) {
                        if (newDependence.isDefault) {
                            defaultId = newDependence.id;
                        }
                        dependencies.push(newDependence);
                    }
                });
            }
        }

        if (IS.stringNotEmpty(defaultId) && this.recordId !== defaultId) {
            window.location.href = `${window.location.origin}${UTILS.link(`/product/${defaultId}`)}`;
            return;
        }

        const { newVariations, newDependencies } = this.removeUnuselessVariation(variations, dependencies);
        this.variations = newVariations;
        this.dependencies = newDependencies;

        // PRESELECT VARIATION
        this.preselectVariation();

        // UPDATE DISABLED
        this.updateDisabled();
    }
    
    removeUnuselessVariation(variations, dependencies) {
        let newVariations = [];
        let newDependencies = [];

        if (
            IS.arrayNotEmpty(variations)
            && IS.arrayNotEmpty(dependencies)
        ) {
            let variantIds = variations.map((item) => item.id);

            let variationsMap = {};
            variations.forEach((variant) => {
                if (IS.arrayIncludes(variantIds, variant.id)) {
                    let newOptions = variant.options.map((item) => item.value);
                    if (IS.arrayNotEmpty(newOptions)) {
                        variationsMap[variant.id] = newOptions;
                    }
                }
            });

            let dependenciesMap = {};
            let tmpDependenciesMap = {};
            dependencies.forEach((dependence) => {
                variantIds.forEach((item) => {
                    if (!IS.arrayNotEmpty(tmpDependenciesMap[item])) {
                        tmpDependenciesMap[item] = [];
                    }
                    if (dependence[item]) {
                        tmpDependenciesMap[item].push(dependence[item]);
                    }
                });
            });
            for (let key in tmpDependenciesMap) {
                if (IS.arrayNotEmpty(tmpDependenciesMap[key])) {
                    dependenciesMap[key] = tmpDependenciesMap[key];
                }
            }
            
            // COMBINE IDS
            let ids = {};
            variantIds.forEach((item) => {
                ids[item] = null;
            });
            ids = Object.keys(Object.assign({}, ids, variationsMap, dependenciesMap));

            // COMBINE OPTIONS
            let newVariationsMap = {};
            ids.forEach((id) => {
                let newVariant = [];
                if (dependenciesMap[id]) {
                    dependenciesMap[id].forEach((option) => {
                        if (variationsMap[id] && IS.arrayIncludes(variationsMap[id], option)) {
                            newVariant.push(option);
                        }
                    });
                }
                if (IS.arrayNotEmpty(newVariant)) {
                    newVariationsMap[id] = newVariant;
                }
            });

            // UPDATE VARIATION
            variations.forEach((variant) => {
                if (IS.arrayIncludes(Object.keys(newVariationsMap), variant.id)) {
                    let newOptions = [];
                    variant.options.forEach((option) => {
                        if (IS.arrayIncludes(newVariationsMap[variant.id], option.value)) {
                            newOptions.push(option);
                        }
                    });
                    if (IS.arrayNotEmpty(newOptions)) {
                        variant.options = newOptions;
                        newVariations.push(variant);
                    }
                }
            });

            // UPDATE DEPENDENCIES
            dependencies.forEach((dependence) => {
                let validity = [];
                Object.keys(newVariationsMap).forEach((id) => {
                    validity.push(IS.arrayIncludes(newVariationsMap[id], dependence[id]));
                });
                if (!IS.arrayIncludes(validity, false)) {
                    newDependencies.push(dependence);
                }
            });

            //REMOVE EXTRA VARIATIONS
            if (IS.arrayNotEmpty(newVariations)) {
                newVariations.forEach((variation) => {
                    if (variation && variation.options && IS.arrayNotEmpty(variation.options)) {
                        variation.options = variation.options.filter((option, index, self) =>
                            index === self.findIndex((t) => (
                                t.value === option.value
                            ))
                        );
                    }
                });
            }

        }
        return { newVariations, newDependencies };
    }

    preselectVariation() {
        if (
            IS.stringNotEmpty(this.recordId)
            && IS.arrayNotEmpty(this.variations)
            && IS.arrayNotEmpty(this.dependencies)
        ) {
            this.dependencies.forEach((dependence) => {
                if (dependence.id === this.recordId) {
                    this.variations.forEach((variant) => {
                        this.handleChangeVariant({
                            detail: {
                                value: dependence[variant.id],
                                dataset: {
                                    id: variant.id
                                }
                            }
                        });
                    });
                }
            });
        }
    }

    getSelectedValues() {
        let result = {};
        this.variations.forEach((variant) => {
            if (IS.stringNotEmpty(variant.value)) {
                result[variant.id] =  variant.value;
            }
        });
        return result;
    }

    updateDisabled() {
        // GET SELECTED VALUES / IDS
        let selectedValues = this.getSelectedValues();
        if (!IS.objectNotEmpty(selectedValues)) {
            this.variations.forEach((variant) => {
                variant.options.forEach((option) => {
                    option.disabled = null;
                });
            });
            return;
        }

        let isSelectedOneId = Object.keys(selectedValues).filter((item) => IS.stringNotEmpty(item))[0];
        let isSelectedOneValue = Object.values(selectedValues).filter((item) => IS.stringNotEmpty(item)).length === 1;
        let variantIds = this.variations.map((item) => item.id);

        // GET SUITABLE DEPENDENCIES
        let suitableDependencies = [];
        this.dependencies.forEach((dependence) => {
            let flags = [];
            variantIds.forEach((variantId) => {
                flags.push(
                    IS.null(selectedValues[variantId])
                    || !IS.objectProperty(selectedValues, variantId)
                    || (
                        IS.stringNotEmpty(selectedValues[variantId])
                        && selectedValues[variantId] === dependence[variantId]
                    )
                );
            });
            if (!IS.arrayIncludes(flags, false)) {
                suitableDependencies.push(dependence);
            }
        });

        // GET AVAILABLE MAP
        let availableMap = {};
        if (IS.arrayNotEmpty(suitableDependencies)) {
            suitableDependencies.forEach((dependence) => {
                variantIds.forEach((variantId) => {
                    if (!IS.arrayNotEmpty(availableMap[variantId])) {
                        availableMap[variantId] = [];
                    }
                    if (dependence[variantId]) {
                        availableMap[variantId].push(dependence[variantId]);
                    }
                });
            });
        }

        // UPDATE VARIATIONS
        /*
        this.variations.forEach((variant) => {
            if (
                IS.arrayIncludes(Object.keys(availableMap), variant.id)
                && IS.arrayNotEmpty(availableMap[variant.id])
            ) {
                if (isSelectedOneValue && variant.id === isSelectedOneId) {
                    variant.options.forEach((option) => {
                        option.disabled = null;
                    });
                } else {
                    variant.options.forEach((option) => {
                        option.disabled = IS.arrayIncludes(availableMap[variant.id], option.value) ? null : true;
                    });
                }
            }
        });
        */
        // CHECK DEPENDENCIES
        if (
            IS.arrayNotEmpty(suitableDependencies)
            && suitableDependencies.length === 1
        ) {
            let isDependenceValid = variantIds.reduce((flag, key) => {
                if (!(
                    IS.stringNotEmpty(suitableDependencies[0][key])
                    && IS.stringNotEmpty(selectedValues[key])
                    && selectedValues[key] === suitableDependencies[0][key]
                )) {
                    flag = false;
                }
                return flag;
            }, true);

            if (isDependenceValid && this.recordId !== suitableDependencies[0].id) {
                window.location.href = `${window.location.origin}${UTILS.link(`/product/${suitableDependencies[0].id}`)}`;
                return;
            }
        }
    }

    // HANDLERS

    handleChangeVariant(event) {
        if (
            IS.objectNotEmpty(event.detail)
            && IS.objectNotEmpty(event.detail.dataset)
            && IS.stringNotEmpty(event.detail.dataset.id)
        ) {
            this.variations.forEach((item) => {
                if (item.id === event.detail.dataset.id) {
                    item.value = IS.stringNotEmpty(event.detail.value)
                        ? event.detail.value
                        : null;
                }
            });
            this.updateDisabled();
        }
    }

}