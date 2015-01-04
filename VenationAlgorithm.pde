/**
 * @see http://algorithmicbotany.org/papers/venation.sig2005.pdf
 */

class VenationAlgorithm {
  ArrayList<Auxin> _auxins;
  float _auxinRadius;
  ArrayList<VeinNode> _veinNodes;
  float _veinNodeRadius;
  float _killRadius;
  float _neighborhoodRadius;

  VenationAlgorithm() {
    _auxins = new ArrayList<Auxin>();
    _auxinRadius = 0.025;
    _veinNodes = new ArrayList<VeinNode>();
    _veinNodeRadius = 0.0125;
    _killRadius = 0.075;
    _neighborhoodRadius = 0.1;

    seedVeinNodes();
    seedAuxins();
  }

  /// Accessors

  float getAuxinRadius() {
    return _auxinRadius;
  }

  float getVeinNodeRadius() {
    return _veinNodeRadius;
  }

  float getKillRadius() {
    return _killRadius;
  }

  Auxin getAuxin(int index) {
    return _auxins.get(index);
  }

  ArrayList<Auxin> getAuxins() {
    return _auxins;
  }

  int numAuxins() {
    return _auxins.size();
  }

  ArrayList<VeinNode> getVeinNodes() {
    return _veinNodes;
  }

  int numVeinNodes() {
    return _veinNodes.size();
  }

  VeinNode getVeinNode(int index) {
    return _veinNodes.get(index);
  }

  ArrayList<Auxin> getNeighborAuxins(float x, float y) {
    float dx, dy, r = 4.0 * _neighborhoodRadius * _neighborhoodRadius;
    PVector p;
    ArrayList<Auxin> neighborAuxins = new ArrayList<Auxin>();
    for (Auxin auxin : _auxins) {
      p = auxin.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        neighborAuxins.add(auxin);
      }
    }
    return neighborAuxins;
  }

  ArrayList<VeinNode> getNeighborVeinNodes(float x, float y) {
    float dx, dy, r = 4.0 * _neighborhoodRadius * _neighborhoodRadius;
    PVector p;
    ArrayList<VeinNode> neighborVeinNodes = new ArrayList<VeinNode>();
    for (VeinNode veinNode : _veinNodes) {
      p = veinNode.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        neighborVeinNodes.add(veinNode);
      }
    }
    return neighborVeinNodes;
  }

  ArrayList<Auxin> getInfluencerAuxins(VeinNode veinNode) {
    PVector veinNodePos = veinNode.getPositionRef();
    ArrayList<Auxin> neighborAuxins = getNeighborAuxins(veinNodePos.x, veinNodePos.y);
    ArrayList<Auxin> influencerAuxins = new ArrayList<Auxin>();
    for (Auxin auxin : neighborAuxins) {
      // FIXME: getInfluencedVeinNodes gets called multiple times per auxin. Cache.
      if (getInfluencedVeinNodes(auxin).contains(veinNode)) {
        influencerAuxins.add(auxin);
      }
    }
    return influencerAuxins;
  }

  ArrayList<VeinNode> getInfluencedVeinNodes(Auxin auxin) {
    return getRelativeNeighborVeinNodes(auxin);
  }

  PVector getAuxinInfluenceDirection(VeinNode veinNode, ArrayList<Auxin> auxinInfluencers) {
    PVector p, result = null;
    for (Auxin auxin : auxinInfluencers) {
      p = auxin.getPosition();
      p.sub(veinNode.getPositionRef());
      p.normalize();

      if (result == null) {
        result = new PVector();
      }
      result.add(p);
    }

    if (result != null) {
      result.normalize();
    }
    return result;
  }

  ArrayList<VeinNode> getRelativeNeighborVeinNodes(Auxin auxin) {
    // FIXME: Inefficient because of instantiation of PVectors.
    boolean fail;
    PVector p0, p1, auxinPos = auxin.getPositionRef();
    PVector auxinToP0, auxinToP1, p0ToP1;

    // Limit search to the neighborhood of the auxin.
    ArrayList<VeinNode> neighborVeinNodes = getNeighborVeinNodes(auxinPos.x, auxinPos.y);

    // p0 is a relative neighbor of auxinPos iff
    // for any point p1 that is closer to auxinPos than is p0,
    // p0 is closer to auxinPos than to p1.
    ArrayList<VeinNode> relNeighborVeinNodes = new ArrayList<VeinNode>();
    for (VeinNode vn0 : neighborVeinNodes) {
      p0 = vn0.getPositionRef();
      auxinToP0 = PVector.sub(p0, auxinPos);
      fail = false;

      for (VeinNode vn1 : neighborVeinNodes) {
        if (vn0 == vn1) continue;
        p1 = vn1.getPositionRef();
        auxinToP1 = PVector.sub(p1, auxinPos);
        if (auxinToP1.mag() > auxinToP0.mag()) continue;
        p0ToP1 = PVector.sub(p1, p0);
        if (auxinToP0.mag() > p0ToP1.mag()) {
          fail = true;
          break;
        }
      }

      if (!fail) {
        relNeighborVeinNodes.add(vn0);
      }
    }
    return relNeighborVeinNodes;
  }

  VeinNode getNearestVeinNode(float x, float y) {
    VeinNode candidate = null;
    PVector p;
    float dx, dy, distSq, candidateDistSq = 0;
    for (VeinNode veinNode : _veinNodes) {
      p = veinNode.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      distSq = dx * dx + dy * dy;
      if (candidate == null || distSq < candidateDistSq) {
        candidate = veinNode;
        candidateDistSq = distSq;
      }
    }
    return candidate;
  }

  /// Algorithm

  void step() {
    placeVeinNodes();
    killAuxins();
  }

  void seedVeinNodes() {
    float x, y;
    for (int i = 0; i < 3; i++) {
      x = random(1);
      y = random(1);
      _veinNodes.add(new VeinNode(x, y));
    }
  }

  void seedAuxins() {
    float x, y;
    for (int i = 0; i < 1000 && _auxins.size() < 200; i++) {
      x = random(1);
      y = random(1);
      if (!hitTestPotentialAuxin(x, y)) {
        _auxins.add(new Auxin(x, y));
      }
    }
  }

  void placeVeinNodes() {
    // Make sure we don't iterate newly-placed vein nodes.
    int count = _veinNodes.size();
    for (int i = 0; i < count; i++) {
      placeVeinNode(i);
    }
  }

  void placeVeinNode(int seedVeinNodeIndex) {
    VeinNode veinNode = _veinNodes.get(seedVeinNodeIndex);
    ArrayList<Auxin> influencerAuxins = getInfluencerAuxins(veinNode);
    PVector p = getAuxinInfluenceDirection(veinNode, influencerAuxins);
    if (p != null) {
      if (p.mag() <= 0) {
        p.x = 1;
        p.y = 0;
        p.rotate(random(1) * 2 * PI);
      }
      p.mult(2 * _veinNodeRadius);
      p.rotate((2 * random(1) - 1) * 2 * PI * 0.05); // jitter
      p.add(veinNode.getPositionRef());
      _veinNodes.add(new VeinNode(p));
    }
  }

  void killAuxins() {
    PVector p;
    for (int i = 0; i < _auxins.size(); i++) {
      p = _auxins.get(i).getPositionRef();
      if (hitTestExistingAuxin(p.x, p.y)) {
        _auxins.remove(i);
        i--;
      }
    }
  }

  /**
   * x and y are in [0,1]
   */
  private boolean hitTestExistingAuxin(float x, float y) {
    float dx, dy, r;
    PVector p;

    r = _killRadius * _killRadius;
    for (VeinNode veinNode : _veinNodes) {
      p = veinNode.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        return true;
      }
    }

    return false;
  }

  /**
   * x and y are in [0,1]
   */
  private boolean hitTestPotentialAuxin(float x, float y) {
    float dx, dy, r;
    PVector p;

    r = 4.0 * _auxinRadius * _auxinRadius;
    for (Auxin auxin : _auxins) {
      p = auxin.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        return true;
      }
    }

    r = _killRadius * _killRadius;
    for (VeinNode veinNode : _veinNodes) {
      p = veinNode.getPositionRef();
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        return true;
      }
    }

    return false;
  }
}
