const Navigate = Symbol("Navigate");

let mockPageReference = null;

export const NavigationMixin = (Base) => {
  return class extends Base {
    [Navigate](pageReference) {
      mockPageReference = {
        pageReference
      };
    }
  };
};

NavigationMixin.Navigate = Navigate;

export function getNavigateCalledWith() {
  return mockPageReference;
}

export function reset() {
  mockPageReference = null;
}
