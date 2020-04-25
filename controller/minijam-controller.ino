#include <MPU6050_tockn.h>
#include <Wire.h>
#include <SoftTimer.h>

#define ArrayLength  60

void takeSample(Task* me);
void sendData(Task* me);

Task sampleTask(10, takeSample); // read gyro every x ms
Task dataTask(100, sendData); // write to serial every x ms

int xArray[ArrayLength];
int xArrayIndex=0;
int yArray[ArrayLength];
int yArrayIndex=0;
int zArray[ArrayLength];
int zArrayIndex=0;

MPU6050 mpu(Wire);

void setup(){
  Wire.begin();
  Serial.begin(9600);
  mpu.begin();
  mpu.calcGyroOffsets();

  while(!Serial) {}
  
  SoftTimer.add(&sampleTask);
  SoftTimer.add(&dataTask);

//  while (Serial.available() <= 0) {
//    Serial.println("A");    // send ping
//    delay(300);
//  }
}

void takeSample(Task* me) {
  mpu.update();
  
  xArray[xArrayIndex++]= mpu.getAngleX();
  if(xArrayIndex==ArrayLength) xArrayIndex=0;
  yArray[yArrayIndex++]= mpu.getAngleY();
  if(yArrayIndex==ArrayLength) yArrayIndex=0;
  zArray[zArrayIndex++]= mpu.getAngleZ();
  if(zArrayIndex==ArrayLength) zArrayIndex=0;
}

void sendData(Task* me) {
  //Serial.print("x,");
  Serial.print(averagearray(xArray, ArrayLength));
  Serial.print(",");
  //Serial.print("y,");
  Serial.print(averagearray(yArray, ArrayLength));
  Serial.print(",");
  //Serial.print("z,");
  Serial.println(averagearray(zArray, ArrayLength));
}

double averagearray(int* arr, int number) {
  int i;
  int max, min;
  double avg;
  long amount = 0;
  if (number <= 0) {
    Serial.println("Error number for the array to avraging!/n");
    return 0;
  }
  if (number<5) {   //less than 5, calculated directly statistics
    for (i=0;i<number;i++) {
      amount += arr[i];
    }
    avg = amount/number;
    return avg;
  } else {
    if(arr[0]<arr[1]){
      min = arr[0];
      max=arr[1];
    } else {
      min=arr[1];
      max=arr[0];
    }
    for (i=2; i<number; i++){
      if(arr[i]<min){
        amount+=min;        //arr<min
        min=arr[i];
      } else {
        if (arr[i]>max) {
          amount+=max;    //arr>max
          max=arr[i];
        } else {
          amount+=arr[i]; //min<=arr<=max
        }
      }//if
    }//for
    avg = (double)amount/(number-2);
  }//if
  return avg;
}
