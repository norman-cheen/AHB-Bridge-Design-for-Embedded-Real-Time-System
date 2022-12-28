-- Group 15:
-- ye20178 Student number: 2072442
-- ts20365 Student number: 2086685

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;


-- led_blink is a component in the CM0Wrapper that is added to detect a specific number, which
-- is this case is the group number 15 (HEX 0F0F0F0F)


ENTITY led_blink IS 
  PORT( cm0_led : out std_logic; 
        data : in  std_logic_vector (31 downto 0);
        clk : in std_logic; 
        reset: in std_logic ); 
END led_blink ; 


ARCHITECTURE behavioural OF led_blink IS 

--------------Detector Bus-----------------------------------
  COMPONENT DetectorBus IS
    PORT ( Clock : IN  STD_LOGIC;
           DataBus : IN  STD_LOGIC_VECTOR (31 downto 0);
           Detector : OUT  STD_LOGIC );
  END COMPONENT;
  
  ---------Detector Bus Port Mapping ---------------------------------
  BEGIN
  Inst_Detector: DetectorBus 
    PORT MAP ( Clock => clk,
               DataBus => data,
               Detector => cm0_led );
 
  
END behavioural; 
