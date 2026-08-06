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
// EVMVersion: =osaka
// ----
// TypeError 1048: (76-89): "slotnum" is not supported by the VM version.
// DeclarationError 4619: (187-194): Function "slotnum" not found.
// DeclarationError 8678: (180-196): Variable count for assignment to "ret" does not match number of values (1 vs. 0)
