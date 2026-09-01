uint8 constant x = uint8(16) ** 2;

contract C {
    function a() external pure returns (uint8) { return x; }
    function b() external pure returns (uint8) { unchecked { return x; } }
    function c() external view returns (uint8) {
        unchecked {
            return this.a();
        }
    }
}
// ====
// compileViaYul: true
// ----
// a() -> FAILURE, hex"4e487b71", 0x11
// b() -> FAILURE, hex"4e487b71", 0x11
// c() -> FAILURE, hex"4e487b71", 0x11
