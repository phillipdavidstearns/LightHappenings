
char ints[10] = {'0','1','2','3','4','5','6','7','8','9'};

void setup() {
  
  Serial.begin(115200);
  
}

void loop() {
  char c[4];

  Serial.print("char[]: ");
  for (int i = 0 ; i < 4 ; i++){
    c[i] = ints[int(random(10))];
    Serial.print(c[i]);
  }

  Serial.print(" converted to int: ");
  Serial.println(atoi(c));

  delay(1000);
  
}
