`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 12:17:31
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input clk,
    input rst_n,

    input [2:0] Baud_Set,
    input [7:0] data, // 发送数据
    output reg tx, // 串行发送线
    input send_en, // 发送使能
    output tx_done // 发送完成
    );
    
    // 分频计数器
    parameter CLK_FREQ = 100000000; // 硬件时钟频率

    reg [15:0] BPS_CNT; // 传输一位数据所需要的时钟周期，BPS_CNT倍频
    always @(*) begin
        case(Baud_Set) // 波特率选择
            0:BPS_CNT = CLK_FREQ/9600;
            1:BPS_CNT = CLK_FREQ/19200;
            2:BPS_CNT = CLK_FREQ/38400;
            3:BPS_CNT = CLK_FREQ/57600;
            4:BPS_CNT = CLK_FREQ/115200;
        endcase
    end

    reg [15:0] div_cnt;
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            div_cnt <= 0;
        end else if(send_en)begin // 在传输过程中才进行分频计数
            if(div_cnt == BPS_CNT - 1)begin // 记满归0，意味着串口传输完一位数据
                div_cnt <= 0;
            end else begin // 未记满继续计
                div_cnt <= div_cnt + 1;
            end
        end else begin
            div_cnt <= 0;
        end
    end

    // 发送位计数
    reg [3:0] bit_cnt; 
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            bit_cnt <= 0;
        end else if(send_en) begin
            if(bit_cnt == 10) begin // 发完10位
                bit_cnt <= 0;
            end else if(div_cnt == BPS_CNT - 1) begin // 未发完10位，当1位发送完成时
                bit_cnt <= bit_cnt + 1;
            end
        end else begin
            bit_cnt <= 0;
        end
    end

    // 帧发送控制块
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            tx <= 1'b1;
        end else if(send_en) begin
            case(bit_cnt)
                0:tx <= 1'b0; // 发送起始位
                1:tx <= data[0];
                2:tx <= data[1];
                3:tx <= data[2];
                4:tx <= data[3];
                5:tx <= data[4];
                6:tx <= data[5];
                7:tx <= data[6];
                8:tx <= data[7];
                9:begin // 发送停止位
                    tx <= 1'b1;
                    if(div_cnt == BPS_CNT-(BPS_CNT/16))begin // 提前1/16周期进入空闲状态（tx=1）
                        tx <= 1'b1;
                    end
                end
            endcase
        end
    end

    // 输出完成标志位，提前1/16个周期表示已发送完毕（好让上层模块控制send_en）
    assign tx_done = (bit_cnt == 9 && div_cnt == BPS_CNT-(BPS_CNT/16));

endmodule
