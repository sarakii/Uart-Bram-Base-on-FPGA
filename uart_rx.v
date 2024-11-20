`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/11 14:36:22
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input clk,
    input rst_n,

    input [2:0] Baud_Set,
    input rx, // 串行接收数据线，接收发送方的串行数据
    output reg [7:0] data, // 并行输出数据
    output reg rx_busy, // 接收状态
    output rx_done // 接收完成
    );

    // 检测数据线的下降沿（还可以直接判断低电平实现）
    reg rx_d0;
    reg rx_d1;
    wire rx_flag;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rx_d0 <= 1'b0;
            rx_d1 <= 1'b0;
        end else begin
            rx_d0 <= rx;
            rx_d1 <= rx_d0;
        end
    end
    // 这里用边沿跳变来定位接收的开始位置，是为了方便精确地定位开始位置
    assign rx_flag = (rx_d1) & (~rx_d0); 

    // 分频计数器
    parameter CLK_FREQ = 100000000;
    reg [15:0] BPS_CNT;
    always @(*)begin
        case(Baud_Set)
            0:BPS_CNT = CLK_FREQ/9600;
            1:BPS_CNT = CLK_FREQ/19200;
            2:BPS_CNT = CLK_FREQ/38400;
            3:BPS_CNT = CLK_FREQ/57600;
            4:BPS_CNT = CLK_FREQ/115200;
            default:BPS_CNT = CLK_FREQ/115200;
        endcase
    end

    reg [15:0] div_cnt; // BPS_CNT计数变量
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            div_cnt <= 0;
        end else if(rx_busy) begin
            if(div_cnt == BPS_CNT - 1)begin
                div_cnt <= 0;
            end else begin // 记满归0，意味着串口接收完一位数据
                div_cnt <= div_cnt + 1;
            end
        end else begin
            div_cnt <= 0;
        end
    end

    // 接收位数计数器
    reg [3:0] bit_cnt;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            bit_cnt <= 0;
        end else if(rx_busy) begin
            if(bit_cnt == 10)begin
                bit_cnt <= 0;
            end else if(div_cnt == BPS_CNT - 1)begin
                bit_cnt <= bit_cnt + 1;
            end
        end else begin
            bit_cnt <= 0;
        end
    end

    // 串行接收逻辑
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            data <= 8'b0;
        end else if(rx_busy)begin
            if(div_cnt == BPS_CNT/2)begin
                case(bit_cnt)
                    1: data[0] <= rx; // 接收数据的第1位
                    2: data[1] <= rx;
                    3: data[2] <= rx;
                    4: data[3] <= rx;
                    5: data[4] <= rx;
                    6: data[5] <= rx;
                    7: data[6] <= rx;
                    8: data[7] <= rx; // 接收数据的第8位
                endcase
            end
        end
    end

    // 串口状态
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            rx_busy <= 1'b0;
        end else if(rx_flag) begin // 数据线下降沿/低电平就拉高使能，说明recv在忙
            rx_busy <= 1'b1; 
        end else if(bit_cnt==9 && div_cnt==BPS_CNT/2) begin // 一帧数据接收完成，回归到空闲状态
            rx_busy <= 1'b0; 
        end
    end

    // 接收完成逻辑，提前表示接收完毕，让上层模块可以拿接收到的数据进行运算
    assign rx_done = (bit_cnt==9 && div_cnt==1);

endmodule
