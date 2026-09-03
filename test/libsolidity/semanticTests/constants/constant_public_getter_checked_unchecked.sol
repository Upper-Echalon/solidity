contract C {
    uint8 public constant X = uint8(200) + 200;
    // The auto-generated getter requests X's value before any function body is
    // generated.
    function f() external pure returns (uint8) { unchecked { return X; } }
}
// ----
// X() -> FAILURE, hex"4e487b71", 0x11
// f() -> 0x90
