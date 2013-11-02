// RFID->Arduino->Imp->Prowl + Input Button
// Button is triggered by visiting this site --> https://api.electricimp.com/v1/19d54b3ebd6dc97b/30cec085973fb548
// Added a variable resistor to measure location of the garage door - inputs to pin 1


//Connections
//Arduino GND = Black x 2
//Arduino 5V = Red -> RFID Input 11 '5V'
//Arduino Pin 0 = Green -> RFID Input 9 'D0' 
//Arduino Pin 13 = Green + Tape -> RFDI Input 2 'RST'
//Electric Imp Pin 1 = Blue -> Relay

//Notes:
// reads from the Arduino serial port
//sends it over to the imp
//imp planner reads the ascii file
// if its a 1, 2, 3, 4, 5 it sends a HTML call to Prowl for ios notification


// These variables keep track of rx/tx LED toggling status
local txLEDToggle = 1;
local count=0;  //this is just a counter

// input class for Garage Door Solenoid control channel
// from http://devwiki.electricimp.com/doku.php?id=blinkomatic
// This is triggered when we vist the web site --> https://api.electricimp.com/v1/19d54b3ebd6dc97b/30cec085973fb548
class myInput extends InputPort
{
  name = "HTTPinput"
  type = "string"
  
    function set(value)
    {
        server.show("Web Activation")
        toggleTxLED();      // Toggle the TX LED
    }
}

local inputHTTP = myInput();  // assign impeeIn class to the impeeInput
local impOut1 = OutputPort("Bonnie", "string");  // set impeeOutput as a string
local impOut2 = OutputPort("Connor", "string");  // set impeeOutput as a string
local impOut3 = OutputPort("Zoe", "string");  // set impeeOutput as a string
local impOut4 = OutputPort("Caroline", "string");  // set impeeOutput as a string
local impOut5 = OutputPort("Ivan", "string");  // set impeeOutput as a string
local impOut6 = OutputPort("Guest 1", "string");  // set impeeOutput as a string
local impOut7 = OutputPort("Guest 2", "string");  // set impeeOutput as a string//
local pin1Out = OutputPort("pin1Out", "number");  // set impeeOutput as a string
local pin1txt = OutputPort("pin1txt", "string");  // set impeeOutput as a string
// local impOut8 = OutputPort("Glass RFID", "string");  // set impeeOutput as a string

function initUart()
{
    hardware.configure(UART_57);    // Using UART on pins 5 and 7
    hardware.uart57.configure(19200, 8, PARITY_NONE, 1, NO_CTSRTS); // 19200 baud worked well, no parity, 1 stop bit, 8 data bits
    
}

function initLEDs()
{
    // LED is on pin 9 on the imp Shield
    // Active low, so writing the pin a 1 will turn the LED off
    hardware.pin9.configure(DIGITAL_OUT_OD);
    hardware.pin9.write(1);
    
    // Input pin to measure garage door location (10 x turn potentiometer, 10kohms)
    hardware.pin1.configure(ANALOG_IN);   
    
    
}

// This function turns an LED on/off quickly on pin 9.
// It first turns the LED on, then calls itself again in 300 ms to turn the LED off
function toggleTxLED()
{
    txLEDToggle = txLEDToggle?0:1;    // toggle the txLEDtoggle variable
    if (!txLEDToggle)
    {
        imp.wakeup(0.3, toggleTxLED.bindenv(this)); // if we're turning the LED on, set a timer to call this function again (to turn the LED off)
    }
    hardware.pin9.write(txLEDToggle);  // TX LED is on pin 9 (active-low)
}


// This is our UART polling function. We'll call it once at the beginning of the program,
// then it calls itself every 10us. If there is data in the UART57 buffer, this will read
// as much of it as it can, and send it out of the impee's outputPort.
function pollUart()
{
    imp.wakeup(0.1, pollUart.bindenv(this));    // schedule the next poll in 0.1s
    //  imp.wakeup(0.00001, pollUart.bindenv(this));    // schedule the next poll in 10us
     
    // count just delays sending info to COSM until every 2.0 sec
    count=count+1
   if (count > 50)  // Counts for 50 cycles which is 5.0 seconds
    { 
        local byte1 = hardware.pin1.read();    // read the voltage on pin2 16 bit so 0-65,536
        local volts1=(1.65*((byte1/655.3-19.9))); //converts the number to a %
        pin1Out.set(volts1);
        server.show(volts1); //logs the value in the event log
        volts1=format("%d", volts1) // convert it to an string which will represent an integer.
        pin1txt.set(volts1);    
        count=0
   }
    
    
    
    
    
    local byte = hardware.uart57.read();    // read the UART buffer
    // This will return -1 if there is no data to be read.
    while (byte != -1)  // otherwise, we keep reading until there is no data to be read.
    {
        server.log(format("%c", byte)); // send the character out to the server log. Optional, great for debugging
        server.show(byte)
        if (byte ==49)
        { 
            impOut1.set(byte);  // send the valid character out the impee's outputPort ="1" Bonnie
            toggleTxLED();      // Toggle the TX LED
        }


        if (byte ==50)
        {   
            impOut2.set(byte)   // send the valid character out the impee's outputPort ="2" Connor
            toggleTxLED();      // Toggle the TX LED
        }
        
        if (byte ==51)
        {
            impOut3.set(byte)   // send the valid character out the impee's outputPort ="3" Zoe
            toggleTxLED();      // Toggle the TX LED
        }
        
        if (byte ==52)
        {
            impOut4.set(byte);  // send the valid character out the impee's outputPort ="4" Caroline
            toggleTxLED();      // Toggle the TX LED
        }
        
        if (byte ==53)
        {
            impOut5.set(byte);  // send the valid character out the impee's outputPort ="5" Ivan
            toggleTxLED();      // Toggle the TX LED
        }
        
        if (byte ==54)
        {
            impOut6.set(byte);  // send the valid character out the impee's outputPort ="6" Guest 1
            toggleTxLED();      // Toggle the TX LED
        }
        
        if (byte ==55)
        {
            impOut7.set(byte);  // send the valid character out the impee's outputPort ="7" Guest 2
            toggleTxLED();      // Toggle the TX LED
        }
        
  //      if (byte ==56) // "8"
    //    {
     //       impOut8.set(byte);  // send the valid character out the impee's outputPort ="8" Glass RFID
      //      toggleTxLED();      // Toggle the TX LED
    //    }
        
        
        //impOut1.set(byte);  // send the valid character out the impee's outputPort
        byte = hardware.uart57.read();  // read from the UART buffer again (not sure if it's a valid character yet)
        
    }
}

// This is where our program actually starts! Previous stuff was all function and variable declaration.
// This'll configure our impee. It's name is "UartCrossAir", and it has both an input and output to be connected:
imp.configure("imp-->HTTP-->Prowl", [inputHTTP], [impOut1,impOut2,impOut3,impOut4,impOut5,impOut6,impOut7,pin1Out,pin1txt]);
initUart(); // Initialize the UART, called just once
initLEDs(); // Initialize the LEDs, called just once
pollUart(); // start the UART polling, this function continues to call itself
// From here, two main functions are at play:
//      1. We'll be calling pollUart every 10us. If data is sent from the UART, we'll send out out of the impee.
//      2. If data is sent into the impee, we'll jump into the set function in the InputPort.
//
// The end
