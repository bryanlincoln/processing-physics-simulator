import java.util.*; 

int selectedScene = 0;
String[] scenes = {
  "scenes/scene1.dat",
  "scenes/scene2.dat",
  "scenes/scene3.dat"
};

Screen screen;
World world;
PVector[] observer; // observador/câmera
float deltaTime = 0;
float lastTime = 0;


void setup() {
  size(720, 720);
  // fullScreen();
  strokeWeight(2);
  
  world = new World();
  screen = new Screen();

  lastTime = millis();
  
  load(scenes[selectedScene]);
}


void draw() {
  deltaTime = (millis() - lastTime) / 1000;
  lastTime = millis();

  background(77);
  
  if(helpPressed) screen.showHelp();
  
  // pega inputs
  keyRepeat();
  
  // calcula e renderiza o mundo
  world.step();
  world.render();
  
  // exibe interface
  screen.showFPS();
  screen.showInfo();
  screen.addLine(world.name, 0, 0);
  screen.addLine("\"" + world.selectedName() + "\" selected", 1, 2);
  screen.addLine("Position:  " + world.selectedPosition() + "\nRotation: " + world.selectedRotation() + "\nScale:      " + world.selectedScale(), 2, 2);
}


void mousePressed() {
  int mY = height - mouseY;
}


void mouseReleased() {
  int mY = height - mouseY;
}

void switchScene() {
  selectedScene = (selectedScene + 1) % scenes.length;

  world = new World();
  screen = new Screen();

  load(scenes[selectedScene]);
}


void load(String fileName) {
  // Carrega dados do mundo e objetos de um arquivo
  
  String[] fileLines = loadStrings(fileName);
  int cursorPosition = 0;
  
  String figureName = fileLines[cursorPosition++].substring(2);
  
  // lê as dimensões do dispositivo
  String[] worldDimensions = split(fileLines[cursorPosition++], " ");

  // lê a posição da câmera
  String[] cameraAttrs = split(fileLines[cursorPosition++], " ");
  PVector cameraPosition = new PVector(Float.parseFloat(cameraAttrs[0]), Float.parseFloat(cameraAttrs[1]), Float.parseFloat(cameraAttrs[2]));
  PVector cameraRotation = new PVector(Float.parseFloat(cameraAttrs[3]), Float.parseFloat(cameraAttrs[4]), Float.parseFloat(cameraAttrs[5]));
  PVector cameraScale = new PVector(Float.parseFloat(cameraAttrs[6]), Float.parseFloat(cameraAttrs[7]), Float.parseFloat(cameraAttrs[8]));
  
  // lê a posição do observador
  String[] obsAttrs = split(fileLines[cursorPosition++], " ");
  PVector observer = new PVector(Float.parseFloat(obsAttrs[0]), Float.parseFloat(obsAttrs[1]), Float.parseFloat(obsAttrs[2]));

  // lê a quantidade de objetos
  int numObjects = Integer.parseInt(fileLines[cursorPosition++]);
  
  // lê os objetos
  for(int i = 0; i < numObjects; i++) {
    Object object = new Object(fileLines[cursorPosition++].substring(2));
    
    String[] objectDimensions = split(fileLines[cursorPosition++], " ");
    
    int numPoints = Integer.parseInt(objectDimensions[0]);
    int numLines = Integer.parseInt(objectDimensions[1]);
    int numFaces = Integer.parseInt(objectDimensions[2]);
    
    float[][] vertices = new float[numPoints][3];
    int[][] edges = new int[numLines][2];
    Face[] faces = new Face[numFaces];
    
    // lê os vertices
    for(int j = 0; j < numPoints; j++) {
      String[] point = split(fileLines[cursorPosition++], " ");
      for(int k = 0; k < 3; k++) {
        vertices[j][k] = Float.parseFloat(point[k]);
      }
    }
    
    // lê as linhas
    for(int j = 0; j < numLines; j++) {
      String[] line = split(fileLines[cursorPosition++], " ");
      for(int k = 0; k < 2; k++) {
        edges[j][k] = Integer.parseInt(line[k]) - 1;
      }
    }
    
    // lê as faces
    for(int j = 0; j < numFaces; j++) {
      String[] face = split(fileLines[cursorPosition++], " ");
      
      int[] facePoints = new int[Integer.parseInt(face[0])];
      
      for(int k = 1; k <= facePoints.length; k++) {
        facePoints[k - 1] = Integer.parseInt(face[k]) - 1;
      }
      
      int faceColorR = int(Float.parseFloat(face[facePoints.length + 1]) * 255);
      int faceColorG = int(Float.parseFloat(face[facePoints.length + 2]) * 255);
      int faceColorB = int(Float.parseFloat(face[facePoints.length + 3]) * 255);
      color colour = color(faceColorR, faceColorG, faceColorB);
       
      faces[j] = new Face(facePoints, colour);
    }
    
    // lê a rotação
    String rotationS[] = split(fileLines[cursorPosition++], " ");
    PVector rotation = new PVector(Float.parseFloat(rotationS[0]), Float.parseFloat(rotationS[1]), Float.parseFloat(rotationS[2]));
    
    // lê a escala
    String scaleS[] = split(fileLines[cursorPosition++], " ");
    PVector scale = new PVector(Float.parseFloat(scaleS[0]), Float.parseFloat(scaleS[1]), Float.parseFloat(scaleS[2]));
    
    // lê a translação
    String translationS[] = split(fileLines[cursorPosition++], " ");
    PVector translation = new PVector(Float.parseFloat(translationS[0]), Float.parseFloat(translationS[1]), Float.parseFloat(translationS[2]));
    
    // lê os atributos da física
    Physics physics = (Physics) object.getComponent(new Physics(null));
    if(physics != null) {
      physics.isRigidbody = (1 == Integer.parseInt(fileLines[cursorPosition++]));
      physics.mass = Float.parseFloat(fileLines[cursorPosition++]);
    }

    // inicializa o objeto
    object.init(vertices, edges, translation, rotation, scale, faces);
    // adiciona o objeto ao mundo
    world.create(object);
  }

  // inicializa o mundo depois que todos os objetos foram configurados para que a física funcione corretamente
  world.init(
    figureName, 
    new PVector(Integer.parseInt(worldDimensions[0]), 
    Integer.parseInt(worldDimensions[2])), 
    new PVector(Integer.parseInt(worldDimensions[1]), 
    Integer.parseInt(worldDimensions[3])),
    cameraPosition,
    cameraRotation,
    cameraScale,
    observer
  );
}
