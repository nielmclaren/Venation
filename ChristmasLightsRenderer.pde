
import java.awt.Color;

class ChristmasLightsRenderer {
  private VenationAlgorithm _va;
  private PGraphics _g;
  private int _size;
  private ArrayList<Integer> _palette;
  private ArrayList<Integer> _colors;

  ChristmasLightsRenderer(VenationAlgorithm va, PGraphics g, int size) {
    _va = va;
    _g = g;
    _size = size;

    _palette = getPalette();
    _colors = new ArrayList<Integer>();
  }

  void draw() {
    colorMode(RGB);

    VeinNode veinNode;
    PVector p;
    color c;

    ArrayList<VeinNode> veinNodes = _va.getVeinNodes();
    int numVeinNodes = veinNodes.size();

    fillColors();

    _g.strokeWeight(2);

    for (int i = 0; i < numVeinNodes; i++) {
      veinNode = veinNodes.get(i);
      p = veinNode.getPositionRef();
      c = _colors.get(i);
      if (c == 0) continue;

      drawPoint(_size * p.x, _size * p.y, c);
    }
  }

  void drawPoint(float x, float y, color c) {
    float r;

    for (int i = 0; i < 6; i++) {
      r = 5;
      _g.stroke(color(red(c), green(c), blue(c), 88));
      _g.fill(color(red(c), green(c), blue(c), 32));
      _g.ellipse(x + jitter(), y + jitter(), 2*r, 2*r);

      r = 3;
      _g.noStroke();
      _g.fill(color(red(c), green(c), blue(c), 88));
      _g.ellipse(x + jitter(), y + jitter(), 2*r, 2*r);
    }
  }

  float jitter() {
    return 4 * (2 * random(1) - 1);
  }

  void recalculateColors() {
    _colors = new ArrayList<Integer>();
    fillColors();
  }

  private void fillColors() {
    int numVeinNodes = _va.getVeinNodes().size();
    while (_colors.size() < numVeinNodes) {
      _colors.add(random(1) < 0.05 ? 0 : getPaletteColor());
    }
  }

  private ArrayList<Integer> getPalette() {
    ArrayList<Integer> palette = new ArrayList<Integer>();
    palette.add(color(249, 240, 78)); // yellow 57° 69% 98%
    palette.add(color(255, 26, 86)); // red 344° 90% 100%
    palette.add(color(76, 91, 217)); // blue 234° 65% 85%
    palette.add(color(0, 236, 166)); // green 162° 100% 93%
    palette.add(color(148, 78, 210)); // purple 270° 63% 82%
    palette.add(color(252, 152, 65)); // orange 28° 74% 99%
    palette.add(color(153, 244, 254)); // cyan 186° 40% 100%
    return palette;
  }

  private int getPaletteColor() {
    return _palette.get(floor(random(1) * _palette.size()));
  }
}
