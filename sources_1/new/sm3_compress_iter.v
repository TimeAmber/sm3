`timescale 1ns / 1ps
`define WORD_WIDTH 32

module sm3_compress_iter(
    input wire clk,
    input wire rst_n,
    input wire [2 * `WORD_WIDTH - 1 : 0] data,
    input wire data_en,
    output reg [2 * `WORD_WIDTH - 1 : 0] data_iter,
    output reg data_iter_en
);
    reg [2 * `WORD_WIDTH - 1 : 0] data_reg;
    reg data_en_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_reg <= 1'b0;
            data_en_reg <= 1'b0;
        end
        else begin
            data_reg <= data;
            data_en_reg <= data_en;
        end 
    end
    
    reg [`WORD_WIDTH - 1:0] A;
    reg [`WORD_WIDTH - 1:0] B;
    reg [`WORD_WIDTH - 1:0] C;
    reg [`WORD_WIDTH - 1:0] D;
    reg [`WORD_WIDTH - 1:0] E;
    reg [`WORD_WIDTH - 1:0] F;
    reg [`WORD_WIDTH - 1:0] G;
    reg [`WORD_WIDTH - 1:0] H;
    reg [`WORD_WIDTH - 1:0] SS1;
    reg [`WORD_WIDTH - 1:0] SS2;
    reg [`WORD_WIDTH - 1:0] TT1;
    reg [`WORD_WIDTH - 1:0] TT2;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            A <= `WORD_WIDTH'b0;
        end
        else if (data_en_reg == 1'b0 && data_en == 1'b1) begin
            A <= 32'h7380166f;
        end
        else begin
            A <= A;
        end
    end
endmodule
