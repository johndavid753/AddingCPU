`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2024 10:57:22 PM
// Design Name: 
// Module Name: addingcpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//Instruction Register

module IR(data_in,load,clk,data_out);
input [7:0] data_in;
input load, clk;
output reg [7:0]data_out;

always@(posedge clk)
if (load) 
	data_out <= data_in;
endmodule



// Program Counter

module PC(data_in,load,inc,clr,clk,data_out);
input [5:0] data_in;
input load, inc, clr,clk;
output reg [5:0]data_out;

always@( posedge clk )
if( clr ) 
	data_out <= 6'b000000;
else if(load) 
	data_out <= data_in;
else if(inc) 
	data_out <= data_out + 1;
endmodule

// Accumulator Resisitor

module AC( data_in,load,clk,data_out);
input [7:0] data_in;
input load, clk;
output reg [7:0] data_out;

always @( posedge clk )
if( load ) 
	data_out <= data_in;
endmodule


// ALU

module ALU(a,b,pass,add,alu_out);
input [7:0] a, b;
input pass, add;
output reg [7:0]alu_out;

always @(*)
	if (pass) 
		alu_out = a;
	else if (add) 
		alu_out = a + b;
	else 
		alu_out = 0;
endmodule

// Complete DataPath....

module datapath(ir_on_adr, pc_on_adr, dbus_on_data, data_on_dbus, ld_ir, ld_ac, ld_pc, inc_pc, clr_pc, pass, add, alu_on_dbus, clk,adr_bus,op_code,data_bus);
// declaration input and output ports..

input ir_on_adr, pc_on_adr, dbus_on_data,
data_on_dbus, ld_ir, ld_ac, ld_pc,
inc_pc, clr_pc, pass, add, alu_on_dbus,clk;

output [5:0] adr_bus;
output [1:0] op_code;
inout [7:0] data_bus;
wire [7:0] dbus, ir_out, a_side, alu_out;
wire [5:0] pc_out;

IR ir( dbus, ld_ir, clk, ir_out );
PC pc( ir_out[5:0], ld_pc, inc_pc, clr_pc, clk, pc_out );
AC ac( dbus, ld_ac, clk, a_side );
ALU alu( a_side, {2'b00,ir_out[5:0]}, pass, add, alu_out );

assign adr_bus   =    ir_on_adr ? ir_out[5:0] : 6'bzzzzzz;
assign adr_bus   =    pc_on_adr ? pc_out : 6'bzzzzzz;
assign dbus         =    alu_on_dbus ? alu_out : 8'bzzzzzzzz;
assign data_bus  =    dbus_on_data ? dbus : 8'bzzzzzzzz;
assign dbus        =    data_on_dbus ? data_bus : 8'bzzzzzzzz;
assign op_code  =    ir_out[7:6];
endmodule




//Controller....

module Controlpath(input reset, clk, input [1:0] op_code,
	output reg rd_mem, wr_mem, ir_on_adr,pc_on_adr, dbus_on_data,data_on_dbus, ld_ir, ld_ac,ld_pc, inc_pc,     clr_pc,pass, add, alu_on_dbus);

parameter Reset=2'b00,Fetch=2'b01,Decode=2'b10,Execute=2'b11;

reg [1:0] present_state, next_state;

always @( posedge clk )
	if( reset ) 
		present_state <= Reset;
	else present_state <= next_state;

always@( present_state or reset )
 
	begin : Combination
	rd_mem=1'b0; wr_mem=1'b0; ir_on_adr=1'b0;  pc_on_adr=1'b0;
dbus_on_data=1'b0; data_on_dbus=1'b0;   ld_ir=1'b0;ld_ac=1'b0; ld_pc=1'b0; inc_pc=1'b0;clr_pc=1'b0; pass=0; add=0; alu_on_dbus=1'b0;

case ( present_state )
Reset : begin next_state = reset ? Reset : Fetch;
               clr_pc = 1;
        end // End `Reset

Fetch : begin next_state = Decode;
               pc_on_adr = 1; rd_mem = 1; data_on_dbus = 1;
               ld_ir = 1; inc_pc = 1;
        end // End `Fetch

Decode : next_state = Execute; // End `Decode

Execute: begin next_state = Fetch;
         case( op_code )
               2'b00: begin
                       ir_on_adr = 1; rd_mem = 1;
                       data_on_dbus = 1; ld_ac = 1;
                      end
               2'b01: begin
                      pass = 1;
                      ir_on_adr = 1; alu_on_dbus = 1;
                      dbus_on_data = 1; wr_mem = 1;
                      end

               2'b10: ld_pc = 1;
               2'b11: begin
                      add = 1; alu_on_dbus = 1; ld_ac = 1;
                      end
          endcase
        end  // End `Execute
        
default : next_state = Reset;
endcase
end
endmodule




//Complete Adding CPU Machine…
module addingcpu(reset,clk,adr_bus,rd_mem,wr_mem,data_bus);
    input reset, clk;
    output [5:0] adr_bus; 
    output rd_mem, wr_mem;
    inout [7:0] data_bus;
    wire ir_on_adr, pc_on_adr, dbus_on_data, data_on_dbus,ld_ir,
        ld_ac, ld_pc, inc_pc, clr_pc, pass, add, alu_on_dbus;
    wire [1:0] op_code;

Controlpath Cu( reset, clk, op_code, rd_mem, wr_mem, ir_on_adr,
pc_on_adr, dbus_on_data, data_on_dbus, ld_ir,
ld_ac, ld_pc, inc_pc, clr_pc, pass,
add, alu_on_dbus );

datapath dp( ir_on_adr, pc_on_adr, dbus_on_data, data_on_dbus,
ld_ir, ld_ac, ld_pc, inc_pc, clr_pc, pass, add,
alu_on_dbus, clk, adr_bus, op_code, data_bus );

endmodule

