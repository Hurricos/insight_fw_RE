// Programming voltage switch pin
#define VPP 2
// !VCC pin
#define nVCC A5
// Latch pull-down pin
#define LAT  A1
// Macro!
#define SET_VPP(x) digitalWrite(VPP, x)

boolean vcc_on = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("                      "); // Small flush for the Arduino's IDE serial monitor
  pinMode( 2, OUTPUT );
  pinMode( nVCC, OUTPUT );
  pinMode( LAT, INPUT );

  digitalWrite(nVCC,HIGH);
  vcc_on = false;
}

// Helper for parsing Serial commands
String getValue(String data, char separator, int index)
{
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i=0; i<=maxIndex && found<=index; i++){
    if(data.charAt(i)==separator || i==maxIndex){
        found++;
        strIndex[0] = strIndex[1]+1;
        strIndex[1] = (i == maxIndex) ? i+1 : i;
    }
  }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void blip_vcc(uint16_t delay_usec) {
  if(vcc_on) {
    digitalWrite(nVCC,HIGH);
    delay(delay_usec);
    digitalWrite(nVCC,LOW);
  }
}

void set_vcc(boolean state) {
  digitalWrite(nVCC, !state);
  vcc_on = state;
}

void blip_latch(String input) {
  uint16_t delay_usec = getValue(input, ' ', 1).toInt();
  if(!delay_usec) {
    delay_usec = 0;
  }
  pinMode( LAT, OUTPUT );
  digitalWrite( LAT, LOW );
  digitalWrite( LAT, HIGH );
  digitalWrite( LAT, LOW );
  delay(delay_usec);
  pinMode( LAT, INPUT );
}


void menu() {
  while(!Serial.available() ){ }                   // Hang until any data is available
  String input = Serial.readStringUntil('\n');     // Read input command
  input.trim();                                    // Then parse it
  Serial.println(input);

  String cmd = getValue(input, ' ', 0);
  if(cmd.equals("$BVCC")) {
    blip_vcc(getValue(input, ' ', 1).toInt());
  } else if(cmd.equals("$SVPPH")) {
    SET_VPP(HIGH);
  } else if(cmd.equals("$SVPPL")) {
    SET_VPP(LOW);
  } else if(cmd.equals("$SVCCH")) {
    set_vcc(HIGH);
  } else if(cmd.equals("$SVCCL")) {
    set_vcc(LOW);
  } else if(cmd.equals("$BLAT")) {
    blip_latch(input);
  } else if(cmd.equals("$SAFE")) {
    blip_latch("");
    delay(10);
    SET_VPP(LOW);
    set_vcc(LOW);
  } else if(cmd.equals("$BOOTMODE")) {
    blip_latch("");
    delay(10);
    SET_VPP(LOW);       // $SAFE
    set_vcc(LOW);
    delay(10);
    
    set_vcc(HIGH);      // $SVCCH
    delay(10);

    blip_latch("");     // $BLAT
    delay(10);

    SET_VPP(HIGH);      // $SVPPH
    delay(10);

    blip_vcc(10); // $BVCC 10
    delay(10);
  } else {
    Serial.print(input);
    Serial.println(": Unknown command");
  }
}

void loop(){
  menu();
}
