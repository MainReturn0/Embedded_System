void setup() 
{
  // put
  for (int i=0; i<7; i++)
  {
    pinMode(i,OUTPUT);
  }
}

void showDigit(int digit)
{
  const byte segments[] = {0b0111111,0b110,0b1011011,0b1001111,0b1100110,0b1101101,0b1111101,0b0111,0b1111111,0b1101111};
  byte current = segments[digit];
   for (int i=0; i<7; i++)
   {
    digitalWrite(i, current&1);
    current >>= 1; 
   }
}

void loop() 
{
  // put your main code here, to run repeatedly:
  for (int i=0; i<=9; i++)
  {
    showDigit(i);
    delay(1000);
  }
}
