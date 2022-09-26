class RedBlackTree {
    array<CustomEvent@> allNodes = {};
    array<int3> nodeLinks = {}; // left, right, lrBranch

    RedBlackTree() {}

    uint get_Length() { return size; }
    bool get_IsEmpty() { return size == 0; }
    uint get_size() { return allNodes.Length; }
    CustomEvent@ get_root() { return allNodes.Length == 0 ? null : allNodes[allNodes.Length - 1]; }
    int3 get_rootLinks() { return nodeLinks.Length == 0 ? int3(-1, -1, -2) : nodeLinks[nodeLinks.Length - 1]; }

    CustomEvent@ GN(uint id) {
        if (id >= allNodes.Length) return null;
        return allNodes[id];
    }
    int3 GNL(uint id) {
        if (id >= nodeLinks.Length) {
            warn('GNL called with id ' + id + ' that does not exist');
            return int3(-1, -1, 0);
        }
        return nodeLinks[id];
    }
    CustomEvent@ GetNodeById(uint id) {
        return GN(id);
    }

    // returns ID
    uint AddNode(CustomEvent@ ce, int lrBranch) {
        allNodes.InsertLast(ce);
        nodeLinks.InsertLast(int3(-1, -1, lrBranch));
        return size - 1;
    }

    void Put(CustomEvent@ ce) {
        // string[] key = {ce.s_type, Hash::MD5(ce.ToString(true))};
        string[] key = {ce.s_type, ce.ToString(true)};
        // dev_trace("Put: " + ce.ToString() + " -- " + ArrStringToString(key));
        if (size == 0) {
            AddNode(ce, 0);
        } else {
            _Put(ce, 0);
        }
        // dev_trace("RB Tree added ce: " + ce.ToString());

        // todo ;ater
        /* todo: later
        // if (tip !is null)
        //     _Put(key, ce, tip);
        // else
            // @this.tip = RBTreeNode(key, ce, 0, null);
        auto _node = RBTreeNode(key, ce, 0, null);
        tips.InsertLast(_node);
        @tip = _node;
        // @tip = _node;
        */
    }

    void _Put(CustomEvent@ ce, uint currNodeId) {
        int loopDepth = 0;
        while (loopDepth < 52) {
            auto currNode = GN(currNodeId);
            int3 cnl = GNL(currNodeId);

            auto c = StrCompare(ce.s_type, currNode.s_type);
            if (c == Cmp::Eq) {
                c = StrCompare(ce.ToString(true), currNode.ToString(true));
            }

            if (c == Cmp::Lt) {
                if (cnl.x > 0) {
                    currNodeId = cnl.x;
                } else {
                    auto newId = AddNode(ce, -1);
                    cnl.x = newId;
                    nodeLinks[currNodeId] = cnl;
                    break;
                }
            } else if (c == Cmp::Gt) {
                if (cnl.y > 0) {
                    currNodeId = cnl.y;
                } else {
                    auto newId = AddNode(ce, 1);
                    cnl.y = newId;
                    nodeLinks[currNodeId] = cnl;
                    break;
                }
            } else if (c == Cmp::Eq) {
                currNode.repeatCount += 1;
                break;
            } else {
                warn('!! impossible !!');
                NotifyError("impossible thing in rb tree");
            }
            loopDepth++;
            if (loopDepth > 50) {
                warn('loop at depth of 50! very unlikely :/');
                break;
            }
        }
    }

    // Cmp KeyCompare(const string[] &in key1, const string[] &in key2) {
    //     for (uint i = 0; i < key1.Length; i++) {
    //         // if we run out of key2s then key1 is greater
    //         if (i >= key2.Length) return Cmp::Gt;
    //         auto c = StrCompare(key1[i], key2[i]); // compare next keys
    //         if (c == Cmp::Eq && i != key2.Length - 1) continue; // equal, next key
    //         // if they weren't equal then we have an answer
    //         return c;
    //     }
    //     if (key1.Length == key2.Length) return Cmp::Eq; // if we got here it's b/c all the keys are Eq, so if lengths match they're equal
    //     // if k1 was greater we would have exited earlier, therefore k1 is Lt
    //     return Cmp::Lt;
    // }

    /* true == "" < "a" && "a" < "b" && "B" < "b" && "x" < "b"; */
    Cmp StrCompare(const string &in s1, const string &in s2) {
        return Cmp(s1.opCmp(s2));
    }

    IterCE@ GetIter() {
        return IterCE(this);
    }
}

class IterCE {
    private RedBlackTree@ tree;
    uint[] history = {};
    IterCE(RedBlackTree@ _tree) {
        @tree = _tree;
        AppendToHistory(0);
    }

    // void _ExtendHistoryLeft(uint node) {
    //     auto nl = tree.GNL(node);
    //     if (nl.x > 0)
    //         AppendToHistory(nl.x);
    // }

    void AppendToHistory(int id) {
        if (id >= tree.size) return;
        history.InsertLast(id);
        int3 links = tree.GNL(id);
        while (links.x > 0) {
            id = links.x;
            history.InsertLast(id);
            links = tree.GNL(id);
        }
    }

    CustomEvent@ get_Next() {
        if (history.Length == 0) return null;
        auto ret = history[history.Length - 1];
        history.RemoveLast();

        // string hist = "HIST: ";
        // for (uint i = 0; i < history.Length; i++) {
        //     auto item = history[i];
        //     hist += item.ToString() + ", ";
        // }
        // hist += ret.ToString();
        // print(hist);

        auto retLinks = tree.GNL(ret);
        if (retLinks.y > 0)
            AppendToHistory(retLinks.y);
        return tree.GN(ret);
    }
}

// class MaybeRBTreeNode {
//     bool hasNode;
//     RBTreeNode@ node;
//     MaybeRBTreeNode() {
//         hasNode = false;
//     }
//     MaybeRBTreeNode(RBTreeNode@ node) {
//         @this.node = node;
//         hasNode = true;
//     }
//     bool IsSome() {
//         return hasNode;
//     }
// }

// class RBTreeNode {
//     int left = -1;
//     int right = -1;
//     uint depth;
//     string[]@ key;
//     CustomEvent@ ce;
//     int lrBranch;
//     RBTreeNode(string[] &in _key, CustomEvent@ _ce, int _lrBranch, uint _depth) {
//         @key = _key;
//         @ce = _ce;
//         lrBranch = _lrBranch; // -1 left, 0 root, 1 right
//         depth = _depth;
//     }
// #if DEV
//     // string ToString() {
//     //     return "TN(d=" + depth + ", l:" + (left is null ? '_' : left.ToString()) + ", r:" + (right is null ? '_' : right.ToString()) + ")";
//     // }
// #endif
// }



void RedBlackTreeChecks() {
    // print('"a".opCmp("b") = ' + "a".opCmp("b"));
    // print('"B".opCmp("b") = ' + "B".opCmp("b"));
    // print('"b".opCmp("b") = ' + "b".opCmp("b"));
    // print('"x".opCmp("b") = ' + "x".opCmp("b"));
    // print('"".opCmp("b") = ' + "".opCmp("b"));
    uint rbTestStart = Time::Now;
    auto rb = RedBlackTree();
    CustomEvent@[] rbQueue = {};
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "3"}));
    // if (true) {
    //     print(rb.size);
    //     RBTreeNode@ tn;
    //     auto iter = rb.GetIter();
    //     uint count = 0;
    //     for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
    //         // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
    //         print(tn.ce.ToString() + " " + tn.ce.repeatCount);
    //         count++;
    //     }
    //     print("total looped: " + count);
    // }
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "7"}));
    // if (true) {
    //     print(rb.size);
    //     RBTreeNode@ tn;
    //     auto iter = rb.GetIter();
    //     uint count = 0;
    //     for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
    //         // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
    //         print(tn.ce.ToString() + " " + tn.ce.repeatCount);
    //         count++;
    //     }
    //     print("total looped: " + count);
    // }
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "5"}));
    // if (true) {
    //     print(rb.size);
    //     RBTreeNode@ tn;
    //     auto iter = rb.GetIter();
    //     uint count = 0;
    //     for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
    //         // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
    //         print(tn.ce.ToString() + " " + tn.ce.repeatCount);
    //         count++;
    //     }
    //     print("total looped: " + count);
    // }
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "4"}));
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "9"}));
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "9"}));
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "1"}));
    rbQueue.InsertLast(CustomEvent("", {"2", "1"}));
    rbQueue.InsertLast(CustomEvent("", {"2", "1", "a"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "j", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "i", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "j", "m"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "j", "z"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "j", "z"}));
    rbQueue.InsertLast(CustomEvent("", {"a", "h", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "r", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "1", "d"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "r", "z"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "6", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "3", "z"}));
    rbQueue.InsertLast(CustomEvent("", {"z", "r", "8"}));
    rbQueue.InsertLast(CustomEvent("", {"m", "r", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"m", "rr", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"m", "rl", "r"}));
    rbQueue.InsertLast(CustomEvent("", {"m", "rl", "2r"}));
    rbQueue.InsertLast(CustomEvent("", {"l", "rl", "2r"}));
    rbQueue.InsertLast(CustomEvent("", {"r", "l", "2r"}));
    rbQueue.InsertLast(CustomEvent("", {"m", "l", "zz"}));
    for(uint i = 0; i < 2000; i++) {
        rbQueue.InsertLast(CustomEvent(tostring(Math::Rand(0, 100)), {tostring(Math::Rand(0, 100)), tostring(Math::Rand(0, 100)), tostring(Math::Rand(0, 100))}));
    }
    print("obj creation w/ array duration: " + (Time::Now - rbTestStart));
    print(rbQueue.Length);
    for (uint i = 0; i < rbQueue.Length; i++) {
        rbQueue[i].ToString();
    }
    print("string cache duration: " + (Time::Now - rbTestStart));

    for (uint i = 0; i < rbQueue.Length; i++) {
        auto item = rbQueue[i];
        rb.Put(item);
    }
    print("obj insert duration: " + (Time::Now - rbTestStart));
    print(rb.size);
    CustomEvent@ tn;
    auto iter = rb.GetIter();
    uint count = 0;
    for (@tn = iter.Next; tn !is null; @tn = iter.Next) {
        // print(ArrStringToString(tn.key) + " " + tn.ce.repeatCount + "  --  " + tn.ToString());
        // print(tn.ToString() + " " + tn.repeatCount);
        count++;
    }
    print("total looped: " + count);
    print("total duration: " + (Time::Now - rbTestStart));
}
