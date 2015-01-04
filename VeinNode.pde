
class VeinNode extends Point {
  VeinNode() {
    pos = new PVector();
  }

  VeinNode(PVector p) {
    pos = p;
  }

  VeinNode(float x, float y) {
    pos = new PVector(x, y);
  }
}
