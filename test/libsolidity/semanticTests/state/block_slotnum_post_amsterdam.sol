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
// f() -> 2863311530
// g() -> 2863311530
// f() -> 2863311530
// g() -> 2863311530
