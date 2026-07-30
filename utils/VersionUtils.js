.pragma library

function compareSemanticVersions(version1, version2) {
    // Returns 0 if version1 == version2
    // Returns 1 if version1 > version2
    // Returns -1 if version1 < version2

    var v1 = version1.split('.').map(function(part) { return parseInt(part); });
    var v2 = version2.split('.').map(function(part) { return parseInt(part); });

    for (var i = 0; i < Math.max(v1.length, v2.length); i++) {
        var num1 = i < v1.length ? v1[i] : 0;
        var num2 = i < v2.length ? v2[i] : 0;

        if (num1 < num2) {
            return -1; // version1 is lower
        } else if (num1 > num2) {
            return 1; // version1 is higher
        }
    }

    return 0; // versions are equal
}
