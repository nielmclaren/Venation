
class Point {
  protected PVector pos;

  Point() {
    pos = new PVector();
  }

  Point(PVector p) {
    pos = p;
  }

  Point(float x, float y) {
    pos = new PVector(x, y);
  }

  PVector getPosition() {
    return pos.get();
  }

  PVector getPositionRef() {
    return pos;
  }

  void setPosition(PVector p) {
    pos.set(p);
  }

  void setPosition(float x, float y) {
    pos.set(x, y);
  }
}
