contract C {
    function f() public view returns (uint64 ret) {
        assembly {
            let slotnum := sload(0)
            ret := slotnum
        }
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
// ParserError 5568: (100-107): Cannot use builtin function name "slotnum" as identifier name.
// ParserError 7104: (139-146): Builtin function "slotnum" must be called.
