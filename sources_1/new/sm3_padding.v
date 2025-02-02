`timescale 1ns / 1ps

module sm3_padding(
    input wire clk,
    input wire rst_n,
    input wire data,
    input wire data_en,
    output reg data_padding,
    output reg data_padding_en
);
    reg data_reg, data_en_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_reg <= 1'b0;
            data_en_reg <= 1'b0;
        end
        else begin                                      //计时加1
            data_reg <= data;
            data_en_reg <= data_en;
        end 
    end
    
    reg [63:0] length;
    // 求出填充位数k
    reg [8:0] k;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            k <= 9'b0;
        end
        else if (data_en_reg == 1'b1 && data_en == 1'b0) begin
            k <= 9'd447 - length[8:0];
        end
        else begin
            k <= k;
        end
    end

    
    reg padding_step1;
    reg padding_step1_en;
    reg [8:0] padding_step1_count;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step1_count <= 9'b0;
        end
        else if (data_en_reg == 1'b1 && data_en == 1'b0) begin
            padding_step1_count <= 9'b1;
        end
        else if (padding_step1_count != 9'b0)begin
            padding_step1_count <= padding_step1_count + 1'b1;
        end 
        else begin
            padding_step1_count <= padding_step1_count;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step1_en <= 1'b0;
        end
        else if(data_en_reg) begin                                      //计时加1
            padding_step1_en <= 1'b1;
        end
        else if (padding_step1_count != 9'b0 && padding_step1_count <= k) begin
            padding_step1_en <= 1'b1;
        end
        else begin
            padding_step1_en <= 1'b0;
        end
    end
    
    reg data_en_reg1;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_en_reg1 <= 1'b0;
        end
        else begin                                      //计时加1
            data_en_reg1 <= data_en_reg;
        end 
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step1 <= 1'b0;
        end
        else if(data_en_reg) begin                                      //计时加1
            padding_step1 <= data_reg;
        end
        else if(data_en_reg == 1'b0 && data_en_reg1 == 1'b1) begin
            padding_step1 <= 1'b1;
        end
        else begin
            padding_step1 <= 1'b0;
        end
    end
    
    reg padding_step1_en_reg;
    reg padding_step1_reg;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step1_en_reg <= 1'b0;
            padding_step1_reg <= 1'b0;
        end
        else begin
            padding_step1_en_reg <= padding_step1_en;
            padding_step1_reg <= padding_step1;
        end
    end
    
    reg padding_step2_en, padding_step2_en_pre;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            length <= 64'b0;
        end
        else if (data_en_reg == 1'b0 && data_en == 1'b1) begin
            length <= 64'b0;
        end
        else if (data_en_reg == 1'b1)begin
            length <= length + 1'b1;
        end
        else if (padding_step2_en_pre == 1'b1) begin
            length <= length << 1;
        end
        else begin
            length <= length;
        end
    end
    
    reg [5:0] padding_step2_count;
    reg padding_step2;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step2_count <= 6'b0;
            padding_step2_en_pre <= 1'b0;
            padding_step2 <= 1'b0;
        end
        else if(padding_step1_en_reg == 1'b1 && padding_step1_en == 1'b0) begin
            padding_step2_count <= 6'b1;
            padding_step2_en_pre <= 1'b1;
            padding_step2 <= length[63];
        end
        else if(padding_step2_count != 6'b0) begin
            padding_step2_count <= padding_step2_count + 6'b1;
            padding_step2 <= length[63];
            padding_step2_en_pre <= 1'b1;
        end
        else begin
            padding_step2_count <= padding_step2_count;
            padding_step2_en_pre <= 1'b0;
            padding_step2 <= 1'b0;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step2_en <= 1'b0;
        end
        else begin
            padding_step2_en <= padding_step2_en_pre;
        end
    end
    
    reg padding_step1_en_reg1;
    reg padding_step1_reg1;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_step1_en_reg1 <= 1'b0;
            padding_step1_reg1 <= 1'b0;
        end
        else begin
            padding_step1_en_reg1 <= padding_step1_en_reg;
            padding_step1_reg1 <= padding_step1_reg;
        end
    end
    
    reg padding_en, padding;
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            padding_en <= 1'b0;
            padding <= 1'b0;
        end
        else if(padding_step1_en_reg1 || padding_step2_en) begin
            padding_en <= 1'b1;
            padding <= padding_step2 || padding_step1_reg1;
        end
        else begin
            padding_en <= 1'b0;
            padding <= 1'b0;
        end
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            data_padding <= 1'b0;
            data_padding_en <= 1'b0;
        end
        else begin
            data_padding <= padding;
            data_padding_en <= padding_en;
        end
    end
endmodule
