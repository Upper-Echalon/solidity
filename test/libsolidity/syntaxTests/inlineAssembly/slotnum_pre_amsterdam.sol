// NOTE: Once Amsterdam becomes the default EVM version, this is expected to instead report
// 1049: The "slotnum" instruction is only available for Amsterdam-compatible VMs
contract C {
    function f() public view returns (uint64 ret) {
        assembly {
            ret := slotnum()
        }
    }
}
// ====
// EVMVersion: =osaka
// ----
// DeclarationError 4619: (277-284): Function "slotnum" not found.
// DeclarationError 8678: (270-286): Variable count for assignment to "ret" does not match number of values (1 vs. 0)
