/**
 * @see http://algorithmicbotany.org/papers/venation.sig2005.pdf
 */

import org.jgrapht.Graph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;

import java.util.Set;

class VenationAlgorithm {
  ArrayList<Auxin> _auxins;
  float _auxinRadius;
  float _veinNodeRadius;
  float _killRadius;
  float _neighborhoodRadius;
  Graph _graph;

  VenationAlgorithm() {
    _auxins = new ArrayList<Auxin>();
    _auxinRadius = 0.025;
    _veinNodeRadius = 0.0125;
    _killRadius = 0.025;
    _neighborhoodRadius = 0.1;
    _graph = new SimpleGraph(DefaultEdge.class);

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

  Set<VeinNode> getVeinNodes() {
    return _graph.vertexSet();
  }

  int numVeinNodes() {
    return _graph.vertexSet().size();
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
    Set<VeinNode> veinNodes = _graph.vertexSet();
    for (VeinNode veinNode : veinNodes) {
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
    VeinNode veinNode;
    PVector veinNodePos, auxinPos = auxin.getPositionRef();
    ArrayList<VeinNode> veinNodes = getRelativeNeighborVeinNodes(auxin);
    for (int i = 0; i < veinNodes.size(); i++) {
      veinNode = veinNodes.get(i);
      veinNodePos = veinNode.getPositionRef();
      if (PVector.sub(veinNodePos, auxinPos).mag() < _killRadius) {
        veinNodes.remove(i);
        i--;
      }
    }
    return veinNodes;
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
      if (result.mag() < 1) {
        Auxin auxin = auxinInfluencers.get(0);
        p = auxin.getPosition();
        p.sub(veinNode.getPositionRef());
        p.normalize();
        result = p;
      }
      else {
        result.normalize();
      }
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
    Set<VeinNode> veinNodes = _graph.vertexSet();
    for (VeinNode veinNode : veinNodes) {
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
    VeinNode veinNode;
    for (int i = 0; i < 3; i++) {
      x = random(1);
      y = random(1);
      veinNode = new VeinNode(x, y);
      _graph.addVertex(veinNode);
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
    Object[] veinNodes = _graph.vertexSet().toArray();
    int count = veinNodes.length;
    for (int i = 0; i < count; i++) {
      VeinNode veinNode = (VeinNode)veinNodes[i];
      placeVeinNode(veinNode);
    }
  }

  void placeVeinNode(VeinNode seedVeinNode) {
    VeinNode veinNode;
    ArrayList<Auxin> influencerAuxins = getInfluencerAuxins(seedVeinNode);
    PVector p = getAuxinInfluenceDirection(seedVeinNode, influencerAuxins);
    if (p != null) {
      if (p.mag() <= 0) {
        p.x = 1;
        p.y = 0;
        p.rotate(random(1) * 2 * PI);
      }
      p.mult(2 * _veinNodeRadius);
      //p.rotate((2 * random(1) - 1) * 2 * PI * 0.05); // jitter
      p.add(seedVeinNode.getPositionRef());
      veinNode = new VeinNode(p);
      _graph.addVertex(veinNode);
      _graph.addEdge(seedVeinNode, veinNode);
    }
  }

  void killAuxins() {
    Auxin auxin;
    VeinNode veinNode;
    PVector auxinPos, veinNodePos;
    float dist;

    for (int i = 0; i < _auxins.size(); i++) {
      auxin = _auxins.get(i);
      auxinPos = auxin.getPositionRef();
      if (auxin.isDoomed()) {
        ArrayList<VeinNode> influencedVeinNodes = getInfluencedVeinNodes(auxin);
        ArrayList<VeinNode> taggedVeinNodes = auxin.getTaggedVeinNodesRef();
        for (int j = 0; j < taggedVeinNodes.size(); j++) {
          veinNode = taggedVeinNodes.get(j);
          veinNodePos = veinNode.getPositionRef();
          // FIXME: Inefficient because of PVector instantiation.
          dist = PVector.sub(veinNodePos, auxinPos).mag();
          if (dist < _killRadius || !influencedVeinNodes.contains(veinNode)) {
            taggedVeinNodes.remove(j);
            j--;
          }
        }

        if (taggedVeinNodes.size() <= 0) {
          _auxins.remove(i);
          i--;
        }
      }
      else {
        if (hitTestExistingAuxin(auxinPos.x, auxinPos.y)) {
          ArrayList<VeinNode> influencedVeinNodes = getInfluencedVeinNodes(auxin);
          if (influencedVeinNodes.size() > 1) {
            auxin.setDoomed(true);
            auxin.setTaggedVeinNodes(influencedVeinNodes);
          }
          else {
            _auxins.remove(i);
            i--;
          }
        }
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

    Set<VeinNode> veinNodes = _graph.vertexSet();
    for (VeinNode veinNode : veinNodes) {
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
    Set<VeinNode> veinNodes = _graph.vertexSet();
    for (VeinNode veinNode : veinNodes) {
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
