#include <stdio.h>
#include "edge-impulse-sdk/classifier/ei_run_classifier.h"

int main(int argc, char** argv) {
  printf("hello world\n");
  return 0;
}

/*
#include <Arduino.h>
#include "esp_camera.h"
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "driver/rtc_io.h"

#include "camera.cpp"

void classify_image(camera_fb_t *fb) {
    if (!fb) {
        ei_printf("ERR: Camera capture failed\n");
        return;
    }
    // kodu jeszcze nie ma
}

void takeNewPhoto() {

  camera_fb_t  * fb = esp_camera_fb_get();

  if (!fb) {
    Serial.println("Camera capture failed");
    return;
  }

  classify_image(fb);

  // Return the frame buffer back to the driver for reuse
  esp_camera_fb_return(fb);
}

void setup() {

  // Disable brownout detector
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);

  // Start Serial Monitor
  Serial.begin(115200);

  // Initialize the camera
  Serial.print("Initializing the camera module...");
  configESPCamera();
  Serial.println("Camera OK!");

  // Take and Save Photo
  takeNewPhoto();
  
  // findPigeons()
  // ...


  // Bind Wakeup to GPIO13 going LOW
  esp_sleep_enable_ext0_wakeup(GPIO_NUM_13, 0);

  Serial.println("Entering sleep mode");
  delay(1000);

  // Enter deep sleep mode
  esp_deep_sleep_start();

}

void loop() {

}*/