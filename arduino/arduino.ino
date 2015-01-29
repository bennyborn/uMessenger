#include <SPI.h>
#include <Wire.h>
#include "Adafruit_GFX.h"
#include "Adafruit_SSD1306.h"

#define OLED_RESET 4
Adafruit_SSD1306 display(OLED_RESET);

String serialData = "";
boolean serialDataComplete = false;

void setup()   {            

  Serial.begin(9600);

  display.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  display.clearDisplay();
  display.setTextColor(WHITE);
  display.setCursor(0,1);
  display.setTextSize(1);
  display.println("Booting up...");
  display.display();
  
  serialData.reserve(200);
}

void serialEvent() {
  while( Serial.available() ) {
    char inChar = (char)Serial.read(); 
    serialData += inChar;
    if (inChar == '\n') {
      serialDataComplete = true;
    } 
  }
}

void loop() {

  if( serialDataComplete ) {

    // ::MSG::subject#message##    
    if( serialData.charAt(0) == ':' && serialData.charAt(6) == ':' ) {

      display.clearDisplay();
      
      // print header
      display.setCursor(0,1);
      display.setTextSize(1);
      
      int i=7;

      for( ; i<serialData.indexOf('#'); i++ )
        display.print( serialData.charAt(i) );

      display.print('\n');
      display.display();

      // print message
      display.setCursor(0,16);
      display.setTextSize( (((serialData.length()-i-4) > 20)?1:2) );

      for( i=i+1; i<serialData.length()-4; i++ )
        display.print( serialData.charAt(i) );

      display.display();
    }

    serialData = "";
    serialDataComplete = false; 
  }
}
