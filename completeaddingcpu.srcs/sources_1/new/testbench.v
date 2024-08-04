`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/12/2024 10:55:49 PM
// Design Name: 
// Module Name: testbench
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


//Test bench
module testbench;
reg reset=1, clk=0;
wire [5:0] adr_bus;
wire rd_mem, wr_mem;
wire [7:0] data_bus;
reg [7:0] memory[0:63];  // Declare memory array


   initial begin
   // Read the memory file into the array
      $readmemh("instructions.mem", memory);  
      #25 reset=1'b0;
    end
addingcpu UUT(reset, clk, adr_bus, rd_mem, wr_mem, data_bus);
always #10 clk = ~clk;
reg [7:0] mem_data=8'b0;
reg control=0;

always@(posedge clk) begin : Memory_Read_Write
control = 1'b0;
     #1;
    if(rd_mem) begin
        mem_data=memory[adr_bus];
        control = 1'b1;
        end
    if(wr_mem) begin
         #3 memory[adr_bus]=data_bus;
        end 
end
// Assigning( Copying) the mem_data to the data_bus
assign data_bus = (control) ? mem_data: 8'hZZ;   
 
endmodule

