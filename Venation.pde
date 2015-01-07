
VenationAlgorithm va;
VenationRenderer renderer;
FileNamer folderNamer, fileNamer;

void setup() {
  size(800, 800);

  folderNamer = new FileNamer("output/export", "/");

  reset();
  redraw();
}

void draw() {
}

void reset() {
  va = new VenationAlgorithm();
  renderer = new VenationRenderer(va, this.g, width);

  fileNamer = new FileNamer(folderNamer.next() + "frame", "gif");
}

void redraw() {
  background(255);

  renderer.draw();
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
