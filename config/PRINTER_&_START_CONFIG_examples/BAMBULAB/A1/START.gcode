;===== machine: A1 Travis90x ==============
;===== Start G-Code date: 20251110 ========
G392 S0  ; turn off clog detection
M9833.2
;M400
;M73 P1.717

M106 S200

; M204 S10000 - Acceleration limit (mm/s^2)
; M205 X0 Y0 Z0 E0 -  Set jerk limits

;===== start to heat heatbead&hotend==========
M1002 gcode_claim_action : 2  ; Heatbed preheating
M1002 set_filament_type:{filament_type[initial_no_support_extruder]}

; heat hotend
; M104 S140  ; Soft the material sticked on nozzle for unprecise homing
; M104 S{nozzle_temperature_initial_layer[initial_extruder]}
; heat bed
;M140 S[bed_temperature_initial_layer_single]


;=====start printer sound ===================
; M17 S - Enable steppers
; M17 R - Restore default values
M17
M400 S1
M1006 S1
M1006 A0 B10 L100 C37 D10 M60 E37 F10 N60
M1006 A0 B10 L100 C41 D10 M60 E41 F10 N60
M1006 A0 B10 L100 C44 D10 M60 E44 F10 N60
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N60
M1006 A43 B10 L100 C46 D10 M70 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C43 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C41 D10 M80 E41 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E44 F10 N80
M1006 A0 B10 L100 C49 D10 M80 E49 F10 N80
M1006 A0 B10 L100 C0 D10 M80 E0 F10 N80
M1006 A44 B10 L100 C48 D10 M60 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E39 F10 N80
M1006 A0 B10 L100 C0 D10 M60 E0 F10 N80
M1006 A43 B10 L100 C46 D10 M60 E39 F10 N80
M1006 W
; M18 ; disables the steppers

;===== start printer sound end ===================


;=====avoid end stop =================
; G380 Move Z only - Must be preceded by G91
G91
; small movements up & down
G380 S2 Z40 F1200 ; prevent heatbed touching the top
G380 S3 Z-15 F1200 ; prevent heatbed touching the bottom
G90

;===== reset machine status =================
;M290 X39 Y39 Z8
M204 S6000   ; Set accell S-acceleration

M630 S0 P0
G91
M17 Z0.3 ; lower the z-motor current

G90
M17 X0.65 Y1.2 Z0.6 ; reset motor current to default

M960 S5 P1 ; turn on logo lamp
G90

M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate

M73.2   R1.0 ;Reset left time magnitude
;M211 X0 Y0 Z0 ; turn off soft endstop to prevent protential logic problem

;===== reset machine status end =================


;===== sound 1 ===================
M400 S1
M1006 S1
M1006 A0 B10 L100 C37 D10 M60 E37 F10 N60
M1006 A0 B10 L100 C41 D10 M60 E41 F10 N60
M1006 W
;===== sound 1 end ===================

;====== cog noise reduction=================
M106 S0
M982.2 S1 ; turn on cog noise reduction
;M982.2 C1 ; turn on motor noise cancellation

; Homing toolhead
M1002 gcode_claim_action : 13


;  ██████╗ ██╗██████╗ ████████╗██╗   ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
;  ██╔══██╗██║██╔══██╗╚══██╔══╝╚██╗ ██╔╝    ██║  ██║██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝ 
;  ██║  ██║██║██████╔╝   ██║    ╚████╔╝     ███████║██║   ██║██╔████╔██║██║██╔██╗ ██║██║  ███╗
;  ██║  ██║██║██╔══██╗   ██║     ╚██╔╝      ██╔══██║██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
;  ██████╔╝██║██║  ██║   ██║      ██║       ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
;  ╚═════╝ ╚═╝╚═╝  ╚═╝   ╚═╝      ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
; 

; == Homing XY  ==
; == Nozzle with blob ==

G91 ; Set all axes to relative
;G0 Z20
; G0 Z5 F1200
G90 ; Set all axes to absolute
; homing XY
G28 X ; homing X with very dirty nozzle
G0 X20 F30000 ; if blob fake the homing
G0 Y250 F6000

; homing Z
G28 Z P0 T300 ; homing Z with very dirty nozzle


;M109 S25 H140
;M109 S{nozzle_temperature_initial_layer[initial_extruder]-10}

; ====== Homing Z not precise ======

; == remove pressure on hotend  ==
; Stepper Motor Current
M17 E0.3
; E Relative
M83
; pressure in the hotend
G92 E0
; G1 E10 F1200
; G1 E1.5 F1200
; G1 E-0.5 F30

M17 D



; remove old purge line
;M83
;G0 Z5 F1200
;G0 Y258 F6000
;G0 X155 F20000
;G0 Z-0.5 F1200
;G0 X152 Y262 F1200
;G0 Y260 F1200
;G0 X147 Y262.5 F1200
;G0 Y260 F1200
;G0 X142 Y262.5 F1200
;G0 Y260 F1200
;G0 Z5 F1200
;G1 X55 F10000
;G0 Z1 F1200
;G0 Z5 F1200
;G1 X-48.2 F10000

; remove old purge line end 



;G28 Z P0 T140; home z with low precision,permit 300deg temperature
;G28 Z P0 T{nozzle_temperature_initial_layer[initial_extruder]}; homing z with low precision,permit 300deg temperature

; == Homing Z not precise end ==

; == remoev big blob ==
M104 S{nozzle_temperature_initial_layer[initial_extruder]}
M106 S0

G90
M83
G0 X-20 F20000
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G0 X-48.2 F5000  ; remove blob slowly
M104 S0
M106 S255
G1 E-1 F1200



;===== prepare print temperature and material ==========
M1002 gcode_claim_action : 24

M400
; turn on clog detection
;G392 S1
M211 X0 Y0 Z0 ;turn off soft endstop

;vibration compensation
M975 S1 ; turn on


;   ██╗     ██████╗██╗     ███████╗ █████╗ ███╗   ██╗    ███╗   ██╗ ██████╗ ███████╗███████╗██╗     ███████╗
;  ███║    ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║    ████╗  ██║██╔═══██╗╚══███╔╝╚══███╔╝██║     ██╔════╝
;  ╚██║    ██║     ██║     █████╗  ███████║██╔██╗ ██║    ██╔██╗ ██║██║   ██║  ███╔╝   ███╔╝ ██║     █████╗  
;   ██║    ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║    ██║╚██╗██║██║   ██║ ███╔╝   ███╔╝  ██║     ██╔══╝  
;   ██║    ╚██████╗███████╗███████╗██║  ██║██║ ╚████║    ██║ ╚████║╚██████╔╝███████╗███████╗███████╗███████╗
;   ╚═╝     ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝
;  


; clean nozzle
;===== wipe and shake x1 =====
G90


;  ██╗    ██╗██╗██████╗ ███████╗
;  ██║    ██║██║██╔══██╗██╔════╝
;  ██║ █╗ ██║██║██████╔╝█████╗  
;  ██║███╗██║██║██╔═══╝ ██╔══╝  
;  ╚███╔███╔╝██║██║     ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝     ╚══════╝

M106 S255
M400

G0 Y262.5 F6000
G0 X-28.5 F30000
G0 X-48.2 F3000
G0 X-28.5 F30000
G0 X-48.2 F3000
G0 X-28.5 F30000
G0 X-48.2 F3000


;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
;   

G90
G0 Z0.7 F1200 ; brush height
G0 X55 Y262.5 F6000 ; start brush point

G91
G0 X-45 F30000
G0 Y-0.5
G0 X55
G0 Y-0.5
G0 X-45   
G0 Y-0.5
G0 X45
G0 Y-0.5
G0 X-45 
G0 Y-0.5
G0 X45
G90

G0 X-48.2 F20000
G0 Z5.000 F1200



;  ██████╗ ███████╗    ██╗  ██╗ ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
;  ██╔══██╗██╔════╝    ██║  ██║██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝ 
;  ██████╔╝█████╗█████╗███████║██║   ██║██╔████╔██║██║██╔██╗ ██║██║  ███╗
;  ██╔══██╗██╔══╝╚════╝██╔══██║██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
;  ██║  ██║███████╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
;  ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
;  rehoming   


M106 S0
; M109 S[nozzle_temperature_initial_layer]
G28 X; re-homing XY without blob

G91
G0 Z5 F1200
G90

G0 X135 Y261 F6000
G28 Z P0 T300 ; homing Z with dirty nozzle
G0 X-48.2 F30000


;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
;   

G90
G0 Z0.7 F1200 ; brush height
G0 X55 Y262.5 F6000 ; start brush point

G91
G0 X-45 F30000
G0 Y-0.5
G0 X55
G0 Y-0.5
G0 X-45   
G0 Y-0.5
G0 X45
G0 Y-0.5
G0 X-45 
G0 Y-0.5
G0 X45
G90

G0 X-48.2 F20000
G0 Z5 F1200

; nozzle cleaned


;  ██████╗ ███████╗████████╗███████╗ ██████╗████████╗    
;  ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    
;  ██║  ██║█████╗     ██║   █████╗  ██║        ██║       
;  ██║  ██║██╔══╝     ██║   ██╔══╝  ██║        ██║       
;  ██████╔╝███████╗   ██║   ███████╗╚██████╗   ██║       
;  ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝       
;                                                        
;  ██████╗ ██╗      █████╗ ████████╗███████╗             
;  ██╔══██╗██║     ██╔══██╗╚══██╔══╝██╔════╝             
;  ██████╔╝██║     ███████║   ██║   █████╗               
;  ██╔═══╝ ██║     ██╔══██║   ██║   ██╔══╝               
;  ██║     ███████╗██║  ██║   ██║   ███████╗             
;  ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝             
;  

; == detect build plate ==


G90
G0 Y262 X128 F6000

M1002 judge_flag build_plate_detect_flag
M622 S1
  G39.4
  G90
  G0 Z5 F1200
M623
G0 X0 F30000
G0 X-48.2 F20000

;M400
;M73 P1.717
; == detect build plate end ==


;   ██████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ███████╗              
;  ██╔════╝██║  ██║██╔══██╗████╗  ██║██╔════╝ ██╔════╝              
;  ██║     ███████║███████║██╔██╗ ██║██║  ███╗█████╗                
;  ██║     ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══╝                
;  ╚██████╗██║  ██║██║  ██║██║ ╚████║╚██████╔╝███████╗              
;   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝              
;                                                                   
;  ███████╗██╗██╗      █████╗ ███╗   ███╗███████╗███╗   ██╗████████╗
;  ██╔════╝██║██║     ██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
;  █████╗  ██║██║     ███████║██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
;  ██╔══╝  ██║██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
;  ██║     ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
;  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
;   

;===== change filament =====
M620 M ;enable remap
M620 S[initial_no_support_extruder]A   ; switch material if AMS exist


; Changing filament
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
	
	; purge hard material
	M106 S0
	; heat hotend and wait
    M109 S[nozzle_temperature_initial_layer]
	M104 S250
    M400
    T[initial_no_support_extruder]
    G1 X-48.2 F3000
    M400
    G92 E0
    M620.1 E F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60} T{nozzle_temperature_range_high[initial_no_support_extruder]}
; save material from AMS flush
    M109 S250 ;set nozzle to common flush temp
    M106 P1 S0
    G92 E0
	; lower extrusion speed to avoid clog
    G1 E50 F200
	G92 E0
    M400
    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}
M621 S[initial_no_support_extruder]A

G90
G0 Z5 F1200
G1 X-48 F30000

; save material from AMS flush
M109 S{nozzle_temperature_range_high[initial_no_support_extruder]} H300
M83
G1 E50 F200 ; lower extrusion speed to avoid clog
M400
M106 S200
G1 E5 F200



;  ██╗      ██████╗  █████╗ ██████╗                                 
;  ██║     ██╔═══██╗██╔══██╗██╔══██╗                                
;  ██║     ██║   ██║███████║██║  ██║                                
;  ██║     ██║   ██║██╔══██║██║  ██║                                
;  ███████╗╚██████╔╝██║  ██║██████╔╝                                
;  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝                                 
;                                                                   
;  ███████╗██╗██╗      █████╗ ███╗   ███╗███████╗███╗   ██╗████████╗
;  ██╔════╝██║██║     ██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
;  █████╗  ██║██║     ███████║██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
;  ██╔══╝  ██║██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
;  ██║     ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
;  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
;

;===== load filament =====

; heat hotend
M104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]}
G1 E-0.5 F300
G92 E0



;  ██╗    ██╗██╗██████╗ ███████╗
;  ██║    ██║██║██╔══██╗██╔════╝
;  ██║ █╗ ██║██║██████╔╝█████╗  
;  ██║███╗██║██║██╔═══╝ ██╔══╝  
;  ╚███╔███╔╝██║██║     ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝     ╚══════╝
;


;===== wipe and shake x3 =====
G90
M106 S200
G0 X-28.5 F30000
G0 X-48.2 F3000
G0 X-28.5 F30000
G0 X-48.2 F3000
G0 X-28.5 F30000
G0 X-48.2 F3000

;G392 S0

M109 S160
M400

; fan OFF
M106 S0

;===== prepare print temperature and material end =====

;M400
;M73 P1.717

;===== sound 3 ===================
M400 S1
M1006 S1
M1006 A0 B10 L100 C41 D10 M80 E41 F10 N80
M1006 A0 B10 L100 C44 D10 M80 E44 F10 N80
M1006 A0 B10 L100 C49 D10 M80 E49 F10 N80
M1006 W
;===== sound 3 end ===================


;  ███╗   ███╗███████╗ ██████╗██╗  ██╗    ███╗   ███╗ ██████╗ ██████╗ ███████╗
;  ████╗ ████║██╔════╝██╔════╝██║  ██║    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
;  ██╔████╔██║█████╗  ██║     ███████║    ██╔████╔██║██║   ██║██║  ██║█████╗  
;  ██║╚██╔╝██║██╔══╝  ██║     ██╔══██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  
;  ██║ ╚═╝ ██║███████╗╚██████╗██║  ██║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
;  ╚═╝     ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
; 

;===== mech mode fast check start =====================
;===== input shaping =====================
;M1002 gcode_claim_action : 3
;M106 S255 ; turn on fan
;G90
;G0 Z5 F1200
;G0 X128 Y128 F20000

;M400 P200
;M970.3 Q1 A5 K0 O3
;M974 Q1 S2 P0

;M970.2 Q1 K1 W58 Z0.1
;M974 S2


;G0 X128 Y128 F20000

;M400 P200
;M970.3 Q0 A10 K0 O1
;M974 Q0 S2 P0
;M970.2 Q0 K1 W78 Z0.1
;M974 S2

;M975 S1

;G90
;G1 F30000
;G28 X ; re-homing

;G0 Z5 F1200
;M106 S0 ; turn off fan
;===== mech mode fast check end =======================


;  ██████╗ ██╗   ██╗███╗   ██╗ █████╗ ███╗   ███╗██╗ ██████╗
;  ██╔══██╗╚██╗ ██╔╝████╗  ██║██╔══██╗████╗ ████║██║██╔════╝
;  ██║  ██║ ╚████╔╝ ██╔██╗ ██║███████║██╔████╔██║██║██║     
;  ██║  ██║  ╚██╔╝  ██║╚██╗██║██╔══██║██║╚██╔╝██║██║██║     
;  ██████╔╝   ██║   ██║ ╚████║██║  ██║██║ ╚═╝ ██║██║╚██████╗
;  ╚═════╝    ╚═╝   ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝ ╚═════╝
;                                                           
;  ███████╗██╗      ██████╗ ██╗    ██╗                      
;  ██╔════╝██║     ██╔═══██╗██║    ██║                      
;  █████╗  ██║     ██║   ██║██║ █╗ ██║                      
;  ██╔══╝  ██║     ██║   ██║██║███╗██║                      
;  ██║     ███████╗╚██████╔╝╚███╔███╔╝                      
;  ╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝                       
  


;===== Dynamic Flow Calibration =========================
;===== auto extrude cali start =========================
; turn on mech mode supression
M975 S1
;G392 S1

G90
; E Relative
M83
T1000

;G1 X-48.2 Y0 Z10 F10000
G0 X-48.2 Z5 F30000
M400
M1002 set_filament_type:UNKNOWN

M412 S1 ;  ===turn on  filament runout detection===
M400 P10
M620.3 W1; === turn on filament tangle detection===
M400 S2

M1002 set_filament_type:{filament_type[initial_no_support_extruder]}

;M1002 set_flag extrude_cali_flag=1
M1002 judge_flag extrude_cali_flag

M622 J1
    M1002 gcode_claim_action : 8

    M109 S{nozzle_temperature[initial_extruder]}
    G1 E10 F{outer_wall_volumetric_speed/2.4*60}
	G92 E0
    M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation

    M106 P1 S255
    M400 S5
	
	;wipe and shake
    G0 X-28.5 F30000
    G0 X-48.2 F3000
    G0 X-28.5 F30000 ;wipe and shake
    G0 X-48.2 F3000
    G0 X-28.5 F30000 ;wipe and shake
    G0 X-48.2 F3000
    M400
    M106 P1 S0

    M1002 judge_last_extrude_cali_success
    M622 J0
        M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation
        M106 P1 S255
        M400 S5
	
    	;wipe and shake
        G0 X-28.5 F30000
        G0 X-48.2 F3000
        G0 X-28.5 F30000 ;wipe and shake
        G0 X-48.2 F3000
        G0 X-28.5 F30000 ;wipe and shake
        M400
        M106 P1 S0
    M623
    
    G0 X-48.2 F3000
    M400
    M984 A0.1 E1 S1 F{outer_wall_volumetric_speed/2.4} H[nozzle_diameter]
    M106 P1 S178
    M400 S7
	;wipe and shake
    G0 X-28.5 F30000
    G0 X-48.2 F3000
    G0 X-28.5 F30000
    G0 X-48.2 F3000
    G0 X-28.5 F30000
    G0 X-48.2 F3000
    M400
    M106 P1 S0
	
M623 ; end of "draw extrinsic para cali paint"

;G392 S0
;===== auto extrude cali end ========================

;M400
;M73 P1.717						   

;M400
;M73 P1.717



;  ███████╗███╗   ██╗██████╗ ███████╗████████╗ ██████╗ ██████╗ 
;  ██╔════╝████╗  ██║██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
;  █████╗  ██╔██╗ ██║██║  ██║███████╗   ██║   ██║   ██║██████╔╝
;  ██╔══╝  ██║╚██╗██║██║  ██║╚════██║   ██║   ██║   ██║██╔═══╝ 
;  ███████╗██║ ╚████║██████╔╝███████║   ██║   ╚██████╔╝██║     
;  ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
;                                                              
;   ██████╗ ███████╗███████╗                                   
;  ██╔═══██╗██╔════╝██╔════╝                                   
;  ██║   ██║█████╗  █████╗                                     
;  ██║   ██║██╔══╝  ██╔══╝                                     
;  ╚██████╔╝██║     ██║                                        
;   ╚═════╝ ╚═╝     ╚═╝                                        
;    

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14

M975 S1

; M106 S0
; heat hotend
; M104 S{nozzle_temperature_initial_layer[initial_extruder]}

M211 S; push soft endstop status
M211 X0 Y0 Z0 ;turn off Z axis endstop

;===== prepare to wipe nozzle end ===============================


;===== remove waste by touching start =====
; ; heat hotend
; M104 S170 ; set temp down to heatbed acceptable

; M83
; G92 E0
; G1 E-1 F500
; G92 E0
; G90
; M83

; M109 S170
; G0 X108 Y-0.5 F30000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X110 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X112 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X114 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X116 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X118 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X120 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X122 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X124 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X126 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X128 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X130 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X132 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X134 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X136 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X138 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X140 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X142 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X144 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X146 F10000
; G380 S3 Z-5 F1200
; G1 Z2 F1200
; G1 X148 F10000
; G380 S3 Z-5 F1200

; G1 Z5 F30000
;===== remove waste by touching end =====


;M140 S[bed_temperature_initial_layer_single]; ensure bed temp
									  


;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝

;===== brush material wipe nozzle =====

M106 S255
M400
; heat hotend
M104 S140 ; prepare to abl ;1st wipe
;M104 S{nozzle_temperature_initial_layer[initial_extruder]}
G90
;G0 Z5 F1200
G0 Y262.5 F6000
G0 X-48.2 F30000


G29.2 S0 ; turn off ABL - Bed Mesh

;G0 Z-1.01 F1200      ; stop the nozzle
; homing z P0 = low precision, nozzle T=temp
;G28 Z P0 T300; homing z with low precision,permit 300deg temperature



; heat hotend and wait
;M106 S255
;M109 S140
; heat hotend and wait
;M106 S0
;M109 S{nozzle_temperature_initial_layer[initial_extruder]}

;M106 S255
;M104 S140


;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝

M106 S255

G90
G0 Z1 F1200   ; first one brush height
G0 X55 Y262.5 F6000 ; start brush point slowly, dirty nozzle after load filament

G91
G0 X-45 F30000
G0 Y-0.5 
G0 X55 
G0 Y-0.5 
G0 X-45 
G0 Y-0.5 
G0 X45 
G0 Y-0.5 
G0 X-45 
G0 Y-0.5 
G0 X45 
G90

G0 Z2.000 F1200
M17 E0.3
M83
G92 E0
G1 E-0.5 F300
G92 E0
M17 D



; homing dirty nozzle
G0 Z2.000 F1200
G0 Y262.5 F6000
G0 X135 F30000
G0 Z-1 F1200  ; remove waste from nozzle on build plate clip


G28 Z P0 T250
M106 P1 S255



;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝

G90
G0 Z0.7 F1200 ; second brush height
G0 X55 Y262.5 F6000 ; start brush point

G91
G0 X-45 F30000
G0 Y-0.5
G0 X55
G0 Y-0.5
G0 X-45   
G0 Y-0.5
G0 X45
G0 Y-0.5
G0 X-45 
G0 Y-0.5
G0 X45
G90

G0 Z5.000 F1200
G90
;G0 Y262 F6000
G0 X15 F30000
G0 X-48.2 F18000


;===== brush material wipe nozzle end =====







;  ██████╗ ███████╗██████╗                  
;  ██╔══██╗██╔════╝██╔══██╗                 
;  ██████╔╝█████╗  ██║  ██║                 
;  ██╔══██╗██╔══╝  ██║  ██║                 
;  ██████╔╝███████╗██████╔╝                 
;  ╚═════╝ ╚══════╝╚═════╝                  
;                                           
;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
;       
;===== Circle brush on bed wipe nozzle =====

; heat hotend
;M104 S{nozzle_temperature_initial_layer[initial_extruder]}
M104 S0
M106 S255 ; turn on fan

G90
G0 Z5 F1200
;G0 X128 Y261 F20000  ; move to exposed steel surface
G0 Y261 F6000        ; ; circle brush start position
G0 X135 F20000
	   
G0 Z-1.01 F1200      ; stop the nozzle
;M109 S{nozzle_temperature_initial_layer[initial_extruder]}

; circle brush
G91
G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G90


G0 Z1 F1200      ; stop the nozzle
G0 X128 F20000
G0 Z-1 F1200      ; stop the nozzle

; heat hotend and wait cold nozzle
M109 S140
M106 S0
M400
											  

;===== brush on bed wipe nozzle end ================================

		
                                                              
;  ███████╗    ██╗  ██╗ ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
;  ╚══███╔╝    ██║  ██║██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝ 
;    ███╔╝     ███████║██║   ██║██╔████╔██║██║██╔██╗ ██║██║  ███╗
;   ███╔╝      ██╔══██║██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
;  ███████╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
     		

;===== precise homing z =====

; heat hotend and wait

G90
G0 Z5 F1200
G0 X128 Y128 F6000
G28 Z  ; homing z precise 


M211 R  ; pop softend status ; turn off soft endstop to prevent protential logic problem
; maybe redo a G28 full- CHECK other G28 after this!!

;===== precise homing z end =====



;  ██████╗ ███████╗██████╗     ███╗   ███╗███████╗███████╗██╗  ██╗
;  ██╔══██╗██╔════╝██╔══██╗    ████╗ ████║██╔════╝██╔════╝██║  ██║
;  ██████╔╝█████╗  ██║  ██║    ██╔████╔██║█████╗  ███████╗███████║
;  ██╔══██╗██╔══╝  ██║  ██║    ██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║
;  ██████╔╝███████╗██████╔╝    ██║ ╚═╝ ██║███████╗███████║██║  ██║
;  ╚═════╝ ╚══════╝╚═════╝     ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝
;    

;===== bed leveling ==================================
;===== Bed Mesh     ==================================
M1002 judge_flag g29_before_print_flag

G90
; G0 Z5 F1200
; G1 X0 Y0 F30000
; turn on Bed Mesh
G29.2 S1 ; turn on ABL

M106 S0 ; turn off fan , too noisy

M622 J1
    M1002 gcode_claim_action : 1
    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}
    M400
    M500 ; save cali data
	; to EEPROM
	
	M1002 judge_flag g29_before_print_flag
	M1002 gcode_claim_action : 13
	G28
	
M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
;M1002 judge_flag g29_before_print_flag
;M622 J0

;    M1002 gcode_claim_action : 13
;    G28
; G28 only if new bed mesh is saved in eeprom

;M623

;===== home after wipe mouth end =======================

;  ██████╗ ██████╗ ███████╗ ██████╗██╗███████╗███████╗           
;  ██╔══██╗██╔══██╗██╔════╝██╔════╝██║██╔════╝██╔════╝           
;  ██████╔╝██████╔╝█████╗  ██║     ██║███████╗█████╗             
;  ██╔═══╝ ██╔══██╗██╔══╝  ██║     ██║╚════██║██╔══╝             
;  ██║     ██║  ██║███████╗╚██████╗██║███████║███████╗           
;  ╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝╚══════╝╚══════╝           
;                                                                
;  ███████╗    ██╗  ██╗ ██████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
;  ╚══███╔╝    ██║  ██║██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝ 
;    ███╔╝     ███████║██║   ██║██╔████╔██║██║██╔██╗ ██║██║  ███╗
;   ███╔╝      ██╔══██║██║   ██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
;  ███████╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
    

G90
G0 Z5 F1200
G0 X128 Y128 F6000
G2814 Z0.32 ; homing with zoffset 

; heat hotend
;M104 S140
; heat bed
M140 S[bed_temperature_initial_layer_single]; ensure bed temp

; stop the nozzle
M211 X0 Y0 Z0 ;turn off soft endstop
G90
G0 Z5 F1200


M400
G0 Z5 F1200





;===== prepare to print =====
;M400
;M73 P1.717

G90
;G1 X108.000 Y-0.500 F30000
; G0 Z0.300 F1200
M400

; G2814 Z0.32

;M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; prepare to print

;===== nozzle load line ===============================
;G90
;M83
;G1 Z5 F1200
;G1 X88 Y-0.5 F20000
;G1 Z0.3 F1200

;M109 S{nozzle_temperature_initial_layer[initial_extruder]}
;G92 E0
;G1 E2 F300
;G1 X168 E4.989 F6000
;G92 E0
;G1 Z1 F1200
;===== nozzle load line end ===========================

;===== extrude cali test ===============================

;M400
;    M104 S{nozzle_temperature_initial_layer[initial_extruder]} ; prepare to print
;    G1 X108.000 Y-0.500 F30000
;    G0 Z0.300 F1200
;    M900 S
;    M900 C
;    G90
;    M83
;    G92 E0
;    M109 S{nozzle_temperature_initial_layer[initial_extruder]}
;    G0 X128 E8  F{outer_wall_volumetric_speed/(24/20)    * 60}
;    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G91
;    G1 X1 Z-0.300
;    G1 X4
;    G1 Z1 F1200
;    G90
;    M400
;
;M900 R
;
;M1002 judge_flag extrude_cali_flag
;M622 J1
;    G90
;    G1 X108.000 Y1.000 F30000
;    G91
;    G1 Z-0.700 F1200
;    G90
;    M83
;    G92 E0
;    G0 X128 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}
;    G0 X133 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G0 X138 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;    G0 X143 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G0 X148 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;    G0 X153 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;    G91
;    G1 X1 Z-0.300
;    G1 X4
;    G1 Z1 F1200
;    G90
;    M400
;M623
;
;G1 Z0.2
;
;M400
;M73 P1.717

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0
M400





;  ██╗      █████╗ ███████╗████████╗     ██████╗        ██████╗ ██████╗ ██████╗ ███████╗
;  ██║     ██╔══██╗██╔════╝╚══██╔══╝    ██╔════╝       ██╔════╝██╔═══██╗██╔══██╗██╔════╝
;  ██║     ███████║███████╗   ██║       ██║  ███╗█████╗██║     ██║   ██║██║  ██║█████╗  
;  ██║     ██╔══██║╚════██║   ██║       ██║   ██║╚════╝██║     ██║   ██║██║  ██║██╔══╝  
;  ███████╗██║  ██║███████║   ██║       ╚██████╔╝      ╚██████╗╚██████╔╝██████╔╝███████╗
; 

;===== Last Start G-Code =====

M104 S{nozzle_temperature_initial_layer[initial_extruder]}
M140 S[bed_temperature_initial_layer_single]; ensure bed temp
; stop the nozzle
M211 X0 Y0 Z0 ;turn off soft endstop
G90

; for purge basket
G0 X-48.5 F20000

; for purge line
;G0 Z5 F1200
;G0 Y261 F6000 
;G0 X128 F20000  ; move to exposed steel surface
;G0 Z-1 F1200      ; stop the nozzle


;===== END GCODE =====
M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
;G392 S1 ; turn on clog detection
M1007 S1 ; turn on mass estimation
G29.4
;===== END GCODE =====

G0 Z1 F1200
G90


;===== Purge Basket =====

M109 S{nozzle_temperature_initial_layer[initial_extruder]}
M190 S[bed_temperature_initial_layer_single] ; ensure bed temp



M83
G1 E5 F1200
;G1 E-1 F1800
G92 E0


;wipe and shake


;  ██╗    ██╗██╗██████╗ ███████╗
;  ██║    ██║██║██╔══██╗██╔════╝
;  ██║ █╗ ██║██║██████╔╝█████╗  
;  ██║███╗██║██║██╔═══╝ ██╔══╝  
;  ╚███╔███╔╝██║██║     ███████╗
;   ╚══╝╚══╝ ╚═╝╚═╝     ╚══════╝
;

M106 S255 ; turn off fan
M400
G0 X-28.5 F30000
G0 X-48.2 F3000
G0 X-28.5 F30000 ;wipe and shake
G0 X-48.2 F3000
G0 X-28.5 F30000 ;wipe and shake
G0 X-48.2 F3000



;  ██████╗ ██████╗ ██╗   ██╗███████╗██╗  ██╗
;  ██╔══██╗██╔══██╗██║   ██║██╔════╝██║  ██║
;  ██████╔╝██████╔╝██║   ██║███████╗███████║
;  ██╔══██╗██╔══██╗██║   ██║╚════██║██╔══██║
;  ██████╔╝██║  ██║╚██████╔╝███████║██║  ██║
;  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
;===== spazzolino =====

G90
G1 E0.2 F1200
G0 Z1 F1200 ; brush height
G0 X55 Y262.5 F6000 ; start brush point

G1 E-0.1 F1200

G91
G0 X-45 F30000
G0 Y-0.5
G0 X55
G0 Y-0.5
G0 X-45   
G0 Y-0.5
G1 E-0.1 F1200
G0 X45 F30000
G0 Y-0.5
G0 X-45 
G0 Y-0.5
G0 X80 F12000
G90


; last extrution
G1 E0.1 F1200

G90
G92 E0
;===== spazzolino end =====



;===== Purge Line =====

;;M400
;G90

;M109 S{nozzle_temperature_initial_layer[initial_extruder]}
;G0 Z5 F1200

;G0 Y262.5 F6000
;G0 X155 F20000
;G0 Z0.8 F1200
;M83
;G92 E0
;;G1 X135 E8  F{outer_wall_volumetric_speed/(24/20)    * 60}
;;G1 X140 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;;G1 X145 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;;G1 X150 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;;G1 X155 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}

;G1 E5 F500
;G1 X135 E30 F160
;G92 E0
;G1 E-0.5 F2100
;G0 X15 F20000
;G92 E0
;G0 Z5

;G0 Z0.300 F1200
;;G0 Y261 F6000
;;G0 Z0.16 F1200
;;G92 E0
;;G1 X155 E0.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;;G0 Z0.08 F1200
;;G1 X150 E0.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}
;;G0 Z0.04 F1200
;;G1 X145 E0.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}
;;G0 Z0.00 F1200
;;G0 X135 F20000
;;G0 Z2 F1200
;;G92 E0
; ===== Purge Line end ===============================


;  ███████╗      ██████╗ ███████╗███████╗███████╗███████╗████████╗
;  ╚══███╔╝     ██╔═══██╗██╔════╝██╔════╝██╔════╝██╔════╝╚══██╔══╝
;    ███╔╝█████╗██║   ██║█████╗  █████╗  ███████╗█████╗     ██║   
;   ███╔╝ ╚════╝██║   ██║██╔══╝  ██╔══╝  ╚════██║██╔══╝     ██║   
;  ███████╗     ╚██████╔╝██║     ██║     ███████║███████╗   ██║   
;  ╚══════╝      ╚═════╝ ╚═╝     ╚═╝     ╚══════╝╚══════╝   ╚═╝   
;      
;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type={curr_bed_type}
{if curr_bed_type=="Textured PEI Plate"}
; Set Z-trim value
G29.1 Z{-0.02} ; for Textured PEI Plate
{endif}
;===== for Textured PEI Plate end =====


G92 E0

;===== nozzle load line - adaptive purge ===============================

M975 S1 ; turn on vibration supression
G90
M83
T1000
;check if okay to default to KAMP
{if ((first_layer_print_min[0] - 5 < 18) && (first_layer_print_min[1]-5 < 28)) || (first_layer_print_min[0] < 6) || (first_layer_print_min[1] < 6) || (first_layer_print_min[0] > 200)}
G1 Z5
G1 X255.5 Y0.5 F18000;Move to start position
G1 Z0.2
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G0 E2 F300
M400
G1 X230.5 E25 F300
G0 X210 E1.36 F{outer_wall_volumetric_speed/(0.3*0.5) * 60}
G0 X186 E-0.5 F18000 ;Move quickly away
G1 Z1.5 E0.5 F4000;
{else} ;Fallback
G1 Z5
G1 X{first_layer_print_min[0]-2} Y{first_layer_print_min[1]-2} Z1.5 F18000;Move to start position
G1 Z0.8
M109 S{nozzle_temperature_initial_layer[initial_extruder]}
G0 E2 F300
M400
G1 X{first_layer_print_min[0]+15} E20 F150
G1 Z0.2
G0 X{first_layer_print_min[0]+45} F18000 ;Move quickly away
{endif}
M400
G92 E0
