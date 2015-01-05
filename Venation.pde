
VenationAlgorithm va;
VenationRenderer vr;
SimpleRenderer sr;
FileNamer folderNamer, fileNamer;

void setup() {
  size(612, 792);

  va = new VenationAlgorithm();
  vr = new VenationRenderer(va, this.g, height);
  sr = new SimpleRenderer(va, this.g, height);

  folderNamer = new FileNamer("output/export", "/");

  reset();
  redraw();
}

void draw() {
}

void reset() {
  va = new VenationAlgorithm();
  vr = new VenationRenderer(va, this.g, width);
  sr = new SimpleRenderer(va, this.g, width);

  fileNamer = new FileNamer(folderNamer.next() + "frame", "gif");
}

void redraw() {
  background(255);
  sr.draw();
}

void keyReleased() {
  switch (key) {
    case 'e':
      reset();
      redraw();
      break;

    case ' ':
      va.step();
      redraw();
      break;

    case 'r':
      save("render.png");
      break;
  }
}
