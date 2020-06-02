'use strict';

function price(supply, demand) {
  return 5 ** (demand - supply);
}

console.log(price(0, 1 / 30));
