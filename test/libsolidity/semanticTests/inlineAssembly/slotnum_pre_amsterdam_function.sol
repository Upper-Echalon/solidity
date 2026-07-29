contract C {
    function f() public view returns (uint64 ret) {
        assembly {
            let slotnum := 999
            ret := slotnum
        }
    }
    function g() public pure returns (uint64 ret) {
        assembly {
            function slotnum() -> r {
                r := 1000
            }
            ret := slotnum()
        }
    }
}
// ====
// EVMVersion: <amsterdam
// ----
// f() -> 999
// g() -> 1000
