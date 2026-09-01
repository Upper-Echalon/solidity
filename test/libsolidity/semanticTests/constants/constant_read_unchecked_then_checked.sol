uint8 constant x = uint8(200) + 200;

contract C {
    // a() has the lower selector and is generated first.
    function a() external pure returns (uint8) { unchecked { return x; } }
    function b() external pure returns (uint8) { return x; }
}
// ====
// compileViaYul: true
// ----
// a() -> 0x90
// b() -> 0x90
