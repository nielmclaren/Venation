/**
 * @see http://algorithmicbotany.org/papers/venation.sig2005.pdf
 */

class VenationAlgorithm {
  ArrayList<PVector> _auxins;
  float _auxinRadius;
  ArrayList<PVector> _veinNodes;
  float _veinNodeRadius;
  float _killRadius;
  float _neighborhoodRadius;

  VenationAlgorithm() {
    _auxins = new ArrayList<PVector>();
    _auxinRadius = 0.025;
    _veinNodes = new ArrayList<PVector>();
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

  ArrayList<PVector> getAuxins() {
    return _auxins;
  }

  int numAuxins() {
    return _auxins.size();
  }

  ArrayList<PVector> getVeinNodes() {
    return _veinNodes;
  }

  int numVeinNodes() {
    return _veinNodes.size();
  }

  PVector getVeinNode(int veinNodeIndex) {
    return _veinNodes.get(veinNodeIndex);
  }

  ArrayList<PVector> getNeighborAuxins(int veinNodeIndex) {
    ArrayList<Integer> neighborAuxinIndices = getNeighborAuxinIndices(veinNodeIndex);
    ArrayList<PVector> neighborAuxins = new ArrayList<PVector>();
    for (int i : neighborAuxinIndices) {
      neighborAuxins.add(_auxins.get(i));
    }
    return neighborAuxins;
  }

  ArrayList<PVector> getInfluencerAuxins(int veinNodeIndex) {
    ArrayList<Integer> influencerAuxinIndices = getInfluencerAuxinIndices(veinNodeIndex);
    ArrayList<PVector> influencerAuxins = new ArrayList<PVector>();
    for (int i : influencerAuxinIndices) {
      influencerAuxins.add(_auxins.get(i));
    }
    return influencerAuxins;
  }

  PVector getAuxinInfluenceDirection(PVector veinNode, ArrayList<PVector> auxinInfluencers) {
    PVector result = null;
    for (PVector p : auxinInfluencers) {
      p = p.get();
      p.sub(veinNode);
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

  /// Private index accessors

  private ArrayList<Integer> getNeighborAuxinIndices(int veinNodeIndex) {
    float dx, dy, r = 4.0 * _neighborhoodRadius * _neighborhoodRadius;
    PVector p, veinNode = _veinNodes.get(veinNodeIndex);
    ArrayList<Integer> neighborAuxinIndices = new ArrayList<Integer>();
    for (int i = 0; i < _auxins.size(); i++) {
      p = _auxins.get(i);
      dx = p.x - veinNode.x;
      dy = p.y - veinNode.y;
      if (dx * dx + dy * dy < r) {
        neighborAuxinIndices.add(i);
      }
    }
    return neighborAuxinIndices;
  }

  private ArrayList<Integer> getInfluencerAuxinIndices(int veinNodeIndex) {
    ArrayList<Integer> neighborAuxinIndices = getNeighborAuxinIndices(veinNodeIndex);
    ArrayList<Integer> influencerAuxinIndices = new ArrayList<Integer>();
    for (int auxinIndex : neighborAuxinIndices) {
      if (veinNodeIndex == getInfluencedVeinNodeIndex(auxinIndex)) {
        influencerAuxinIndices.add(auxinIndex);
      }
    }
    return influencerAuxinIndices;
  }

  /**
   * Each auxin only influences the nearest vein node.
   */
  int getInfluencedVeinNodeIndex(int auxinIndex) {
    PVector auxin = _auxins.get(auxinIndex);
    return getNearestVeinNodeIndex(auxin.x, auxin.y);
  }

  int getNearestVeinNodeIndex(float x, float y) {
    int candidateIndex = -1;
    PVector p;
    float dx, dy, distSq, candidateDistSq = 0;
    for (int i = 0; i < _veinNodes.size(); i++) {
      p = _veinNodes.get(i);
      dx = p.x - x;
      dy = p.y - y;
      distSq = dx * dx + dy * dy;
      if (candidateIndex < 0 || distSq < candidateDistSq) {
        candidateIndex = i;
        candidateDistSq = distSq;
      }
    }
    return candidateIndex;
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
      _veinNodes.add(new PVector(x, y));
    }
  }

  void seedAuxins() {
    float x, y;
    for (int i = 0; i < 1000 && _auxins.size() < 200; i++) {
      x = random(1);
      y = random(1);
      if (!hitTestPotentialAuxin(x, y)) {
        _auxins.add(new PVector(x, y));
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
    PVector veinNode = _veinNodes.get(seedVeinNodeIndex);
    ArrayList<PVector> influencerAuxins = getInfluencerAuxins(seedVeinNodeIndex);
    PVector p = getAuxinInfluenceDirection(veinNode, influencerAuxins);
    if (p != null) {
      if (p.mag() <= 0) {
        p.x = 1;
        p.y = 0;
        p.rotate(random(1) * 2 * PI);
      }
      p.mult(2 * _veinNodeRadius);
      p.add(veinNode);
      _veinNodes.add(p);
    }
  }

  void killAuxins() {
    PVector p;
    for (int i = 0; i < _auxins.size(); i++) {
      p = _auxins.get(i);
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

    r = _killRadius * _killRadius;
    for (PVector p : _veinNodes) {
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

    r = 4.0 * _auxinRadius * _auxinRadius;
    for (PVector p : _auxins) {
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        return true;
      }
    }

    r = _killRadius * _killRadius;
    for (PVector p : _veinNodes) {
      dx = p.x - x;
      dy = p.y - y;
      if (dx * dx + dy * dy < r) {
        return true;
      }
    }

    return false;
  }
}
