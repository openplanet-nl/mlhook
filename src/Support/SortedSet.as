enum Cmp {Lt = -1, Eq = 0, Gt = 1}

class RedBlackTree {
    uint size = 0;
    // RBTreeNode@ tip = RBTreeNode({"",""}, CustomEvent("", {""}), -1, null);
    RBTreeNode@ tip = null;

    array<RBTreeNode@> tips = {};

    RedBlackTree() {}

    uint get_Length() { return size; }
    bool get_IsEmpty() { return size == 0; }

    void Put(CustomEvent@ ce) {
        if (ce is null) {
            print('Put a null CE!?');
            return;
        }
        string[] key = {ce.s_type, Hash::MD5(ce.ToString(true))};
        print("Put: " + ce.ToString() + " -- " + ArrStringToString(key));
        size += 1;
        // if (tip !is null)
        //     _Put(key, ce, tip);
        // else
            // @this.tip = RBTreeNode(key, ce, 0, null);
        auto _node = RBTreeNode(key, ce, 0, null);
        tips.InsertLast(_node);
        @tip = _node;
        // @tip = _node;
    }

    void _Put(string[] &in key, CustomEvent@ ce, RBTreeNode@ currNode) {
        // print('key is null? ' + (key is null ? 'y' : 'n'));
        // if (key.Length != 2) warn('bad key length: ' + key.Length);
        return;
        auto c = StrCompare(key[0], currNode.key[0]);
        if (c == Cmp::Eq) {
            c = StrCompare(key[1], currNode.key[1]);
        }
        if (c == Cmp::Lt) {
            if (currNode.left !is null) {
                _Put(key, ce, currNode.left);
            } else {
                @currNode.left = RBTreeNode(key, ce, -1, currNode);
            }
        } else if (c == Cmp::Gt) {
            if (currNode.right !is null) {
                _Put(key, ce, currNode.right);
            } else {
                @currNode.right = RBTreeNode(key, ce, 1, currNode);
            }
        } else if (c == Cmp::Eq) {
            size -= 1;
            currNode.ce.repeatCount += 1;
        } else {
            warn('!! impossible !!');
            // NotifyError("impossible thing in rb tree");
        }
    }

    Cmp KeyCompare(const string[] &in key1, const string[] &in key2) {
        for (uint i = 0; i < key1.Length; i++) {
            // if we run out of key2s then key1 is greater
            if (i >= key2.Length) return Cmp::Gt;
            auto c = StrCompare(key1[i], key2[i]); // compare next keys
            if (c == Cmp::Eq && i != key2.Length - 1) continue; // equal, next key
            // if they weren't equal then we have an answer
            return c;
        }
        if (key1.Length == key2.Length) return Cmp::Eq; // if we got here it's b/c all the keys are Eq, so if lengths match they're equal
        // if k1 was greater we would have exited earlier, therefore k1 is Lt
        return Cmp::Lt;
    }

    /* true == "" < "a" && "a" < "b" && "B" < "b" && "x" < "b"; */
    Cmp StrCompare(const string &in s1, const string &in s2) {
        return Cmp(s1.opCmp(s2));
    }

    IterCE@ GetIter() {
        return IterCE(this);
    }
}

class IterCE {
    private RedBlackTree@ _tree;
    RBTreeNode@[] history = {};
    IterCE(RedBlackTree@ tree) {
        @_tree = tree;
        AppendToHistory(tree.tip);
    }

    void _ExtendHistoryLeft(RBTreeNode@ node) {
        if (node.left !is null)
            AppendToHistory(node.left);
    }

    void AppendToHistory(RBTreeNode@ node) {
        if (node is null) return;
        history.InsertLast(node);
        _ExtendHistoryLeft(node);
    }

    RBTreeNode@ get_Next() {
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

        AppendToHistory(ret.right);
        return ret;
    }
}

class RBTreeNode {
    RBTreeNode@ left = null;
    RBTreeNode@ right = null;
    RBTreeNode@ parent = null;
    uint depth;
    string[] key;
    CustomEvent@ ce;
    int lrBranch;
    RBTreeNode(string[] &in _key, CustomEvent@ _ce, int _lrBranch, RBTreeNode@ _parent = null) {
        key = _key;
        @ce = _ce;
        lrBranch = _lrBranch; // -1 left, 0 root, 1 right
        if (lrBranch == 0) {
            depth = 0;
        } else {
            @parent = _parent;
            depth = parent.depth + 1;
        }
    }
#if DEV
    // string ToString() {
    //     return "TN(d=" + depth + ", l:" + (left is null ? '_' : left.ToString()) + ", r:" + (right is null ? '_' : right.ToString()) + ")";
    // }
#endif
}
