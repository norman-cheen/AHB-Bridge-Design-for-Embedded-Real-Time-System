-- Group 15:
-- ye20178 Student number: 2072442
-- ts20365 Student number: 2086685


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

ENTITY cm0_wrapper IS
  PORT(
 -- Clock and Reset -----------------
 clkm : IN std_logic;
 rstn : IN std_logic;
 -- AHB Master records --------------
 ahbmi : IN ahb_mst_in_type;
 ahbmo : OUT ahb_mst_out_type
 );
END cm0_wrapper;
 
ARCHITECTURE structural OF cm0_wrapper IS

--------------CortexM0-----------------------------------  
  COMPONENT CORTEXM0DS 
	PORT(
	  
  -- CLOCK AND RESETS ------------------
  HCLK :     IN std_logic;              -- Clock
  HRESETn :  IN std_logic;           -- Asynchronous reset

  -- AHB-LITE MASTER PORT --------------
  HADDR :     OUT std_logic_vector (31 downto 0);   -- AHB transaction address
  HBURST :    OUT std_logic_vector (2 downto 0);    -- AHB burst: tied to single
  HMASTLOCK : OUT std_logic;                        -- AHB locked transfer (always zero)
  HPROT :     OUT std_logic_vector (3 downto 0);    -- AHB protection: priv; data or inst
  HSIZE :     OUT std_logic_vector (2 downto 0);    -- AHB size: byte, half-word or word
  HTRANS :    OUT std_logic_vector (1 downto 0);    -- AHB transfer: non-sequential only
  HWDATA :    OUT std_logic_vector (31 downto 0);   -- AHB write-data
  HWRITE :    OUT std_logic;                        -- AHB write control
  HRDATA :    IN  std_logic_vector (31 downto 0);    -- AHB read-data
  HREADY :    IN  std_logic;                         -- AHB stall signal
  HRESP :     IN  std_logic;                         -- AHB error response

  -- MISCELLANEOUS ---------------------
  NMI :         IN  std_logic;                       -- Non-maskable interrupt input
  IRQ :         IN  std_logic_vector (15 downto 0);  -- Interrupt request inputs
  TXEV :        OUT std_logic;                      -- Event output (SEV executed)
  RXEV :        IN  std_logic;                       -- Event input
  LOCKUP :      OUT std_logic;                      -- Core is locked-up
  SYSRESETREQ : OUT std_logic;                      -- System reset request

  -- POWER MANAGEMENT ------------------
  SLEEPING :    OUT std_logic                       -- Core and NVIC sleeping
  
  );
  
  END COMPONENT; -- end cortexm0 declaration


--------------AHB Bridge-----------------------------------  
  COMPONENT AHB_bridge IS
	  PORT (
		   clkm: IN std_logic;
		   rstn: IN std_logic;
		   ahbmi: IN ahb_mst_in_type;
       ahbmo : OUT ahb_mst_out_type;
		   HADDR : IN std_logic_vector (31 downto 0);   -- AHB transaction address
       HSIZE : IN std_logic_vector (2 downto 0);    -- AHB size: byte, half-word or word
       HTRANS : IN std_logic_vector (1 downto 0);   -- AHB transfer: non-sequential only
       HWDATA : IN std_logic_vector (31 downto 0);  -- AHB write-data
       HWRITE : IN std_logic;                       -- AHB write control
       HRDATA : OUT std_logic_vector (31 downto 0); -- AHB read-data
       HREADY : OUT std_logic

	     );
    END COMPONENT;
    
--------------LED Blink Detector-----------------------------------      
 COMPONENT led_blink IS 
   PORT( 
     cm0_led : OUT std_logic; 
     data :    IN  std_logic_vector (31 downto 0);
     clk :     IN std_logic; 
     reset:    IN std_logic
       ); 
  END COMPONENT ; 

--------------Signal Declaration------------------------------------
  SIGNAL HADDR_sig : std_logic_vector (31 downto 0);  -- AHB transaction address
  SIGNAL HSIZE_sig : std_logic_vector (2 downto 0);   -- AHB size: byte, half-word or word
  SIGNAL HTRANS_sig : std_logic_vector (1 downto 0);  -- AHB transfer: non-sequential only
  SIGNAL HWDATA_sig : std_logic_vector (31 downto 0); -- AHB write-data
  SIGNAL HWRITE_sig : std_logic;                      -- AHB write control
  SIGNAL HRDATA_sig : std_logic_vector (31 downto 0); -- AHB read-data
  SIGNAL HREADY_sig : std_logic;
  SIGNAL HBurst_sig : std_logic_vector (2 downto 0):= "000";
  SIGNAL dummy : STD_LOGIC_VECTOR (2 downto 0);
  SIGNAL HProt : std_logic_vector (3 downto 0);
  SIGNAL Led1 :  STD_LOGIC;                           -- sleep
  SIGNAL Led2 :  STD_LOGIC;                           -- lock
  SIGNAL Led3: STD_LOGIC;


BEGIN

---------CortexM0 Port Mapping ---------------------------------
Processor : CORTEXM0DS	port map (
	-- CLOCK AND RESETS ------------------
  HCLK => clkm,                  -- Clock
  HRESETn => rstn,               -- Asynchronous reset

  -- AHB-LITE MASTER PORT --------------
  HADDR => HADDR_sig,            -- AHB transaction address
  HBURST =>  HBurst_sig,         -- AHB burst: tied to single (N: 00 because single transfer only)
  HMASTLOCK => dummy(0),         -- AHB locked transfer (always zero)
  HPROT => HProt,                -- AHB protection: priv; data or inst
  HSIZE => HSize_sig,            -- AHB size: byte, half-word or word
  HTRANS => HTrans_sig ,         -- AHB transfer: non-sequential only
  HWDATA => HWData_sig,          -- AHB write-data
  HWRITE => HWrite_sig,          -- AHB write control
  HRDATA => HRData_sig,          -- AHB read-data
  HREADY => HREADY_sig,          -- AHB stall signal
  HRESP => '0',                  -- AHB error response

  -- MISCELLANEOUS ---------------------
  NMI => '0',                    -- Non-maskable interrupt input
  IRQ => "0000000000000000",     -- Interrupciones(15 downto 0), -- Interrupt request inputs
  TXEV => dummy(1),              -- Event output (SEV executed)
  RXEV => '0',                   -- Event input
  LOCKUP => Led2,                -- Core is locked-up
  SYSRESETREQ => dummy(2),       -- System reset request

  -- POWER MANAGEMENT ------------------
  SLEEPING => Led1               -- Core and NVIC sleeping
	);


---------AHB Bridge Port Mapping ---------------------------------
  AHB_bridge_comp: AHB_bridge port map(clkm, rstn, ahbmi, ahbmo, HADDR_sig, HSIZE_sig, HTRANS_sig, HWDATA_sig, HWRITE_sig, HRDATA_sig ,HREADY_sig);
  led_blink_comp : led_blink  port map (Led3, HRDATA_sig,clkm, rstn); 
    
END structural;
 
