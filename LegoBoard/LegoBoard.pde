float BRIGHTNESS_LOWER_BOUND =  30.0f;
float BRIGHTNESS_UPPER_BOUND = 200.0f;

float SATURATION_LOWER_BOUND = 125.0f;
float SATURATION_UPPER_BOUND = 255.0f;

float GREEN_HUE_LOWER_BOUND = 110.0f;
float GREEN_HUE_UPPER_BOUND = 139.0f;

void settings() {
  size(800, 600);
}
void setup() {
  noLoop(); // no interactive behaviour: draw() will be called only once.
}

PImage filter_threshold(PImage img, float lbBright, float upBright, float lbSat, float upSat, float lbHue, float upHue) {
  PImage result = createImage(width, height, ALPHA); // create a new, initially transparent, ’result’ image
  color black = color(0, 0, 0);
  
  for(int i = 0; i < img.width * img.height; i++) {
    float b = brightness(img.pixels[i]);
    float s = saturation(img.pixels[i]);
    float h = hue(img.pixels[i]);
    if (b < lbBright || b > upBright ||
        s < lbSat || s > upSat ||
        h < lbHue || h > upHue) {
      result.pixels[i] = black;
    } else {
      result.pixels[i] = img.pixels[i];
    }
  }
  
  return result;
}

PImage gaussian(PImage img) {
  float[][] kernel = { { 9, 12, 9 },
                       { 12, 15, 12 },
                       { 9, 12, 9 }};
                       
  float weight = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  // kernel size N = 3
  int N = 3;
    
  for (int y = N/2; y < img.height - N/2; ++y) {
    for (int x = N/2; x < img.width - N/2; ++x) {
      float sum = 0;
      for (int dy = -N/2; dy <= N/2; ++dy) {
        for (int dx = -N/2; dx <= N/2; ++dx) {
          sum += brightness(img.pixels[(x+dx) + (y+dy)*img.width]) * kernel[N/2+dx][N/2+dy]/weight; 
        }
      }
      result.pixels[y*img.width + x] = color(sum);
    }
  }

  return result;
}

PImage sobel(PImage img) {
    float[][] hKernel = { { 0, 1, 0 },
                          { 0, 0, 0 },
                          { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 },
                          { 1, 0, -1 },
                          { 0, 0, 0 } };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
        result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];
        
    int N = 3;
    for (int y = N/2; y < img.height - N/2; ++y) {
        for (int x = N/2; x < img.width - N/2; ++x) {
            float sum_v = 0;
            float sum_h = 0;
            for (int dy = -N/2; dy <= N/2; ++dy) {
                for (int dx = -N/2; dx <= N/2; ++dx) {
                    float brightness = brightness(img.pixels[(x+dx) + (y+dy)*img.width]);
                    sum_v += brightness * vKernel[N/2+dx][N/2+dy];
                    sum_h += brightness * hKernel[N/2+dx][N/2+dy];
                }
            }
            float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
            buffer[y*img.width + x] = sum;
            max = max(max, sum);
        }
    }
    
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
        for (int x = 2; x < img.width - 2; x++) { // Skip left and right
            if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
                result.pixels[y * img.width + x] = color(255);
            } else {
                result.pixels[y * img.width + x] = color(0);
            }
        }
    }
    return result;
}

void draw() {
  background(color(0,0,0));
  image(sobel(
          gaussian(
            filter_threshold(loadImage("board1.jpg"), 
            BRIGHTNESS_LOWER_BOUND, BRIGHTNESS_UPPER_BOUND, // Brightness
            SATURATION_LOWER_BOUND, SATURATION_UPPER_BOUND, // Saturation
            GREEN_HUE_LOWER_BOUND, GREEN_HUE_UPPER_BOUND)   // Hue
          )
        ), 0, 0);
}