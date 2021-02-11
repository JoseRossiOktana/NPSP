import { createElement } from 'lwc';
import rd2ElevateCreditCardForm from 'c/rd2ElevateCreditCardForm';
import {registerSa11yMatcher} from "@sa11y/jest";

const PATH_GE_TOKENIZE_CARD = '/apex/GE_TokenizeCard';
const DISABLED_MESSAGE = 'c.RD2_ElevateDisabledMessage';

const createWidget = () => {
    let element = createElement(
        'c-rd2-elevate-credit-card-form',
        { is: rd2ElevateCreditCardForm }
    );
    return element;
}

describe('c-rd2-elevate-credit-card-form', () => {

    beforeAll(() => {
        registerSa11yMatcher();
    });

    afterEach(() => {
        clearDOM();
    });

    it('should allow disabling and enabling of widget', async () => {
        let element = createWidget();
        document.body.appendChild(element);

        return Promise.resolve()
            .then(() => {
                expect(iframe(element)).toBeTruthy();
                expect(iframe(element).src).toContain(PATH_GE_TOKENIZE_CARD);

                doNotUseElevateButton(element).click();
            })
            .then(() => {
                expect(iframe(element)).toBeFalsy();

                // The message received is always empty.  Cannot figure out why...
                // The other parts of this test work as expected.
                expect(spanDisabledMessage(element).innerHTML).toBe(DISABLED_MESSAGE);

                useElevateButton(element).click();
            })
            .then (() => {
                expect(iframe(element)).toBeTruthy();
                expect(iframe(element).src).toContain(PATH_GE_TOKENIZE_CARD);
            });
    });

    it("should be accessible", async () => {
        const element = createWidget();
        document.body.appendChild(element);

        return global.flushPromises().then(async () => {
            await expect(element).toBeAccessible();
        });
    });
});

const useElevateButton = (element) => {
    return shadowQuerySelector(element, '[data-qa-locator="button Use Elevate Now"]');
}

const doNotUseElevateButton = (element) => {
    return shadowQuerySelector(element, '[data-qa-locator="button Do Not Use Elevate"]');
}

const iframe = (element) => {
    return shadowQuerySelector(element, '.payment-services-iframe');
}

const spanDisabledMessage = (element) => {
    return shadowQuerySelector(element, '[data-qa-locator="richtext Elevate Disabled Message"]');
}

const getShadowRoot = (element) => {
    if (!element || !element.shadowRoot) {
        const tagName =
            element && element.tagName && element.tagName.toLowerCase();
        throw new Error(
            `Attempting to retrieve the shadow root of '${tagName || element}'
            but no shadowRoot property found`
        );
    }
    return element.shadowRoot;
}

const shadowQuerySelector = (element, selector) => {
    return getShadowRoot(element).querySelector(selector);
}



