`timescale 1ns / 1ps
`define WORD_WIDTH 32

module sm3(
    input wire clk,
    input wire rst_n,
    input wire data,
    input wire data_en,
    output reg hash_value,
    output reg hash_value_en
);
    // 缓存
    reg data_reg, data_en_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            data_reg <= 1'b0;
            data_en_reg <= 1'b0;
        end
        else begin                                      //计时加1
            data_reg <= data;
            data_en_reg <= data_en;
        end 
    end
    
    // 填充模块
    // 消息$m$，其长度是$l$，填充的过程是：
    // 1. 添加1 bit 1；
    // 2. 添加$k$ bit 0，$k$是满足$l+1+k \equiv 448\pmod{512}$（表示$l+1+k$除512余448）的最小非负整数；
    // 3. 添加64 bit，该比特串是长度$l$的二进制表示。
    // sm3_padding模块完成填充过程，生成n*512bit填充数据
    wire data_padding;
    wire data_padding_en;
    sm3_padding sm3_padding(
        .clk(clk),
        .rst_n(rst_n),
        .data(data_reg),
        .data_en(data_en_reg),
        .data_padding(data_padding),
        .data_padding_en(data_padding_en)
    );
    
    // 迭代压缩，每512bit进行分组
    reg [9:0] count_data_padding;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            count_data_padding <= 10'b0;
        end
        else if(data_padding_en) begin                                      //计时加1
            count_data_padding <= count_data_padding + 1;
        end 
        else begin
            count_data_padding <= 10'b0;
        end
    end
    reg data_padding0_reg;
    reg data_padding_en0_reg;
    reg data_padding1_reg;
    reg data_padding_en1_reg;
    reg [8:0] count_data_padding_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            data_padding0_reg <= 1'b0;
            data_padding_en0_reg <= 1'b0;
        end
        else if(count_data_padding[9] == 1'b0 && data_padding_en) begin
            data_padding0_reg <= data_padding;
            data_padding_en0_reg <= data_padding_en;
        end
        else begin
            data_padding0_reg <= 1'b0;
            data_padding_en0_reg <= 1'b0;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            count_data_padding_reg <= 9'b0;
        end
        else begin
            count_data_padding_reg <= count_data_padding[8:0];
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            data_padding1_reg <= 1'b0;
            data_padding_en1_reg <= 1'b0;
        end
        else if(count_data_padding[9] == 1'b1 && data_padding_en) begin
            data_padding1_reg <= data_padding;
            data_padding_en1_reg <= data_padding_en;
        end
        else begin
            data_padding1_reg <= 1'b0;
            data_padding_en1_reg <= 1'b0;
        end
    end
    wire [2 * `WORD_WIDTH - 1 : 0] data_expand0;
    wire data_expand_en0;
    sm3_expand sm3_expand0(
        .clk(clk),
        .rst_n(rst_n),
        .data(data_padding0_reg),
        .data_en(data_padding_en0_reg),
        .data_count(count_data_padding_reg),
        .data_expand(data_expand0),
        .data_expand_en(data_expand_en0)
    );
    wire [2 * `WORD_WIDTH - 1 : 0] data_expand1;
    wire data_expand_en1;
    sm3_expand sm3_expand1(
        .clk(clk),
        .rst_n(rst_n),
        .data(data_padding1_reg),
        .data_en(data_padding_en1_reg),
        .data_count(count_data_padding_reg),
        .data_expand(data_expand1),
        .data_expand_en(data_expand_en1)
    );
    
    reg data_expand_en_reg;
    reg [2 * `WORD_WIDTH - 1 : 0] data_expand_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin         //复位时，计我
            data_expand_en_reg <= 1'b0;
            data_expand_reg <= 63'b0;
        end
        else begin
            data_expand_en_reg <= data_expand_en1 || data_expand_en0;
            data_expand_reg <= data_expand0 || data_expand1;
        end
    end
    
    sm3_compress_iter(
        .clk(clk),
        .rst_n(rst_n),
        .data(data_expand_reg),
        .data_en(data_expand_en_reg),
        .data_iter(),
        .data_iter_en()
    );
endmodule
