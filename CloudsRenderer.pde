
import java.util.Collections;

class CloudsRenderer {
  private VenationAlgorithm _va;
  private PGraphics _g;
  private int _size;
  private color _c;

  ArrayList<Integer> _reindex;
  ArrayList<Float> _radii;

  CloudsRenderer(VenationAlgorithm va, PGraphics g, int size, int c) {
    _va = va;
    _g = g;
    _size = size;
    _c = c;

    _reindex = new ArrayList<Integer>();
    _radii = new ArrayList<Float>();
  }

  void draw() {
    VeinNode veinNode;
    PVector p;
    float rw, rh;

    Object[] veinNodes = _va.getVeinNodes().toArray();
    int numVeinNodes = veinNodes.length;

    fillPoints();

    _g.fill(_c);
    _g.stroke(0);
    _g.strokeWeight(2);

    for (int i = 0; i < numVeinNodes; i++) {
      veinNode = (VeinNode)veinNodes[_reindex.get(i)];
      p = veinNode.getPositionRef();
      rw = _radii.get(2*i);
      rh = _radii.get(2*i+1);
      _g.ellipse(_size * p.x, _size * p.y, rw, rh);
    }

    fill(_c);
    noStroke();
    for (int i = 0; i < numVeinNodes; i++) {
      veinNode = (VeinNode)veinNodes[_reindex.get(i)];
      p = veinNode.getPositionRef();
      rw = _radii.get(2*i);
      rh = _radii.get(2*i+1);
      _g.ellipse(_size * p.x, _size * p.y, rw*0.8, rh*0.8);
    }
  }

  void drawPoint(float x, float y) {
    _g.line(x, y, x, y + 4);
  }

  private void fillPoints() {
    float r;
    int numPoints = _va.numVeinNodes();
    while (_radii.size() < numPoints * 2) {
      r = 25 + random(1) * 10;
      _radii.add(r);
      _radii.add(r * (1 + (2*random(1)-1) * 0.1));
    }

    _reindex = new ArrayList<Integer>();
    while (_reindex.size() < numPoints) {
      _reindex.add(_reindex.size());
    }
    Collections.shuffle(_reindex);
  }
}
