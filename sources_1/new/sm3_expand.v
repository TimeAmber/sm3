`timescale 1ns / 1ps
`define WORD_WIDTH 32

module sm3_expand(
    input wire clk,
    input wire rst_n,
    input wire data,
    input wire data_en,
    input wire [8:0] data_count,
    output reg [2 * `WORD_WIDTH - 1 : 0] data_expand,
    output reg data_expand_en
);

    parameter WORD_WIDRH = 32;        //可以制定位宽，或者编译器直接分配位宽
    
    reg [WORD_WIDRH - 1:0] data_reg;
    reg data_en_reg;
    reg [8:0] data_count_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_reg <= 1'b0;
            data_en_reg <= 1'b0;
            data_count_reg <= 9'b0;
        end
        else begin
            data_reg <= {data_reg[WORD_WIDRH - 2:0], data};
            data_en_reg <= data_en;
            data_count_reg <= data_count;
        end 
    end
    
    reg fifo0_write_en;
    reg [WORD_WIDRH - 1:0] fifo0_write_data;
    // fifo_read_addr设计成一个状态机
    // 2'b00：state0 初始状态
    // 2'b01：state1 地址w16-w67，此时需要读取fifo，然后计算新的迭代值存入fifo
    // 2'b10：state2 地址w'00-w'63，此时需要读取fifo，然后计算新的迭代值存入fifo
    // state1和staet2的计算方式不同
    
    reg [WORD_WIDRH - 1:0] w0;
    reg [WORD_WIDRH - 1:0] w1;
    reg [WORD_WIDRH - 1:0] w2;
    reg [WORD_WIDRH - 1:0] w3;
    reg [WORD_WIDRH - 1:0] w4;
    reg [WORD_WIDRH - 1:0] w5;
    reg [WORD_WIDRH - 1:0] w6;
    reg [WORD_WIDRH - 1:0] w7;
    reg [WORD_WIDRH - 1:0] w8;
    reg [WORD_WIDRH - 1:0] w9;
    reg [WORD_WIDRH - 1:0] w10;
    reg [WORD_WIDRH - 1:0] w11;
    reg [WORD_WIDRH - 1:0] w12;
    reg [WORD_WIDRH - 1:0] w13;
    reg [WORD_WIDRH - 1:0] w14;
    reg [WORD_WIDRH - 1:0] w15;
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            w0 <= `WORD_WIDTH'b0;
            w1 <= `WORD_WIDTH'b0;
            w2 <= `WORD_WIDTH'b0;
            w3 <= `WORD_WIDTH'b0;
            w4 <= `WORD_WIDTH'b0;
            w5 <= `WORD_WIDTH'b0;
            w6 <= `WORD_WIDTH'b0;
            w7 <= `WORD_WIDTH'b0;
            w8 <= `WORD_WIDTH'b0;
            w9 <= `WORD_WIDTH'b0;
            w10 <= `WORD_WIDTH'b0;
            w11 <= `WORD_WIDTH'b0;
            w12 <= `WORD_WIDTH'b0;
            w13 <= `WORD_WIDTH'b0;
            w14 <= `WORD_WIDTH'b0;
            w15 <= `WORD_WIDTH'b0;
        end
        else if (fifo0_write_en) begin
            w0 <= fifo0_write_data;
            w1 <= w0;
            w2 <= w1;
            w3 <= w2;
            w4 <= w3;
            w5 <= w4;
            w6 <= w5;
            w7 <= w6;
            w8 <= w7;
            w9 <= w8;
            w10 <= w9;
            w11 <= w10;
            w12 <= w11;
            w13 <= w12;
            w14 <= w13;
            w15 <= w14;
        end
        else begin
            w0 <= w0;
            w1 <= w1;
            w2 <= w2;
            w3 <= w3;
            w4 <= w4;
            w5 <= w5;
            w6 <= w6;
            w7 <= w7;
            w8 <= w8;
            w9 <= w9;
            w10 <= w10;
            w11 <= w11;
            w12 <= w12;
            w13 <= w13;
            w14 <= w14;
            w15 <= w15;
        end
    end
    
    reg [WORD_WIDRH - 1 : 0] caculate_w0;
    reg [WORD_WIDRH - 1 : 0] caculate_w1;
    reg [WORD_WIDRH - 1 : 0] caculate_w2;
    reg [WORD_WIDRH - 1 : 0] caculate_w3;
    reg [WORD_WIDRH - 1 : 0] caculate_w4;
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            caculate_w0 <= `WORD_WIDTH'b0;
            caculate_w1 <= `WORD_WIDTH'b0;
            caculate_w2 <= `WORD_WIDTH'b0;
            caculate_w3 <= `WORD_WIDTH'b0;
            caculate_w4 <= `WORD_WIDTH'b0;
        end
        else begin
            caculate_w0 <= w15 ^ w8 ^ {w2[16 : 0], w2[31 : 17]};
            caculate_w1 <= caculate_w0 ^ {caculate_w0[16 : 0], caculate_w0[31 : 17]};
            caculate_w2 <= caculate_w1 ^ {caculate_w0[8 : 0], caculate_w0[31 : 9]};
            caculate_w3 <= caculate_w2 ^ w5;
            caculate_w4 <= caculate_w3 ^ {w12[24 : 0], w12[31 : 25]};
        end 
    end
    
    reg [8:0] caculate_count;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            caculate_count <= 9'b0;
        end
        else if (data_en == 1'b0 && data_en_reg == 1'b1) begin
            caculate_count <= caculate_count + 1;
        end
        else if (caculate_count != 9'b0) begin
            caculate_count <= caculate_count + 1;
        end
        else begin
            caculate_count <= caculate_count;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo0_write_en <= 1'b0;
            fifo0_write_data <= `WORD_WIDTH'b0;
        end
        else if(data_count_reg[4:0] == 5'b11111 && data_en_reg == 1'b1) begin                                      //计时加1
            fifo0_write_en <= 1'b1;
            fifo0_write_data <= data_reg;
        end
        else if (caculate_count[2:0] == 3'b111 && caculate_count <= 9'd419) begin
            fifo0_write_en <= 1'b1;
            fifo0_write_data <= caculate_w4;
        end
        else begin
            fifo0_write_en <= 1'b0;
            fifo0_write_data <= fifo0_write_data;
        end
    end
    
    reg fifo0_read_enable;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo0_read_enable <= 1'b0;
        end
        else if (caculate_count >= 9'd360 && caculate_count <= 9'd427) begin
            fifo0_read_enable <= 1'b1;
        end
        else begin
            fifo0_read_enable <= 1'b0;
        end
    end
    
    wire [WORD_WIDRH - 1 : 0] fifo0_read_data;
    fifo_sm_expand fifo_sm_expand0 (
        .clk(clk),      // input wire clk
        .din(fifo0_write_data),      // input wire [31 : 0] din
        .wr_en(fifo0_write_en),  // input wire wr_en
        .rd_en(fifo0_read_enable),  // input wire rd_en
        .dout(fifo0_read_data),    // output wire [31 : 0] dout
        .full(),    // output wire full
        .empty()  // output wire empty
    );
    
    reg [WORD_WIDRH - 1 : 0] fifo0_read_data_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo0_read_data_reg <= `WORD_WIDTH'b0;
        end
        else begin
            fifo0_read_data_reg <= fifo0_read_data;
        end
    end
    
    wire [WORD_WIDRH - 1 : 0] caculate_w5;
    assign caculate_w5 = w0 ^ w4;
    reg [WORD_WIDRH - 1 : 0] fifo1_write_data;
    reg caculate_w5_en, fifo1_write_en;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            caculate_w5_en <= 1'b0;
        end
        else if (data_count_reg[8:5] <= 4'b0100 && data_count_reg[8:5] >= 4'b0001) begin
            caculate_w5_en <= 1'b0;
        end
        else begin
            caculate_w5_en <= fifo0_write_en;
        end
    end
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo1_write_en <= 1'b0;
            fifo1_write_data <= `WORD_WIDTH'b0;
        end
        else begin
            fifo1_write_en <= caculate_w5_en;
            fifo1_write_data <= caculate_w5;
        end
    end
    
    reg fifo1_read_enable;
    wire [WORD_WIDRH - 1 : 0] fifo1_read_data;
    fifo_sm_expand fifo_sm_expand1 (
        .clk(clk),      // input wire clk
        .din(fifo1_write_data),      // input wire [31 : 0] din
        .wr_en(fifo1_write_en),  // input wire wr_en
        .rd_en(fifo1_read_enable),  // input wire rd_en
        .dout(fifo1_read_data),    // output wire [31 : 0] dout
        .full(),    // output wire full
        .empty()  // output wire empty
    );
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo1_read_enable <= 1'b0;
        end
        else if (caculate_count >= 9'd360 && caculate_count <= 9'd423) begin
            fifo1_read_enable <= 1'b1;
        end
        else begin
            fifo1_read_enable <= 1'b0;
        end
    end
    
    reg fifo1_read_en;
    reg fifo1_read_en_reg;
    reg [WORD_WIDRH - 1 : 0] fifo1_read_data_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            fifo1_read_en <= 1'b0;
            fifo1_read_data_reg <= 0;
            fifo1_read_en_reg <= 0;
        end
        else begin
            fifo1_read_en <= fifo1_read_enable;
            fifo1_read_en_reg <= fifo1_read_en;
            fifo1_read_data_reg <= fifo1_read_data;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_expand <= `WORD_WIDTH'b0;
            data_expand_en <= 0;
        end
        else if (fifo1_read_en_reg) begin
            data_expand <= {fifo0_read_data_reg, fifo1_read_data_reg};
            data_expand_en <= 1;
        end
        else begin
            data_expand <= `WORD_WIDTH'b0;
            data_expand_en <= 0;
        end
    end
    
    
endmodule
