
class VenationRenderer {
  VenationAlgorithm _va;
  PGraphics _g;
  int _size;

  VenationRenderer(VenationAlgorithm va, PGraphics g, int size) {
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
    drawInfluentialAuxins();
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

    ArrayList<Auxin> auxins = _va.getAuxins();
    for (Auxin auxin : auxins) {
      p = auxin.getPositionRef();
      if (auxin.isDoomed()) {
        _g.fill(255, 128, 128);
      }
      else {
        _g.fill(255, 224, 224);
      }
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawVeinNodes() {
    float r = _va.getVeinNodeRadius() * _size;
    PVector p;

    _g.stroke(0);
    _g.strokeWeight(1);
    _g.fill(255);

    ArrayList<VeinNode> veinNodes = _va.getVeinNodes();
    for (VeinNode veinNode : veinNodes) {
      p = veinNode.getPositionRef();
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawNeighborAuxins() {
    for (VeinNode veinNode : _va.getVeinNodes()) {
      drawNeighborAuxins(veinNode);
    }
  }

  void drawNeighborAuxins(VeinNode veinNode) {
    float r = _va.getAuxinRadius() * _size;
    PVector p;

    PVector veinNodePos = veinNode.getPositionRef();
    ArrayList<Auxin> neighborAuxins = _va.getNeighborAuxins(veinNodePos.x, veinNodePos.y);
    for (Auxin auxin : neighborAuxins) {
      p = auxin.getPositionRef();
      _g.stroke(255, 192, 192);
      _g.strokeWeight(1);
      _g.noFill();
      _g.line(_size * p.x, _size * p.y, _size * veinNodePos.x, _size * veinNodePos.y);
    }
  }

  void drawInfluencerAuxins() {
    for (VeinNode veinNode : _va.getVeinNodes()) {
      drawInfluencerAuxins(veinNode);
    }
  }

  void drawInfluencerAuxins(VeinNode veinNode) {
    float r = _va.getAuxinRadius() * _size * 0.6;
    PVector p;

    PVector veinNodePos = veinNode.getPositionRef();
    ArrayList<Auxin> influencerAuxins = _va.getInfluencerAuxins(veinNode);
    for (Auxin auxin : influencerAuxins) {
      p = auxin.getPositionRef();

      _g.stroke(255, 128, 128);
      _g.strokeWeight(2);
      _g.noFill();
      _g.line(_size * p.x, _size * p.y, _size * veinNodePos.x, _size * veinNodePos.y);

      _g.noStroke();
      _g.fill(255);
      _g.ellipse(_size * p.x, _size * p.y, 2*r, 2*r);
    }
  }

  void drawAuxinInfluenceDirections() {
    for (VeinNode veinNode : _va.getVeinNodes()) {
      drawAuxinInfluenceDirection(veinNode);
    }
  }

  void drawAuxinInfluenceDirection(VeinNode veinNode) {
    PVector veinNodePos = veinNode.getPosition();
    PVector p = _va.getAuxinInfluenceDirection(veinNode, _va.getInfluencerAuxins(veinNode));
    if (p != null) {
      veinNodePos.mult(_size);

      p.mult(20);
      p.add(veinNodePos);

      _g.stroke(0);
      _g.strokeWeight(2);
      _g.noFill();
      _g.line(veinNodePos.x, veinNodePos.y, p.x, p.y);
    }
  }

  void drawInfluentialAuxins() {
    PVector auxinPos;
    for (Auxin auxin : _va.getAuxins()) {
      if (_va.getRelativeNeighborVeinNodes(auxin).size() > 1) {
        auxinPos = auxin.getPositionRef();
        _g.noStroke();
        _g.fill(128);
        _g.ellipse(_size * auxinPos.x, _size * auxinPos.y, 10, 10);
      }
    }
  }
}
