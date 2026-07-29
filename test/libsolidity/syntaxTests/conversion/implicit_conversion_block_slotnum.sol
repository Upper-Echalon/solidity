contract C {
    uint slot256 = block.slotnum;
    uint64 slot64 = block.slotnum;
    uint56 slot56 = block.slotnum;
    uint32 slot32 = block.slotnum;

    function f() public view returns (uint) {
        return block.slotnum;
    }
    function f() public view returns (uint64) {
        return block.slotnum;
    }
    function g() public view returns (uint56) {
        return block.slotnum;
    }
    function g() public view returns (uint32) {
        return block.slotnum;
    }
}
// ====
// EVMVersion: >=amsterdam
// ----
// DeclarationError 1686: (157-234): Function with same name and parameter types defined twice.
// DeclarationError 1686: (323-402): Function with same name and parameter types defined twice.
// TypeError 7407: (102-115): Type uint64 is not implicitly convertible to expected type uint56.
// TypeError 7407: (137-150): Type uint64 is not implicitly convertible to expected type uint32.
// TypeError 6359: (382-395): Return argument type uint64 is not implicitly convertible to expected type (type of first return variable) uint56.
// TypeError 6359: (466-479): Return argument type uint64 is not implicitly convertible to expected type (type of first return variable) uint32.
