uint8 constant x = uint8(200) + 200;

contract C {
    // a() has the lower selector and is generated first.
    function a() external pure returns (uint8) { return x; }
    function b() external pure returns (uint8) { unchecked { return x; } }
}
// ----
// a() -> FAILURE, hex"4e487b71", 0x11
// b() -> 0x90
