
class SimpleRenderer {
  private VenationAlgorithm _va;
  private PGraphics _g;
  private int _size;

  SimpleRenderer(VenationAlgorithm va, PGraphics g, int size) {
    _va = va;
    _g = g;
    _size = size;
  }

  void draw() {
    VeinNode veinNode;
    PVector p;

    ArrayList<VeinNode> veinNodes = _va.getVeinNodes();
    int numVeinNodes = veinNodes.size();

    _g.stroke(128);
    _g.strokeWeight(1);
    _g.noFill();

    for (int i = 0; i < numVeinNodes; i++) {
      veinNode = veinNodes.get(i);
      p = veinNode.getPositionRef();
      drawPoint(_size * p.x, _size * p.y);
    }
  }

  void drawPoint(float x, float y) {
    _g.line(x, y, x, y + 4);
  }
}
