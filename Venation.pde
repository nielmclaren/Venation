
VenationAlgorithm va, vaX2;
VenationRenderer vr;
CloudsRenderer renderer, rendererX2, rendererX_5;
FileNamer folderNamer, fileNamer;

void setup() {
  size(612, 792);

  folderNamer = new FileNamer("output/export", "/");

  reset();
  redraw();
}

void draw() {
}

void reset() {
  va = new VenationAlgorithm();
  vaX2 = new VenationAlgorithm();
  vr = new VenationRenderer(va, this.g, width);
  renderer = new CloudsRenderer(va, this.g, height, color(129, 195, 182));
  rendererX2 = new CloudsRenderer(vaX2, this.g, height, color(25, 52, 134));
  rendererX_5 = new CloudsRenderer(va, this.g, height*2, color(255, 224, 70));

  fileNamer = new FileNamer(folderNamer.next() + "frame", "gif");

  for (int i = 0; i < 14; i++) {
    va.step();
    if (i > 6) {
      vaX2.step();
    }
  }
}

void redraw() {
  background(128);

  pushMatrix();
  scale(1.5);
  rendererX2.draw();
  popMatrix();

  renderer.draw();

  pushMatrix();
  scale(0.5);
  rendererX_5.draw();
  popMatrix();
}

void keyReleased() {
  switch (key) {
    case 'e':
      reset();
      redraw();
      break;

    case ' ':
      va.step();
      vaX2.step();
      redraw();
      break;

    case 'r':
      save("render.png");
      break;
  }
}
