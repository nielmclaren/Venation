
class VenationDrawer {
  VenationAlgorithm _va;
  PGraphics _g;
  int _size;

  VenationDrawer(VenationAlgorithm va, PGraphics g, int size) {
    _va = va;
    _g = g;
    _size = size;
  }

  void draw() {
    drawKillRadii();
    drawAuxins();
    drawNeighborAuxins();
    drawInfluencerAuxins();
    drawVeinNodes();
    drawAuxinInfluenceDirections();
  }

  void drawKillRadii() {
    float r = _va.getKillRadius() * _size;
    PVector p;

    _g.noStroke();
    _g.fill(244);

    ArrayList<VeinNode> veinNodes = _va.getVeinNodes();
    for (VeinNode veinNode : veinNodes) {
      p = veinNode.getPositionRef();
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawAuxins() {
    float r = 0.025 * _size;
    PVector p;

    _g.stroke(255, 192, 192);
    _g.strokeWeight(1);
    _g.fill(255, 224, 224);

    ArrayList<Auxin> auxins = _va.getAuxins();
    for (Auxin auxin : auxins) {
      p = auxin.getPositionRef();
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawVeinNodes() {
    float r = _va.getVeinNodeRadius() * _size;
    PVector p;

    _g.stroke(0);
    _g.strokeWeight(2);
    _g.fill(255);

    ArrayList<VeinNode> veinNodes = _va.getVeinNodes();
    for (VeinNode veinNode : veinNodes) {
      p = veinNode.getPositionRef();
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawNeighborAuxins() {
    int count = _va.numVeinNodes();
    for (int i = 0; i < count; i++) {
      drawNeighborAuxins(i);
    }
  }

  void drawNeighborAuxins(int veinNodeIndex) {
    float r = _va.getAuxinRadius() * _size;
    PVector p;

    PVector veinNodePos = _va.getVeinNode(veinNodeIndex).getPositionRef();
    ArrayList<Auxin> neighborAuxins = _va.getNeighborAuxins(veinNodeIndex);
    for (Auxin auxin : neighborAuxins) {
      p = auxin.getPositionRef();
      _g.stroke(255, 192, 192);
      _g.strokeWeight(1);
      _g.noFill();
      _g.line(_size * p.x, _size * p.y, _size * veinNodePos.x, _size * veinNodePos.y);
    }
  }

  void drawInfluencerAuxins() {
    int count = _va.numVeinNodes();
    for (int i = 0; i < count; i++) {
      drawInfluencerAuxins(i);
    }
  }

  void drawInfluencerAuxins(int veinNodeIndex) {
    float r = _va.getAuxinRadius() * _size * 0.6;
    PVector p;

    PVector veinNode = _va.getVeinNode(veinNodeIndex).getPositionRef();
    ArrayList<Auxin> influencerAuxins = _va.getInfluencerAuxins(veinNodeIndex);
    for (Auxin auxin : influencerAuxins) {
      p = auxin.getPositionRef();
      _g.noStroke();
      _g.fill(255);
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);

      _g.stroke(255, 128, 128);
      _g.strokeWeight(2);
      _g.noFill();
      _g.line(_size * p.x, _size * p.y, _size * veinNode.x, _size * veinNode.y);
    }
  }

  void drawAuxinInfluenceDirections() {
    int count = _va.numVeinNodes();
    for (int i = 0; i < count; i++) {
      drawAuxinInfluenceDirection(i);
    }
  }

  void drawAuxinInfluenceDirection(int veinNodeIndex) {
    VeinNode veinNode = _va.getVeinNode(veinNodeIndex);
    PVector veinNodePos = veinNode.getPosition();
    PVector p = _va.getAuxinInfluenceDirection(veinNode, _va.getInfluencerAuxins(veinNodeIndex));
    if (p != null) {
      veinNodePos.mult(_size);

      p.mult(20);
      p.add(veinNodePos);

      _g.stroke(0);
      _g.strokeWeight(3);
      _g.noFill();
      _g.line(veinNodePos.x, veinNodePos.y, p.x, p.y);
    }
  }
}
