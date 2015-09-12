#define APP_VERSION 1.1                         // Keep track of what version this code is
int fsrPin = A0; //analog pin 0
int fsrReading = 0;
char publishBuffer[ 4 ];
unsigned long publishInterval = 1000;

void setup(){
    Spark.publish("status", "{ status: \"started up! "+String(APP_VERSION)+"\"}", 60, PRIVATE );
    Spark.variable( "fsrReading", &fsrReading, INT );
    digitalWrite( fsrPin, HIGH ); //enable pullup resistor
}

void loop(){
    fsrReading = map (
        analogRead( fsrPin ),
        0, 4000, 
        0, 100
    );
    publishData();
    delay( publishInterval );
}

void publishData(){
    // sprintf( publishBuffer, "%d", fsrReading );
    // // Spark.publish( "fsrReading", publishBuffer );

    sprintf( publishBuffer, "{\"flex1\": %d, \"flex2\": %d, \"flex3\": %d, \"flex4\": %d}", 
            fsrReading, 25, 50, 75);
    
    Spark.publish( "pressure", publishBuffer );
}
