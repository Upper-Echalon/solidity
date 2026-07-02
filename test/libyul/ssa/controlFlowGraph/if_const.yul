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
// Block0_0 [label="\
// Block 0; (0, max 4)\nLiveIn: \l\
// LiveOut: v1[1]\l\nUsed: \l\nv1 := calldataload(0x03)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If 0x00 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 4)\nLiveIn: \l\
// LiveOut: v4[1]\l\nUsed: \l\nv4 := calldataload(0x4d)\l\
// "];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 4)\nLiveIn: phi9[2]\l\
// LiveOut: phi9[1]\l\nUsed: phi9[1]\l\nphi9 := φ(\l\
// 	Block 0 => v1,\l\
// 	Block 1 => v4\l\
// )\l\
// "];
// Block0_2 -> Block0_2Exit;
// Block0_2Exit [label="{ If 0x21 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_2Exit:0 -> Block0_4 [style="solid"];
// Block0_2Exit:1 -> Block0_3 [style="solid"];
// Block0_3 [label="\
// Block 3; (3, max 4)\nLiveIn: \l\
// LiveOut: v7[1]\l\nUsed: \l\nv7 := calldataload(0x2a)\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_4 [style="solid"];
// Block0_4 [label="\
// Block 4; (4, max 4)\nLiveIn: phi8[2]\l\
// LiveOut: \l\nUsed: phi8[2]\l\nphi8 := φ(\l\
// 	Block 2 => phi9,\l\
// 	Block 3 => v7\l\
// )\l\
// v14 := calldataload(phi8)\l\
// sstore(v14, 0x00)\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// }
