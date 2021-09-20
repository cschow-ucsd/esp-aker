-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Accelerator Tile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.jtag_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.tile.all;
use work.misc.all;
use work.coretypes.all;
use work.esp_acc_regmap.all;
use work.socmap.all;
use work.grlib_config.all;
use work.tiles_pkg.all;
use work.dvfs.all;

entity fpga_tile_acc is
  generic (
    SIMULATION         : boolean              := false;
    this_hls_conf      : hlscfg_t             := 0;
    this_device        : devid_t              := 0;
    this_irq_type      : integer              := 0;
    this_has_l2        : integer range 0 to 1 := 0;
    this_has_dvfs      : integer range 0 to 1 := 0;
    this_has_pll       : integer range 0 to 1 := 0;
    this_extra_clk_buf : integer range 0 to 1 := 0;
    this_has_token_pm  : integer range 0 to 1 := 0;
    ROUTER_PORTS       : ports_vec            := "11111";
    HAS_SYNC           : integer range 0 to 1 := 1);
  port (
    raw_rstn           : in  std_ulogic;
    rst                : in  std_ulogic;
    refclk             : in  std_ulogic;
    pllbypass          : in  std_ulogic;
    pllclk             : out std_ulogic;
    dco_clk            : out std_ulogic;
    -- Test interface
    tdi                : in  std_logic;
    tdo                : out std_logic;
    tms                : in  std_logic;
    tclk               : in  std_logic;
    -- NOC
    sys_clk_int        : in  std_logic;
    noc1_data_n_in     : in  noc_flit_type;
    noc1_data_s_in     : in  noc_flit_type;
    noc1_data_w_in     : in  noc_flit_type;
    noc1_data_e_in     : in  noc_flit_type;
    noc1_data_void_in  : in  std_logic_vector(3 downto 0);
    noc1_stop_in       : in  std_logic_vector(3 downto 0);
    noc1_data_n_out    : out noc_flit_type;
    noc1_data_s_out    : out noc_flit_type;
    noc1_data_w_out    : out noc_flit_type;
    noc1_data_e_out    : out noc_flit_type;
    noc1_data_void_out : out std_logic_vector(3 downto 0);
    noc1_stop_out      : out std_logic_vector(3 downto 0);
    noc2_data_n_in     : in  noc_flit_type;
    noc2_data_s_in     : in  noc_flit_type;
    noc2_data_w_in     : in  noc_flit_type;
    noc2_data_e_in     : in  noc_flit_type;
    noc2_data_void_in  : in  std_logic_vector(3 downto 0);
    noc2_stop_in       : in  std_logic_vector(3 downto 0);
    noc2_data_n_out    : out noc_flit_type;
    noc2_data_s_out    : out noc_flit_type;
    noc2_data_w_out    : out noc_flit_type;
    noc2_data_e_out    : out noc_flit_type;
    noc2_data_void_out : out std_logic_vector(3 downto 0);
    noc2_stop_out      : out std_logic_vector(3 downto 0);
    noc3_data_n_in     : in  noc_flit_type;
    noc3_data_s_in     : in  noc_flit_type;
    noc3_data_w_in     : in  noc_flit_type;
    noc3_data_e_in     : in  noc_flit_type;
    noc3_data_void_in  : in  std_logic_vector(3 downto 0);
    noc3_stop_in       : in  std_logic_vector(3 downto 0);
    noc3_data_n_out    : out noc_flit_type;
    noc3_data_s_out    : out noc_flit_type;
    noc3_data_w_out    : out noc_flit_type;
    noc3_data_e_out    : out noc_flit_type;
    noc3_data_void_out : out std_logic_vector(3 downto 0);
    noc3_stop_out      : out std_logic_vector(3 downto 0);
    noc4_data_n_in     : in  noc_flit_type;
    noc4_data_s_in     : in  noc_flit_type;
    noc4_data_w_in     : in  noc_flit_type;
    noc4_data_e_in     : in  noc_flit_type;
    noc4_data_void_in  : in  std_logic_vector(3 downto 0);
    noc4_stop_in       : in  std_logic_vector(3 downto 0);
    noc4_data_n_out    : out noc_flit_type;
    noc4_data_s_out    : out noc_flit_type;
    noc4_data_w_out    : out noc_flit_type;
    noc4_data_e_out    : out noc_flit_type;
    noc4_data_void_out : out std_logic_vector(3 downto 0);
    noc4_stop_out      : out std_logic_vector(3 downto 0);
    noc5_data_n_in     : in  misc_noc_flit_type;
    noc5_data_s_in     : in  misc_noc_flit_type;
    noc5_data_w_in     : in  misc_noc_flit_type;
    noc5_data_e_in     : in  misc_noc_flit_type;
    noc5_data_void_in  : in  std_logic_vector(3 downto 0);
    noc5_stop_in       : in  std_logic_vector(3 downto 0);
    noc5_data_n_out    : out misc_noc_flit_type;
    noc5_data_s_out    : out misc_noc_flit_type;
    noc5_data_w_out    : out misc_noc_flit_type;
    noc5_data_e_out    : out misc_noc_flit_type;
    noc5_data_void_out : out std_logic_vector(3 downto 0);
    noc5_stop_out      : out std_logic_vector(3 downto 0);
    noc6_data_n_in     : in  noc_flit_type;
    noc6_data_s_in     : in  noc_flit_type;
    noc6_data_w_in     : in  noc_flit_type;
    noc6_data_e_in     : in  noc_flit_type;
    noc6_data_void_in  : in  std_logic_vector(3 downto 0);
    noc6_stop_in       : in  std_logic_vector(3 downto 0);
    noc6_data_n_out    : out noc_flit_type;
    noc6_data_s_out    : out noc_flit_type;
    noc6_data_w_out    : out noc_flit_type;
    noc6_data_e_out    : out noc_flit_type;
    noc6_data_void_out : out std_logic_vector(3 downto 0);
    noc6_stop_out      : out std_logic_vector(3 downto 0);
    noc1_mon_noc_vec   : out monitor_noc_type;
    noc2_mon_noc_vec   : out monitor_noc_type;
    noc3_mon_noc_vec   : out monitor_noc_type;
    noc4_mon_noc_vec   : out monitor_noc_type;
    noc5_mon_noc_vec   : out monitor_noc_type;
    noc6_mon_noc_vec   : out monitor_noc_type;
    mon_dvfs_in        : in  monitor_dvfs_type;
    mon_acc            : out monitor_acc_type;
    mon_cache          : out monitor_cache_type;
    mon_dvfs           : out monitor_dvfs_type
    );

end;

architecture rtl of fpga_tile_acc is

  -- Tile parameters
  signal this_local_y : local_yx;
  signal this_local_x : local_yx;

  -- Token-based power management config and status
  signal pm_config : pm_config_type;
  signal pm_status : pm_status_type;

  -- -- Token-based power management clock for accelerator tile
  signal acc_clk : std_ulogic;

  -- DCO reset -> keeping the logic compliant with the asic flow
  signal dco_rstn : std_ulogic;

  -- Tile interface signals
  signal test1_output_port_s   : noc_flit_type;
  signal test1_data_void_out_s : std_ulogic;
  signal test1_stop_in_s       : std_ulogic;
  signal test2_output_port_s   : noc_flit_type;
  signal test2_data_void_out_s : std_ulogic;
  signal test2_stop_in_s       : std_ulogic;
  signal test3_output_port_s   : noc_flit_type;
  signal test3_data_void_out_s : std_ulogic;
  signal test3_stop_in_s       : std_ulogic;
  signal test4_output_port_s   : noc_flit_type;
  signal test4_data_void_out_s : std_ulogic;
  signal test4_stop_in_s       : std_ulogic;
  signal test5_output_port_s   : misc_noc_flit_type;
  signal test5_data_void_out_s : std_ulogic;
  signal test5_stop_in_s       : std_ulogic;
  signal test6_output_port_s   : noc_flit_type;
  signal test6_data_void_out_s : std_ulogic;
  signal test6_stop_in_s       : std_ulogic;
  signal test1_input_port_s    : noc_flit_type;
  signal test1_data_void_in_s  : std_ulogic;
  signal test1_stop_out_s      : std_ulogic;
  signal test2_input_port_s    : noc_flit_type;
  signal test2_data_void_in_s  : std_ulogic;
  signal test2_stop_out_s      : std_ulogic;
  signal test3_input_port_s    : noc_flit_type;
  signal test3_data_void_in_s  : std_ulogic;
  signal test3_stop_out_s      : std_ulogic;
  signal test4_input_port_s    : noc_flit_type;
  signal test4_data_void_in_s  : std_ulogic;
  signal test4_stop_out_s      : std_ulogic;
  signal test5_input_port_s    : misc_noc_flit_type;
  signal test5_data_void_in_s  : std_ulogic;
  signal test5_stop_out_s      : std_ulogic;
  signal test6_input_port_s    : noc_flit_type;
  signal test6_data_void_in_s  : std_ulogic;
  signal test6_stop_out_s      : std_ulogic;

  signal noc1_mon_noc_vec_int : monitor_noc_type;
  signal noc2_mon_noc_vec_int : monitor_noc_type;
  signal noc3_mon_noc_vec_int : monitor_noc_type;
  signal noc4_mon_noc_vec_int : monitor_noc_type;
  signal noc5_mon_noc_vec_int : monitor_noc_type;
  signal noc6_mon_noc_vec_int : monitor_noc_type;

  -- Noc signals
  signal noc_rstn                    : std_ulogic;
  signal noc1_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc1_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc1_acc_stop_in            : std_ulogic;
  signal noc1_acc_stop_in_tile       : std_ulogic;
  signal noc1_acc_stop_out           : std_ulogic;
  signal noc1_acc_stop_out_tile      : std_ulogic;
  signal noc1_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc1_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc1_acc_data_void_in       : std_ulogic;
  signal noc1_acc_data_void_in_tile  : std_ulogic;
  signal noc1_acc_data_void_out      : std_ulogic;
  signal noc1_acc_data_void_out_tile : std_ulogic;
  signal noc2_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc2_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc2_acc_stop_in            : std_ulogic;
  signal noc2_acc_stop_in_tile       : std_ulogic;
  signal noc2_acc_stop_out           : std_ulogic;
  signal noc2_acc_stop_out_tile      : std_ulogic;
  signal noc2_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc2_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc2_acc_data_void_in       : std_ulogic;
  signal noc2_acc_data_void_in_tile  : std_ulogic;
  signal noc2_acc_data_void_out      : std_ulogic;
  signal noc2_acc_data_void_out_tile : std_ulogic;
  signal noc3_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc3_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc3_acc_stop_in            : std_ulogic;
  signal noc3_acc_stop_in_tile       : std_ulogic;
  signal noc3_acc_stop_out           : std_ulogic;
  signal noc3_acc_stop_out_tile      : std_ulogic;
  signal noc3_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc3_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc3_acc_data_void_in       : std_ulogic;
  signal noc3_acc_data_void_in_tile  : std_ulogic;
  signal noc3_acc_data_void_out      : std_ulogic;
  signal noc3_acc_data_void_out_tile : std_ulogic;
  signal noc4_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc4_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc4_acc_stop_in            : std_ulogic;
  signal noc4_acc_stop_in_tile       : std_ulogic;
  signal noc4_acc_stop_out           : std_ulogic;
  signal noc4_acc_stop_out_tile      : std_ulogic;
  signal noc4_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc4_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc4_acc_data_void_in       : std_ulogic;
  signal noc4_acc_data_void_in_tile  : std_ulogic;
  signal noc4_acc_data_void_out      : std_ulogic;
  signal noc4_acc_data_void_out_tile : std_ulogic;
  signal noc5_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc5_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc5_acc_stop_in            : std_ulogic;
  signal noc5_acc_stop_in_pm         : std_ulogic;
  signal noc5_acc_stop_in_tile       : std_ulogic;
  signal noc5_acc_stop_out           : std_ulogic;
  signal noc5_acc_stop_out_pm        : std_ulogic;
  signal noc5_acc_stop_out_tile      : std_ulogic;
  signal noc5_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc5_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc5_acc_data_void_in       : std_ulogic;
  signal noc5_acc_data_void_in_pm    : std_ulogic;
  signal noc5_acc_data_void_in_tile  : std_ulogic;
  signal noc5_acc_data_void_out      : std_ulogic;
  signal noc5_acc_data_void_out_pm   : std_ulogic;
  signal noc5_acc_data_void_out_tile : std_ulogic;
  signal noc6_stop_in_s              : std_logic_vector(4 downto 0);
  signal noc6_stop_out_s             : std_logic_vector(4 downto 0);
  signal noc6_acc_stop_in            : std_ulogic;
  signal noc6_acc_stop_in_tile       : std_ulogic;
  signal noc6_acc_stop_out           : std_ulogic;
  signal noc6_acc_stop_out_tile      : std_ulogic;
  signal noc6_data_void_in_s         : std_logic_vector(4 downto 0);
  signal noc6_data_void_out_s        : std_logic_vector(4 downto 0);
  signal noc6_acc_data_void_in       : std_ulogic;
  signal noc6_acc_data_void_in_tile  : std_ulogic;
  signal noc6_acc_data_void_out      : std_ulogic;
  signal noc6_acc_data_void_out_tile : std_ulogic;
  signal noc1_input_port             : noc_flit_type;
  signal noc1_input_port_tile        : noc_flit_type;
  signal noc2_input_port             : noc_flit_type;
  signal noc2_input_port_tile        : noc_flit_type;
  signal noc3_input_port             : noc_flit_type;
  signal noc3_input_port_tile        : noc_flit_type;
  signal noc4_input_port             : noc_flit_type;
  signal noc4_input_port_tile        : noc_flit_type;
  signal noc5_input_port             : misc_noc_flit_type;
  signal noc5_input_port_pm          : misc_noc_flit_type;
  signal noc5_input_port_tile        : misc_noc_flit_type;
  signal noc6_input_port             : noc_flit_type;
  signal noc6_input_port_tile        : noc_flit_type;
  signal noc1_output_port            : noc_flit_type;
  signal noc1_output_port_tile       : noc_flit_type;
  signal noc2_output_port            : noc_flit_type;
  signal noc2_output_port_tile       : noc_flit_type;
  signal noc3_output_port            : noc_flit_type;
  signal noc3_output_port_tile       : noc_flit_type;
  signal noc4_output_port            : noc_flit_type;
  signal noc4_output_port_tile       : noc_flit_type;
  signal noc5_output_port            : misc_noc_flit_type;
  signal noc5_output_port_pm         : misc_noc_flit_type;
  signal noc5_output_port_tile       : misc_noc_flit_type;
  signal noc6_output_port            : noc_flit_type;
  signal noc6_output_port_tile       : noc_flit_type;

  attribute keep                           : string;
  attribute keep of noc1_acc_stop_in       : signal is "true";
  attribute keep of noc1_acc_stop_out      : signal is "true";
  attribute keep of noc1_acc_data_void_in  : signal is "true";
  attribute keep of noc1_acc_data_void_out : signal is "true";
  attribute keep of noc1_input_port        : signal is "true";
  attribute keep of noc1_output_port       : signal is "true";
  attribute keep of noc1_data_n_in         : signal is "true";
  attribute keep of noc1_data_s_in         : signal is "true";
  attribute keep of noc1_data_w_in         : signal is "true";
  attribute keep of noc1_data_e_in         : signal is "true";
  attribute keep of noc1_data_void_in      : signal is "true";
  attribute keep of noc1_stop_in           : signal is "true";
  attribute keep of noc1_data_n_out        : signal is "true";
  attribute keep of noc1_data_s_out        : signal is "true";
  attribute keep of noc1_data_w_out        : signal is "true";
  attribute keep of noc1_data_e_out        : signal is "true";
  attribute keep of noc1_data_void_out     : signal is "true";
  attribute keep of noc1_stop_out          : signal is "true";
  attribute keep of noc2_acc_stop_in       : signal is "true";
  attribute keep of noc2_acc_stop_out      : signal is "true";
  attribute keep of noc2_acc_data_void_in  : signal is "true";
  attribute keep of noc2_acc_data_void_out : signal is "true";
  attribute keep of noc2_input_port        : signal is "true";
  attribute keep of noc2_output_port       : signal is "true";
  attribute keep of noc2_data_n_in         : signal is "true";
  attribute keep of noc2_data_s_in         : signal is "true";
  attribute keep of noc2_data_w_in         : signal is "true";
  attribute keep of noc2_data_e_in         : signal is "true";
  attribute keep of noc2_data_void_in      : signal is "true";
  attribute keep of noc2_stop_in           : signal is "true";
  attribute keep of noc2_data_n_out        : signal is "true";
  attribute keep of noc2_data_s_out        : signal is "true";
  attribute keep of noc2_data_w_out        : signal is "true";
  attribute keep of noc2_data_e_out        : signal is "true";
  attribute keep of noc2_data_void_out     : signal is "true";
  attribute keep of noc2_stop_out          : signal is "true";
  attribute keep of noc3_acc_stop_in       : signal is "true";
  attribute keep of noc3_acc_stop_out      : signal is "true";
  attribute keep of noc3_acc_data_void_in  : signal is "true";
  attribute keep of noc3_acc_data_void_out : signal is "true";
  attribute keep of noc3_input_port        : signal is "true";
  attribute keep of noc3_output_port       : signal is "true";
  attribute keep of noc3_data_n_in         : signal is "true";
  attribute keep of noc3_data_s_in         : signal is "true";
  attribute keep of noc3_data_w_in         : signal is "true";
  attribute keep of noc3_data_e_in         : signal is "true";
  attribute keep of noc3_data_void_in      : signal is "true";
  attribute keep of noc3_stop_in           : signal is "true";
  attribute keep of noc3_data_n_out        : signal is "true";
  attribute keep of noc3_data_s_out        : signal is "true";
  attribute keep of noc3_data_w_out        : signal is "true";
  attribute keep of noc3_data_e_out        : signal is "true";
  attribute keep of noc3_data_void_out     : signal is "true";
  attribute keep of noc3_stop_out          : signal is "true";
  attribute keep of noc4_acc_stop_in       : signal is "true";
  attribute keep of noc4_acc_stop_out      : signal is "true";
  attribute keep of noc4_acc_data_void_in  : signal is "true";
  attribute keep of noc4_acc_data_void_out : signal is "true";
  attribute keep of noc4_input_port        : signal is "true";
  attribute keep of noc4_output_port       : signal is "true";
  attribute keep of noc4_data_n_in         : signal is "true";
  attribute keep of noc4_data_s_in         : signal is "true";
  attribute keep of noc4_data_w_in         : signal is "true";
  attribute keep of noc4_data_e_in         : signal is "true";
  attribute keep of noc4_data_void_in      : signal is "true";
  attribute keep of noc4_stop_in           : signal is "true";
  attribute keep of noc4_data_n_out        : signal is "true";
  attribute keep of noc4_data_s_out        : signal is "true";
  attribute keep of noc4_data_w_out        : signal is "true";
  attribute keep of noc4_data_e_out        : signal is "true";
  attribute keep of noc4_data_void_out     : signal is "true";
  attribute keep of noc4_stop_out          : signal is "true";
  attribute keep of noc5_acc_stop_in       : signal is "true";
  attribute keep of noc5_acc_stop_out      : signal is "true";
  attribute keep of noc5_acc_data_void_in  : signal is "true";
  attribute keep of noc5_acc_data_void_out : signal is "true";
  attribute keep of noc5_input_port        : signal is "true";
  attribute keep of noc5_output_port       : signal is "true";
  attribute keep of noc5_data_n_in         : signal is "true";
  attribute keep of noc5_data_s_in         : signal is "true";
  attribute keep of noc5_data_w_in         : signal is "true";
  attribute keep of noc5_data_e_in         : signal is "true";
  attribute keep of noc5_data_void_in      : signal is "true";
  attribute keep of noc5_stop_in           : signal is "true";
  attribute keep of noc5_data_n_out        : signal is "true";
  attribute keep of noc5_data_s_out        : signal is "true";
  attribute keep of noc5_data_w_out        : signal is "true";
  attribute keep of noc5_data_e_out        : signal is "true";
  attribute keep of noc5_data_void_out     : signal is "true";
  attribute keep of noc5_stop_out          : signal is "true";
  attribute keep of noc6_acc_stop_in       : signal is "true";
  attribute keep of noc6_acc_stop_out      : signal is "true";
  attribute keep of noc6_acc_data_void_in  : signal is "true";
  attribute keep of noc6_acc_data_void_out : signal is "true";
  attribute keep of noc6_input_port        : signal is "true";
  attribute keep of noc6_output_port       : signal is "true";
  attribute keep of noc6_data_n_in         : signal is "true";
  attribute keep of noc6_data_s_in         : signal is "true";
  attribute keep of noc6_data_w_in         : signal is "true";
  attribute keep of noc6_data_e_in         : signal is "true";
  attribute keep of noc6_data_void_in      : signal is "true";
  attribute keep of noc6_stop_in           : signal is "true";
  attribute keep of noc6_data_n_out        : signal is "true";
  attribute keep of noc6_data_s_out        : signal is "true";
  attribute keep of noc6_data_w_out        : signal is "true";
  attribute keep of noc6_data_e_out        : signal is "true";
  attribute keep of noc6_data_void_out     : signal is "true";
  attribute keep of noc6_stop_out          : signal is "true";

  attribute mark_debug                              : string;
  attribute mark_debug of pm_config                 : signal is "true";
  attribute mark_debug of pm_status                 : signal is "true";
  attribute mark_debug of noc5_input_port           : signal is "true";
  attribute mark_debug of noc5_acc_data_void_in     : signal is "true";
  attribute mark_debug of noc5_acc_stop_out         : signal is "true";
  attribute mark_debug of noc5_output_port          : signal is "true";
  attribute mark_debug of noc5_acc_data_void_out    : signal is "true";
  attribute mark_debug of noc5_acc_stop_in          : signal is "true";
  attribute mark_debug of noc5_input_port_pm        : signal is "true";
  attribute mark_debug of noc5_acc_data_void_in_pm  : signal is "true";
  attribute mark_debug of noc5_acc_stop_out_pm      : signal is "true";
  attribute mark_debug of noc5_output_port_pm       : signal is "true";
  attribute mark_debug of noc5_acc_data_void_out_pm : signal is "true";
  attribute mark_debug of noc5_acc_stop_in_pm       : signal is "true";

begin

  noc1_mon_noc_vec <= noc1_mon_noc_vec_int;
  noc2_mon_noc_vec <= noc2_mon_noc_vec_int;
  noc3_mon_noc_vec <= noc3_mon_noc_vec_int;
  noc4_mon_noc_vec <= noc4_mon_noc_vec_int;
  noc5_mon_noc_vec <= noc5_mon_noc_vec_int;
  noc6_mon_noc_vec <= noc6_mon_noc_vec_int;

  -----------------------------------------------------------------------------
  -- JTAG for single tile testing / bypass when test_if_en = 0
  -----------------------------------------------------------------------------
  jtag_test_i : jtag_test
    generic map (
      test_if_en => 0)
    port map (
      rst                 => rst,
      refclk              => acc_clk,
      tile_rst            => dco_rstn,
      tdi                 => tdi,
      tdo                 => tdo,
      tms                 => tms,
      tclk                => tclk,
      noc1_output_port    => noc1_output_port_tile,
      noc1_data_void_out  => noc1_acc_data_void_out_tile,
      noc1_stop_in        => noc1_acc_stop_in_tile,
      noc2_output_port    => noc2_output_port_tile,
      noc2_data_void_out  => noc2_acc_data_void_out_tile,
      noc2_stop_in        => noc2_acc_stop_in_tile,
      noc3_output_port    => noc3_output_port_tile,
      noc3_data_void_out  => noc3_acc_data_void_out_tile,
      noc3_stop_in        => noc3_acc_stop_in_tile,
      noc4_output_port    => noc4_output_port_tile,
      noc4_data_void_out  => noc4_acc_data_void_out_tile,
      noc4_stop_in        => noc4_acc_stop_in_tile,
      noc5_output_port    => noc5_output_port_tile,
      noc5_data_void_out  => noc5_acc_data_void_out_tile,
      noc5_stop_in        => noc5_acc_stop_in_tile,
      noc6_output_port    => noc6_output_port_tile,
      noc6_data_void_out  => noc6_acc_data_void_out_tile,
      noc6_stop_in        => noc6_acc_stop_in_tile,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_in_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_out_s,
      noc1_input_port     => noc1_input_port_tile,
      noc1_data_void_in   => noc1_acc_data_void_in_tile,
      noc1_stop_out       => noc1_acc_stop_out_tile,
      noc2_input_port     => noc2_input_port_tile,
      noc2_data_void_in   => noc2_acc_data_void_in_tile,
      noc2_stop_out       => noc2_acc_stop_out_tile,
      noc3_input_port     => noc3_input_port_tile,
      noc3_data_void_in   => noc3_acc_data_void_in_tile,
      noc3_stop_out       => noc3_acc_stop_out_tile,
      noc4_input_port     => noc4_input_port_tile,
      noc4_data_void_in   => noc4_acc_data_void_in_tile,
      noc4_stop_out       => noc4_acc_stop_out_tile,
      noc5_input_port     => noc5_input_port_tile,
      noc5_data_void_in   => noc5_acc_data_void_in_tile,
      noc5_stop_out       => noc5_acc_stop_out_tile,
      noc6_input_port     => noc6_input_port_tile,
      noc6_data_void_in   => noc6_acc_data_void_in_tile,
      noc6_stop_out       => noc6_acc_stop_out_tile);

  -----------------------------------------------------------------------------
  -- NOC Connections
  ----------------------------------------------------------------------------
  noc1_stop_in_s         <= noc1_acc_stop_in & noc1_stop_in;
  noc1_stop_out          <= noc1_stop_out_s(3 downto 0);
  noc1_acc_stop_out      <= noc1_stop_out_s(4);
  noc1_data_void_in_s    <= noc1_acc_data_void_in & noc1_data_void_in;
  noc1_data_void_out     <= noc1_data_void_out_s(3 downto 0);
  noc1_acc_data_void_out <= noc1_data_void_out_s(4);
  noc2_stop_in_s         <= noc2_acc_stop_in & noc2_stop_in;
  noc2_stop_out          <= noc2_stop_out_s(3 downto 0);
  noc2_acc_stop_out      <= noc2_stop_out_s(4);
  noc2_data_void_in_s    <= noc2_acc_data_void_in & noc2_data_void_in;
  noc2_data_void_out     <= noc2_data_void_out_s(3 downto 0);
  noc2_acc_data_void_out <= noc2_data_void_out_s(4);
  noc3_stop_in_s         <= noc3_acc_stop_in & noc3_stop_in;
  noc3_stop_out          <= noc3_stop_out_s(3 downto 0);
  noc3_acc_stop_out      <= noc3_stop_out_s(4);
  noc3_data_void_in_s    <= noc3_acc_data_void_in & noc3_data_void_in;
  noc3_data_void_out     <= noc3_data_void_out_s(3 downto 0);
  noc3_acc_data_void_out <= noc3_data_void_out_s(4);
  noc4_stop_in_s         <= noc4_acc_stop_in & noc4_stop_in;
  noc4_stop_out          <= noc4_stop_out_s(3 downto 0);
  noc4_acc_stop_out      <= noc4_stop_out_s(4);
  noc4_data_void_in_s    <= noc4_acc_data_void_in & noc4_data_void_in;
  noc4_data_void_out     <= noc4_data_void_out_s(3 downto 0);
  noc4_acc_data_void_out <= noc4_data_void_out_s(4);
  noc5_stop_in_s         <= noc5_acc_stop_in & noc5_stop_in;
  noc5_stop_out          <= noc5_stop_out_s(3 downto 0);
  noc5_acc_stop_out      <= noc5_stop_out_s(4);
  noc5_data_void_in_s    <= noc5_acc_data_void_in & noc5_data_void_in;
  noc5_data_void_out     <= noc5_data_void_out_s(3 downto 0);
  noc5_acc_data_void_out <= noc5_data_void_out_s(4);
  noc6_stop_in_s         <= noc6_acc_stop_in & noc6_stop_in;
  noc6_stop_out          <= noc6_stop_out_s(3 downto 0);
  noc6_acc_stop_out      <= noc6_stop_out_s(4);
  noc6_data_void_in_s    <= noc6_acc_data_void_in & noc6_data_void_in;
  noc6_data_void_out     <= noc6_data_void_out_s(3 downto 0);
  noc6_acc_data_void_out <= noc6_data_void_out_s(4);

  no_noc_tile_sync_gen : if HAS_SYNC = 0 generate
    noc1_output_port_tile       <= noc1_output_port;
    noc1_acc_data_void_out_tile <= noc1_acc_data_void_out;
    noc1_acc_stop_in            <= noc1_acc_stop_in_tile;
    noc2_output_port_tile       <= noc2_output_port;
    noc2_acc_data_void_out_tile <= noc2_acc_data_void_out;
    noc2_acc_stop_in            <= noc2_acc_stop_in_tile;
    noc3_output_port_tile       <= noc3_output_port;
    noc3_acc_data_void_out_tile <= noc3_acc_data_void_out;
    noc3_acc_stop_in            <= noc3_acc_stop_in_tile;
    noc4_output_port_tile       <= noc4_output_port;
    noc4_acc_data_void_out_tile <= noc4_acc_data_void_out;
    noc4_acc_stop_in            <= noc4_acc_stop_in_tile;
    noc5_output_port_tile       <= noc5_output_port_pm;
    noc5_acc_data_void_out_tile <= noc5_acc_data_void_out_pm;
    noc5_acc_stop_in_pm         <= noc5_acc_stop_in_tile;
    noc6_output_port_tile       <= noc6_output_port;
    noc6_acc_data_void_out_tile <= noc6_acc_data_void_out;
    noc6_acc_stop_in            <= noc6_acc_stop_in_tile;

    noc1_input_port          <= noc1_input_port_tile;
    noc1_acc_data_void_in    <= noc1_acc_data_void_in_tile;
    noc1_acc_stop_out_tile   <= noc1_acc_stop_out;
    noc2_input_port          <= noc2_input_port_tile;
    noc2_acc_data_void_in    <= noc2_acc_data_void_in_tile;
    noc2_acc_stop_out_tile   <= noc2_acc_stop_out;
    noc3_input_port          <= noc3_input_port_tile;
    noc3_acc_data_void_in    <= noc3_acc_data_void_in_tile;
    noc3_acc_stop_out_tile   <= noc3_acc_stop_out;
    noc4_input_port          <= noc4_input_port_tile;
    noc4_acc_data_void_in    <= noc4_acc_data_void_in_tile;
    noc4_acc_stop_out_tile   <= noc4_acc_stop_out;
    noc5_input_port_pm       <= noc5_input_port_tile;
    noc5_acc_data_void_in_pm <= noc5_acc_data_void_in_tile;
    noc5_acc_stop_out_tile   <= noc5_acc_stop_out_pm;
    noc6_input_port          <= noc6_input_port_tile;
    noc6_acc_data_void_in    <= noc6_acc_data_void_in_tile;
    noc6_acc_stop_out_tile   <= noc6_acc_stop_out;
  end generate;

  -- The noc_synchronizers component adds synchronizers between NoC and tile.
  -- By default the synchronizers are instantiated inside the NoC (when the
  -- generic HAS_SYNC=1). For this tile, however, the power management logic
  -- needs to sit in the NoC domain, between the NoC and the synchronizers. For
  -- that reason the synchronizers (noc_synchronizers component) are
  -- instantiated here instead of inside the NoC.

  noc_tile_sync_gen : if HAS_SYNC = 1 generate
    noc_tile_synchronizers : noc_synchronizers
      port map (
        noc_rstn  => rst,
        tile_rstn => dco_rstn,
        noc_clk   => sys_clk_int,
        tile_clk  => acc_clk,

        noc1_output_port   => noc1_output_port,
        noc1_data_void_out => noc1_acc_data_void_out,
        noc1_stop_in       => noc1_acc_stop_in,
        noc2_output_port   => noc2_output_port,
        noc2_data_void_out => noc2_acc_data_void_out,
        noc2_stop_in       => noc2_acc_stop_in,
        noc3_output_port   => noc3_output_port,
        noc3_data_void_out => noc3_acc_data_void_out,
        noc3_stop_in       => noc3_acc_stop_in,
        noc4_output_port   => noc4_output_port,
        noc4_data_void_out => noc4_acc_data_void_out,
        noc4_stop_in       => noc4_acc_stop_in,
        noc5_output_port   => noc5_output_port_pm,
        noc5_data_void_out => noc5_acc_data_void_out_pm,
        noc5_stop_in       => noc5_acc_stop_in_pm,
        noc6_output_port   => noc6_output_port,
        noc6_data_void_out => noc6_acc_data_void_out,
        noc6_stop_in       => noc6_acc_stop_in,

        noc1_input_port   => noc1_input_port,
        noc1_data_void_in => noc1_acc_data_void_in,
        noc1_stop_out     => noc1_acc_stop_out,
        noc2_input_port   => noc2_input_port,
        noc2_data_void_in => noc2_acc_data_void_in,
        noc2_stop_out     => noc2_acc_stop_out,
        noc3_input_port   => noc3_input_port,
        noc3_data_void_in => noc3_acc_data_void_in,
        noc3_stop_out     => noc3_acc_stop_out,
        noc4_input_port   => noc4_input_port,
        noc4_data_void_in => noc4_acc_data_void_in,
        noc4_stop_out     => noc4_acc_stop_out,
        noc5_input_port   => noc5_input_port_pm,
        noc5_data_void_in => noc5_acc_data_void_in_pm,
        noc5_stop_out     => noc5_acc_stop_out_pm,
        noc6_input_port   => noc6_input_port,
        noc6_data_void_in => noc6_acc_data_void_in,
        noc6_stop_out     => noc6_acc_stop_out,

        noc1_output_port_tile   => noc1_output_port_tile,
        noc1_data_void_out_tile => noc1_acc_data_void_out_tile,
        noc1_stop_in_tile       => noc1_acc_stop_in_tile,
        noc2_output_port_tile   => noc2_output_port_tile,
        noc2_data_void_out_tile => noc2_acc_data_void_out_tile,
        noc2_stop_in_tile       => noc2_acc_stop_in_tile,
        noc3_output_port_tile   => noc3_output_port_tile,
        noc3_data_void_out_tile => noc3_acc_data_void_out_tile,
        noc3_stop_in_tile       => noc3_acc_stop_in_tile,
        noc4_output_port_tile   => noc4_output_port_tile,
        noc4_data_void_out_tile => noc4_acc_data_void_out_tile,
        noc4_stop_in_tile       => noc4_acc_stop_in_tile,
        noc5_output_port_tile   => noc5_output_port_tile,
        noc5_data_void_out_tile => noc5_acc_data_void_out_tile,
        noc5_stop_in_tile       => noc5_acc_stop_in_tile,
        noc6_output_port_tile   => noc6_output_port_tile,
        noc6_data_void_out_tile => noc6_acc_data_void_out_tile,
        noc6_stop_in_tile       => noc6_acc_stop_in_tile,

        noc1_input_port_tile   => noc1_input_port_tile,
        noc1_data_void_in_tile => noc1_acc_data_void_in_tile,
        noc1_stop_out_tile     => noc1_acc_stop_out_tile,
        noc2_input_port_tile   => noc2_input_port_tile,
        noc2_data_void_in_tile => noc2_acc_data_void_in_tile,
        noc2_stop_out_tile     => noc2_acc_stop_out_tile,
        noc3_input_port_tile   => noc3_input_port_tile,
        noc3_data_void_in_tile => noc3_acc_data_void_in_tile,
        noc3_stop_out_tile     => noc3_acc_stop_out_tile,
        noc4_input_port_tile   => noc4_input_port_tile,
        noc4_data_void_in_tile => noc4_acc_data_void_in_tile,
        noc4_stop_out_tile     => noc4_acc_stop_out_tile,
        noc5_input_port_tile   => noc5_input_port_tile,
        noc5_data_void_in_tile => noc5_acc_data_void_in_tile,
        noc5_stop_out_tile     => noc5_acc_stop_out_tile,
        noc6_input_port_tile   => noc6_input_port_tile,
        noc6_data_void_in_tile => noc6_acc_data_void_in_tile,
        noc6_stop_out_tile     => noc6_acc_stop_out_tile);
  end generate;

  sync_noc_set_acc : sync_noc_set
    generic map (
      PORTS    => ROUTER_PORTS,
      HAS_SYNC => 0)                    -- no synchronizers in the NoC because
    -- they are already explicitly added in
    -- this asic_tile_acc entity (noc_synchronizers)
    port map (
      clk                => sys_clk_int,
      clk_tile           => acc_clk,
      rst                => rst,
      rst_tile           => dco_rstn,
      CONST_local_x      => this_local_x,
      CONST_local_y      => this_local_y,
      noc1_data_n_in     => noc1_data_n_in,
      noc1_data_s_in     => noc1_data_s_in,
      noc1_data_w_in     => noc1_data_w_in,
      noc1_data_e_in     => noc1_data_e_in,
      noc1_input_port    => noc1_input_port,
      noc1_data_void_in  => noc1_data_void_in_s,
      noc1_stop_in       => noc1_stop_in_s,
      noc1_data_n_out    => noc1_data_n_out,
      noc1_data_s_out    => noc1_data_s_out,
      noc1_data_w_out    => noc1_data_w_out,
      noc1_data_e_out    => noc1_data_e_out,
      noc1_output_port   => noc1_output_port,
      noc1_data_void_out => noc1_data_void_out_s,
      noc1_stop_out      => noc1_stop_out_s,
      noc2_data_n_in     => noc2_data_n_in,
      noc2_data_s_in     => noc2_data_s_in,
      noc2_data_w_in     => noc2_data_w_in,
      noc2_data_e_in     => noc2_data_e_in,
      noc2_input_port    => noc2_input_port,
      noc2_data_void_in  => noc2_data_void_in_s,
      noc2_stop_in       => noc2_stop_in_s,
      noc2_data_n_out    => noc2_data_n_out,
      noc2_data_s_out    => noc2_data_s_out,
      noc2_data_w_out    => noc2_data_w_out,
      noc2_data_e_out    => noc2_data_e_out,
      noc2_output_port   => noc2_output_port,
      noc2_data_void_out => noc2_data_void_out_s,
      noc2_stop_out      => noc2_stop_out_s,
      noc3_data_n_in     => noc3_data_n_in,
      noc3_data_s_in     => noc3_data_s_in,
      noc3_data_w_in     => noc3_data_w_in,
      noc3_data_e_in     => noc3_data_e_in,
      noc3_input_port    => noc3_input_port,
      noc3_data_void_in  => noc3_data_void_in_s,
      noc3_stop_in       => noc3_stop_in_s,
      noc3_data_n_out    => noc3_data_n_out,
      noc3_data_s_out    => noc3_data_s_out,
      noc3_data_w_out    => noc3_data_w_out,
      noc3_data_e_out    => noc3_data_e_out,
      noc3_output_port   => noc3_output_port,
      noc3_data_void_out => noc3_data_void_out_s,
      noc3_stop_out      => noc3_stop_out_s,
      noc4_data_n_in     => noc4_data_n_in,
      noc4_data_s_in     => noc4_data_s_in,
      noc4_data_w_in     => noc4_data_w_in,
      noc4_data_e_in     => noc4_data_e_in,
      noc4_input_port    => noc4_input_port,
      noc4_data_void_in  => noc4_data_void_in_s,
      noc4_stop_in       => noc4_stop_in_s,
      noc4_data_n_out    => noc4_data_n_out,
      noc4_data_s_out    => noc4_data_s_out,
      noc4_data_w_out    => noc4_data_w_out,
      noc4_data_e_out    => noc4_data_e_out,
      noc4_output_port   => noc4_output_port,
      noc4_data_void_out => noc4_data_void_out_s,
      noc4_stop_out      => noc4_stop_out_s,
      noc5_data_n_in     => noc5_data_n_in,
      noc5_data_s_in     => noc5_data_s_in,
      noc5_data_w_in     => noc5_data_w_in,
      noc5_data_e_in     => noc5_data_e_in,
      noc5_input_port    => noc5_input_port,
      noc5_data_void_in  => noc5_data_void_in_s,
      noc5_stop_in       => noc5_stop_in_s,
      noc5_data_n_out    => noc5_data_n_out,
      noc5_data_s_out    => noc5_data_s_out,
      noc5_data_w_out    => noc5_data_w_out,
      noc5_data_e_out    => noc5_data_e_out,
      noc5_output_port   => noc5_output_port,
      noc5_data_void_out => noc5_data_void_out_s,
      noc5_stop_out      => noc5_stop_out_s,
      noc6_data_n_in     => noc6_data_n_in,
      noc6_data_s_in     => noc6_data_s_in,
      noc6_data_w_in     => noc6_data_w_in,
      noc6_data_e_in     => noc6_data_e_in,
      noc6_input_port    => noc6_input_port,
      noc6_data_void_in  => noc6_data_void_in_s,
      noc6_stop_in       => noc6_stop_in_s,
      noc6_data_n_out    => noc6_data_n_out,
      noc6_data_s_out    => noc6_data_s_out,
      noc6_data_w_out    => noc6_data_w_out,
      noc6_data_e_out    => noc6_data_e_out,
      noc6_output_port   => noc6_output_port,
      noc6_data_void_out => noc6_data_void_out_s,
      noc6_stop_out      => noc6_stop_out_s,
      noc1_mon_noc_vec   => noc1_mon_noc_vec_int,
      noc2_mon_noc_vec   => noc2_mon_noc_vec_int,
      noc3_mon_noc_vec   => noc3_mon_noc_vec_int,
      noc4_mon_noc_vec   => noc4_mon_noc_vec_int,
      noc5_mon_noc_vec   => noc5_mon_noc_vec_int,
      noc6_mon_noc_vec   => noc6_mon_noc_vec_int
      );

  tile_acc_1 : tile_acc
    generic map (
      this_hls_conf      => this_hls_conf,
      this_device        => this_device,
      this_irq_type      => this_irq_type,
      this_has_l2        => this_has_l2,
      this_has_dvfs      => this_has_dvfs,  -- no DVFS controller
      this_has_pll       => this_has_pll,
      this_has_dco       => 0,
      this_extra_clk_buf => this_extra_clk_buf)
    port map (
      raw_rstn            => raw_rstn,
      tile_rst            => rst,
      refclk              => acc_clk,
      pllbypass           => pllbypass,
      pllclk              => pllclk,
      dco_clk             => dco_clk,
      dco_rstn            => dco_rstn,
      pad_cfg             => open,
      local_x             => this_local_x,
      local_y             => this_local_y,
      pm_config           => pm_config,
      pm_status           => pm_status,
      test1_output_port   => test1_output_port_s,
      test1_data_void_out => test1_data_void_out_s,
      test1_stop_in       => test1_stop_out_s,
      test1_input_port    => test1_input_port_s,
      test1_data_void_in  => test1_data_void_in_s,
      test1_stop_out      => test1_stop_in_s,
      test2_output_port   => test2_output_port_s,
      test2_data_void_out => test2_data_void_out_s,
      test2_stop_in       => test2_stop_out_s,
      test2_input_port    => test2_input_port_s,
      test2_data_void_in  => test2_data_void_in_s,
      test2_stop_out      => test2_stop_in_s,
      test3_output_port   => test3_output_port_s,
      test3_data_void_out => test3_data_void_out_s,
      test3_stop_in       => test3_stop_out_s,
      test3_input_port    => test3_input_port_s,
      test3_data_void_in  => test3_data_void_in_s,
      test3_stop_out      => test3_stop_in_s,
      test4_output_port   => test4_output_port_s,
      test4_data_void_out => test4_data_void_out_s,
      test4_stop_in       => test4_stop_out_s,
      test4_input_port    => test4_input_port_s,
      test4_data_void_in  => test4_data_void_in_s,
      test4_stop_out      => test4_stop_in_s,
      test5_output_port   => test5_output_port_s,
      test5_data_void_out => test5_data_void_out_s,
      test5_stop_in       => test5_stop_out_s,
      test5_input_port    => test5_input_port_s,
      test5_data_void_in  => test5_data_void_in_s,
      test5_stop_out      => test5_stop_in_s,
      test6_output_port   => test6_output_port_s,
      test6_data_void_out => test6_data_void_out_s,
      test6_stop_in       => test6_stop_out_s,
      test6_input_port    => test6_input_port_s,
      test6_data_void_in  => test6_data_void_in_s,
      test6_stop_out      => test6_stop_in_s,
      noc1_mon_noc_vec    => noc1_mon_noc_vec_int,
      noc2_mon_noc_vec    => noc2_mon_noc_vec_int,
      noc3_mon_noc_vec    => noc3_mon_noc_vec_int,
      noc4_mon_noc_vec    => noc4_mon_noc_vec_int,
      noc5_mon_noc_vec    => noc5_mon_noc_vec_int,
      noc6_mon_noc_vec    => noc6_mon_noc_vec_int,
      mon_dvfs_in         => mon_dvfs_in,
      mon_acc             => mon_acc,
      mon_cache           => mon_cache,
      mon_dvfs            => mon_dvfs
      );

  token_pm_gen : if this_has_token_pm = 1 generate

    token_pm_i : token_pm
      generic map (
        SIMULATION => SIMULATION,
        is_asic    => false)
      port map (
        noc_rstn              => rst,
        tile_rstn             => dco_rstn,
        noc_clk               => sys_clk_int,
        refclk                => refclk,
        tile_clk              => acc_clk,
        local_x               => this_local_x,
        local_y               => this_local_y,
        pm_config             => pm_config,
        pm_status             => pm_status,
        noc5_input_port       => noc5_input_port,
        noc5_data_void_in     => noc5_acc_data_void_in,
        noc5_stop_out         => noc5_acc_stop_out,
        noc5_output_port      => noc5_output_port,
        noc5_data_void_out    => noc5_acc_data_void_out,
        noc5_stop_in          => noc5_acc_stop_in,
        noc5_input_port_pm    => noc5_input_port_pm,
        noc5_data_void_in_pm  => noc5_acc_data_void_in_pm,
        noc5_stop_out_pm      => noc5_acc_stop_out_pm,
        noc5_output_port_pm   => noc5_output_port_pm,
        noc5_data_void_out_pm => noc5_acc_data_void_out_pm,
        noc5_stop_in_pm       => noc5_acc_stop_in_pm,
        acc_clk               => acc_clk);

  end generate;

  no_token_pm_gen : if this_has_token_pm = 0 generate
    acc_clk                   <= refclk;
    pm_status                 <= (others => (others => '0'));
    noc5_input_port           <= noc5_input_port_pm;
    noc5_acc_data_void_in     <= noc5_acc_data_void_in_pm;
    noc5_acc_stop_out_pm      <= noc5_acc_stop_out;
    noc5_output_port_pm       <= noc5_output_port;
    noc5_acc_data_void_out_pm <= noc5_acc_data_void_out;
    noc5_acc_stop_in          <= noc5_acc_stop_in_pm;
  end generate;

end;