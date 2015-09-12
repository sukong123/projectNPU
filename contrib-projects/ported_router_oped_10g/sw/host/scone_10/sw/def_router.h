//-----------------------------------------------------------------------------
// File:  def_router.h
// Date:  Tue Nov 06 14:54:30 PDT 2012
// Author: Gianni Antichi
//
// Description:
//
// Router register HW defines
//
//-----------------------------------------------------------------------------

#define ROUTER_OP_LUT_ROUTE_TABLE_DEPTH             32
#define ROUTER_OP_LUT_ARP_TABLE_DEPTH               32
#define ROUTER_OP_LUT_DST_IP_FILTER_TABLE_DEPTH     32

#define ROUTER_OP_LUT_ARP_NUM_MISSES_REG            0x76600000
#define ROUTER_OP_LUT_LPM_NUM_MISSES_REG            0x76600004
#define ROUTER_OP_LUT_NUM_CPU_PKTS_SENT_REG         0x76600008
#define ROUTER_OP_LUT_NUM_BAD_OPTS_VER_REG          0x7660000c
#define ROUTER_OP_LUT_NUM_BAD_CHKSUMS_REG           0x76600010
#define ROUTER_OP_LUT_NUM_BAD_TTLS_REG              0x76600014
#define ROUTER_OP_LUT_NUM_NON_IP_RCVD_REG           0x76600018
#define ROUTER_OP_LUT_NUM_PKTS_FORWARDED_REG        0x7660001c
#define ROUTER_OP_LUT_NUM_WRONG_DEST_REG            0x76600020
#define ROUTER_OP_LUT_NUM_FILTERED_PKTS_REG         0x76600024

#define ROUTER_OP_LUT_MAC_0_HI_REG                  0x76600028
#define ROUTER_OP_LUT_MAC_0_LO_REG                  0x7660002c
#define ROUTER_OP_LUT_MAC_1_HI_REG                  0x76600030
#define ROUTER_OP_LUT_MAC_1_LO_REG                  0x76600034
#define ROUTER_OP_LUT_MAC_2_HI_REG                  0x76600038
#define ROUTER_OP_LUT_MAC_2_LO_REG                  0x7660003c
#define ROUTER_OP_LUT_MAC_3_HI_REG                  0x76600040
#define ROUTER_OP_LUT_MAC_3_LO_REG                  0x76600044

#define ROUTER_OP_LUT_ARP_TABLE_ENTRY_MAC_HI_REG    0x76600048
#define ROUTER_OP_LUT_ARP_TABLE_ENTRY_MAC_LO_REG    0x7660004c
#define ROUTER_OP_LUT_ARP_TABLE_ENTRY_NEXT_HOP_IP_REG 0x76600050
#define ROUTER_OP_LUT_ARP_TABLE_RD_ADDR_REG         0x76600054
#define ROUTER_OP_LUT_ARP_TABLE_WR_ADDR_REG         0x76600058

#define ROUTER_OP_LUT_ROUTE_TABLE_ENTRY_IP_REG      0x7660005c
#define ROUTER_OP_LUT_ROUTE_TABLE_ENTRY_MASK_REG    0x76600060
#define ROUTER_OP_LUT_ROUTE_TABLE_ENTRY_NEXT_HOP_IP_REG 0x76600064
#define ROUTER_OP_LUT_ROUTE_TABLE_ENTRY_OUTPUT_PORT_REG 0x76600068
#define ROUTER_OP_LUT_ROUTE_TABLE_RD_ADDR_REG       0x7660006c
#define ROUTER_OP_LUT_ROUTE_TABLE_WR_ADDR_REG       0x76600070

#define ROUTER_OP_LUT_DST_IP_FILTER_TABLE_ENTRY_IP_REG 0x76600074
#define ROUTER_OP_LUT_DST_IP_FILTER_TABLE_RD_ADDR_REG 0x76600078
#define ROUTER_OP_LUT_DST_IP_FILTER_TABLE_WR_ADDR_REG 0x7660007c

