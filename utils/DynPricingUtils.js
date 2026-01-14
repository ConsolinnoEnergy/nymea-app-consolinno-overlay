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
