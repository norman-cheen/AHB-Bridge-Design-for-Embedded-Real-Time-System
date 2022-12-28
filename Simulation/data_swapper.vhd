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

ENTITY data_swapper IS
PORT(
     dmao:   IN  ahb_dma_out_type;
     HRDATA: OUT std_logic_vector (31 downto 0)
     ); 
END data_swapper;

ARCHITECTURE data_swapper_arch OF data_swapper IS 
TYPE data_list IS ARRAY (0 to 3) OF std_logic_vector ( 7 downto 0); 

BEGIN 
  swapping: PROCESS(dmao)
     variable data_list_original: data_list; 
     variable data_list_swapped: data_list;
     variable data_list_sum: std_logic_vector(31 downto 0); 
     BEGIN
          data_list_original(0):= dmao.rdata(7 downto 0);
          data_list_original(1):= dmao.rdata(15 downto 8);
          data_list_original(2):= dmao.rdata(23 downto 16);
          data_list_original(3):= dmao.rdata(31 downto 24);
          data_list_swapped(0):=  data_list_original(3);
          data_list_swapped(1):=  data_list_original(2);
          data_list_swapped(2):=  data_list_original(1);
          data_list_swapped(3):=  data_list_original(0);
          data_list_sum(7 downto 0):= data_list_swapped(0); 
          data_list_sum(15 downto 8):= data_list_swapped(1);
          data_list_sum(23 downto 16):= data_list_swapped(2); 
          data_list_sum(31 downto 24):= data_list_swapped(3);
          HRDATA <= data_list_sum;     
   END PROCESS swapping;
          
END data_swapper_arch; 