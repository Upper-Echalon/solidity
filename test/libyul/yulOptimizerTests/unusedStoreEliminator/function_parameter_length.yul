{
    function f(len) {
        let dst := 0
        calldatacopy(dst, 0, len) // Redundant, overwritten below with an identical copy.
        calldatacopy(dst, 0, len)
        return(0, len)
    }
}
// ----
// step: unusedStoreEliminator
//
// {
//     { }
//     function f(len)
//     {
//         let dst := 0
//         let _1 := 0
//         calldatacopy(dst, 0, len)
//         return(0, len)
//     }
// }
