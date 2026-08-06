contract C {
    function f() external view returns (uint64 a) {
        assembly {
            a := slotnum()
        }
    }
    function g() external view returns (uint64) {
        return block.slotnum;
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
