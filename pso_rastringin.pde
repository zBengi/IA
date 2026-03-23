//===================================================================================================================================//
// Implementación corregida de PSO para la función Rastrigin
// Módulo de Inteligencia Artificial
//===================================================================================================================================//

int    N_PARTICULAS = 30;
float  W = 0.5;
float  C1 = 1.5;
float  C2 = 1.5;
float  X_MIN = -3;
float  X_MAX = 7;
int    MAX_ITER = 300;

//Límite de velocidad dinámico basado en el 15% del dominio
float  V_MAX = (X_MAX - X_MIN) * 0.15; 

float[][] pos;
float[][] vel;
float[][] pbest;
float[]   pbest_val;
float[]   gbest;
float     gbest_val;

int iter = 0;
boolean ejecutando = true;

// UI y Gráficos
Slider[] sliders;
int activeSlider = -1;
int infoBx=0, infoBy=0, infoBw=0, infoBh=0;

//Objeto para almacenar el mapa de calor estático
PGraphics fondoRastrigin;

//===================================================================================================================================//
float rastrigin(float[] x) {
  int n = x.length;
  float sum = 10 * n;
  for (int i = 0; i < n; i++) {
    sum += x[i]*x[i] - 10 * cos(2 * PI * x[i]);
  }
  return sum;
}

//===================================================================================================================================//
void initPSO() {
  pos       = new float[N_PARTICULAS][2];
  vel       = new float[N_PARTICULAS][2];
  pbest     = new float[N_PARTICULAS][2];
  pbest_val = new float[N_PARTICULAS];
  gbest     = new float[2];
  gbest_val = Float.MAX_VALUE;
  
  iter      = 0;
  ejecutando   = true;
  
  for (int i = 0; i < N_PARTICULAS; i++) {
    for (int d = 0; d < 2; d++) {
      pos[i][d]  = random(X_MIN, X_MAX);
      vel[i][d]  = random(-V_MAX, V_MAX);
      pbest[i][d] = pos[i][d];
    }
    pbest_val[i] = rastrigin(pos[i]);
    
    if (pbest_val[i] < gbest_val) {
      gbest_val = pbest_val[i];
      gbest[0]  = pos[i][0];
      gbest[1]  = pos[i][1];
    }
  }
}

//===================================================================================================================================//
void stepPSO() {
  for (int i = 0; i < N_PARTICULAS; i++) {
    for (int d = 0; d < 2; d++) {
      float r1 = random(1);
      float r2 = random(1);

      // Actualizar velocidad
      vel[i][d] = W  * vel[i][d]
                + C1 * r1 * (pbest[i][d] - pos[i][d])
                + C2 * r2 * (gbest[d]    - pos[i][d]);
                
      // Limitar velocidad al V_MAX dinámico
      vel[i][d] = constrain(vel[i][d], -V_MAX, V_MAX);
      
      // Actualizar posición
      pos[i][d] += vel[i][d];
      
      // CORRECCIÓN: Manejo de fronteras elástico para no mermar la exploración
      if (pos[i][d] < X_MIN) { 
        pos[i][d] = X_MIN; 
        vel[i][d] *= -0.5; // Rebote con amortiguación
      } else if (pos[i][d] > X_MAX) { 
        pos[i][d] = X_MAX; 
        vel[i][d] *= -0.5; // Rebote con amortiguación
      }
    }

    // Actualizar pbest
    float val = rastrigin(pos[i]);
    if (val < pbest_val[i]) {
      pbest_val[i] = val;
      pbest[i][0]  = pos[i][0];
      pbest[i][1]  = pos[i][1];

      // Actualizar gbest
      if (val < gbest_val) {
        gbest_val = val;
        gbest[0]  = pos[i][0];
        gbest[1]  = pos[i][1];
      }
    }
  }
}

//===================================================================================================================================//
void generarFondoRastrigin() {
  // Genera el mapa de calor 
  fondoRastrigin = createGraphics(480, 480);
  fondoRastrigin.beginDraw();
  
  int resolucion = 150; // Aumentado para mejor detalle sin afectar rendimiento
  float cellSize = 480.0 / resolucion;
  
  fondoRastrigin.colorMode(HSB, 360, 100, 100);
  fondoRastrigin.noStroke();
  
  for (int ix = 0; ix < resolucion; ix++) {
    for (int iy = 0; iy < resolucion; iy++) {
      float x0 = map(ix, 0, resolucion, X_MIN, X_MAX);
      float x1 = map(iy, 0, resolucion, X_MAX, X_MIN); 
      
      float[] xv = {x0, x1};
      float val = rastrigin(xv);
      
      // Mapeo ajustado al máximo real del dominio (~125)
      float hue = map(val, 0, 130, 240, 0);
      hue = constrain(hue, 0, 240); // Evita colores basura
      
      fondoRastrigin.fill(hue, 90, 80, 200);
      fondoRastrigin.rect(ix * cellSize, iy * cellSize, cellSize + 1, cellSize + 1);
    }
  }
  fondoRastrigin.endDraw();
}

//===================================================================================================================================//
void setup() {
  size(760, 600);
  textFont(createFont("Monospaced", 12));
  generarFondoRastrigin(); // Cargar la imagen del heatmap
  initPSO();
  initSliders();
}

//===================================================================================================================================//
void draw() {
  background(30);
  
  // Dibujar el mapa en caché de forma ultrarrápida (60 FPS estables)
  image(fondoRastrigin, 60, 60);
  
  if (ejecutando && iter < MAX_ITER) {
    stepPSO();
    iter++;
  } else {
    ejecutando = false;
  }
  
  // Dibujar partículas
  for (int i = 0; i < N_PARTICULAS; i++) {
    float sx = map(pos[i][0], X_MIN, X_MAX, 60, 540);
    float sy = map(pos[i][1], X_MIN, X_MAX, 540, 60);
    
    fill(0);           
    stroke(255);       
    strokeWeight(1);
    ellipse(sx, sy, 8, 8);
  }
  
  // Dibujar gbest 
  float gx = map(gbest[0], X_MIN, X_MAX, 60, 540);
  float gy = map(gbest[1], X_MIN, X_MAX, 540, 60);
  
  fill(255, 80, 80);
  stroke(255);
  strokeWeight(1.5);
  ellipse(gx, gy, 14, 14);
  
  noStroke();
  drawEjes();
  drawInfoBox();
}

//===================================================================================================================================//
void drawEjes() {
  stroke(200);
  strokeWeight(1);
  fill(200);
  textSize(11);
  textAlign(CENTER);
  
  for (float v = X_MIN; v <= X_MAX; v += 2) {
    float sx = map(v, X_MIN, X_MAX, 60, 540);
    text(nf(v, 1, 0), sx, 560);          
    stroke(200, 50);
    line(sx, 60, sx, 540);               
    stroke(200);
  }
  text("x1", 300, 578);
  
  textAlign(RIGHT);
  for (float v = X_MIN; v <= X_MAX; v += 2) {
    float sy = map(v, X_MIN, X_MAX, 540, 60);
    text(nf(v, 1, 0), 52, sy + 4);      
    stroke(200, 50);
    line(60, sy, 540, sy);              
    stroke(200);
  }
  
  noFill();
  stroke(200);
  strokeWeight(1.5);
  rect(60, 60, 480, 480);
}

//===================================================================================================================================//
void drawInfoBox() {
  int bx = 560; int by = 60; int bw = 180; int bh = 240;
  infoBx = bx; infoBy = by; infoBw = bw; infoBh = bh;
  
  noStroke();
  fill(40, 40, 40, 220);
  rect(bx, by, bw, bh, 6);

  fill(255);
  textAlign(LEFT);
  textSize(12);
  
  String estado = ejecutando ? "Ejecutando" : "Detenido";
  text("Iter: " + iter + " / " + MAX_ITER, bx + 10, by + 18);
  text("gbest: " + nf(gbest_val, 1, 4), bx + 10, by + 36);
  
  if (sliders != null) {
    for (int i = 0; i < sliders.length; i++) {
      sliders[i].setBounds(bx + 10, by + 50 + i * 30, bw - 20, 14);
      sliders[i].display();
    }
  }

  int btnW = 70; int btnH = 22;
  int btnY = by + bh - 36;
  int btnPlayX = bx + 10;
  int btnResetX = bx + 20 + btnW;

  fill(ejecutando ? color(80,200,80) : color(200));
  rect(btnPlayX, btnY, btnW, btnH, 4);
  fill(0);
  textAlign(CENTER, CENTER);
  text(ejecutando ? "Pausa" : "Play", btnPlayX + btnW/2, btnY + btnH/2);
  
  fill(200);
  rect(btnResetX, btnY, btnW, btnH, 4);
  fill(0);
  text("Reset", btnResetX + btnW/2, btnY + btnH/2);
  
  textAlign(LEFT);
}

//===================================================================================================================================//
void initSliders() {
  sliders = new Slider[5];
  sliders[0] = new Slider("Partículas", 2, 200, N_PARTICULAS);
  sliders[1] = new Slider("W", 0.0, 1.5, W);
  sliders[2] = new Slider("C1", 0.0, 3.0, C1);
  sliders[3] = new Slider("C2", 0.0, 3.0, C2);
  sliders[4] = new Slider("Iteraciones", 10, 2000, MAX_ITER);
}

class Slider {
  String label;
  float minv, maxv, value;
  float x, y, w, h;
  boolean dragging = false;

  Slider(String label, float minv, float maxv, float value) {
    this.label = label; this.minv = minv; this.maxv = maxv; this.value = value;
  }

  void setBounds(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  void display() {
    fill(120);
    rect(x, y, w, h, 4);
    float tx = map(value, minv, maxv, x, x + w);
    fill(240);
    ellipse(tx, y + h/2, h+6, h+6);

    fill(255); textSize(11); textAlign(LEFT, CENTER);
    String valStr;
    if (label.equals("Partículas") || label.equals("Iteraciones")) {
      valStr = str(int(value));
    } else {
      valStr = nf(value, 1, 3);
    }
    text(label + ": " + valStr, x, y - 8);
  }

  boolean overThumb() {
    float tx = map(value, minv, maxv, x, x + w);
    return dist(mouseX, mouseY, tx, y + h/2) <= (h+6)/2;
  }

  void pressed() { if (overThumb()) dragging = true; }
  
  void dragged() {
    if (dragging) {
      float nx = constrain(mouseX, x, x + w);
      value = map(nx, x, x + w, minv, maxv);
    }
  }
  
  void released() { dragging = false; }
  float getValue() { return value; }
}

void mousePressed() {
  if (sliders != null) {
    for (int i = 0; i < sliders.length; i++) {
      sliders[i].pressed();
      if (sliders[i].dragging) { activeSlider = i; break; }
    }
  }

  if (mouseX >= infoBx && mouseX <= infoBx + infoBw && mouseY >= infoBy && mouseY <= infoBy + infoBh) {
    int btnW = 70; int btnH = 22; int btnY = infoBy + infoBh - 36;
    int btnPlayX = infoBx + 10; int btnResetX = infoBx + 20 + btnW;

    if (mouseX >= btnPlayX && mouseX <= btnPlayX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
      ejecutando = !ejecutando;
    }

    if (mouseX >= btnResetX && mouseX <= btnResetX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
      N_PARTICULAS = int(sliders[0].getValue());
      W = sliders[1].getValue();
      C1 = sliders[2].getValue();
      C2 = sliders[3].getValue();
      MAX_ITER = int(sliders[4].getValue());
      initPSO();
    }
  }
}

void mouseDragged() {
  if (activeSlider >= 0 && sliders != null && activeSlider < sliders.length) {
    sliders[activeSlider].dragged();
  }
}

void mouseReleased() {
  if (sliders != null) {
    for (int i = 0; i < sliders.length; i++) sliders[i].released();
  }
  activeSlider = -1;
}