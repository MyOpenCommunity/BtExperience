.pragma library

function requestLoadStatus(itemObject) {
    itemObject.requestLoadStatus()
    if (itemObject.hasConsumptionMeters)
        itemObject.requestTotals()
    itemObject.requestConsumptionUpdateStart()
}

function stopLoadRequests(itemObject) {
    itemObject.requestConsumptionUpdateStop()
}
