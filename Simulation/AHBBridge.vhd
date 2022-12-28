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

ENTITY AHB_bridge IS
 PORT(
 -- Clock and Reset -----------------
 clkm : IN std_logic;
 rstn : IN std_logic;
 -- AHB Master records --------------
 ahbmi : IN ahb_mst_in_type;
 ahbmo : OUT ahb_mst_out_type;
 -- ARM Cortex-M0 AHB-Lite signals -- 
 HADDR : IN std_logic_vector (31 downto 0); -- AHB transaction address
 HSIZE : IN std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
 HTRANS : IN std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
 HWDATA : IN std_logic_vector (31 downto 0); -- AHB write-data
 HWRITE : IN std_logic; -- AHB write control
 HRDATA : OUT std_logic_vector (31 downto 0); -- AHB read-data
 HREADY : OUT std_logic -- AHB stall signal
 );
END;



ARCHITECTURE structural OF AHB_bridge IS
  
--declare a component for state_machine
 COMPONENT STATE_MACHINE IS
   PORT(
      -- Clock and Reset -----------------
    clkm : IN std_logic;
    rstn : IN std_logic;
 
     -- AHBLITE Master records --------------
    dmai : OUT ahb_dma_in_type;
    dmao : IN ahb_dma_out_type;
 
    -- AHBBridge to StateMachine ----------------------------
    HADDR  : IN std_logic_vector (31 downto 0);   -- AHBLITE transaction address
    HSIZE  : IN std_logic_vector (2 downto 0);    -- AHBLITE size: byte, half-word or word
    HTRANS : IN std_logic_vector (1 downto 0);    -- AHBLITE transfer: non-sequential only
    HWDATA : IN std_logic_vector (31 downto 0);   -- AHBLITE write-data
    HWRITE : IN std_logic;                        -- AHBLITE write control
    HREADY : OUT std_logic                        -- AHBLITE stall signal
        );
   END COMPONENT; 
     
--declare a component for ahbmst 
 COMPONENT ahbmst IS 
  GENERIC (
    hindex  : integer := 0;
    hirq    : integer := 0;
    venid   : integer := VENDOR_GAISLER;
    devid   : integer := 0;
    version : integer := 0;
    chprot  : integer := 3;
    incaddr : integer := 0); 
  PORT(
      rst  : IN  std_ulogic;
      clk  : IN  std_ulogic;
      dmai : IN ahb_dma_in_type;
      dmao : OUT ahb_dma_out_type;
      ahbi : IN  ahb_mst_in_type;
      ahbo : OUT ahb_mst_out_type);
  END COMPONENT; 
 
--declare a component for data_swapper 
  COMPONENT data_swapper IS
   PORT(
     dmao:   IN  ahb_dma_out_type;
     HRDATA: OUT std_logic_vector (31 downto 0)
       );
   END COMPONENT; 
  

SIGNAL dmai : ahb_dma_in_type;
SIGNAL dmao : ahb_dma_out_type;

BEGIN
 
--instantiate state_machine component and make the connections
 state_machine_comp : STATE_MACHINE port map(clkm,rstn,dmai,dmao,HADDR,HSIZE,HTRANS,HWDATA,HWRITE,HREADY);
   
--instantiate the ahbmst component and make the connections 
 ahbmst_comp: ahbmst port map(rstn,clkm,dmai,dmao,ahbmi,ahbmo);
   
--instantiate the data_swapper component and make the connections
 data_swapper_comp: data_swapper port map(dmao,HRDATA);

END structural;
