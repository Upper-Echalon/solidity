contract C {
    function f() public view returns (uint64) {
        return block.slotnum;
    }
    function g() public view returns (uint64 ret) {
        assembly {
            ret := slotnum()
        }
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
