
VenationAlgorithm va;
VenationDrawer vd;
ChristmasLightsDrawer cld;
FileNamer folderNamer, fileNamer;

void setup() {
  size(540, 540);

  va = new VenationAlgorithm();
  vd = new VenationDrawer(va, this.g, width);
  cld = new ChristmasLightsDrawer(va, this.g, width);

  folderNamer = new FileNamer("output/export", "/");

  reset();
  redraw();
}

void draw() {
}

void reset() {
  va = new VenationAlgorithm();
  vd = new VenationDrawer(va, this.g, width);
  cld = new ChristmasLightsDrawer(va, this.g, width);

  fileNamer = new FileNamer(folderNamer.next() + "frame", "gif");
}

void redraw() {
  background(75, 40, 46);
  cld.draw();
}

void keyReleased() {
  switch (key) {
    case 'e':
      reset();
      redraw();
      break;
     
    case 'd':
      cld.recalculateColors();
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
