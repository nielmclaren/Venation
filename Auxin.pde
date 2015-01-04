
class Auxin extends Point {
  private boolean _isDoomed;
  private ArrayList<VeinNode> _taggedVeinNodes;

  Auxin() {
    pos = new PVector();
    _isDoomed = false;
    _taggedVeinNodes = new ArrayList<VeinNode>();
  }

  Auxin(PVector p) {
    pos = p;
    _isDoomed = false;
    _taggedVeinNodes = new ArrayList<VeinNode>();
  }

  Auxin(float x, float y) {
    pos = new PVector(x, y);
    _isDoomed = false;
    _taggedVeinNodes = new ArrayList<VeinNode>();
  }

  boolean isDoomed() {
    return _isDoomed;
  }

  void setDoomed(boolean b) {
    _isDoomed = b;
  }

  ArrayList<VeinNode> getTaggedVeinNodesRef() {
    return _taggedVeinNodes;
  }

  boolean hasTaggedVeinNodes() {
    return _taggedVeinNodes.size() > 0;
  }

  void setTaggedVeinNodes(ArrayList<VeinNode> veinNodes) {
    _taggedVeinNodes = veinNodes;
  }
}
