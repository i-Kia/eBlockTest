#include <TFT_eSPI.h>
#include <SPI.h>
#include <Wire.h>
#include <SensirionI2cScd4x.h>
#include <SplashScreen.h>

// ArduinoBLE
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// =================================================
// SCD4 WARM UP TIME
// =================================================
#define WARMUP_TIME 60
#define UPDATE_INTERVAL 4000

// =================================================
// BATTERY PIN DEFINITIONS
// =================================================
#define BAT_EN  15        // 🔋 Battery / Power enable pin

// =================================================
// LILYGO T-DISPLAY S3 PIN DEFINITIONS
// =================================================
#define TFT_BL   38        // Backlight pin (MUST be enabled)

// I2C pins (physically available on the board)
#define I2C_SDA  43        // IO43
#define I2C_SCL  44        // IO44

// =================================================
// SCREEN
// =================================================
#define SCREEN_H 320
#define SCREEN_W 170

// =================================================
// SPRITE SIZE
// =================================================
#define SPRITE_W 160
#define SPRITE_H 160

// =================================================
// BLUETOOTH
// =================================================
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer *pServer;
BLEService *pService;
BLECharacteristic *pCharacteristic;

// =================================================
// OBJECTS
// =================================================
TFT_eSPI tft = TFT_eSPI();
SensirionI2cScd4x scd4x;

// =================================================
// UI 
// =================================================
TFT_eSprite gaugeSprite = TFT_eSprite(&tft);
TFT_eSprite warmupSprite = TFT_eSprite(&tft);
bool warmingUp = true;

// =================================================
// GAUGE GEOMETRY
// =================================================
int centerX = SPRITE_W / 2;
int centerY = SPRITE_H / 2 + 60;
int radius    = 70;
int thickness = 14;

int screenGaugeX = (SCREEN_W - SPRITE_W) / 2;
int screenGaugeY = 30;

// =================================================
// TIMING
// =================================================
unsigned long lastUpdateTime = 0;

// =================================================
// COLOUR LOGIC
// =================================================
uint16_t getColor(int value) {
  if (value < 800)  return tft.color565(0, 255, 0);     // Green
  if (value < 1500) return tft.color565(255, 255, 0);   // Yellow
  return tft.color565(255, 80, 0);                      // Red
}

// =================================================
// DRAW SPLASH SCREEN
// =================================================
void drawSplashScreen() {
  tft.fillScreen(TFT_WHITE);

  for (int i=0; i<sizeof(image); i++){
    switch (image[i]) {
      case 'b':
        if (image[i] == 'b') tft.drawPixel((int)(i / SCREEN_H), SCREEN_H - i % SCREEN_H, tft.color565(26, 34, 37));
        break;
      case 'y':
        if (image[i] == 'y') tft.drawPixel((int)(i / SCREEN_H), SCREEN_H - i % SCREEN_H, tft.color565(94, 103, 108));
        break;
      case 'g':
        if (image[i] == 'g') tft.drawPixel((int)(i / SCREEN_H), SCREEN_H - i % SCREEN_H, tft.color565(53, 127, 44));
        break;
    }
  }

}

// =================================================
// DRAW SCD41 WARM-UP SPRITE
// =================================================
void drawWarmUpMsg(int timeElapsed) {

  warmupSprite.fillSprite(TFT_BLACK);

  warmupSprite.setTextColor(TFT_WHITE, TFT_BLACK);
  warmupSprite.setTextSize(2);
  warmupSprite.drawString("WARMING UP", 10, 10);
  warmupSprite.drawString("TIME LEFT:" + String(WARMUP_TIME - timeElapsed) + "s", 10, 40);

  warmupSprite.setTextSize(1);
  warmupSprite.drawString("During this time readings", 10, 70);
  warmupSprite.drawString("may be unstable. CO2 ", 10, 90);
  warmupSprite.drawString("values can drift or spike. ", 10, 110);
  warmupSprite.drawString("Temperature and Humidity", 10, 130);
  warmupSprite.drawString("also stabilises. Do not", 10, 150);
  warmupSprite.drawString("trust readings in the", 10, 170);
  warmupSprite.drawString("first minute.", 10, 190);

  warmupSprite.pushSprite(0, 0);
}

// =================================================
// DRAW GAUGE SPRITE
// =================================================
void drawGaugeSprite(int value) {

  gaugeSprite.fillSprite(TFT_BLACK);

  const int startAngle = -160;
  const int endAngle   = 160;

  uint16_t statusColor = getColor(value);

  // ----- BACKGROUND ARC -----
  for (int i = startAngle; i < endAngle; i++) {
    float a = i * DEG_TO_RAD;
    gaugeSprite.drawLine(
      centerX + cos(a) * (radius - thickness),
      centerY + sin(a) * (radius - thickness),
      centerX + cos(a) * radius,
      centerY + sin(a) * radius,
      tft.color565(60, 60, 60)
    );
  }

  // ----- VALUE ARC -----
  int limit = map(value, 0, 5000, startAngle, endAngle);
  for (int i = startAngle; i < limit; i++) {
    float a = i * DEG_TO_RAD;
    gaugeSprite.drawLine(
      centerX + cos(a) * (radius - thickness),
      centerY + sin(a) * (radius - thickness),
      centerX + cos(a) * radius,
      centerY + sin(a) * radius,
      statusColor
    );
  }

  // ----- CO2 VALUE -----
  gaugeSprite.setTextDatum(MC_DATUM);
  gaugeSprite.setTextColor(TFT_WHITE, TFT_BLACK);
  gaugeSprite.setTextSize(3);
  gaugeSprite.drawString(String(value), centerX, centerY - 6);

  gaugeSprite.setTextSize(1);
  gaugeSprite.drawString("CO2 ppm", centerX, centerY + 28);

}

void drawProgressBar(float progress) {
  int barX = 20;
  int barY = SCREEN_H - 15;
  int barW = SCREEN_W - 40;
  int barH = 8;

  // Clear area
  tft.fillRect(barX - 2, barY - 2, barW + 4, barH + 4, TFT_BLACK);

  // Outline
  tft.drawRect(barX, barY, barW, barH, TFT_WHITE);

  // Fill
  int fillW = (int)(barW * progress);
  if (fillW < 0) fillW = 0;
  if (fillW > barW) fillW = barW;

  tft.fillRect(barX + 1, barY + 1, fillW - 2, barH - 2, TFT_WHITE);
}

// =================================================
// BLE CALLBACK
// =================================================
class pServerCallbacks: public BLEServerCallbacks {
  void onDisconnect(BLEServer* pServer) {
    Serial.println("Client Disconnected");
    pServer->startAdvertising();
  }
};

// =================================================
// SETUP
// =================================================
void setup() {

  // 🔋 BATTERY ENABLE (IMPORTANT)
  pinMode(BAT_EN, OUTPUT);
  digitalWrite(BAT_EN, HIGH);

  // ----- BACKLIGHT -----
  pinMode(TFT_BL, OUTPUT);
  digitalWrite(TFT_BL, HIGH);

  // ----- SERIAL -----
  Serial.begin(115200);
  delay(1000);
  Serial.println("BOOT OK");

  // ----- DISPLAY -----
  tft.init();
  tft.setRotation(2);
  tft.fillScreen(TFT_BLACK);

  // ----- SPRITES -----
  gaugeSprite.setColorDepth(16);
  gaugeSprite.createSprite(SCREEN_W, SCREEN_H - 60);

  warmupSprite.setColorDepth(16);
  warmupSprite.createSprite(SCREEN_W, SCREEN_H);

  // ----- SPLASH SCREEN -----
  drawSplashScreen();
  delay(5000);
  tft.fillScreen(TFT_BLACK);
  // drawWarmUpMsg(0);

  // ----- I2C -----
  Wire.begin(I2C_SDA, I2C_SCL);
  Serial.println("I2C started on SDA=43, SCL=44");

  // ----- SENSOR -----
  scd4x.begin(Wire, 0x62);
  scd4x.stopPeriodicMeasurement();
  delay(50);
  scd4x.startPeriodicMeasurement();

  Serial.println("SCD4x warming up...");

  // ----- SCD41 WARM UP -----
  for (int i = 0; i < WARMUP_TIME; i++) {
    delay(1000);
    drawWarmUpMsg(i);
  }

  // ----- BLUETOOTH -----
  BLEDevice::init("eBlockTester");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new pServerCallbacks());

  pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE
  );

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  
   // EXIT WARMUP MODE
  warmingUp = false;
  lastUpdateTime = millis();

  tft.fillScreen(TFT_BLACK);
}

// =================================================
// LOOP
// =================================================
void loop() {

  // LOCK UI DURING WARMUP
  if (warmingUp) {
    return;
  }

  static int displayValue = 400;
  unsigned long now = millis();

  // PROGRESS BAR
  float progress = (float)(now - lastUpdateTime) / UPDATE_INTERVAL;
  if (progress > 1.0) progress = 1.0;
  drawProgressBar(progress);

  if (now - lastUpdateTime >= UPDATE_INTERVAL) {
    
    lastUpdateTime = now;

    uint16_t co2 = 0;
    float temperature = 0;
    float humidity = 0;

    uint16_t error = scd4x.readMeasurement(co2, temperature, humidity);

    if (!error && co2 > 0) {
      displayValue = co2;

      Serial.print("CO2: ");
      Serial.print(co2);
      Serial.print(" ppm | Temp: ");
      Serial.print(temperature);
      Serial.print(" C | Hum: ");
      Serial.println(humidity);
    }

    
    // ----- GAUGE -----
    drawGaugeSprite(displayValue);
    gaugeSprite.pushSprite(screenGaugeX, screenGaugeY);

    // ----- STATUS BAR -----
    uint16_t statusColor = getColor(displayValue);
    tft.fillRect(0, 0, SCREEN_W, 48, TFT_BLACK);
    tft.setTextDatum(MC_DATUM);
    tft.setTextColor(statusColor, TFT_BLACK);
    tft.setTextSize(2);

    if (displayValue < 800) {
      tft.drawString("NORMAL", SCREEN_W / 2, 20);
    } else if (displayValue < 1500) {
      tft.drawString("ELEVATED CO2", SCREEN_W / 2, 20);
    } else {
      tft.drawString("COMBUSTION", SCREEN_W / 2, 20);
      tft.drawString("LEAK!", SCREEN_W / 2, 37);
    }

    // Data received via BLE
    std::string value = pCharacteristic->getValue();

    // Display BLE in Serial
    if(strcmp(value.c_str(), "") != 0) {
      Serial.println(value.c_str());
      String message = String(displayValue);
      pCharacteristic->setValue(message.c_str());
      pCharacteristic->notify();
    }
    pCharacteristic->setValue("");

  }
  delay(50);

}
