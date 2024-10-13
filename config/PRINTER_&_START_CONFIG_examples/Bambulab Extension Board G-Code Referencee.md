# Bambulab Extension Board G-Code Reference

M1004 S0 P[ppp]
S = 0 save 
P: Command selection (0-1), 1: storage configuration, 0: erase configuration

If the user does not save DIY configuration, the default will be restored after restarting.

    LED strip configuration
    Fan switch or speed setting
    Sliding varistor, reserved AD interface function configuration
    Switch, reserved GPIO function configuration

LED lighting configuration (S = 1,2)
Single LED configuration
The current settings support individual control of each color in the light strip for more complex mode settings.

Command format

M1004 S1 L[lll] M[mmm] B[bbb] T[sss] O[ooo] F[fff]

Description

    L: LED index (0-5), expansion board supports two strips, each containing RGB three colors.
        LED 0 contains channel 0,1,2
        LED 1 contains channel 3,4,5
    M: LED Mode (0-2)
        0: Always bright
        1: Breath
        2: Blink
    B: Brightness setting (0-255)
    T: Relative start time (0-65535 ms), this parameter is used for the delay control of the light strip, and this parameter will be explained after introducing all the parameters
    O: On time in breath/blink mode (M = 1, 2) (0-65535 ms)
    F: Off time in breath/blink mode (M = 1, 2) (0-65535 ms)

For example, to achieve RGB alternating flashing of lights, take the light strip 0 as an example (LED indices are 0, 1, 2, respectively), the command is as follows

M1004 S1 L0 M2 B255 T0 O500 F1000
M1004 S1 L1 M2 B255 T500 O500 F1000
M1004 S1 L2 M2 B255 T1000 O500 F1000

The above configuration indicates that RGB cycle of the three-color lights is 1500 milliseconds (O500 + F1000), the first 500ms is turned on and the next 1000ms is turned off during the cycle, and LED0 starts to execute from time 0 (T = 0), LED1 starts to execute from 500ms (T = 500), and LED2 starts to execute from 1000ms (T = 1000).

In this way, when L0 is turned off at 500ms, L1 is lit; when L1 is turned off at 1000ms, L2 is lit. In this way, RGB tri-color alternating flicker is realized.
LED strip brightness configuration
Command format

M1004 S2 I[iii] B[bbb]

Description

I: LED Strip Index (0-1)

B: Brightness (0-255)

This command controls the RGB brightness of the LED light strip at the same time, without changing the color. Note that if the sliding rheostat or the reserved AD interface is configured to control the LED brightness, when the AD sampling value changes, the setting of this command will be overwritten.
Servo control (S = 3)
Command format

M1004 S3 I[iii] F[fff] D[ddd] T[ttt] B[bbb]

Description

    I: Servo index (0-1)
    F: PWM frequency (hz), general steering gear control frequency is 50Hz (20ms)
    D: PWM duty cycle, the PWM duty cycle range of general servo control is 0.025-0.125 (pulse width 0.5ms-2.5ms)
    T: [Optional] When the sliding rheostat is configured for servo control, this parameter limits the maximum value of the duty cycle adjustment range, which is 0.125 by default
    B: [Optional] When the sliding rheostat is configured for servo control, this parameter limits the minimum value of the duty cycle adjustment range, which is 0.025 by default

Fan Control (S = 4)
Command format

M1004 S4 F[iii] P[ppp]

Description

    F: Fan index (0-3)
    P: Speed/Switch (0-100):
        4pin fan control speed
        2pin fan only control switch
        When this parameter is not 0, the fan is on

Camera Control (S = 5)
Command format

M1004 S5 F[fff] P[ppp]

Description

    F : Focus (0-1), F=0: turn off; F=1: turn on
    P : Photo (0-1), P=0: no effect; P=1: take a photo

Just set one of the above parameters
Sliding potentiometer function configuration (S = 6)
Command format

M1004 S6 I[iii] F[fff] D[ddd]

Description

    I: Sliding Potentiometer Index (0-1)
    F: Function selection, supports the following functions:
        F = 0: Control LED brightness
        F = 1: Control fan speed (valid for FAN2/FAN3 only)
        F = 2: Control servo angle
        F = 3: Control motor speed
    D : Control device index.
        For example, the function is to control the fan. This parameter specifies the fan number. If the index is greater than or equal to the total number of devices, all devices are controlled simultaneously.

Switch function configuration (S = 7)
Command format

M1004 S7 I[iii] F[fff] D[ddd]

Description

    I: I switch index (0-1)
    F: Function selection, supports the following functions:
        F = 0: Control fan switch
        F = 1: Control LED strip switch
        F = 2: Control motor switch
        F = 3: Control relay switch
        F = 4: Control buzzer switch
        F = 5: Controls the high and low level of the reserved GPIO
    D : Control device index.
        For example, the function is to control the fan. This parameter specifies the fan number. If the index is greater than or equal to the total number of devices, all devices are controlled simultaneously

Relay control (S = 8)
Command format

M1004 S8 P[ppp]

Description

    P: Switch parameters (0-1), 0 disconnected, 1 connected

Buzzer Switch Configuration (S = 9)
Command format

M1004 S9 P[ppp] F[fff]

Description

    P: Switch parameters (0-1), 0 off, 1 on
    F: Frequency setting, the frequency range supported by the buzzer is 2000~5000hz (V1 hardware does not support this parameter)

Stepper motor control (S = 10)
Command format

M1004 S10 D[ddd] P[ppp]

Description

    D: Rotation direction (0-1)
    P: Speed (r/min)

Reserve pin control command (S = 11)
Command format

M1004 S11 T0 I[iii] D[lll] P[ppp]
M1004 S11 T1 I[iii] F[fff] D[ddd]
M1004 S11 T2 I[iii] F[fff] D[ddd]

Description

    T: reserved IO type of
        T = 0: GPIO pin
        T = 1: PWM pin
        T = 2: ADC pin

GPIO Reserved Pin Parameters (T = 0)

    I: GPIO Index (4-17)
    O: GPIO direction (0-1), 0 input, 1 output
    P: When O is 0, the control input function is as the same as that of the switch. Please refer to the switch function configuration (S=7).

             When O is 1, control the output level (0-1), 0 low, 1 high

    D: When O is 0, Control the device index.
        For example, the function is to control the fan. This parameter specifies the fan number. If the index is bigger than or equal to the total number of devices, all devices are controlled simultaneously. When O is 1, this parameter is invalid.

PWM reserved pin parameter (T = 1)

    I: PWM pin index (currently only 0)
    F: PWM frequency (Hz), 100-100k
    D: PWM output duty cycle, float between 0 and 1, for example 0.02

ADC Reserved pin parameters (T = 2)

    I: ADC Pin Index (0-2)
    F: Function selection, all functions are the same as the sliding potentiometer. Please refer to the sliding potentiometer function configuration (S=6)
    D : Control the device index. For example, the function is to control the fan, this parameter specifies the fan number.

######################################


G-Code Placeholder Reference for Extension Board
Placeholder Lists
Name 	Type 	Definition 	Instance
total_layer_count 	int 	Total layer counting 	

; layer num/total_layer_count: {layer_num+1}/[total_layer_count] 

Showing the number of total layers
previous_extruder 	int 0-16 	Previous type of filament extruded 	

;{ filament_type[previous_extruder]} 

Getting information about the previous type of filament extruded when changing
next_extruder 	int 0-16 	Next type of filament extruded 	

;{ filament_type[next_extruder]} 

Getting information about the next type of filament extruded when changing
layer_num 	int 	Current layer number 	

;{layer_num} 

Showing the number of current layer
layer_z 	float 	Current layer height 	 
max_layer_z 	float 	The maximum layer height 	 
x_after_toolchange 	float 	Coordinates after changing filaments 	 
y_after_toolchange 	float 	 
z_after_toolchange 	float 	 
filament_extruder_id 	int 	Current type of filament ID  	

If 

Conditional statement
toolchange_z 	float 	Current total layer height 	

G1 Z{toolchange_z}

Moving the filament extruder
G-Code Guide
Obtaining values from variable names

The variable "layer_z" can be accessed directly by using its name.

To obtain its value, use  {layer_z}.
Accessing the value of an array or vector placeholder using variable name [index]

"cool_plate_temp_initial_layer[0]" accesses the first element of "cool_plate_temp_initial_layer".

To obtain its value, use {cool_plate_temp_initial_layer[0]}.
Conditional statements

{if scan_first_layer}

;=========register first layer scan=====

M977 S1 P60

{endif}
The ternary operator/Conditional operator

(<condition> ? <cond_true>:<cond_false>)
Combining G-code instructions

S[next_extruder]

S{cool_plate_temp_initial_layer[0]}
Representing the String data type using "string"

Strings:

"Bambu PLA Basic @BBL X1C"
Regular expression

/regex/
Compare <, >, ==, !=, <>, <=, >=

toolchange_count > 1
Logical Operations &&, ||, !

{if old_filament_temp > 142 && next_extruder < 255};dosomething{endif}
Arithmetic operations +，-， *， /

Arithmetic Operators：

{layer_num+1}

Float operations return float type, while integer operations return integer type. 

If you want the result to be a decimal value, you need to include a float type argument in the operation.

For example, 3/2 will return 1 (an integer), while 3.0/2 will return 1.5 (a float).
Matching

=~ matching and !~ not matching:

=~ and !~ are comparison operators used in programming to check if a string matches a pattern or not. The =~ operator checks if a string matches a pattern, while the !~ operator checks if a string does not match a pattern.
Function operations

Functions are a set of instructions that are executed when called upon to do so. In programming, a function may accept arguments and return a result. Here are some common function operations in programming:

    min(a, b): returns the minimum value between a and b.
    max(a, b): returns the maximum value between a and b.
    int(a): converts a to an integer type.
    round(a): rounds a to the nearest integer.
    digits(a, num_digits, num_decimals=0): rounds the decimal portion of a to an integer and displays num_digits digits using space padding, where num_decimals defaults to 0 and can be left empty.
    zdigits(a, num_digits, num_decimals=0): same as above, except it uses 0 padding instead of space padding.
