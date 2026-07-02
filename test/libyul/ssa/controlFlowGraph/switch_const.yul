{
    let x := calldataload(3)

    // this should yield calldataload(88) directly
    switch 1
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }

    // this should yield the default case
    switch 55
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }

    // this should be skipped entirely
    switch 66
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    sstore(x, 0)
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
// Block 0; (0, max 14)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv1 := calldataload(0x03)\l\
// v4 := eq(0x01, 0x00)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v4 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_3 [style="solid"];
// Block0_0Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (1, max 11)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv6 := calldataload(0x4d)\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_1 [style="solid"];
// Block0_3 [label="\
// Block 3; (12, max 14)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv7 := eq(0x01, 0x01)\l\
// "];
// Block0_3 -> Block0_3Exit;
// Block0_3Exit [label="{ If v7 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_3Exit:0 -> Block0_5 [style="solid"];
// Block0_3Exit:1 -> Block0_4 [style="solid"];
// Block0_1 [label="\
// Block 1; (2, max 11)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv13 := eq(0x37, 0x00)\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v13 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_8 [style="solid"];
// Block0_1Exit:1 -> Block0_7 [style="solid"];
// Block0_4 [label="\
// Block 4; (13, max 13)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv9 := calldataload(0x58)\l\
// "];
// Block0_4 -> Block0_4Exit [arrowhead=none];
// Block0_4Exit [label="Jump" shape=oval];
// Block0_4Exit -> Block0_1 [style="solid"];
// Block0_5 [label="\
// Block 5; (14, max 14)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv11 := calldataload(0x63)\l\
// "];
// Block0_5 -> Block0_5Exit [arrowhead=none];
// Block0_5Exit [label="Jump" shape=oval];
// Block0_5Exit -> Block0_1 [style="solid"];
// Block0_7 [label="\
// Block 7; (3, max 8)\nLiveIn: \l\
// LiveOut: v14[1]\l\nUsed: \l\nv14 := calldataload(0x4d)\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_6 [style="solid"];
// Block0_8 [label="\
// Block 8; (9, max 11)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv15 := eq(0x37, 0x01)\l\
// "];
// Block0_8 -> Block0_8Exit;
// Block0_8Exit [label="{ If v15 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_8Exit:0 -> Block0_10 [style="solid"];
// Block0_8Exit:1 -> Block0_9 [style="solid"];
// Block0_6 [label="\
// Block 6; (4, max 8)\nLiveIn: phi25[2]\l\
// LiveOut: phi25[1]\l\nUsed: phi25[1]\l\nphi25 := φ(\l\
// 	Block 7 => v14,\l\
// 	Block 9 => v16,\l\
// 	Block 10 => v17\l\
// )\l\
// v19 := eq(0x42, 0x00)\l\
// "];
// Block0_6 -> Block0_6Exit;
// Block0_6Exit [label="{ If v19 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_6Exit:0 -> Block0_13 [style="solid"];
// Block0_6Exit:1 -> Block0_12 [style="solid"];
// Block0_9 [label="\
// Block 9; (10, max 10)\nLiveIn: \l\
// LiveOut: v16[1]\l\nUsed: \l\nv16 := calldataload(0x58)\l\
// "];
// Block0_9 -> Block0_9Exit [arrowhead=none];
// Block0_9Exit [label="Jump" shape=oval];
// Block0_9Exit -> Block0_6 [style="solid"];
// Block0_10 [label="\
// Block 10; (11, max 11)\nLiveIn: \l\
// LiveOut: v17[1]\l\nUsed: \l\nv17 := calldataload(0x63)\l\
// "];
// Block0_10 -> Block0_10Exit [arrowhead=none];
// Block0_10Exit [label="Jump" shape=oval];
// Block0_10Exit -> Block0_6 [style="solid"];
// Block0_12 [label="\
// Block 12; (5, max 6)\nLiveIn: \l\
// LiveOut: v20[1]\l\nUsed: \l\nv20 := calldataload(0x4d)\l\
// "];
// Block0_12 -> Block0_12Exit [arrowhead=none];
// Block0_12Exit [label="Jump" shape=oval];
// Block0_12Exit -> Block0_11 [style="solid"];
// Block0_13 [label="\
// Block 13; (7, max 8)\nLiveIn: phi25[1]\l\
// LiveOut: phi25[1]\l\nUsed: \l\nv21 := eq(0x42, 0x01)\l\
// "];
// Block0_13 -> Block0_13Exit;
// Block0_13Exit [label="{ If v21 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_13Exit:0 -> Block0_11 [style="solid"];
// Block0_13Exit:1 -> Block0_14 [style="solid"];
// Block0_11 [label="\
// Block 11; (6, max 6)\nLiveIn: phi23[2]\l\
// LiveOut: \l\nUsed: phi23[2]\l\nphi23 := φ(\l\
// 	Block 12 => v20,\l\
// 	Block 13 => phi25,\l\
// 	Block 14 => v22\l\
// )\l\
// sstore(phi23, 0x00)\l\
// "];
// Block0_11Exit [label="MainExit"];
// Block0_11 -> Block0_11Exit;
// Block0_14 [label="\
// Block 14; (8, max 8)\nLiveIn: \l\
// LiveOut: v22[1]\l\nUsed: \l\nv22 := calldataload(0x58)\l\
// "];
// Block0_14 -> Block0_14Exit [arrowhead=none];
// Block0_14Exit [label="Jump" shape=oval];
// Block0_14Exit -> Block0_11 [style="solid"];
// }
