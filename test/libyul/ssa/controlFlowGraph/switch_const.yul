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
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv1 := calldataload(0x03)\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_3 [style="solid"];
// Block0_3 [fillcolor="#FF746C", style=filled, label="\
// Block 3; (1, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_4 [style="solid"];
// Block0_4 [fillcolor="#FF746C", style=filled, label="\
// Block 4; (2, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv9 := calldataload(0x58)\l\
// "];
// Block0_4 -> Block0_4Exit [arrowhead=none];
// Block0_4Exit [label="Jump" shape=oval];
// Block0_4Exit -> Block0_1 [style="solid"];
// Block0_1 [fillcolor="#FF746C", style=filled, label="\
// Block 1; (3, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_8 [style="solid"];
// Block0_8 [fillcolor="#FF746C", style=filled, label="\
// Block 8; (4, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_10 [style="solid"];
// Block0_10 [fillcolor="#FF746C", style=filled, label="\
// Block 10; (5, max 8)\nLiveIn: \l\
// LiveOut: v17[1]\l\nUsed: \l\nv17 := calldataload(0x63)\l\
// "];
// Block0_10 -> Block0_10Exit [arrowhead=none];
// Block0_10Exit [label="Jump" shape=oval];
// Block0_10Exit -> Block0_6 [style="solid"];
// Block0_6 [fillcolor="#FF746C", style=filled, label="\
// Block 6; (6, max 8)\nLiveIn: v17[1]\l\
// LiveOut: v17[1]\l\nUsed: \l\n"];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_13 [style="solid"];
// Block0_13 [fillcolor="#FF746C", style=filled, label="\
// Block 13; (7, max 8)\nLiveIn: v17[1]\l\
// LiveOut: v17[1]\l\nUsed: \l\n"];
// Block0_13 -> Block0_13Exit [arrowhead=none];
// Block0_13Exit [label="Jump" shape=oval];
// Block0_13Exit -> Block0_11 [style="solid"];
// Block0_11 [fillcolor="#FF746C", style=filled, label="\
// Block 11; (8, max 8)\nLiveIn: v17[1]\l\
// LiveOut: \l\nUsed: v17[1]\l\nsstore(v17, 0x00)\l\
// "];
// Block0_11Exit [label="MainExit"];
// Block0_11 -> Block0_11Exit;
// }
