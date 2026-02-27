.pragma library

function getVAT(dpThing) {
    if (!dpThing || !dpThing.thingClass || !dpThing.thingClass.id) {
        return 0.;
    }

    let epexDayAheadThingClassId = "{678dd2a6-b162-4bfb-98cc-47f225f9008c}";
    if (dpThing.thingClass.id.toString() === epexDayAheadThingClassId) {
        let addedVATParam = dpThing.paramByName("addedVAT");
        return (addedVATParam && typeof addedVATParam.value === "number") ?
                    addedVATParam.value :
                    0.;
    } else {
        // Other dynamic tariffs already include the VAT in their prices.
        return 0.;
    }
}

function relPrice2AbsPrice(relPrice, dynamicPriceThing) {
    if (!dynamicPriceThing) return 0;
    let averagePrice = dynamicPriceThing.stateByName("averageTotalCost").value;
    let minPrice = dynamicPriceThing.stateByName("lowestPrice").value;
    let maxPrice = dynamicPriceThing.stateByName("highestPrice").value;
    if (averagePrice == minPrice || averagePrice == maxPrice) {
        return averagePrice;
    }
    var thresholdPrice;
    if (relPrice <= 0) {
        thresholdPrice = averagePrice - 0.01 * relPrice * (minPrice - averagePrice);
    } else {
        thresholdPrice = 0.01 * relPrice * (maxPrice - averagePrice) + averagePrice;
    }
    thresholdPrice = thresholdPrice.toFixed(2);
    return thresholdPrice;
}
