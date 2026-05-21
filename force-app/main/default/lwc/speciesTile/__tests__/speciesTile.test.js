import { createElement } from "lwc";
import SpeciesTile from "c/speciesTile";

import { getNavigateCalledWith, reset } from "lightning/navigation";

// =========================
// MOCK NAVIGATION
// =========================

const mockNavigate = jest.fn();
let mockPageReference;

jest.mock(
  "lightning/navigation",
  () => {
    const Navigate = Symbol("Navigate");
    const NavigationMixin = (Base) => {
      return class extends Base {
        [Navigate](pageReference) {
          mockPageReference = pageReference;
          mockNavigate(pageReference);
        }
      };
    };

    NavigationMixin.Navigate = Navigate;

    return {
      NavigationMixin,
      getNavigateCalledWith: jest.fn(() => ({
        pageReference: mockPageReference
      })),
      reset: jest.fn(() => {
        mockPageReference = undefined;
        mockNavigate.mockClear();
      })
    };
  },
  { virtual: true }
);

const mockSpecies = {
  Id: "s01",
  Name: "Aloe Vera",
  Description__c: "Planta resistente",
  Image_URL__c: "https://example.com/aloe.jpg",
  Location__c: "Outdoors - Garden"
};

function createComponent(speciesData) {
  const element = createElement("c-species-tile", {
    is: SpeciesTile
  });

  element.species = speciesData;

  document.body.appendChild(element);

  return element;
}

describe("c-species-tile", () => {
  afterEach(() => {
    reset();

    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }

    jest.clearAllMocks();
  });

  it("renders species correctly", () => {
    const element = createComponent(mockSpecies);

    const title = element.shadowRoot.querySelector(".title");

    expect(title.textContent).toBe(mockSpecies.Name);
  });

  it("renders the details button", () => {
    const element = createComponent(mockSpecies);

    const button = element.shadowRoot.querySelector("lightning-button");

    expect(button.label).toBe("View Details");
  });

  it("navigates correctly", () => {
    const element = createComponent(mockSpecies);

    const button = element.shadowRoot.querySelector("lightning-button");

    button.dispatchEvent(new CustomEvent("click"));

    const { pageReference } = getNavigateCalledWith();

    expect(pageReference).toEqual({
      type: "standard__recordPage",
      attributes: {
        recordId: mockSpecies.Id,
        objectApiName: "Species__c",
        actionName: "view"
      }
    });
  });
});
