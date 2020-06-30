///////////////////////////////////////////////////////////////////////////////
//    Copyright (c) 1995/2005 Xilinx, Inc.
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.13)
//  \   \         Description : Xilinx Timing Simulation Library Component
//  /   /                  Dual Data Rate Input D Flip-Flop
// /___/   /\     Filename : IDDR.v
// \   \  /  \    Timestamp : Thu Mar 11 16:44:06 PST 2005
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    03/11/05 - Added LOC parameter, removed GSR ports and initialized outpus.
//    12/20/05 - Fixed setup and hold checks.
//    04/28/06 - Added c_in into the sensitivity list (CR 219840).
//    05/29/07 - Added wire declaration for internal signals
//    04/16/08 - CR 468871 Negative SetupHold fix
//    05/06/08 - CR 455447 add XON MSGON property to support async reg
//    12/03/08 - CR 498674 added pulldown on R/S.
//    12/13/11 - Added `celldefine and `endcelldefine (CR 524859).
//    08/23/13 - PR683925 - add invertible pin support.
//    10/22/14 - Added #1 to $finish (CR 808642).
// End Revision

`timescale  1 ps / 1 ps


`celldefine


module IDDR (Q1, Q2, C, CE, D, R, S);
    
    output Q1;
    output Q2;
    
    input C;
    input CE;
    input D;
    input R;
    input S;

    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE";    
    parameter INIT_Q1 = 1'b0;
    parameter INIT_Q2 = 1'b0;
    parameter [0:0] IS_C_INVERTED = 1'b0;
    parameter [0:0] IS_D_INVERTED = 1'b0;
    parameter SRTYPE = "SYNC";











    pulldown P1 (R);
    pulldown P2 (S);

    reg q1_out = INIT_Q1, q2_out = INIT_Q2;
    reg q1_out_int, q2_out_int;
    reg q1_out_pipelined, q2_out_same_edge_int;
    reg notifier, notifier1, notifier2;
    wire notifier1x, notifier2x;

    wire c_in,delay_c;
    wire ce_in,delay_ce;
    wire d_in,delay_d;
    wire gsr_in;
    wire r_in,delay_r;
    wire s_in,delay_s;
    
    tri0 GSR = glbl.GSR;
    
    assign gsr_in = GSR;
    assign Q1 = q1_out;
    assign Q2 = q2_out;
    
    wire nr, ns, ngsr;
    wire ce_c_enable, d_c_enable, r_c_enable, s_c_enable;
    wire ce_c_enable1, d_c_enable1, r_c_enable1, s_c_enable1;
    not (nr, R);
    not (ns, S);
    not (ngsr, GSR);

    and (ce_c_enable, ngsr, nr, ns);
    and (d_c_enable, ngsr, nr, ns, CE);
    and (s_c_enable, ngsr, nr);














    
    initial begin

   if ((INIT_Q1 != 0) && (INIT_Q1 != 1)) begin
       $display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q1);
       #1 $finish;
   end
   
       if ((INIT_Q2 != 0) && (INIT_Q2 != 1)) begin
       $display("Attribute Syntax Error : The attribute INIT_Q1 on IDDR instance %m is set to %d.  Legal values for this attribute are 0 or 1.", INIT_Q2);
       #1 $finish;
   end

       if ((DDR_CLK_EDGE != "OPPOSITE_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE") && (DDR_CLK_EDGE != "SAME_EDGE_PIPELINED")) begin
       $display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
       #1 $finish;
   end
   
   if ((SRTYPE != "ASYNC") && (SRTYPE != "SYNC")) begin
       $display("Attribute Syntax Error : The attribute SRTYPE on IDDR instance %m is set to %s.  Legal values for this attribute are ASYNC or SYNC.", SRTYPE);
       #1 $finish;
   end

    end // initial begin
    
         
    always @(gsr_in or r_in or s_in) begin
   if (gsr_in == 1'b1) begin
       assign q1_out_int = INIT_Q1;
       assign q1_out_pipelined = INIT_Q1;
       assign q2_out_same_edge_int = INIT_Q2;
       assign q2_out_int = INIT_Q2;
   end
   else if (gsr_in == 1'b0) begin
       if (r_in == 1'b1 && SRTYPE == "ASYNC") begin
      assign q1_out_int = 1'b0;
      assign q1_out_pipelined = 1'b0;
      assign q2_out_same_edge_int = 1'b0;
      assign q2_out_int = 1'b0;
       end
            else if (r_in == 1'b0 && s_in == 1'b1 && SRTYPE == "ASYNC") begin
      assign q1_out_int = 1'b1;
      assign q1_out_pipelined = 1'b1;
      assign q2_out_same_edge_int = 1'b1;
      assign q2_out_int = 1'b1;
       end
       else if ((r_in == 1'b1 || s_in == 1'b1) && SRTYPE == "SYNC") begin
      deassign q1_out_int;
      deassign q1_out_pipelined;
      deassign q2_out_same_edge_int;
      deassign q2_out_int;
       end       
       else if (r_in == 1'b0 && s_in == 1'b0) begin
      deassign q1_out_int;
      deassign q1_out_pipelined;
      deassign q2_out_same_edge_int;
      deassign q2_out_int;
       end
   end // if (gsr_in == 1'b0)
    end // always @ (gsr_in or r_in or s_in)
    
       
    always @(posedge c_in) begin
    if (r_in == 1'b1) begin
       q1_out_int <= 1'b0;
       q1_out_pipelined <= 1'b0;
       q2_out_same_edge_int <= 1'b0;
   end
   else if (r_in == 1'b0 && s_in == 1'b1) begin
       q1_out_int <= 1'b1;
       q1_out_pipelined <= 1'b1;
       q2_out_same_edge_int <= 1'b1;
   end
   else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0) begin
            q1_out_int <= d_in;
       q1_out_pipelined <= q1_out_int;
       q2_out_same_edge_int <= q2_out_int;
   end
    end // always @ (posedge c_in)
    
   
    always @(negedge c_in) begin
   if (r_in == 1'b1)
       q2_out_int <= 1'b0;
   else if (r_in == 1'b0 && s_in == 1'b1)
       q2_out_int <= 1'b1;
   else if (ce_in == 1'b1 && r_in == 1'b0 && s_in == 1'b0)
       q2_out_int <= d_in;
    end
    
    
    always @(c_in or q1_out_int or q2_out_int or q2_out_same_edge_int or q1_out_pipelined) begin
   case (DDR_CLK_EDGE)
       "OPPOSITE_EDGE" : begin
                        q1_out <= q1_out_int;
                        q2_out <= q2_out_int;
                         end
       "SAME_EDGE" : begin
                         q1_out <= q1_out_int;
                         q2_out <= q2_out_same_edge_int;
                     end
       "SAME_EDGE_PIPELINED" : begin
                              q1_out <= q1_out_pipelined;
                                     q2_out <= q2_out_same_edge_int;
                               end
       default : begin
                       $display("Attribute Syntax Error : The attribute DDR_CLK_EDGE on IDDR instance %m is set to %s.  Legal values for this attribute are OPPOSITE_EDGE, SAME_EDGE or SAME_EDGE_PIPELINED.", DDR_CLK_EDGE);
                $finish;
       end
   endcase // case(DDR_CLK_EDGE)
    end // always @ (q1_out_int or q2_out_int or q2_out_same_edge_int or q1_out_pipelined or q2_out_pipelined)
    



    assign delay_c =  C;
    assign delay_ce = CE;
    assign delay_d =  D;
    assign delay_r = R;
    assign delay_s = S;


    assign c_in = IS_C_INVERTED ^ delay_c;
    assign ce_in = delay_ce;
    assign d_in = IS_D_INVERTED ^ delay_d;
    assign r_in = delay_r;
    assign s_in = delay_s;
 
    
//*** Timing Checks Start here












    

















    specify
   
   (C => Q1) = (100:100:100, 100:100:100);
   (C => Q2) = (100:100:100, 100:100:100);
   (posedge R => (Q1 +: 0)) = (0:0:0, 0:0:0);
   (posedge R => (Q2 +: 0)) = (0:0:0, 0:0:0);
   (posedge S => (Q1 +: 0)) = (0:0:0, 0:0:0);
   (posedge S => (Q2 +: 0)) = (0:0:0, 0:0:0);









































   specparam PATHPULSE$ = 0;
   
    endspecify


endmodule // IDDR

`endcelldefine


