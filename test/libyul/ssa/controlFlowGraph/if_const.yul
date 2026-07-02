{
    let x := calldataload(3)
    // this should not appear in the output at all
    if 0 {
        x := calldataload(77)
    }
    // this should avoid a conditional jump
    if 33 {
        x := calldataload(42)
    }
    let y := calldataload(x)
    sstore(y, 0)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans"]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 3)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv1 := calldataload(0x03)\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_2 [style="solid"];
// Block0_2 [fillcolor="#FF746C", style=filled, label="\
// Block 2; (1, max 3)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_3 [style="solid"];
// Block0_3 [fillcolor="#FF746C", style=filled, label="\
// Block 3; (2, max 3)\nLiveIn: \l\
// LiveOut: v7[1]\l\nUsed: \l\nv7 := calldataload(0x2a)\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_4 [style="solid"];
// Block0_4 [fillcolor="#FF746C", style=filled, label="\
// Block 4; (3, max 3)\nLiveIn: v7[1]\l\
// LiveOut: \l\nUsed: v7[1]\l\nv14 := calldataload(v7)\l\
// sstore(v14, 0x00)\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// }
