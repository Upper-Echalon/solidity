contract C {
    function f() public pure {
        assembly { pop(slotnum()) }
    }
    function g() public pure returns (uint64) {
        return block.slotnum;
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
// TypeError 2527: (67-76): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (149-162): Function declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
