
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

    _g.noStroke();
    _g.fill(244);

    ArrayList<PVector> veinNodes = _va.getVeinNodes();
    for (PVector p : veinNodes) {
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawAuxins() {
    float r = 0.025 * _size;

    _g.stroke(255, 192, 192);
    _g.strokeWeight(1);
    _g.fill(255, 224, 224);

    ArrayList<PVector> auxins = _va.getAuxins();
    for (PVector p : auxins) {
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawVeinNodes() {
    float r = _va.getVeinNodeRadius() * _size;

    _g.stroke(0);
    _g.strokeWeight(2);
    _g.fill(255);

    ArrayList<PVector> veinNodes = _va.getVeinNodes();
    for (PVector p : veinNodes) {
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

    PVector veinNode = _va.getVeinNode(veinNodeIndex);
    ArrayList<PVector> neighborAuxins = _va.getNeighborAuxins(veinNodeIndex);
    for (PVector p : neighborAuxins) {
      _g.stroke(255, 192, 192);
      _g.strokeWeight(1);
      _g.noFill();
      _g.line(_size * p.x, _size * p.y, _size * veinNode.x, _size * veinNode.y);
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

    PVector veinNode = _va.getVeinNode(veinNodeIndex);
    ArrayList<PVector> influencerAuxins = _va.getInfluencerAuxins(veinNodeIndex);
    for (PVector p : influencerAuxins) {
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
    PVector veinNode = _va.getVeinNodes().get(veinNodeIndex).get();
    PVector p = _va.getAuxinInfluenceDirection(veinNode, _va.getInfluencerAuxins(veinNodeIndex));
    if (p != null) {
      veinNode.mult(_size);

      p.mult(20);
      p.add(veinNode);

      _g.stroke(0);
      _g.strokeWeight(3);
      _g.noFill();
      _g.line(veinNode.x, veinNode.y, p.x, p.y);
    }
  }
}
