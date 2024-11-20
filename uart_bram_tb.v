`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/18 21:05:26
// Design Name: 
// Module Name: uart_bram_tb
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

module uart_bram_tb();

    // 时钟 复位
    reg clk;
    reg rst_n;
    
    // 震荡
    always begin // 时钟震荡 100MHz
        clk <= 1'b0;
        # 5;
        clk <= 1'b1;
        # 5;
    end

    // 待测模块
    reg tx;
    wire rx;
    reg [7:0] data_test;
    uart_bram u_uart_bram(
        .sys_clk_p(clk),
        .sys_clk_n(~clk),
        .sys_rst_n(rst_n),

        .rx(tx),
        .tx(rx)
    );

    // 激励信号
    integer i=0;
    initial begin
        rst_n = 1'b0; // 复位
        tx <= 1'd1;
        # 200;
        rst_n = 1'b1;
        # 1000;

        for(i=0; i<16; i=i+1)begin
            data_test = i; // 发送的数据
            tx = 1'b0; // 起始信号
            # 8680;
            tx = data_test[0]; // 第1位数据
            # 8680;
            tx = data_test[1]; // 第2位数据
            # 8680;
            tx = data_test[2]; // 第3位数据
            # 8680;
            tx = data_test[3]; // 第4位数据
            # 8680;
            tx = data_test[4]; // 第5位数据
            # 8680;
            tx = data_test[5]; // 第6位数据
            # 8680;
            tx = data_test[6]; // 第7位数据
            # 8680;
            tx = data_test[7]; // 第8位数据
            # 8680;
            tx = 1'b1; // 停止信号
            # 8680;
        end
        
    end

endmodule

