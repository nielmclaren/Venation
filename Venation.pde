
VenationAlgorithm va;
VenationDrawer vd;
FileNamer folderNamer, fileNamer;

void setup() {
  size(800, 800);

  va = new VenationAlgorithm();
  vd = new VenationDrawer(va, this.g, width);

  folderNamer = new FileNamer("output/export", "/");

  reset();
  redraw();
}

void draw() {
}

void reset() {
  va = new VenationAlgorithm();
  vd = new VenationDrawer(va, this.g, width);

  fileNamer = new FileNamer(folderNamer.next() + "frame", "gif");
}

void redraw() {
  background(255);
  vd.draw();
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
      save(fileNamer.next());
      break;
  }
}
