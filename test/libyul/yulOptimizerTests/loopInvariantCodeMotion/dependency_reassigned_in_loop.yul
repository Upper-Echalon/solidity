{
    let x := calldataload(0)
    let b := x
    for { let i := 1 } iszero(eq(i, 10)) { i := add(i, 1) } {
        let inv := add(b, 42)
        x := add(x, 32)
    }
}
// ----
// step: loopInvariantCodeMotion
//
// {
//     let x := calldataload(0)
//     let b := x
//     let i := 1
//     let inv := add(b, 42)
//     for { } iszero(eq(i, 10)) { i := add(i, 1) }
//     { x := add(x, 32) }
// }
