`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/18 15:01:55
// Design Name: 
// Module Name: uart_bram
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

module uart_bram(
    input sys_clk_p,
    input sys_clk_n,
    input sys_rst_n,

    input rx,
    output tx
    );

    IBUFDS diff_clk(
        .I(sys_clk_p),
        .IB(sys_clk_n),
        .O(sys_clk)
    );

    // 串口信号
    // wire rx_done; // 接收1帧完成（仿真时，需将这个标志位设置成output端口）
    wire rx_busy; // 接收状态
    wire [7:0] rx_data; // 接收到的8位数据
    reg [7:0] tx_data; // 要发送的8位数据
    wire tx_done; // 接收1帧完成（仿真时，需将这个标志位设置成output端口）
    reg send_en; // 发送使能

    // bram信号
    reg ena; // 端口A使能
    reg wea; // 写使能
    reg [3:0] addra; // 地址线
    reg [7:0] dina; // 写数据线
    wire [7:0] douta; // 读数据线

    // Bram
    blk_mem_gen_0 my_bram(
        .clka(sys_clk),
        .ena(1'b1), // 模块持续使能
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta)
    );

    // 串口接收模块
    uart_rx u_uart_rx (
        .clk(sys_clk),
        .rst_n(sys_rst_n),

        .Baud_Set(4),
        .rx(rx), // 串行接收数据线，接收发送方的串行数据
        .data(rx_data), // 并行输出数据
        .rx_busy(rx_busy), // 接收状态
        .rx_done(rx_done) // 接收完成
    );

    // 串口发送模块
    uart_tx u_uart_tx(
        .clk(sys_clk),
        .rst_n(sys_rst_n),

        .Baud_Set(4),
        .data(tx_data), // 发送数据
        .tx(tx),
        .send_en(send_en), // 发送使能控制
        .tx_done(tx_done)
    );

    // 三段式状态机
    // 实现功能：1.从串口接收16帧数据并写入bram的0~15号内存 2.再把16位数据从bram中读取出来发送到串口上
    // 状态空间
    parameter RECV = 1'b0;
    parameter SEND = 1'b1;
    reg state, next;

    // 状态转换
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            state <= RECV;
        end else begin
            state <= next;
        end
    end

    // 转换逻辑
    always @(*)begin
        if(!sys_rst_n)begin
            next = RECV;
        end else begin
            case(state)
                RECV:begin
                    if(addra == 15 && wea)begin
                        next = SEND;
                    end else begin
                        next = state;
                    end
                end
                SEND:begin
                    if(addra == 15 && tx_done)begin
                        next = RECV;
                    end else begin
                        next = state;
                    end
                end
            endcase
        end
    end

    // 输出逻辑功能
    // 收发共用 - 地址自增
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            addra <= 4'b0;
        end else begin
            if(tx_done | wea)begin // 在接收/发送模式下，接收/发送完一帧数据后令其地址自增
                if(addra < 15)begin
                    addra <= addra + 4'b1;
                end else begin
                    addra <= 4'b0;
                end
            end
        end
    end
    // 不同状态下的实现的功能
    // - 收：每接收8位串口数据后就把它扔进bram里
    // - 发：接收16帧串口数据后就把它们从bram里读出来并发到串口上
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            wea <= 1'b0;
            dina <= 8'b0;
            tx_data <= 8'b0;
            send_en <= 1'b0;
        end else begin
            if(state == RECV)begin
                if(rx_done)begin // 接收到8位数据（产生的一个脉冲）
                    dina <= rx_data; // 接收到的数据赋值到dina
                    wea <= 1'b1; // 写使能
                end else begin
                    dina <= dina;
                    wea <= 1'b0; // 写失能
                end
            end
            if(state == SEND)begin
                wea <= 1'b0; // 读模式
                tx_data <= douta;
                if(tx_done)begin
                    send_en <= 1'b0; // 发送控制
                end else begin
                    send_en <= 1'b1;
                end
            end
        end
    end

endmodule
